// Strong definitions of the XPLM functions that the XLua tests need. See fake_xplm.h.

#include "fake_xplm.h"

#include "XPLMPlanes.h"
#include "XPLMPlugin.h"

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <filesystem>

namespace fake {
namespace {

// All state is in one object that is made on first use, because XLua can call XPLM from static initializers.
struct sim {
	std::string					log;
	bool						plugin_enabled = false;
	std::string					system_path;
	double						time = 0;
	float						frame_period = 0.05f;
	int							cycle = 0;
	std::vector<dataref*>		datarefs;
	std::vector<std::string*>	commands;
	std::vector<command_handler> handlers;
	size_t						unregister_calls = 0;
	std::vector<flight_loop*>	loops;
	std::vector<window*>		windows;
};

sim& S()
{
	static sim* s = new sim;
	return *s;
}

float get_time(void*)			{ return static_cast<float>(S().time); }
float get_frame_period(void*)	{ return S().frame_period; }
int get_zero(void*)				{ return 0; }

dataref* find_dataref(char const* name)
{
	for (dataref* d : S().datarefs)
		if (d->name == name)
			return d;
	return nullptr;
}

void add_sim_dataref(char const* name, XPLMDataTypeID types, XPLMGetDatai_f geti, XPLMGetDataf_f getf)
{
	auto* d = new dataref{ name, true, types };
	d->geti = geti;
	d->getf = getf;
	S().datarefs.push_back(d);
}

// The sim datarefs that XLua reads.
void add_sim_datarefs()
{
	static bool done = false;
	if (done)
		return;
	done = true;
	add_sim_dataref("sim/time/total_running_time_sec", xplmType_Float, nullptr, get_time);
	add_sim_dataref("sim/network/misc/network_time_sec", xplmType_Float, nullptr, get_time);
	add_sim_dataref("sim/operation/misc/frame_rate_period", xplmType_Float, nullptr, get_frame_period);
	add_sim_dataref("sim/time/is_in_replay", xplmType_Int, get_zero, nullptr);
}

dataref* live(XPLMDataRef ref)
{
	auto* d = static_cast<dataref*>(ref);
	return (d != nullptr && d->registered) ? d : nullptr;
}

// As XPLM does, a write to a dataref that is not writable does nothing.
dataref* writable(XPLMDataRef ref)
{
	dataref* d = live(ref);
	return (d != nullptr && d->writable) ? d : nullptr;
}

// Calls the handlers of one phase. As in XPLM, a handler that returns 0 stops the command.
void dispatch_command(XPLMCommandRef cmd, XPLMCommandPhase phase)
{
	if (!S().plugin_enabled)
		return;
	for (int before = 1; before >= 0; --before)
	{
		// Copy the list: a handler can register or unregister handlers.
		std::vector<command_handler> const list = S().handlers;
		for (command_handler const& h : list)
			if (h.cmd == cmd && h.before == before && h.func(cmd, phase, h.refcon) == 0)
				return;
	}
}

} // namespace

std::string const& log() { return S().log; }

size_t log_count(std::string_view text)
{
	size_t n = 0;
	for (size_t p = S().log.find(text); p != std::string::npos; p = S().log.find(text, p + text.size()))
		++n;
	return n;
}

void set_plugin_enabled(bool enabled) { S().plugin_enabled = enabled; }
void set_system_path(std::string const& path) { S().system_path = path; }

void run_frame(float dt)
{
	S().time += dt;
	S().frame_period = dt;
	++S().cycle;
	if (!S().plugin_enabled)
		return;
	// A callback can create flight loops, so walk by index and do not run the new ones in this frame.
	size_t const count = S().loops.size();
	for (size_t i = 0; i < count; ++i)
	{
		flight_loop* l = S().loops[i];
		if (l->destroyed || !l->scheduled || l->next_time > S().time + 1e-6)
			continue;
		float const r = l->params.callbackFunc(dt, dt, S().cycle, l->params.refcon);
		if (l->destroyed)
			continue;
		if (r == 0)
			l->scheduled = false;
		else
			l->next_time = S().time + (r > 0 ? r : -r * dt);
	}
}

bool command_once(char const* name)
{
	XPLMCommandRef cmd = XPLMFindCommand(name);
	if (cmd == nullptr)
		return false;
	XPLMCommandOnce(cmd);
	return true;
}

std::vector<command_handler> const& command_handlers() { return S().handlers; }

size_t command_handler_count(char const* command_name)
{
	XPLMCommandRef cmd = XPLMFindCommand(command_name);
	return std::count_if(S().handlers.begin(), S().handlers.end(), [cmd](command_handler const& h) { return h.cmd == cmd; });
}

size_t unregister_command_handler_calls() { return S().unregister_calls; }
std::vector<flight_loop*> const& flight_loops() { return S().loops; }
std::vector<dataref*> const& datarefs() { return S().datarefs; }
std::vector<window*> const& windows() { return S().windows; }

void draw_windows()
{
	if (!S().plugin_enabled)
		return;
	size_t const count = S().windows.size();
	for (size_t i = 0; i < count; ++i)
	{
		window* w = S().windows[i];
		if (!w->destroyed && w->params.visible && w->params.drawWindowFunc)
			w->params.drawWindowFunc(w, w->params.refcon);
	}
}

} // namespace fake

using namespace fake;

// ─── Log, identity and paths ────────────────────────────────────────────────

void XPLMDebugString(char const* text)
{
	S().log += text;
	fputs(text, stdout);
}

XPLMPluginID XPLMGetMyID(void) { return 1; }
XPLMPluginID XPLMFindPluginBySignature(char const*) { return XPLM_NO_PLUGIN_ID; }
char const* XPLMGetDirectorySeparator(void) { return "/"; }
void XPLMGetSystemPath(char* out_path) { strcpy(out_path, S().system_path.c_str()); }

// The aircraft is <system>/Aircraft/Test/Test.acf, and XLua is in its plugins/xlua folder.
void XPLMGetPluginInfo(XPLMPluginID, char* out_name, char* out_path, char* out_signature, char* out_description)
{
	if (out_name) strcpy(out_name, "xlua");
	if (out_path) strcpy(out_path, (S().system_path + "Aircraft/Test/plugins/xlua/64/xlua.xpl").c_str());
	if (out_signature) strcpy(out_signature, "xlua.test");
	if (out_description) strcpy(out_description, "");
}

void XPLMGetNthAircraftModel(int, char* out_file, char* out_path)
{
	strcpy(out_file, "Test.acf");
	strcpy(out_path, (S().system_path + "Aircraft/Test/Test.acf").c_str());
}

int XPLMGetDirectoryContents(char const* dir, int offset, char* names, int names_size, char** index, int index_count,
							 int* out_total, int* out_returned)
{
	std::vector<std::string> all;
	std::error_code ec;
	for (auto const& e : std::filesystem::directory_iterator(dir, ec))
		all.push_back(e.path().filename().string());
	std::sort(all.begin(), all.end());

	int n = 0;
	char* w = names;
	for (int i = offset; i < (int)all.size() && n < index_count; ++i, ++n)
	{
		if (w + all[i].size() + 1 > names + names_size)
			break;
		strcpy(w, all[i].c_str());
		index[n] = w;
		w += all[i].size() + 1;
	}
	if (out_total) *out_total = (int)all.size();
	if (out_returned) *out_returned = n;
	return offset + n >= (int)all.size();
}

// ─── Clock ──────────────────────────────────────────────────────────────────

float XPLMGetElapsedTime(void) { return static_cast<float>(S().time); }
int XPLMGetCycleNumber(void) { return S().cycle; }

// ─── Datarefs ───────────────────────────────────────────────────────────────

XPLMDataRef XPLMFindDataRef(char const* name)
{
	add_sim_datarefs();
	return find_dataref(name);
}

int XPLMIsDataRefGood(XPLMDataRef ref) { return live(ref) != nullptr; }
XPLMDataTypeID XPLMGetDataRefTypes(XPLMDataRef ref) { dataref* d = live(ref); return d ? d->types : xplmType_Unknown; }

int XPLMCanWriteDataRef(XPLMDataRef ref) { return writable(ref) != nullptr; }

XPLMDataRef XPLMRegisterDataAccessor(char const* name, XPLMDataTypeID types, int is_writable,
									 XPLMGetDatai_f geti, XPLMSetDatai_f seti, XPLMGetDataf_f getf, XPLMSetDataf_f setf,
									 XPLMGetDatad_f getd, XPLMSetDatad_f setd, XPLMGetDatavi_f getvi, XPLMSetDatavi_f setvi,
									 XPLMGetDatavf_f getvf, XPLMSetDatavf_f setvf, XPLMGetDatab_f getb, XPLMSetDatab_f setb,
									 void* read_refcon, void* write_refcon)
{
	add_sim_datarefs();
	dataref* d = find_dataref(name);
	if (d == nullptr)
	{
		d = new dataref{ name };
		S().datarefs.push_back(d);
	}
	else if (d->registered)
	{
		// As XPLM does: keep the first registration.
		XPLMDebugString(("fake XPLM: dataref " + d->name + " is already registered\n").c_str());
		return d;
	}
	*d = dataref{ name, true, types, is_writable != 0, geti, seti, getf, setf, getd, setd, getvi, setvi, getvf, setvf, getb, setb,
				  read_refcon, write_refcon };
	return d;
}

void XPLMUnregisterDataAccessor(XPLMDataRef ref)
{
	if (dataref* d = live(ref))
		d->registered = false;
}

int XPLMGetDatai(XPLMDataRef ref) { dataref* d = live(ref); return (d && d->geti) ? d->geti(d->read_refcon) : 0; }
float XPLMGetDataf(XPLMDataRef ref) { dataref* d = live(ref); return (d && d->getf) ? d->getf(d->read_refcon) : 0; }
double XPLMGetDatad(XPLMDataRef ref) { dataref* d = live(ref); return (d && d->getd) ? d->getd(d->read_refcon) : 0; }
void XPLMSetDatai(XPLMDataRef ref, int v) { if (dataref* d = writable(ref); d && d->seti) d->seti(d->write_refcon, v); }
void XPLMSetDataf(XPLMDataRef ref, float v) { if (dataref* d = writable(ref); d && d->setf) d->setf(d->write_refcon, v); }
void XPLMSetDatad(XPLMDataRef ref, double v) { if (dataref* d = writable(ref); d && d->setd) d->setd(d->write_refcon, v); }

int XPLMGetDatavi(XPLMDataRef ref, int* out, int offset, int max)
{
	dataref* d = live(ref);
	return (d && d->getvi) ? d->getvi(d->read_refcon, out, offset, max) : 0;
}

int XPLMGetDatavf(XPLMDataRef ref, float* out, int offset, int max)
{
	dataref* d = live(ref);
	return (d && d->getvf) ? d->getvf(d->read_refcon, out, offset, max) : 0;
}

int XPLMGetDatab(XPLMDataRef ref, void* out, int offset, int max)
{
	dataref* d = live(ref);
	return (d && d->getb) ? d->getb(d->read_refcon, out, offset, max) : 0;
}

void XPLMSetDatavi(XPLMDataRef ref, int* values, int offset, int count)
{
	if (dataref* d = writable(ref); d && d->setvi) d->setvi(d->write_refcon, values, offset, count);
}

void XPLMSetDatavf(XPLMDataRef ref, float* values, int offset, int count)
{
	if (dataref* d = writable(ref); d && d->setvf) d->setvf(d->write_refcon, values, offset, count);
}

void XPLMSetDatab(XPLMDataRef ref, void* values, int offset, int count)
{
	if (dataref* d = writable(ref); d && d->setb) d->setb(d->write_refcon, values, offset, count);
}

// ─── Commands ───────────────────────────────────────────────────────────────

XPLMCommandRef XPLMFindCommand(char const* name)
{
	for (std::string* c : S().commands)
		if (*c == name)
			return c;
	return nullptr;
}

XPLMCommandRef XPLMCreateCommand(char const* name, char const*)
{
	if (XPLMCommandRef c = XPLMFindCommand(name))
		return c;
	S().commands.push_back(new std::string(name));
	return S().commands.back();
}

void XPLMRegisterCommandHandler(XPLMCommandRef cmd, XPLMCommandCallback_f func, int before, void* refcon)
{
	S().handlers.push_back({ cmd, func, before != 0, refcon });
}

// As in XPLM, this removes the handler only if all four values match.
void XPLMUnregisterCommandHandler(XPLMCommandRef cmd, XPLMCommandCallback_f func, int before, void* refcon)
{
	++S().unregister_calls;
	auto& h = S().handlers;
	auto it = std::find_if(h.begin(), h.end(), [&](command_handler const& x) {
		return x.cmd == cmd && x.func == func && x.before == (before != 0) && x.refcon == refcon;
	});
	if (it != h.end())
		h.erase(it);
}

void XPLMCommandBegin(XPLMCommandRef cmd) { dispatch_command(cmd, xplm_CommandBegin); }
void XPLMCommandEnd(XPLMCommandRef cmd) { dispatch_command(cmd, xplm_CommandEnd); }

void XPLMCommandOnce(XPLMCommandRef cmd)
{
	dispatch_command(cmd, xplm_CommandBegin);
	dispatch_command(cmd, xplm_CommandEnd);
}

// ─── Flight loops ───────────────────────────────────────────────────────────

XPLMFlightLoopID XPLMCreateFlightLoop(XPLMCreateFlightLoop_t* params)
{
	S().loops.push_back(new flight_loop{ *params });
	return S().loops.back();
}

void XPLMDestroyFlightLoop(XPLMFlightLoopID id)
{
	if (id)
		static_cast<flight_loop*>(id)->destroyed = true;
}

// A positive interval is in seconds, a negative interval is in frames, and 0 stops the loop.
void XPLMScheduleFlightLoop(XPLMFlightLoopID id, float interval, int)
{
	auto* l = static_cast<flight_loop*>(id);
	if (l == nullptr || l->destroyed)
		return;
	l->scheduled = (interval != 0);
	l->next_time = S().time + (interval > 0 ? interval : (-interval - 1) * S().frame_period);
}

// ─── Windows ────────────────────────────────────────────────────────────────

XPLMWindowID XPLMCreateWindowEx(XPLMCreateWindow_t* params)
{
	S().windows.push_back(new window{ *params });
	return S().windows.back();
}

void XPLMDestroyWindow(XPLMWindowID id)
{
	if (id)
		static_cast<window*>(id)->destroyed = true;
}

void* XPLMGetWindowRefCon(XPLMWindowID id) { return static_cast<window*>(id)->params.refcon; }
void XPLMSetWindowRefCon(XPLMWindowID id, void* refcon) { static_cast<window*>(id)->params.refcon = refcon; }
int XPLMGetWindowIsVisible(XPLMWindowID id) { auto* w = static_cast<window*>(id); return !w->destroyed && w->params.visible; }

void XPLMGetWindowGeometry(XPLMWindowID id, int* left, int* top, int* right, int* bottom)
{
	auto const& p = static_cast<window*>(id)->params;
	if (left) *left = p.left;
	if (top) *top = p.top;
	if (right) *right = p.right;
	if (bottom) *bottom = p.bottom;
}
