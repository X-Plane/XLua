#ifndef XLUA_IMGUI_CONTEXT_H_
#define XLUA_IMGUI_CONTEXT_H_

// Lua-free C++ ImGui-on-XPLM driver. Owns one ImGuiContext + the XPLM-side font
// texture, and exposes BeginFrame/EndFrame plus drop-in static thunks matching
// every XPLMCreateWindow_t callback signature (refcon must be the context*).
//
// Two consumers share this class today:
//   - src/xlua.cpp's profiler window (one instance per window, refcon = this)
//   - src/xlua_imgui.cpp's Lua bindings (one instance per lua_State, stored as
//     userdata in the Lua registry)
//
// Discipline: every public method calls ImGui::SetCurrentContext on its own
// ctx_ first, so multiple contexts can coexist (Lua-driven UI and the profiler
// running side by side).

#include <XPLMDisplay.h>

struct ImGuiContext;

class XplmImguiContext {
public:
    XplmImguiContext();
    ~XplmImguiContext();
    XplmImguiContext(const XplmImguiContext&) = delete;
    XplmImguiContext& operator=(const XplmImguiContext&) = delete;

    // Frame lifecycle. Call BeginFrame at the top of XPLMDrawWindow_f and
    // EndFrame after issuing widgets; EndFrame walks ImDrawData and dispatches
    // XPLMDrawCalls.
    void BeginFrame(int display_width, int display_height, XPLMWindowID win);
    void EndFrame();

    // Drop-ins for XPLMCreateWindow_t callback fields. Pass a XplmImguiContext*
    // as the window's refcon and these can be wired up directly.
    static int  HandleMouseClick(XPLMWindowID, int x, int y, XPLMMouseStatus, void* refcon);
    static int  HandleRightClick(XPLMWindowID, int x, int y, XPLMMouseStatus, void* refcon);
    static int  HandleMouseWheel(XPLMWindowID, int x, int y, int wheel, int clicks, void* refcon);
    static XPLMCursorStatus HandleCursor(XPLMWindowID, int x, int y, void* refcon);
    static void HandleKey(XPLMWindowID, char key, XPLMKeyFlags, char vkey, void* refcon, int losingFocus);

    // Returns the underlying ImGuiContext* — used by Lua bindings that need to
    // call ImGui APIs (like SetCurrentContext) outside of BeginFrame/EndFrame.
    // Treat as opaque otherwise.
    ImGuiContext* raw_context() const { return ctx_; }

    // Records a mouse-button event (down/up/drag) with proper coordinate
    // translation. Returns 1 if ImGui wants the event consumed.
    int OnMouseButton(XPLMWindowID win, int x, int y, XPLMMouseStatus status, int button);

    // Records a mouse-wheel event with proper coordinate translation. Returns
    // 1 if ImGui wants the event consumed.
    int OnMouseWheel(XPLMWindowID win, int x, int y, int wheel, int clicks);

    // Records a key event (down/up + modifier flags + text input). When
    // losing_focus is non-zero this is the host's "you've just lost keyboard
    // focus" notification — drop the key event and clear ImGui's pressed-key
    // state so a held key isn't stuck.
    void OnKey(char key, XPLMKeyFlags flags, char vkey, int losing_focus = 0);

private:
    // Poll X-Plane's live modifier-key state (XPLMGetModifierKeys, XPLM440) and
    // feed it to ImGui. Must be called with ctx_ already current. The mouse
    // callbacks call this *before* their button/wheel event so the modifier is
    // queued ahead of the click — otherwise modifier state is only fresh while
    // a text widget holds keyboard focus (see OnKey).
    void PushModifiers();

    ImGuiContext* ctx_       = nullptr;
    void*         font_tex_  = nullptr;   // XPLM texture handle
    XPLMWindowID  cur_win_   = nullptr;   // window passed to most recent BeginFrame
    bool          has_focus_ = false;     // last-known result of XPLMTakeKeyboardFocus
};

#endif // XLUA_IMGUI_CONTEXT_H_
