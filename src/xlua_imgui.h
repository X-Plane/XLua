#ifndef XLUA_IMGUI_H_
#define XLUA_IMGUI_H_

#include <XPLMDefs.h>
#include <XPLMDisplay.h>

extern "C" {
	#include "lua.h"
}

// Vendored upstream entry point — creates the global `imgui.*` widget table
// (and `imgui.constant.*` enum tables) on the given lua_State. No X-Plane-
// specific surface is layered on top: frame management is driven from C by
// XLuaCreateImguiWindow's draw wrapper (see xlua2_window_helpers.cpp), and
// input plumbing is wired by the same wrapper through the C-callable cores
// below. Lua scripts only see the imgui widget calls.
//
// Call once per Lua VM that wants imgui access.
//
// (Defined in the vendored imgui_lua_bindings.cpp, no upstream header. The
// extern declaration here lets the rest of the codebase call it without
// taking that fact into account.)
void LoadImguiBindings(lua_State* L);

// Frame primitives — wrap XplmImguiContext::BeginFrame / EndFrame, looking
// the per-VM context out of the Lua registry on the given state. Driven by
// XLuaCreateImguiWindow's auto-framing draw wrapper; not exposed to Lua.
void xplm_imgui_begin_frame(lua_State* L, int w, int h, XPLMWindowID win);
void xplm_imgui_end_frame  (lua_State* L);

// Adds imgui.InputText / InputTextWithHint / InputTextMultiline to the global
// `imgui` table. Must be called *after* LoadImguiBindings (which creates the
// table). The vendored binder can't emit buf+size APIs, so these three are
// hand-rolled in xlua_imgui.cpp.
void register_xlua_imgui_text_inputs(lua_State* L);

// C-callable imgui input handlers with the exact signatures expected by
// XPLMCreateWindow_t. They route the event straight into the per-lua_State
// ImGuiContext stored in the refcon, with no Lua marshalling on the hot path.
// XLuaCreateImguiWindow wires these onto the underlying XPLMCreateWindowEx
// call.
//
// The refcon MUST be a `lua_State*` for the script that owns the window —
// the handlers look up the imgui context out of that state's registry.
int              xplm_imgui_handle_mouse_click       (XPLMWindowID, int x, int y,
                                                      XPLMMouseStatus, void* refcon);
int              xplm_imgui_handle_right_click       (XPLMWindowID, int x, int y,
                                                      XPLMMouseStatus, void* refcon);
void             xplm_imgui_handle_key               (XPLMWindowID, char key,
                                                      XPLMKeyFlags, char vkey,
                                                      void* refcon, int losingFocus);
XPLMCursorStatus xplm_imgui_handle_cursor            (XPLMWindowID, int x, int y,
                                                      void* refcon);
int              xplm_imgui_handle_mouse_wheel       (XPLMWindowID, int x, int y,
                                                      int wheel, int clicks, void* refcon);

#endif
