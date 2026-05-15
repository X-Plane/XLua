#ifndef XLUA2_WINDOW_HELPERS_H_
#define XLUA2_WINDOW_HELPERS_H_

extern "C" {
    #include "lua.h"
}

// Registers XLuaCreateImguiWindow and XLuaCreateBrowserWindow as Lua globals.
//
// Both wrap XPLMCreateWindowEx with content-type-specific defaults and pre-
// wired handlers (imgui input plumbing for one, optional URL load for the
// other), so script authors cannot accidentally configure a half-set-up
// imgui or browser window. The raw XPLMCreateWindowEx Lua binding is
// excluded from the auto-generated XLua glue (see exclude="lua" on
// XPLMCreateWindowEx in XPLMDisplay.xml).
//
// Call AFTER add_xplm_to_interp() and LoadXLuaImguiBindings().
void register_xlua2_window_helpers(lua_State* L);

#endif
