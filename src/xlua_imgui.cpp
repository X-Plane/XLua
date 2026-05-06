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
    const int losing_focus = static_cast<int>(luaL_optinteger(L, 6, 0));
    st->OnKey(static_cast<char>(key),
              static_cast<XPLMKeyFlags>(flags),
              static_cast<char>(vkey),
              losing_focus);
    return 0;
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
        {nullptr, nullptr},
    };
    luaL_setfuncs(L, kXplmEntries, 0);
    lua_pop(L, 1);
}
