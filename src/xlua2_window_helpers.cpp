// KEEP IN SYNC WITH XPLMDisplay.xml: these hand-written bodies back the
// lua_impl="external" imgui window-helper declarations there. A missing/renamed
// impl fails the link — but the XML's params/return/desc (which become the
// published EmmyLua docs) are NOT checked, so if you change what a function
// takes or returns here, update the XML too or the docs silently go stale.
//
// XLuaCreateImguiWindow wraps XPLMCreateWindowEx, opening/closing an imgui frame
// around the Lua draw callback and wiring the input handlers. header_parser does
// NOT auto-generate these bodies — it only emits the EmmyLua type stub and a
// registration entry in the generated XLua_Register_glue.cpp pointing at the
// hand-written extern "C" definitions below.

#include "shared_lua_helpers.h"
#include "shared_xpfuncs.h"
#include "xlua2_window_helpers.h"
#include "xlua_imgui.h"

#include <XPLMDefs.h>
#include <XPLMDisplay.h>

extern "C" {
    #include <lauxlib.h>
}

#include <memory>

// Forward decl from XPLMDisplay_glue.cpp -- sets up the metatable so the Lua
// value returned matches what every other XPLMWindowID-producing binding
// returns. The generated glue wraps its definitions in `extern "C"`, so we
// must match that linkage here for the symbol names to line up.
extern "C" XPLMWindowID* Make_XPLMWindowID(lua_State* L, XPLMWindowID const& init);

namespace {

// Resolve a workable debug-proc stack index for fmt_pcall_stdvars in both the
// XLua per-aircraft context (sets __module_ptr global) and the host-loaded
// .lua test-plugin context (sets __debug_proc global directly). Returns 0 if
// neither is present, which lua_pcall treats as "no traceback handler".
int find_debug_proc(lua_State* L) {
    lua_getglobal(L, "__debug_proc");
    int v = 0;
    if (lua_isuserdata(L, -1)) {
        if (int* p = static_cast<int*>(lua_touserdata(L, -1))) v = *p;
    }
    lua_pop(L, 1);
    // (XLua per-aircraft path also sets up a traceback handler via the same
    // lua_pushtraceback mechanism but stashes the index inside the module*;
    // the auto-generated glue reads it via module::debug_proc_from_interp.
    // We don't reach for that here because adding the module.h dependency
    // would lock this file to the per-aircraft context only — and in
    // practice 0 just means "no traceback", not a crash.)
    return v;
}

// Per-window context held in XPLMCreateWindow_t::refcon. Allocated in the
// create wrapper, freed by XLuaDestroyImguiWindow. Non-copyable and non-movable:
// XPLM holds the raw pointer for the window's whole lifetime, so the address has
// to stay stable.
struct window_ctx final {
    lua_State*                   L;
    std::shared_ptr<notify_cb_t> draw_cb;

    explicit window_ctx(lua_State* in_L) : L(in_L) {}
    ~window_ctx()                            = default;
    window_ctx(window_ctx const&)            = delete;
    window_ctx& operator=(window_ctx const&) = delete;
    window_ctx(window_ctx&&)                 = delete;
    window_ctx& operator=(window_ctx&&)      = delete;
};

void cb_draw(XPLMWindowID win, void* refcon) {
    auto* ctx = static_cast<window_ctx*>(refcon);
    if (ctx == nullptr) return;

    int left, top, right, bottom;
    XPLMGetWindowGeometry(win, &left, &top, &right, &bottom);
    const int w = right - left;
    const int h = top - bottom;

    // Open the imgui frame in C so the plugin's Lua callback is just widget
    // calls — no NewFrame/Render boilerplate. EndFrame fires unconditionally
    // (even on Lua error) to leave imgui in a clean state for the next tick.
    xplm_imgui_begin_frame(ctx->L, w, h, win);
    if (ctx->draw_cb) {
        lua_rawgeti(ctx->L, LUA_REGISTRYINDEX, ctx->draw_cb->callbacks.at("drawWindowFunc"));
        if (lua_isfunction(ctx->L, -1))
        {
            fmt_pcall_stdvars(ctx->L, find_debug_proc(ctx->L), false, "uiir",
                              win, w, h, ctx->draw_cb->get_capture());
        }
    }
    xplm_imgui_end_frame(ctx->L);
}

int cb_mouse_click(XPLMWindowID w, int x, int y, XPLMMouseStatus s, void* rc) {
    auto* ctx = static_cast<window_ctx*>(rc);
    return xplm_imgui_handle_mouse_click(w, x, y, s, ctx ? ctx->L : nullptr);
}

int cb_right_click(XPLMWindowID w, int x, int y, XPLMMouseStatus s, void* rc) {
    auto* ctx = static_cast<window_ctx*>(rc);
    return xplm_imgui_handle_right_click(w, x, y, s, ctx ? ctx->L : nullptr);
}

void cb_key(XPLMWindowID w, char key, XPLMKeyFlags fl, char vk, void* rc, int lf) {
    auto* ctx = static_cast<window_ctx*>(rc);
    xplm_imgui_handle_key(w, key, fl, vk, ctx ? ctx->L : nullptr, lf);
}

XPLMCursorStatus cb_cursor(XPLMWindowID w, int x, int y, void* rc) {
    auto* ctx = static_cast<window_ctx*>(rc);
    return xplm_imgui_handle_cursor(w, x, y, ctx ? ctx->L : nullptr);
}

int cb_mouse_wheel(XPLMWindowID w, int x, int y, int wh, int cl, void* rc) {
    auto* ctx = static_cast<window_ctx*>(rc);
    return xplm_imgui_handle_mouse_wheel(w, x, y, wh, cl, ctx ? ctx->L : nullptr);
}

int field_int(lua_State* L, int tbl, const char* key, int dflt) {
    lua_getfield(L, tbl, key);
    int v = lua_isnil(L, -1) ? dflt : static_cast<int>(luaL_checkinteger(L, -1));
    lua_pop(L, 1);
    return v;
}

bool field_bool(lua_State* L, int tbl, const char* key, bool dflt) {
    lua_getfield(L, tbl, key);
    bool v = lua_isnil(L, -1) ? dflt : (lua_toboolean(L, -1) != 0);
    lua_pop(L, 1);
    return v;
}

std::shared_ptr<notify_cb_t> capture_field_func(lua_State* L, int tbl,
                                                const char* key) {
    lua_getfield(L, tbl, key);
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        return nullptr;
    }
    if (!lua_isfunction(L, -1)) {
        lua_pop(L, 1);
        luaL_error(L, "%s must be a function", key);
        return nullptr;
    }
    auto cb = wrap_lua_func_no_userref(L, -1, key);
    lua_pop(L, 1);

    return cb;
}

void apply_geometry(lua_State* L, int tbl, XPLMCreateWindow_t& p) {
    p.structSize = sizeof(p);
    p.left    = field_int (L, tbl, "left",    100);
    p.top     = field_int (L, tbl, "top",     500);
    p.right   = field_int (L, tbl, "right",   600);
    p.bottom  = field_int (L, tbl, "bottom",  100);
    p.visible = field_bool(L, tbl, "visible", true) ? 1 : 0;
    p.decorateAsFloatingWindow = static_cast<XPLMWindowDecoration>(
        field_int(L, tbl, "decorateAsFloatingWindow",
                  xplm_WindowDecorationRoundRectangle));
    p.layer = static_cast<XPLMWindowLayer>(
        field_int(L, tbl, "layer", xplm_WindowLayerFloatingWindows));
}

int destroy_window(lua_State* L) {
    XPLMWindowID win = xlua_checkuserdata<XPLMWindowID>(L, 1, "Expected XPLMWindowID");
    auto* ctx = static_cast<window_ctx*>(XPLMGetWindowRefCon(win));
    XPLMDestroyWindow(win);
    delete ctx;   // ~window_ctx drops the persisted-callback references
    return 0;
}

} // namespace

// ─────────────────────────────────────────────────────────────────────────────
// Public Lua entry points. extern "C" + exact names so they link against the
// forward declarations emitted into XLua_Register_glue.cpp for the
// lua_impl="external" functions in XPLMDisplay.xml.
// ─────────────────────────────────────────────────────────────────────────────

extern "C" int XLuaCreateImguiWindow(lua_State* L) {
    luaL_checktype(L, 1, LUA_TTABLE);

    XPLMCreateWindow_t p = {};
    apply_geometry(L, 1, p);
    p.windowContentType = xplm_WindowContentTypePanelGraphics;

    auto* ctx = new window_ctx(L);
    ctx->draw_cb = capture_field_func(L, 1, "drawWindowFunc");
    p.refcon = ctx;
    p.drawWindowFunc = ctx->draw_cb ? cb_draw : nullptr;

    // imgui owns the input chain unconditionally — anything the user passed
    // in handleMouseClickFunc etc. is ignored by design. (If a plugin needs
    // its own input on an imgui window, the right answer is a non-imgui
    // window with manual ImGui::GetIO() forwarding, not a hybrid.)
    p.handleMouseClickFunc = cb_mouse_click;
    p.handleRightClickFunc = cb_right_click;
    p.handleKeyFunc        = cb_key;
    p.handleCursorFunc     = cb_cursor;
    p.handleMouseWheelFunc = cb_mouse_wheel;

    XPLMWindowID win = XPLMCreateWindowEx(&p);
    if (win == nullptr) {
        delete ctx;
        lua_pushnil(L);
        return 1;
    }

    Make_XPLMWindowID(L, win);
    return 1;
}

extern "C" int XLuaDestroyImguiWindow(lua_State* L) {
    return destroy_window(L);
}
