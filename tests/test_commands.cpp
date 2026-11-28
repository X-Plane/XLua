// Command handlers that a script registers with XPLMRegisterCommandHandler.

#include "host.h"
#include "fake_xplm.h"

#include "XPLMUtilities.h"

#include <catch2/catch_amalgamated.hpp>

#include <string>

namespace {

int count_calls(XPLMCommandRef, XPLMCommandPhase, void* refcon)
{
	++*static_cast<int*>(refcon);
	return 1;
}

// Fires the command and returns how many phases reached a handler that runs after the script's handler.
int calls_after(char const* command)
{
	int calls = 0;
	XPLMCommandRef cmd = XPLMFindCommand(command);
	XPLMRegisterCommandHandler(cmd, count_calls, 0, &calls);
	REQUIRE(fake::command_once(command));
	XPLMUnregisterCommandHandler(cmd, count_calls, 0, &calls);
	return calls;
}

} // namespace

TEST_CASE("The return value of a command handler decides if the command goes on")
{
	xlua_plugin xlua({ "command_bindings" });
	xlua.start();

	// As for a C handler: true lets the command go on, and false stops it. nil is false.
	CHECK(calls_after("xluatest/commands/returns_true") == 2);
	CHECK(calls_after("xluatest/commands/returns_false") == 0);
	CHECK(calls_after("xluatest/commands/returns_nil") == 0);

	// A handler with an error must not stop the command for all other handlers.
	CHECK(calls_after("xluatest/commands/raises_error") == 2);
	CHECK(fake::log_count("this handler fails on purpose") == 2);
	xlua.finish();
}

TEST_CASE("A command handler is unregistered only with its own function and refcon and phase")
{
	xlua_plugin xlua({ "command_bindings" });
	xlua.start();
	CHECK(fake::command_handler_count("xluatest/commands/target") == 1);

	// A call that does not match writes an error and makes no XPLM call.
	size_t const xplm_calls = fake::unregister_command_handler_calls();
	for (char const* wrong : { "wrong_function", "wrong_refcon", "wrong_phase" })
	{
		INFO(wrong);
		REQUIRE(fake::command_once((std::string("xluatest/commands/unregister_") + wrong).c_str()));
		CHECK(fake::command_handler_count("xluatest/commands/target") == 1);
	}
	CHECK(fake::log_count("found no handler registered with this exact function and refcon") == 3);
	CHECK(fake::unregister_command_handler_calls() == xplm_calls);

	REQUIRE(fake::command_once("xluatest/commands/unregister_correct"));
	CHECK(fake::command_handler_count("xluatest/commands/target") == 0);
	CHECK(fake::unregister_command_handler_calls() == xplm_calls + 1);
	xlua.finish();
}
