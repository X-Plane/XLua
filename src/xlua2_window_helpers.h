#ifndef XLUA2_WINDOW_HELPERS_H_
#define XLUA2_WINDOW_HELPERS_H_

extern "C" {
    #include "lua.h"
}

// XLua-2-only imgui window helper. XLuaCreateImguiWindow wraps
// XPLMCreateWindowEx, opening and closing an imgui frame around the Lua draw
// callback and wiring the input handlers, so scripts write pure widget calls.
// Non-imgui windows use the raw XPLMCreateWindowEx binding directly.
//
// These are declared in XPLMDisplay.xml with lua_impl="external", so they are
// registered as Lua globals by the generated add_xplm_to_interp(); there is no
// separate hand-written registration call. The declarations here exist so the
// definitions in xlua2_window_helpers.cpp are checked against a single
// contract and match the extern "C" forward declarations the generator emits
// into XLua_Register_glue.cpp.

extern "C" {
    int XLuaCreateImguiWindow(lua_State* L);
    int XLuaDestroyImguiWindow(lua_State* L);
}

#endif
