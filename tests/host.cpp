#include "host.h"
#include "fake_xplm.h"

#include "module.h"
#include "xptimers.h"

#include "XPLMPlugin.h"

#include <catch2/catch_amalgamated.hpp>

#include <unistd.h>
#include <regex>
#include <string_view>

namespace fs = std::filesystem;

extern "C" {
int XPluginStart(char* name, char* signature, char* description);
int XPluginEnable(void);
void XPluginDisable(void);
void XPluginStop(void);
void XPluginReceiveMessage(XPLMPluginID from, int message, void* param);
}

namespace {

// Log lines that show a defect in XLua, not in a script.
char const* const kDefectLines[] = {
	"FATAL: unprotected Lua error",
	"This is a plugin bug",
	"we did not persist a closure",
};

char const* const kReloadCommand = "laminar/xlua/reload_all_scripts";

// Checks a part of the log for lines that show a defect, except lines that contain allowed text.
void check_log_lines(std::string_view text, std::vector<std::string> const& allowed)
{
	size_t start = 0;
	while (start < text.size())
	{
		size_t end = text.find('\n', start);
		if (end == std::string_view::npos)
			end = text.size();
		std::string_view const line = text.substr(start, end - start);
		start = end + 1;

		for (char const* bad : kDefectLines)
		{
			if (line.find(bad) == std::string_view::npos)
				continue;
			bool ok = false;
			for (std::string const& a : allowed)
				ok = ok || line.find(a) != std::string_view::npos;
			INFO("log line: " << line);
			CHECK(ok);
		}
	}
}

} // namespace

// ─── test_aircraft ──────────────────────────────────────────────────────────

test_aircraft::test_aircraft(std::initializer_list<char const*> scripts)
{
	std::string tmpl = (fs::temp_directory_path() / "xlua_test.XXXXXX").string();
	REQUIRE(mkdtemp(tmpl.data()) != nullptr);
	// XLua compares this path with the paths that XPLM gives, so use the canonical form.
	root = fs::canonical(tmpl);
	plugin_dir = root / "Aircraft/Test/plugins/xlua";
	fs::create_directories(plugin_dir / "64");
	fs::create_directories(plugin_dir / "scripts");
	fs::copy_file(XLUA_INIT_LUA, plugin_dir / "init.lua");
	for (char const* s : scripts)
		fs::copy(fs::path(XLUA_TEST_SCRIPTS) / s, plugin_dir / "scripts" / s, fs::copy_options::recursive);
	fake::set_system_path(root.string() + "/");
}

test_aircraft::~test_aircraft()
{
	std::error_code ec;
	fs::remove_all(root, ec);
}

// ─── xlua_plugin ────────────────────────────────────────────────────────────

xlua_plugin::xlua_plugin(std::initializer_list<char const*> scripts) : m_aircraft(scripts)
{
}

void xlua_plugin::start()
{
	char name[256], signature[256], description[256];
	REQUIRE(XPluginStart(name, signature, description) == 1);
	m_started = true;
	enable();
	XPluginReceiveMessage(XPLM_PLUGIN_XPLANE, XPLM_MSG_PLANE_LOADED, nullptr);
	XPluginReceiveMessage(XPLM_PLUGIN_XPLANE, XPLM_MSG_AIRPORT_LOADED, nullptr);
}

void xlua_plugin::enable()
{
	REQUIRE(XPluginEnable() == 1);
	fake::set_plugin_enabled(true);
	m_enabled = true;
}

void xlua_plugin::disable()
{
	fake::set_plugin_enabled(false);
	XPluginDisable();
	m_enabled = false;
}

void xlua_plugin::run_frames(int count)
{
	for (int i = 0; i < count; ++i)
		fake::run_frame();
}

void xlua_plugin::allow_log(std::string text)
{
	m_allowed.push_back(std::move(text));
}

void xlua_plugin::finish()
{
	if (m_enabled)
		disable();

	// The close must unregister each command handler of the scripts. Only the handler of the
	// reload command stays, because it belongs to the plugin, not to a script.
	XPLMCommandRef const reload = XPLMFindCommand(kReloadCommand);
	for (fake::command_handler const& h : fake::command_handlers())
	{
		INFO("a command handler is still registered after the scripts closed");
		CHECK(h.cmd == reload);
	}


	check_log_lines(fake::log(), m_allowed);

	// Call each callback that XPLM still holds, as XPLM can do after a disable and an enable. XLua must
	// find that the callback is stale and return zero. A stale callback logs a defect line, so it is allowed here.
	size_t const log_size = fake::log().size();
	for (fake::flight_loop* l : fake::flight_loops())
		if (!l->destroyed)
			CHECK(l->params.callbackFunc(0.05f, 0.05f, 1, l->params.refcon) == 0);
	for (fake::dataref* d : fake::datarefs())
	{
		if (!d->registered || d->name.starts_with("sim/"))
			continue;
		INFO("dataref " << d->name);
		if (d->geti) CHECK(d->geti(d->read_refcon) == 0);
		if (d->getf) CHECK(d->getf(d->read_refcon) == 0);
		if (d->getd) CHECK(d->getd(d->read_refcon) == 0);
		if (d->getvi) CHECK(d->getvi(d->read_refcon, nullptr, 0, 0) == 0);
		if (d->getvf) CHECK(d->getvf(d->read_refcon, nullptr, 0, 0) == 0);
		if (d->getb) CHECK(d->getb(d->read_refcon, nullptr, 0, 0) == 0);
		int ivalues[1] = { 1 };
		float fvalues[1] = { 1 };
		char bvalues[1] = { 1 };
		if (d->seti) d->seti(d->write_refcon, 1);
		if (d->setf) d->setf(d->write_refcon, 1);
		if (d->setd) d->setd(d->write_refcon, 1);
		if (d->setvi) d->setvi(d->write_refcon, ivalues, 0, 1);
		if (d->setvf) d->setvf(d->write_refcon, fvalues, 0, 1);
		if (d->setb) d->setb(d->write_refcon, bvalues, 0, 1);
	}
	std::string const stale_log = fake::log().substr(log_size);
	INFO("a stale callback ran Lua code:\n" << stale_log);
	CHECK(stale_log.find("XLUATEST") == std::string::npos);

	if (m_started)
		XPluginStop();
	m_started = false;
}

// ─── module_host ────────────────────────────────────────────────────────────

module_host::module_host(std::initializer_list<char const*> scripts) : m_aircraft(scripts)
{
	// XPluginStart sets the XLua version that a module compares with the version line of its script.
	char name[256], signature[256], description[256];
	REQUIRE(XPluginStart(name, signature, description) == 1);
	fake::set_plugin_enabled(true);
}

module_host::~module_host()
{
	m_modules.clear();
	XPluginStop();
}

module* module_host::load(char const* script)
{
	fs::path const dir = m_aircraft.plugin_dir / "scripts" / script;
	m_modules.push_back(std::make_unique<module>(dir, m_aircraft.plugin_dir / "init.lua",
												 dir / (std::string(script) + ".lua"), nullptr, nullptr));
	module* m = m_modules.back().get();
	REQUIRE(m->is_started());

	// Each callback must leave the Lua stack as it found it. run_frames compares with this depth.
	lua_State* L = m->get_interp();
	m_stack_tops.push_back(lua_gettop(L));
	return m;
}

void module_host::close(module* m)
{
	for (size_t i = 0; i < m_modules.size(); ++i)
	{
		if (m_modules[i].get() == m)
		{
			m_modules.erase(m_modules.begin() + i);
			m_stack_tops.erase(m_stack_tops.begin() + i);
			return;
		}
	}
	FAIL("unknown module");
}

void module_host::allow_log(std::string text)
{
	m_allowed.push_back(std::move(text));
}

void module_host::finish()
{
	m_modules.clear();
	m_stack_tops.clear();
	{
		INFO("a command handler is still registered after the scripts closed");
		CHECK(fake::command_handlers().empty());
	}
	check_log_lines(fake::log(), m_allowed);
}

void module_host::run_frames(int count)
{
	for (int i = 0; i < count; ++i)
	{
		fake::run_frame();
		xlua_do_timers_for_time(xlua_get_simulated_time());
		for (size_t m = 0; m < m_modules.size(); ++m)
			CHECK(lua_gettop(m_modules[m]->get_interp()) == m_stack_tops[m]);
	}
}

// ─── Helpers ────────────────────────────────────────────────────────────────

int get_int(char const* dataref)
{
	XPLMDataRef ref = XPLMFindDataRef(dataref);
	INFO("dataref " << dataref);
	REQUIRE(ref != nullptr);
	return XPLMGetDatai(ref);
}

void check_script_result(char const* script, int expected_pass)
{
	std::string const& log = fake::log();
	std::regex const done(std::string("XLUATEST ") + script + ": DONE pass=(\\d+) fail=(\\d+)");
	std::smatch m;
	INFO("log:\n" << log);
	REQUIRE(std::regex_search(log, m, done));
	CHECK(std::stoi(m[2]) == 0);
	CHECK(std::stoi(m[1]) == expected_pass);
}
