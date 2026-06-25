// KEEP IN SYNC WITH XPLMDisplay.xml: these hand-written bodies back the
// lua_impl="external" window-helper declarations there. A missing/renamed impl
// fails the link — but the XML's params/return/desc (which become the published
// EmmyLua docs) are NOT checked, so if you change what a function takes or returns
// here, update the XML too or the docs silently go stale.
//
// XLuaCreateImguiWindow / XLuaCreateBrowserWindow — XLua-2-only convenience
// constructors that wrap XPLMCreateWindowEx with content-type-specific
// defaults and pre-installed handlers. See header for the registration
// contract; rationale for hiding XPLMCreateWindowEx itself lives in the
// exclude="lua" comment on the XPLMDisplay.xml master.
//
// These four functions are declared in XPLMDisplay.xml with lua_impl="external"
// and exclude="c|pascal|php", so header_parser does NOT auto-generate their
// bodies — it only emits the EmmyLua type stub and a registration entry in the
// generated XLua_Register_glue.cpp that points at the hand-written extern "C"
// definitions below. The generated forward declaration must match these
// signatures exactly, so any drift becomes a link/compile error.

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
// create wrappers, freed by XLuaDestroyImguiWindow / XLuaDestroyBrowserWindow.
// Non-copyable and non-movable: XPLM holds the raw pointer for the window's
// whole lifetime, so the address has to stay stable.
struct window_ctx final {
    lua_State*                   L;
    std::shared_ptr<notify_cb_t> draw_cb;
    std::shared_ptr<notify_cb_t> browser_nav_cb;

    explicit window_ctx(lua_State* in_L) : L(in_L) {}

    ~window_ctx() {
        // Drop the per-VM s_RegisteredCallbacks references so the captured
        // Lua functions can be GC'd. The map holds shared_ptrs and would
        // otherwise keep them alive (and count against the 500-entry cap in
        // shared_xpfuncs.cpp) for the script's whole lifetime.
        if (draw_cb)        xlua_remove_callback(draw_cb);
        if (browser_nav_cb) xlua_remove_callback(browser_nav_cb);
    }

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
        lua_State* L = setup_lua_callback(ctx->draw_cb.get(), "drawWindowFunc");
        if (L) {
            fmt_pcall_stdvars(L, find_debug_proc(L), false, "uiir",
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

void cb_browser_nav(XPLMWindowID win, const char* url,
                    int success, const char* err, void* refcon) {
    auto* ctx = static_cast<window_ctx*>(refcon);
    if (ctx == nullptr || ctx->browser_nav_cb == nullptr) return;
    lua_State* L = setup_lua_callback(ctx->browser_nav_cb.get(),
                                      "browserNavigationFunc");
    if (L == nullptr) return;
    fmt_pcall_stdvars(L, find_debug_proc(L), false, "usbsr",
                      win, url, static_cast<bool>(success), err,
                      ctx->browser_nav_cb->get_capture());
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
    auto cb = wrap_lua_func(L, -1, /*optional=*/false, key);
    lua_pop(L, 1);
    if (cb) xlua_persist_userref(L, cb);
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

// Shared destroyer for both imgui and browser windows. The bodies are
// identical (read ctx out of the refcon, destroy the window, delete ctx); the
// only reason we expose two Lua names is API symmetry with the two
// constructors and script-side legibility.
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

extern "C" int XLuaCreateBrowserWindow(lua_State* L) {
    luaL_checktype(L, 1, LUA_TTABLE);

    XPLMCreateWindow_t p = {};
    apply_geometry(L, 1, p);
    p.windowContentType = xplm_WindowContentTypeBrowser;
    // CEF routes input itself; no Lua-side handlers are wired.

    auto* ctx = new window_ctx(L);
    ctx->browser_nav_cb = capture_field_func(L, 1, "browserNavigationFunc");
    p.refcon = ctx;
    p.browserNavigationFunc = ctx->browser_nav_cb ? cb_browser_nav : nullptr;

    lua_getfield(L, 1, "url");
    const char* url = lua_isstring(L, -1) ? lua_tostring(L, -1) : nullptr;
    // Copy the string out before any potential GC; XPLMWindowSetURL takes
    // const char* and copies internally, but the Lua VM owns the underlying
    // storage and could collect it once we pop. So load it eagerly here and
    // pop after the create call below.

    XPLMWindowID win = XPLMCreateWindowEx(&p);
    if (win == nullptr) {
        lua_pop(L, 1); // url
        delete ctx;
        lua_pushnil(L);
        return 1;
    }

    if (url != nullptr) {
        XPLMWindowSetURL(win, url);
    }
    lua_pop(L, 1); // url

    Make_XPLMWindowID(L, win);
    return 1;
}

extern "C" int XLuaDestroyImguiWindow(lua_State* L) {
    return destroy_window(L);
}

extern "C" int XLuaDestroyBrowserWindow(lua_State* L) {
    return destroy_window(L);
}
