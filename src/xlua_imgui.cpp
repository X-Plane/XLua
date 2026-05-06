// X-Plane integration layer on top of imgui_lua_bindings.
//
// imgui_lua_bindings/imgui_lua_bindings.cpp is a vendored submodule (upstream:
// https://github.com/casssoft/imgui_lua_bindings) that has no concept of the
// XPLM API and produces a self-contained `imgui.*` table of widget bindings.
// This file extends that table with frame management (NewFrame, Render) and
// XPLMCreateWindow_t-callback drop-ins (HandleMouseClick etc.) that depend on
// XPLM headers — code that has no business living inside the upstream sources.
//
// Public API: LoadXLuaImguiBindings(lua_State*). It calls the vendored
// LoadImguiBindings internally, then adds the X-Plane entries on the same
// imgui table — so call sites need only this one entry point.
//
// State: each lua_State owns one XplmImguiContext stored as userdata in the
// Lua registry under kImguiStateKey. The same class is used by xlua.cpp's
// profiler window (different instance, no Lua state involved).

#include "shared_xpfuncs.h"
#include "xlua_imgui.h"
#include "xlua_imgui_context.h"

#include <XPLMDefs.h>
#include <XPLMDisplay.h>

#include <imgui.h>

#include <algorithm>
#include <cstring>
#include <vector>

extern "C" {
    #include <lauxlib.h>
}

// Vendored upstream — exported but has no header.
extern void LoadImguiBindings(lua_State* L);

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

// Returns the per-lua_State context if NewFrame has already created it; nullptr
// otherwise. Used by input dispatchers — they should not lazily create a context
// on input arriving before the first frame.
XplmImguiContext* GetExistingImguiState(lua_State* L) {
    lua_pushstring(L, kImguiStateKey);
    lua_gettable(L, LUA_REGISTRYINDEX);
    auto* st = lua_isuserdata(L, -1)
        ? static_cast<XplmImguiContext*>(lua_touserdata(L, -1)) : nullptr;
    lua_pop(L, 1);
    return st;
}

int impl_NewFrame(lua_State* L) {
    const int w = static_cast<int>(luaL_checkinteger(L, 1));
    const int h = static_cast<int>(luaL_checkinteger(L, 2));
    XPLMWindowID win = nullptr;
    if (lua_isuserdata(L, 3)) {
        win = xlua_checkuserdata<XPLMWindowID>(L, 3, "Expected XPLMWindowID");
    }

    auto* st = GetOrCreateImguiState(L);
    st->BeginFrame(w, h, win);
    return 0;
}

int impl_Render(lua_State* L) {
    auto* st = GetOrCreateImguiState(L);
    st->EndFrame();
    return 0;
}

int impl_HandleMouseClick(lua_State* L) {
    auto* st = GetExistingImguiState(L);
    if (st == nullptr) { lua_pushinteger(L, 0); return 1; }
    XPLMWindowID win = lua_isuserdata(L, 1)
        ? xlua_checkuserdata<XPLMWindowID>(L, 1, "Expected XPLMWindowID") : nullptr;
    const int x = static_cast<int>(luaL_checkinteger(L, 2));
    const int y = static_cast<int>(luaL_checkinteger(L, 3));
    const int status = static_cast<int>(luaL_checkinteger(L, 4));
    lua_pushinteger(L, st->OnMouseButton(win, x, y, static_cast<XPLMMouseStatus>(status), 0));
    return 1;
}

int impl_HandleMouseRightClick(lua_State* L) {
    auto* st = GetExistingImguiState(L);
    if (st == nullptr) { lua_pushinteger(L, 0); return 1; }
    XPLMWindowID win = lua_isuserdata(L, 1)
        ? xlua_checkuserdata<XPLMWindowID>(L, 1, "Expected XPLMWindowID") : nullptr;
    const int x = static_cast<int>(luaL_checkinteger(L, 2));
    const int y = static_cast<int>(luaL_checkinteger(L, 3));
    const int status = static_cast<int>(luaL_checkinteger(L, 4));
    lua_pushinteger(L, st->OnMouseButton(win, x, y, static_cast<XPLMMouseStatus>(status), 1));
    return 1;
}

int impl_HandleCursor(lua_State* L) {
    // Position update happens in NewFrame; the cursor callback only needs to
    // tell X-Plane what cursor to show. Default = let X-Plane pick.
    lua_pushinteger(L, xplm_CursorDefault);
    return 1;
}

int impl_HandleMouseWheel(lua_State* L) {
    auto* st = GetExistingImguiState(L);
    if (st == nullptr) { lua_pushinteger(L, 0); return 1; }
    XPLMWindowID win = lua_isuserdata(L, 1)
        ? xlua_checkuserdata<XPLMWindowID>(L, 1, "Expected XPLMWindowID") : nullptr;
    const int x = static_cast<int>(luaL_checkinteger(L, 2));
    const int y = static_cast<int>(luaL_checkinteger(L, 3));
    const int wheel = static_cast<int>(luaL_checkinteger(L, 4));   // 0=vertical, 1=horizontal
    const int clicks = static_cast<int>(luaL_checkinteger(L, 5));
    lua_pushinteger(L, st->OnMouseWheel(win, x, y, wheel, clicks));
    return 1;
}

int impl_HandleKey(lua_State* L) {
    auto* st = GetExistingImguiState(L);
    if (st == nullptr) return 0;
    // (win_id at 1 is unused — keys aren't position-dependent.)
    const int key   = static_cast<int>(luaL_checkinteger(L, 2));    // unicode char or 0
    const int flags = static_cast<int>(luaL_checkinteger(L, 3));
    const int vkey  = static_cast<int>(luaL_checkinteger(L, 4));
    // 5 = refcon (unused).
    // The auto-glue's format string for XPLMHandleKey_f pushes losingFocus as
    // a Lua boolean (format 'b' → lua_pushboolean), so use lua_toboolean here
    // — luaL_optinteger errors on a boolean.
    const int losing_focus = lua_toboolean(L, 6);
    st->OnKey(static_cast<char>(key),
              static_cast<XPLMKeyFlags>(flags),
              static_cast<char>(vkey),
              losing_focus);
    return 0;
}

// ─────────────────────────────────────────────────────────────────────────────
// imgui.InputText / InputTextWithHint / InputTextMultiline — bound by hand
// because the upstream iterator's argument macros don't have a shape for
// `(char* buf, size_t buf_size)`. The Lua-side contract matches every other
// Input* widget: returns (changed, new_text). The buffer is short-lived per
// call — ImGui keeps editing state (cursor, selection, undo) in
// ImGuiInputTextState keyed by widget ID, independent of the buffer pointer.
// Lua holds the canonical string between frames.
// ─────────────────────────────────────────────────────────────────────────────

// Allocate a buffer of at least `requested` bytes that comfortably holds `cur`,
// seeded with `cur` and NUL-terminated. Returns the buffer.
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

// On the no-context path we still return (false, current_text) so a caller
// pattern of `local _, t = imgui.InputText(...)` always assigns back cleanly.
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

void LoadXLuaImguiBindings(lua_State* L) {
    // 1. Vendored upstream: creates the imgui.* widget table + constants and
    //    sets it as the global "imgui".
    LoadImguiBindings(L);

    // 2. Re-fetch the imgui table the vendored function just made global, and
    //    add the X-Plane-specific entries to it.
    lua_getglobal(L, "imgui");
    if (!lua_istable(L, -1)) {
        lua_pop(L, 1);
        return;
    }

    static const luaL_Reg kXplmEntries[] = {
        {"NewFrame",              impl_NewFrame},
        {"Render",                impl_Render},
        {"HandleMouseClick",      impl_HandleMouseClick},
        {"HandleMouseRightClick", impl_HandleMouseRightClick},
        {"HandleCursor",          impl_HandleCursor},
        {"HandleMouseWheel",      impl_HandleMouseWheel},
        {"HandleKey",             impl_HandleKey},
        // Hand-rolled because the vendored iterator can't bind buf+size APIs.
        {"InputText",             impl_InputText},
        {"InputTextWithHint",     impl_InputTextWithHint},
        {"InputTextMultiline",    impl_InputTextMultiline},
        {nullptr, nullptr},
    };
    luaL_setfuncs(L, kXplmEntries, 0);
    lua_pop(L, 1);
}
