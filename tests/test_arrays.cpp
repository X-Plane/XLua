// Array datarefs with Lua accessors, through the committed glue.

#include "host.h"

#include <catch2/catch_amalgamated.hpp>

TEST_CASE("Array dataref accessors copy the correct values and counts in each call context")
{
	xlua_plugin xlua({ "array_datarefs" });
	xlua.start();
	xlua.run_frames(2);
	// 22 checks in each of 3 call contexts.
	check_script_result("array_datarefs", 66);
	xlua.finish();
}
