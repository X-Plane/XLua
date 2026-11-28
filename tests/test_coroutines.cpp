// Callbacks that a script registers from inside a Lua coroutine. Each callback must run on the main state of
// its script, and the close of the script must remove all of its command handlers and timers.

#include "host.h"
#include "fake_xplm.h"

#include <catch2/catch_amalgamated.hpp>

#include <string>

TEST_CASE("Callbacks registered inside a coroutine run on the main state")
{
	xlua_plugin xlua({ "coroutine_callbacks" });
	xlua.start();
	xlua.run_frames(85);
	check_script_result("coroutine_callbacks", 40);
	xlua.finish();
}

namespace {

// Registers one callback inside a coroutine, collects the coroutine, and then causes the callback.
void check_collected(char const* kind, int expected_pass)
{
	xlua_plugin xlua({ "coroutine_callbacks" });
	xlua.start();
	REQUIRE(fake::command_once((std::string("xluatest/coroutines/collect_") + kind).c_str()));
	xlua.run_frames(35);
	check_script_result("coroutine_callbacks_collected", expected_pass);
	xlua.finish();
}

} // namespace

TEST_CASE("A dataref accessor registered inside a collected coroutine runs on the main state")
{
	check_collected("dataref", 4);
}

TEST_CASE("A command handler registered inside a collected coroutine runs on the main state")
{
	check_collected("command", 3);
}

TEST_CASE("A flight loop registered inside a collected coroutine runs on the main state")
{
	check_collected("flightloop", 3);
}

TEST_CASE("A timer registered inside a collected coroutine runs on the main state")
{
	check_collected("timer", 3);
}

TEST_CASE("The close removes the command handler when the first callback was registered inside a coroutine")
{
	xlua_plugin xlua({ "first_in_coroutine" });
	xlua.start();
	xlua.run_frames(3);
	REQUIRE(fake::command_once("xluatest/first_in_coroutine/command"));
	CHECK(fake::log_count("XLUATEST first_in_coroutine: the command handler ran") == 2);

	xlua.disable();
	CHECK(fake::command_handler_count("xluatest/first_in_coroutine/command") == 0);
	xlua.finish();
}

TEST_CASE("The close removes the timer when the first callback was registered inside a coroutine")
{
	module_host host({ "first_in_coroutine", "second_script" });
	module* closed = host.load("first_in_coroutine");
	host.load("second_script");
	host.run_frames(3);
	CHECK(fake::log_count("XLUATEST first_in_coroutine: the timer ran") > 0);

	host.close(closed);
	CHECK(fake::command_handler_count("xluatest/first_in_coroutine/command") == 0);
	size_t const timer_calls = fake::log_count("XLUATEST first_in_coroutine: the timer ran");
	host.run_frames(3);
	CHECK(fake::log_count("XLUATEST first_in_coroutine: the timer ran") == timer_calls);

	REQUIRE(fake::command_once("xluatest/second/command"));
	CHECK(get_int("xluatest/second/command_calls") == 1);
	host.finish();
}
