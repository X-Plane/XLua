// X-Plane integration layer for the vendored imgui Lua bindings.
//
// imgui_lua_bindings/imgui_lua_bindings.cpp is a vendored submodule (upstream:
// https://github.com/casssoft/imgui_lua_bindings) that produces a self-contained
// `imgui.*` widget table with no XPLM knowledge. This file provides:
//
//   - the per-lua_State XplmImguiContext (font texture, ImGuiIO bookkeeping,
//     the actual ImGui::NewFrame/Render calls that walk ImDrawData and
//     dispatch through XPLMDrawCalls);
//   - C-callable XPLMCreateWindow_t-callback shims that route input straight
//     into that context;
//   - hand-rolled imgui.InputText* widgets that the vendored macro iterator
//     can't bind (it has no shape for `(char* buf, size_t buf_size)`).
//
// Frame management is not exposed to Lua scripts — XLuaCreateImguiWindow
// installs the BeginFrame/EndFrame bracket and the input handlers in C; the
// script body is pure widget code, plus the InputText widgets registered
// below.

#include "xlua_imgui.h"
#include "xlua_imgui_context.h"

#include <imgui.h>

#include <algorithm>
#include <cstring>
#include <vector>

extern "C" {
    #include <lauxlib.h>
}

namespace {

constexpr char kImguiStateKey[] = "_xlua_imgui_state";

int ImguiState_gc(lua_State* L) {
    auto* st = static_cast<XplmImguiContext*>(lua_touserdata(L, 1));
    if (st == nullptr) return 0;
    st->~XplmImguiContext();
    return 0;
}

XplmImguiContext* GetOrCreateImguiState(lua_State* L) {
    lua_pushstring(L, kImguiStateKey);
    lua_gettable(L, LUA_REGISTRYINDEX);
    if (lua_isuserdata(L, -1)) {
        auto* st = static_cast<XplmImguiContext*>(lua_touserdata(L, -1));
        lua_pop(L, 1);
        return st;
    }
    lua_pop(L, 1);

    auto* st = static_cast<XplmImguiContext*>(
        lua_newuserdata(L, sizeof(XplmImguiContext)));
    new (st) XplmImguiContext();

    if (luaL_newmetatable(L, "_xlua_imgui_state_mt")) {
        lua_pushstring(L, "__gc");
        lua_pushcfunction(L, ImguiState_gc);
        lua_settable(L, -3);
    }
    lua_setmetatable(L, -2);

    lua_pushstring(L, kImguiStateKey);
    lua_pushvalue(L, -2);
    lua_settable(L, LUA_REGISTRYINDEX);
    lua_pop(L, 1);

    return st;
}

// Returns the per-lua_State context if a frame has been opened on it; nullptr
// otherwise. Used by input dispatchers — they should not lazily create a
// context for input arriving before the first frame.
XplmImguiContext* GetExistingImguiState(lua_State* L) {
    lua_pushstring(L, kImguiStateKey);
    lua_gettable(L, LUA_REGISTRYINDEX);
    auto* st = lua_isuserdata(L, -1)
        ? static_cast<XplmImguiContext*>(lua_touserdata(L, -1)) : nullptr;
    lua_pop(L, 1);
    return st;
}

} // anonymous namespace

void xplm_imgui_begin_frame(lua_State* L, int w, int h, XPLMWindowID win) {
    GetOrCreateImguiState(L)->BeginFrame(w, h, win);
}

void xplm_imgui_end_frame(lua_State* L) {
    GetOrCreateImguiState(L)->EndFrame();
}

int xplm_imgui_handle_mouse_click(XPLMWindowID win, int x, int y,
                                  XPLMMouseStatus status, void* refcon) {
    auto* L = static_cast<lua_State*>(refcon);
    if (L == nullptr) return 0;
    auto* st = GetExistingImguiState(L);
    if (st == nullptr) return 0;
    return st->OnMouseButton(win, x, y, status, 0);
}

int xplm_imgui_handle_right_click(XPLMWindowID win, int x, int y,
                                  XPLMMouseStatus status, void* refcon) {
    auto* L = static_cast<lua_State*>(refcon);
    if (L == nullptr) return 0;
    auto* st = GetExistingImguiState(L);
    if (st == nullptr) return 0;
    return st->OnMouseButton(win, x, y, status, 1);
}

void xplm_imgui_handle_key(XPLMWindowID, char key, XPLMKeyFlags flags,
                           char vkey, void* refcon, int losingFocus) {
    auto* L = static_cast<lua_State*>(refcon);
    if (L == nullptr) return;
    auto* st = GetExistingImguiState(L);
    if (st == nullptr) return;
    st->OnKey(key, flags, vkey, losingFocus);
}

XPLMCursorStatus xplm_imgui_handle_cursor(XPLMWindowID, int, int, void*) {
    return xplm_CursorDefault;
}

int xplm_imgui_handle_mouse_wheel(XPLMWindowID win, int x, int y,
                                  int wheel, int clicks, void* refcon) {
    auto* L = static_cast<lua_State*>(refcon);
    if (L == nullptr) return 0;
    auto* st = GetExistingImguiState(L);
    if (st == nullptr) return 0;
    return st->OnMouseWheel(win, x, y, wheel, clicks);
}

// ─────────────────────────────────────────────────────────────────────────────
// imgui.InputText / InputTextWithHint / InputTextMultiline — bound by hand
// because the vendored iterator can't bind buf+size APIs. The Lua-side
// contract matches every other Input* widget: returns (changed, new_text).
// The buffer is short-lived per call — ImGui keeps editing state (cursor,
// selection, undo) in ImGuiInputTextState keyed by widget ID, independent
// of the buffer pointer. Lua holds the canonical string between frames.
// ─────────────────────────────────────────────────────────────────────────────

namespace {

// Allocate a buffer of at least `requested` bytes that comfortably holds
// `cur`, seeded with `cur` and NUL-terminated. Returns the buffer.
std::vector<char> MakeInputBuf(const char* cur, size_t cur_len, int requested) {
    if (requested < 1) requested = 1;
    if (static_cast<size_t>(requested) <= cur_len) {
        requested = static_cast<int>(cur_len + 1);
    }
    std::vector<char> buf(static_cast<size_t>(requested));
    const size_t copy_len = std::min(cur_len, buf.size() - 1);
    std::memcpy(buf.data(), cur, copy_len);
    buf[copy_len] = '\0';
    return buf;
}

// On the no-context path return (false, current_text) so a caller pattern
// of `local _, t = imgui.InputText(...)` always assigns back cleanly.
int InputTextNoContextReturn(lua_State* L, int text_arg_idx) {
    lua_pushboolean(L, 0);
    lua_pushvalue(L, text_arg_idx);
    return 2;
}

// imgui.InputText(label, current_text, [max_len=256], [flags=0])
int impl_InputText(lua_State* L) {
    const char* label = luaL_checkstring(L, 1);
    size_t cur_len = 0;
    const char* cur = luaL_checklstring(L, 2, &cur_len);
    const int max_len = static_cast<int>(luaL_optinteger(L, 3, 256));
    const int flags   = static_cast<int>(luaL_optinteger(L, 4, 0));

    auto* st = GetExistingImguiState(L);
    if (st == nullptr) return InputTextNoContextReturn(L, 2);
    ImGui::SetCurrentContext(st->raw_context());

    auto buf = MakeInputBuf(cur, cur_len, max_len);
    const bool changed = ImGui::InputText(label, buf.data(), buf.size(),
                                          static_cast<ImGuiInputTextFlags>(flags));
    lua_pushboolean(L, changed);
    lua_pushstring(L, buf.data());
    return 2;
}

// imgui.InputTextWithHint(label, hint, current_text, [max_len=256], [flags=0])
int impl_InputTextWithHint(lua_State* L) {
    const char* label = luaL_checkstring(L, 1);
    const char* hint  = luaL_checkstring(L, 2);
    size_t cur_len = 0;
    const char* cur = luaL_checklstring(L, 3, &cur_len);
    const int max_len = static_cast<int>(luaL_optinteger(L, 4, 256));
    const int flags   = static_cast<int>(luaL_optinteger(L, 5, 0));

    auto* st = GetExistingImguiState(L);
    if (st == nullptr) return InputTextNoContextReturn(L, 3);
    ImGui::SetCurrentContext(st->raw_context());

    auto buf = MakeInputBuf(cur, cur_len, max_len);
    const bool changed = ImGui::InputTextWithHint(label, hint, buf.data(), buf.size(),
                                                  static_cast<ImGuiInputTextFlags>(flags));
    lua_pushboolean(L, changed);
    lua_pushstring(L, buf.data());
    return 2;
}

// imgui.InputTextMultiline(label, current_text, [max_len=4096], [width=0], [height=0], [flags=0])
// (default max_len is larger than InputText since multiline content is usually longer.)
int impl_InputTextMultiline(lua_State* L) {
    const char* label = luaL_checkstring(L, 1);
    size_t cur_len = 0;
    const char* cur = luaL_checklstring(L, 2, &cur_len);
    const int   max_len = static_cast<int>(luaL_optinteger(L, 3, 4096));
    const float width   = static_cast<float>(luaL_optnumber(L, 4, 0.0));
    const float height  = static_cast<float>(luaL_optnumber(L, 5, 0.0));
    const int   flags   = static_cast<int>(luaL_optinteger(L, 6, 0));

    auto* st = GetExistingImguiState(L);
    if (st == nullptr) return InputTextNoContextReturn(L, 2);
    ImGui::SetCurrentContext(st->raw_context());

    auto buf = MakeInputBuf(cur, cur_len, max_len);
    const bool changed = ImGui::InputTextMultiline(label, buf.data(), buf.size(),
                                                   ImVec2(width, height),
                                                   static_cast<ImGuiInputTextFlags>(flags));
    lua_pushboolean(L, changed);
    lua_pushstring(L, buf.data());
    return 2;
}

} // namespace

void register_xlua_imgui_text_inputs(lua_State* L) {
    lua_getglobal(L, "imgui");
    if (!lua_istable(L, -1)) {
        lua_pop(L, 1);
        return;
    }
    static const luaL_Reg kEntries[] = {
        {"InputText",          impl_InputText},
        {"InputTextWithHint",  impl_InputTextWithHint},
        {"InputTextMultiline", impl_InputTextMultiline},
        {nullptr, nullptr},
    };
    luaL_setfuncs(L, kEntries, 0);
    lua_pop(L, 1);
}
