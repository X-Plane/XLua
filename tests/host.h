// Runs XLua for a test, as X-Plane runs it, against the fake XPLM.
//
// Each test case runs in its own process (ctest), because XLua keeps state in
// static variables. So a test makes one xlua_plugin or one module_host, and
// never resets anything.

#pragma once

#include <filesystem>
#include <initializer_list>
#include <memory>
#include <string>
#include <vector>

class module;

// A new temporary aircraft folder with the shipped init.lua and some scripts from tests/scripts:
//   <root>/Aircraft/Test/plugins/xlua/init.lua
//   <root>/Aircraft/Test/plugins/xlua/scripts/<name>/<name>.lua
class test_aircraft {
public:
	explicit test_aircraft(std::initializer_list<char const*> scripts);
	~test_aircraft();

	std::filesystem::path root;
	std::filesystem::path plugin_dir;
};

// The XLua plugin, driven through its five XPLM entry points.
class xlua_plugin {
public:
	explicit xlua_plugin(std::initializer_list<char const*> scripts);

	// XPluginStart and XPluginEnable, then the messages that X-Plane sends when it loads the aircraft.
	void start();
	void enable();
	void disable();
	void run_frames(int count);

	// Lets the log contain this text. Use it for a line that the test expects.
	void allow_log(std::string text);

	// Disables and stops the plugin, then does the checks that apply to all tests:
	//   - XPLM holds no command handler of a closed script.
	//   - Each flight loop and dataref accessor that XPLM still holds is safe to call, runs no Lua code
	//     and returns zero. XPLM can call them after a disable and an enable.
	//   - The log has no line that shows a defect in XLua.
	// Call it at the end of each test.
	void finish();

private:
	test_aircraft			m_aircraft;
	bool					m_started = false;
	bool					m_enabled = false;
	std::vector<std::string> m_allowed;
};

// Makes XLua modules directly, so that a test can close one module while another one runs.
// It does not enable the plugin, so it pumps the XLua timers itself.
class module_host {
public:
	explicit module_host(std::initializer_list<char const*> scripts);
	~module_host();

	module* load(char const* script);
	void close(module* m);
	// Runs frames and the XLua timers. After each frame, the Lua stack of each module must be as deep as after load.
	void run_frames(int count);
	void allow_log(std::string text);
	// Closes all modules. Then XPLM must hold no command handler of a script, and the log must have no line
	// that shows a defect in XLua. Call it at the end of each test.
	void finish();

private:
	test_aircraft							m_aircraft;
	std::vector<std::unique_ptr<module>>	m_modules;
	std::vector<int>						m_stack_tops;
	std::vector<std::string>				m_allowed;
};

// Reads an int dataref through XPLM, as another plugin does.
int get_int(char const* dataref);

// Checks the result line of a self-checking script: "XLUATEST <script>: DONE pass=<n> fail=<n>".
// The pass count must be the expected count, so a case that did not run is a failure.
void check_script_result(char const* script, int expected_pass);
