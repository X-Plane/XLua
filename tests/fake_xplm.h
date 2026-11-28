// A small fake of the X-Plane plugin API (XPLM) for the XLua tests.
//
// fake_xplm.cpp defines the XPLM functions that XLua needs to run scripts: the
// log, the clock, datarefs, commands, flight loops, windows and paths. The
// linker uses these definitions instead of the weak no-op stubs that
// gen_xplm_stubs.py writes for all other XPLM functions.
//
// The fake copies the behavior of XPLM where a script can see it. It does not
// call the flight loops, command handlers or windows of a disabled plugin.

#pragma once

#include "XPLMDataAccess.h"
#include "XPLMDisplay.h"
#include "XPLMProcessing.h"
#include "XPLMUtilities.h"

#include <string>
#include <string_view>
#include <vector>

namespace fake {

// The text of all XPLMDebugString calls.
std::string const& log();
size_t log_count(std::string_view text);

// The plugin under test. The host changes this flag in XPluginEnable and XPluginDisable.
void set_plugin_enabled(bool enabled);

// The folder that XPLMGetSystemPath gives. It ends with a separator.
void set_system_path(std::string const& path);

// Moves the sim clock by dt seconds, then calls each flight loop that is due.
void run_frame(float dt = 0.05f);

// Runs the begin and end phase of a command. Returns false if there is no command with this name.
bool command_once(char const* name);

struct command_handler {
	XPLMCommandRef			cmd;
	XPLMCommandCallback_f	func;
	int						before;
	void*					refcon;
};
std::vector<command_handler> const& command_handlers();
size_t command_handler_count(char const* command_name);
size_t unregister_command_handler_calls();

struct flight_loop {
	XPLMCreateFlightLoop_t	params;
	bool					destroyed = false;
	bool					scheduled = false;
	double					next_time = 0;
};
std::vector<flight_loop*> const& flight_loops();

struct dataref {
	std::string			name;
	bool				registered = false;	// True while an accessor is registered.
	XPLMDataTypeID		types = xplmType_Unknown;
	bool				writable = false;
	XPLMGetDatai_f		geti = nullptr;
	XPLMSetDatai_f		seti = nullptr;
	XPLMGetDataf_f		getf = nullptr;
	XPLMSetDataf_f		setf = nullptr;
	XPLMGetDatad_f		getd = nullptr;
	XPLMSetDatad_f		setd = nullptr;
	XPLMGetDatavi_f		getvi = nullptr;
	XPLMSetDatavi_f		setvi = nullptr;
	XPLMGetDatavf_f		getvf = nullptr;
	XPLMSetDatavf_f		setvf = nullptr;
	XPLMGetDatab_f		getb = nullptr;
	XPLMSetDatab_f		setb = nullptr;
	void*				read_refcon = nullptr;
	void*				write_refcon = nullptr;
};
std::vector<dataref*> const& datarefs();

struct window {
	XPLMCreateWindow_t	params;
	bool				destroyed = false;
};
std::vector<window*> const& windows();
// Calls the draw callback of each window that exists, as XPLM does each frame.
void draw_windows();

} // namespace fake
