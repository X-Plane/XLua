// Start of the plugin with the shipped init.lua and the committed glue.

#include "host.h"
#include "fake_xplm.h"

#include <catch2/catch_amalgamated.hpp>

TEST_CASE("An XLua 1 script and an XLua 2 script start and run with no error")
{
	xlua_plugin xlua({ "start_v1", "start_v2" });
	xlua.start();
	xlua.run_frames(5);

	check_script_result("start_v1", 1);
	check_script_result("start_v2", 1);
	INFO(fake::log());
	CHECK(fake::log_count("E/LUA") == 0);
	CHECK(fake::log_count("Error") == 0);
	xlua.finish();
}
