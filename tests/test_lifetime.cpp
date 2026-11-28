// Callback lifetime: a callback must not run Lua code after it is unregistered, after its script fails,
// or after its script closes. XPLM can still call it then, and XLua must return the default value.

#include "host.h"
#include "fake_xplm.h"

#include "XPLMUtilities.h"

#include <catch2/catch_amalgamated.hpp>

#include <string_view>

namespace {

fake::flight_loop const* last_flight_loop()
{
	REQUIRE(!fake::flight_loops().empty());
	return fake::flight_loops().back();
}

fake::dataref const* find_dataref(std::string_view name)
{
	for (fake::dataref const* d : fake::datarefs())
		if (d->name == name)
			return d;
	FAIL("no dataref " << name);
	return nullptr;
}

fake::command_handler find_handler(char const* command)
{
	XPLMCommandRef cmd = XPLMFindCommand(command);
	for (fake::command_handler const& h : fake::command_handlers())
		if (h.cmd == cmd)
			return h;
	FAIL("no handler for " << command);
	return {};
}

int count_calls(XPLMCommandRef, XPLMCommandPhase, void* refcon)
{
	++*static_cast<int*>(refcon);
	return 1;
}

} // namespace

TEST_CASE("A callback runs no Lua code after it is unregistered or after its script closes")
{
	xlua_plugin xlua({ "lifetime" });
	xlua.start();
	xlua.run_frames(3);

	// The flight loop is the last one that was created: XLua creates its own two in XPluginEnable, before the scripts run.
	fake::flight_loop const loop = *last_flight_loop();
	fake::dataref const value = *find_dataref("xluatest/lifetime/value");
	fake::command_handler const handler = find_handler("xluatest/lifetime/command");

	// While they are registered, all four callbacks run.
	CHECK(get_int("xluatest/lifetime/value") == 42);
	REQUIRE(fake::command_once("xluatest/lifetime/command"));
	CHECK(get_int("xluatest/lifetime/command_calls") == 1);
	CHECK(get_int("xluatest/lifetime/loop_calls") >= 2);
	CHECK(get_int("xluatest/lifetime/timer_calls") >= 2);

	// The script unregisters all four. A callback that runs after this writes a FAIL line.
	REQUIRE(fake::command_once("xluatest/lifetime/unregister"));
	xlua.run_frames(3);
	CHECK(fake::command_handler_count("xluatest/lifetime/command") == 0);

	// The command handler record is released at unregister. A late call must not run the handler, and must let
	// the command go on. XPLM does not call a destroyed flight loop or an unregistered accessor, so the
	// test calls those only after the close.
	xlua.allow_log("This is a plugin bug");
	CHECK(handler.func(handler.cmd, xplm_CommandBegin, handler.refcon) == 1);

	// After the close, all records are released. Each callback must return its default.
	xlua.disable();
	CHECK(loop.params.callbackFunc(0.05f, 0.05f, 1, loop.params.refcon) == 0);
	CHECK(value.geti(value.read_refcon) == 0);
	CHECK(handler.func(handler.cmd, xplm_CommandBegin, handler.refcon) == 1);

	CHECK(fake::log_count("XLUATEST lifetime: FAIL") == 0);
	xlua.finish();
}

TEST_CASE("A closed script leaves no command handler or timer and the other script still runs")
{
	module_host host({ "lifetime", "second_script" });
	// The close does not destroy the flight loop of the script, so XPLM still calls it. XLua finds that it is
	// stale and writes this line.
	host.allow_log("This is a plugin bug");
	module* closed = host.load("lifetime");
	host.load("second_script");
	host.run_frames(3);
	CHECK(get_int("xluatest/lifetime/timer_calls") >= 2);

	host.close(closed);
	CHECK(fake::command_handler_count("xluatest/lifetime/command") == 0);
	CHECK(fake::command_handler_count("xluatest/lifetime/unregister") == 0);

	// The timer of the closed script must not fire. Its interpreter is gone.
	host.run_frames(3);

	REQUIRE(fake::command_once("xluatest/second/command"));
	CHECK(get_int("xluatest/second/command_calls") == 1);
	host.finish();
}

TEST_CASE("Callbacks that a script registers while it stops do not run after a disable and an enable")
{
	xlua_plugin xlua({ "shutdown_registration" });
	// XLua does not destroy the flight loops of a closed script, so XPLM calls them again after the enable.
	// XLua finds that they are stale and writes this line.
	xlua.allow_log("This is a plugin bug");
	xlua.start();
	for (int cycle = 0; cycle < 2; ++cycle)
	{
		xlua.run_frames(3);
		// Only the handler of the running script is registered, not one from a closed script.
		CHECK(fake::command_handler_count("xluatest/shutdown/command") == 1);
		REQUIRE(fake::command_once("xluatest/shutdown/command"));
		CHECK(get_int("xluatest/shutdown/command_calls") == 1);

		xlua.disable();
		CHECK(fake::command_handler_count("xluatest/shutdown/command") == 0);
		xlua.enable();
	}
	xlua.run_frames(3);
	CHECK(fake::log_count("XLUATEST shutdown_registration: FAIL") == 0);
	xlua.finish();
}

namespace {

// A script registers a dataref, a command handler, a timer and a callout, and then fails.
void check_dead_script(char const* script)
{
	xlua_plugin xlua({ script, "second_script" });
	xlua.start();
	xlua.run_frames(5);
	CHECK(fake::log_count("did not start") == 1);

	// The dataref stays registered, but reads zero.
	CHECK(get_int("xluatest/dead/value") == 0);

	// The command goes on to the handlers after the handler of the dead script.
	int after_calls = 0;
	XPLMCommandRef cmd = XPLMFindCommand("xluatest/dead/command");
	XPLMRegisterCommandHandler(cmd, count_calls, 0, &after_calls);
	REQUIRE(fake::command_once("xluatest/dead/command"));
	CHECK(after_calls == 2);
	XPLMUnregisterCommandHandler(cmd, count_calls, 0, &after_calls);

	// The other script still runs.
	REQUIRE(fake::command_once("xluatest/second/command"));
	CHECK(get_int("xluatest/second/command_calls") == 1);

	CHECK(fake::log_count("XLUATEST dead: FAIL") == 0);
	xlua.finish();
}

} // namespace

TEST_CASE("A script with an error in its chunk runs none of its callbacks")
{
	check_dead_script("dead_chunk");
}

TEST_CASE("A script whose XPluginStart returns false runs none of its callbacks")
{
	check_dead_script("dead_start");
}

TEST_CASE("A script whose XPluginEnable returns false runs none of its callbacks")
{
	check_dead_script("dead_enable");
}
