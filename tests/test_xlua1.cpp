// The XLua 1 API that init.lua gives to scripts without a version line.

#include "host.h"
#include "fake_xplm.h"

#include "XPLMDataAccess.h"
#include "XPLMUtilities.h"

#include <catch2/catch_amalgamated.hpp>

#include <cstring>

namespace {

int count_calls(XPLMCommandRef, XPLMCommandPhase phase, void* refcon)
{
	if (phase == xplm_CommandBegin)
		++*static_cast<int*>(refcon);
	return 1;
}

} // namespace

TEST_CASE("XLua 1 datarefs and commands and timers work from both sides")
{
	xlua_plugin xlua({ "xlua1_api" });

	// Commands of another plugin, which the script replaces and wraps.
	XPLMCommandRef replace = XPLMCreateCommand("xluatest/other/replace", "");
	XPLMCommandRef wrap = XPLMCreateCommand("xluatest/other/wrap", "");
	int replace_calls = 0, wrap_calls = 0;
	XPLMRegisterCommandHandler(replace, count_calls, 0, &replace_calls);
	XPLMRegisterCommandHandler(wrap, count_calls, 0, &wrap_calls);

	xlua.start();
	xlua.run_frames(12);

	CHECK(fake::log_count("XLUATEST xlua1_api: FAIL") == 0);
	CHECK(XPLMGetDataf(XPLMFindDataRef("xluatest/xlua1/number")) == 7);
	float values[4] = {};
	CHECK(XPLMGetDatavf(XPLMFindDataRef("xluatest/xlua1/array"), values, 0, 4) == 4);
	CHECK(values[0] == 1);
	CHECK(values[3] == 4);
	char text[16] = {};
	XPLMDataRef text_ref = XPLMFindDataRef("xluatest/xlua1/text");
	CHECK(XPLMGetDatab(text_ref, text, 0, sizeof(text) - 1) == 5);
	CHECK(strcmp(text, "hello") == 0);

	// A dataref without a handler is read-only for other plugins.
	CHECK(XPLMCanWriteDataRef(XPLMFindDataRef("xluatest/xlua1/number")) == 0);
	XPLMDataRef writable = XPLMFindDataRef("xluatest/xlua1/writable");
	REQUIRE(XPLMCanWriteDataRef(writable));
	XPLMSetDataf(writable, 2.5f);

	REQUIRE(fake::command_once("xluatest/xlua1/command"));
	REQUIRE(fake::command_once("xluatest/other/replace"));
	REQUIRE(fake::command_once("xluatest/other/wrap"));
	// replace_command takes the command for itself. wrap_command lets it go on to the other handlers.
	CHECK(replace_calls == 0);
	CHECK(wrap_calls == 1);

	xlua.run_frames(10);
	check_script_result("xlua1_api", 11);

	XPLMUnregisterCommandHandler(replace, count_calls, 0, &replace_calls);
	XPLMUnregisterCommandHandler(wrap, count_calls, 0, &wrap_calls);
	xlua.finish();
}
