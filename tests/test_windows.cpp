// Windows that a script makes with XLuaCreateImguiWindow. Their callbacks do not go through the same
// checks as the other callbacks, so they have their own tests.

#include "host.h"
#include "fake_xplm.h"

#include <catch2/catch_amalgamated.hpp>

TEST_CASE("The draw callback of an imgui window runs while its script runs")
{
	xlua_plugin xlua({ "window_helper" });
	xlua.start();
	fake::draw_windows();
	fake::draw_windows();
	CHECK(get_int("xluatest/window/draws") == 2);

	xlua.disable();
	REQUIRE(fake::windows().size() == 1);
	CHECK(fake::windows().front()->destroyed);
	xlua.finish();
}

TEST_CASE("The callbacks of an imgui window run no Lua code after its script fails")
{
	xlua_plugin xlua({ "window_dead" });
	xlua.start();
	REQUIRE(fake::windows().size() == 1);
	fake::window const* w = fake::windows().front();
	fake::draw_windows();
	w->params.handleMouseClickFunc(const_cast<fake::window*>(w), 150, 300, xplm_MouseDown, w->params.refcon);
	w->params.handleKeyFunc(const_cast<fake::window*>(w), 'a', 0, 'A', w->params.refcon, 0);
	CHECK(fake::log_count("XLUATEST window_dead: FAIL") == 0);

	// The window stays after the close, because the script could not destroy it. XPLM does not draw it
	// while the plugin is disabled.
	xlua.finish();
}
