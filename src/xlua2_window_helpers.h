#ifndef XLUA2_WINDOW_HELPERS_H_
#define XLUA2_WINDOW_HELPERS_H_

extern "C" {
    #include "lua.h"
}

// XLua-2-only convenience constructors/destructors for imgui and browser
// windows. Both create functions wrap XPLMCreateWindowEx with content-type-
// specific defaults and pre-wired handlers (imgui input plumbing for one,
// optional URL load for the other), so script authors cannot accidentally
// configure a half-set-up window. The raw XPLMCreateWindowEx Lua binding is
// excluded from the auto-generated XLua glue (see exclude="lua" on
// XPLMCreateWindowEx in XPLMDisplay.xml).
//
// These are declared in XPLMDisplay.xml with lua_impl="external", so they are
// registered as Lua globals by the generated add_xplm_to_interp(); there is no
// separate hand-written registration call. The declarations here exist so the
// definitions in xlua2_window_helpers.cpp are checked against a single
// contract and match the extern "C" forward declarations the generator emits
// into XLua_Register_glue.cpp.

extern "C" {
    int XLuaCreateImguiWindow(lua_State* L);
    int XLuaCreateBrowserWindow(lua_State* L);
    int XLuaDestroyImguiWindow(lua_State* L);
    int XLuaDestroyBrowserWindow(lua_State* L);
}

#endif
