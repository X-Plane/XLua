// Error reports from callbacks.

#include "host.h"
#include "fake_xplm.h"

#include <catch2/catch_amalgamated.hpp>

TEST_CASE("An error in a dataref accessor that runs inside a Lua call shows its message")
{
	xlua_plugin xlua({ "error_in_accessor" });
	xlua.start();
	xlua.run_frames(5);
	INFO(fake::log());
	CHECK(fake::log_count("XLUATEST error_in_accessor: the read gave 0") == 1);
	CHECK(fake::log_count("this accessor fails on purpose") > 0);
	CHECK(fake::log_count("error in error handling") == 0);
	xlua.finish();
}
