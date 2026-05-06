#ifndef XLUA_IMGUI_H_
#define XLUA_IMGUI_H_

extern "C" {
	#include "lua.h"
}

// Sets up the full XLua imgui Lua API on the given lua_State. Internally calls
// the vendored upstream LoadImguiBindings first (which creates the imgui.*
// widget table + the imgui.constant.* enum tables and sets it as a global),
// then registers the X-Plane-specific bindings on the same table:
//
//   imgui.NewFrame(width, height [, win_id])    -- begins an ImGui frame
//   imgui.Render()                              -- ends frame, streams ImDrawData via XPLMDrawCalls
//   imgui.HandleMouseClick(...)                 -- drop-in XPLMCreateWindow_t::handleMouseClickFunc
//   imgui.HandleMouseRightClick(...)            -- drop-in for handleRightClickFunc
//   imgui.HandleCursor(...)                     -- drop-in for handleCursorFunc
//   imgui.HandleMouseWheel(...)                 -- drop-in for handleMouseWheelFunc
//   imgui.HandleKey(...)                        -- drop-in for handleKeyFunc
//
// Per-lua_State ImGuiContext + font texture is lazily created on the first
// NewFrame call; cleanup happens via __gc when the lua_State closes.
void LoadXLuaImguiBindings(lua_State* lState);

#endif
