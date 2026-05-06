// Implementation moved out of xlua_imgui.cpp's anonymous namespace.
//
// Each public method begins with ImGui::SetCurrentContext(ctx_) so the class
// is safe to use alongside other ImGuiContexts (e.g. one per lua_State plus
// one for the C++ profiler window).

#include "xlua_imgui_context.h"

#include <XPLMDefs.h>
#include <XPLMDisplay.h>
#include <XPLMPanelGraphics.h>

#include <imgui.h>

#include <cfloat>
#include <cstdint>
#include <vector>

namespace {

uint32_t PremultiplyColor(uint32_t c) {
    const uint32_t r = c & 0xFFu;
    const uint32_t g = (c >> 8) & 0xFFu;
    const uint32_t b = (c >> 16) & 0xFFu;
    const uint32_t a = (c >> 24) & 0xFFu;
    const uint32_t pr = (r * a + 127u) / 255u;
    const uint32_t pg = (g * a + 127u) / 255u;
    const uint32_t pb = (b * a + 127u) / 255u;
    return pr | (pg << 8) | (pb << 16) | (a << 24);
}

// Translate global-boxel mouse coords to window-local top-left (the space ImGui works in).
// Returns false if the cursor is outside the window's geometry.
bool TranslateToImguiSpace(XPLMWindowID win, int gx, int gy, float& out_x, float& out_y) {
    if (win == nullptr) return false;
    int left, top, right, bottom;
    XPLMGetWindowGeometry(win, &left, &top, &right, &bottom);
    if (gx < left || gx > right || gy < bottom || gy > top) return false;
    out_x = static_cast<float>(gx - left);
    out_y = static_cast<float>(top - gy);
    return true;
}

// Mirrors source_code/core/ui/imgui_impl_xsystem.cpp:127.
ImGuiKey XPLM_VK_to_ImGuiKey(int vkey) {
    switch (vkey) {
        case XPLM_VK_TAB:       return ImGuiKey_Tab;
        case XPLM_VK_LEFT:      return ImGuiKey_LeftArrow;
        case XPLM_VK_RIGHT:     return ImGuiKey_RightArrow;
        case XPLM_VK_UP:        return ImGuiKey_UpArrow;
        case XPLM_VK_DOWN:      return ImGuiKey_DownArrow;
        case XPLM_VK_HOME:      return ImGuiKey_Home;
        case XPLM_VK_END:       return ImGuiKey_End;
        case XPLM_VK_INSERT:    return ImGuiKey_Insert;
        case XPLM_VK_DELETE:    return ImGuiKey_Delete;
        case XPLM_VK_BACK:      return ImGuiKey_Backspace;
        case XPLM_VK_SPACE:     return ImGuiKey_Space;
        case XPLM_VK_ENTER:     return ImGuiKey_Enter;
        case XPLM_VK_ESCAPE:    return ImGuiKey_Escape;
        case XPLM_VK_0:         return ImGuiKey_0;
        case XPLM_VK_1:         return ImGuiKey_1;
        case XPLM_VK_2:         return ImGuiKey_2;
        case XPLM_VK_3:         return ImGuiKey_3;
        case XPLM_VK_4:         return ImGuiKey_4;
        case XPLM_VK_5:         return ImGuiKey_5;
        case XPLM_VK_6:         return ImGuiKey_6;
        case XPLM_VK_7:         return ImGuiKey_7;
        case XPLM_VK_8:         return ImGuiKey_8;
        case XPLM_VK_9:         return ImGuiKey_9;
        case XPLM_VK_A: return ImGuiKey_A; case XPLM_VK_B: return ImGuiKey_B;
        case XPLM_VK_C: return ImGuiKey_C; case XPLM_VK_D: return ImGuiKey_D;
        case XPLM_VK_E: return ImGuiKey_E; case XPLM_VK_F: return ImGuiKey_F;
        case XPLM_VK_G: return ImGuiKey_G; case XPLM_VK_H: return ImGuiKey_H;
        case XPLM_VK_I: return ImGuiKey_I; case XPLM_VK_J: return ImGuiKey_J;
        case XPLM_VK_K: return ImGuiKey_K; case XPLM_VK_L: return ImGuiKey_L;
        case XPLM_VK_M: return ImGuiKey_M; case XPLM_VK_N: return ImGuiKey_N;
        case XPLM_VK_O: return ImGuiKey_O; case XPLM_VK_P: return ImGuiKey_P;
        case XPLM_VK_Q: return ImGuiKey_Q; case XPLM_VK_R: return ImGuiKey_R;
        case XPLM_VK_S: return ImGuiKey_S; case XPLM_VK_T: return ImGuiKey_T;
        case XPLM_VK_U: return ImGuiKey_U; case XPLM_VK_V: return ImGuiKey_V;
        case XPLM_VK_W: return ImGuiKey_W; case XPLM_VK_X: return ImGuiKey_X;
        case XPLM_VK_Y: return ImGuiKey_Y; case XPLM_VK_Z: return ImGuiKey_Z;
        case XPLM_VK_F1:  return ImGuiKey_F1;  case XPLM_VK_F2:  return ImGuiKey_F2;
        case XPLM_VK_F3:  return ImGuiKey_F3;  case XPLM_VK_F4:  return ImGuiKey_F4;
        case XPLM_VK_F5:  return ImGuiKey_F5;  case XPLM_VK_F6:  return ImGuiKey_F6;
        case XPLM_VK_F7:  return ImGuiKey_F7;  case XPLM_VK_F8:  return ImGuiKey_F8;
        case XPLM_VK_F9:  return ImGuiKey_F9;  case XPLM_VK_F10: return ImGuiKey_F10;
        case XPLM_VK_F11: return ImGuiKey_F11; case XPLM_VK_F12: return ImGuiKey_F12;
        case XPLM_VK_F13: return ImGuiKey_F13; case XPLM_VK_F14: return ImGuiKey_F14;
        case XPLM_VK_F15: return ImGuiKey_F15; case XPLM_VK_F16: return ImGuiKey_F16;
        case XPLM_VK_F17: return ImGuiKey_F17; case XPLM_VK_F18: return ImGuiKey_F18;
        case XPLM_VK_F19: return ImGuiKey_F19; case XPLM_VK_F20: return ImGuiKey_F20;
        case XPLM_VK_F21: return ImGuiKey_F21; case XPLM_VK_F22: return ImGuiKey_F22;
        case XPLM_VK_F23: return ImGuiKey_F23; case XPLM_VK_F24: return ImGuiKey_F24;
        case XPLM_VK_QUOTE:     return ImGuiKey_Apostrophe;
        case XPLM_VK_COMMA:     return ImGuiKey_Comma;
        case XPLM_VK_MINUS:     return ImGuiKey_Minus;
        case XPLM_VK_PERIOD:    return ImGuiKey_Period;
        case XPLM_VK_SLASH:     return ImGuiKey_Slash;
        case XPLM_VK_SEMICOLON: return ImGuiKey_Semicolon;
        case XPLM_VK_EQUAL:     return ImGuiKey_Equal;
        case XPLM_VK_LBRACE:    return ImGuiKey_LeftBracket;
        case XPLM_VK_RBRACE:    return ImGuiKey_RightBracket;
        case XPLM_VK_BACKSLASH: return ImGuiKey_Backslash;
    }
    return ImGuiKey_None;
}

} // namespace

XplmImguiContext::XplmImguiContext() {
    ctx_ = ImGui::CreateContext();
    ImGui::SetCurrentContext(ctx_);
    auto& io = ImGui::GetIO();
    io.IniFilename = nullptr;
    io.ConfigMacOSXBehaviors = false;
    io.BackendFlags |= ImGuiBackendFlags_RendererHasVtxOffset;

    // Font atlas: ImGui produces a coverage map; XPLMCreateTexture wants RGBA8
    // pre-multiplied. RGB = A produces (a,a,a,a) — straight-alpha "white with
    // coverage" expressed in pre-multiplied form.
    uint8_t* pixels = nullptr;
    int w = 0, h = 0;
    io.Fonts->GetTexDataAsAlpha8(&pixels, &w, &h);
    std::vector<uint8_t> rgba(static_cast<size_t>(w) * h * 4);
    for (int i = 0; i < w * h; ++i) {
        const uint8_t a = pixels[i];
        rgba[i * 4 + 0] = a;
        rgba[i * 4 + 1] = a;
        rgba[i * 4 + 2] = a;
        rgba[i * 4 + 3] = a;
    }
    font_tex_ = XPLMCreateTexture(rgba.data(), w, h);
    io.Fonts->TexID = reinterpret_cast<ImTextureID>(font_tex_);
}

XplmImguiContext::~XplmImguiContext() {
    if (font_tex_ != nullptr) {
        XPLMDestroyTexture(font_tex_);
        font_tex_ = nullptr;
    }
    if (ctx_ != nullptr) {
        ImGui::DestroyContext(ctx_);
        ctx_ = nullptr;
    }
}

void XplmImguiContext::BeginFrame(int display_width, int display_height, XPLMWindowID win) {
    ImGui::SetCurrentContext(ctx_);
    cur_win_ = win;
    auto& io = ImGui::GetIO();
    io.DisplaySize = ImVec2(static_cast<float>(display_width), static_cast<float>(display_height));
    io.DisplayFramebufferScale = ImVec2(1.0f, 1.0f);

    // Mouse tracking: poll global cursor every frame and emit either a
    // window-local position or "outside" so ImGui's hover state matches reality
    // even when the cursor leaves the window without a final cursor callback.
    if (win != nullptr) {
        int gx = 0, gy = 0;
        XPLMGetMouseLocationGlobal(&gx, &gy);
        float lx = 0, ly = 0;
        if (TranslateToImguiSpace(win, gx, gy, lx, ly)) {
            io.AddMousePosEvent(lx, ly);
        } else {
            io.AddMousePosEvent(-FLT_MAX, -FLT_MAX);
        }
    }

    ImGui::NewFrame();
}

void XplmImguiContext::EndFrame() {
    ImGui::SetCurrentContext(ctx_);
    ImGui::Render();

    // Auto-manage keyboard focus. ImGui's WantTextInput is true while an
    // InputText (or similar) widget is active; the host only delivers
    // handleKeyFunc events to a window that holds keyboard focus, so we have
    // to grab it explicitly. Mirrors what XLua's ImGUIIntegration::onDraw
    // does for the FloatingWindow path.
    if (cur_win_ != nullptr) {
        const bool want_text = ImGui::GetIO().WantTextInput;
        if (want_text && !has_focus_) {
            XPLMTakeKeyboardFocus(cur_win_);
            has_focus_ = true;
        } else if (!want_text && has_focus_) {
            XPLMTakeKeyboardFocus(nullptr);
            has_focus_ = false;
        }
    }

    ImDrawData* drawData = ImGui::GetDrawData();
    if (drawData == nullptr || drawData->CmdListsCount == 0) {
        return;
    }

    std::vector<XPLMDrawCall_t> calls;
    for (int n = 0; n < drawData->CmdListsCount; n++) {
        ImDrawList* cmd_list = drawData->CmdLists[n];

        // ImGui emits straight-alpha vertex colors; XPLMDrawCalls expects
        // pre-multiplied (matching the pre-multiplied font atlas above).
        for (int v = 0; v < cmd_list->VtxBuffer.Size; ++v) {
            cmd_list->VtxBuffer.Data[v].col =
                PremultiplyColor(cmd_list->VtxBuffer.Data[v].col);
        }

        XPLMMesh_t mesh{};
        mesh.vertex_count = cmd_list->VtxBuffer.Size;
        mesh.vertices = reinterpret_cast<const float*>(cmd_list->VtxBuffer.Data);
        mesh.index_count = cmd_list->IdxBuffer.Size;
        mesh.indices = reinterpret_cast<const uint16_t*>(cmd_list->IdxBuffer.Data);

        calls.clear();
        calls.reserve(cmd_list->CmdBuffer.Size);
        for (int cmd_i = 0; cmd_i < cmd_list->CmdBuffer.Size; cmd_i++) {
            const ImDrawCmd& pcmd = cmd_list->CmdBuffer[cmd_i];
            if (pcmd.UserCallback != nullptr) {
                pcmd.UserCallback(cmd_list, &pcmd);
                continue;
            }
            if (pcmd.ElemCount == 0) {
                continue;
            }
            XPLMDrawCall_t dc{};
            // ImDrawCmd::TextureId became ImDrawCmd::GetTexID() in imgui 1.92.0
            // (texture-management refactor); the legacy field was removed.
            dc.tex_ref = reinterpret_cast<void*>(static_cast<uintptr_t>(pcmd.GetTexID()));
            dc.scissors[0] = pcmd.ClipRect.x;
            dc.scissors[1] = pcmd.ClipRect.y;
            dc.scissors[2] = pcmd.ClipRect.z;
            dc.scissors[3] = pcmd.ClipRect.w;
            dc.idx_offset = static_cast<int>(pcmd.IdxOffset);
            dc.element_count = static_cast<int>(pcmd.ElemCount);
            dc.vtx_offset = static_cast<int>(pcmd.VtxOffset);
            calls.push_back(dc);
        }

        if (!calls.empty()) {
            XPLMDrawCalls(&mesh, static_cast<int>(calls.size()), calls.data());
        }
    }
}

int XplmImguiContext::OnMouseButton(XPLMWindowID win, int x, int y, XPLMMouseStatus status, int button) {
    ImGui::SetCurrentContext(ctx_);
    auto& io = ImGui::GetIO();
    float lx = 0, ly = 0;
    if (TranslateToImguiSpace(win, x, y, lx, ly)) {
        io.AddMousePosEvent(lx, ly);
    }
    if (status == xplm_MouseDown) {
        io.AddMouseButtonEvent(button, true);
    } else if (status == xplm_MouseUp) {
        io.AddMouseButtonEvent(button, false);
    }
    // Drag updates position only — already done above.
    return io.WantCaptureMouse ? 1 : 0;
}

int XplmImguiContext::OnMouseWheel(XPLMWindowID win, int x, int y, int wheel, int clicks) {
    ImGui::SetCurrentContext(ctx_);
    auto& io = ImGui::GetIO();
    float lx = 0, ly = 0;
    if (TranslateToImguiSpace(win, x, y, lx, ly)) {
        io.AddMousePosEvent(lx, ly);
    }
    io.AddMouseWheelEvent(wheel == 1 ? static_cast<float>(clicks) : 0.0f,
                          wheel == 0 ? static_cast<float>(clicks) : 0.0f);
    return io.WantCaptureMouse ? 1 : 0;
}

void XplmImguiContext::OnKey(char key, XPLMKeyFlags flags, char vkey, int losing_focus) {
    ImGui::SetCurrentContext(ctx_);
    auto& io = ImGui::GetIO();

    // Losing-focus notification: drop pressed-key state so a key held while
    // focus left this window doesn't stay "down" inside ImGui forever.
    if (losing_focus) {
        io.ClearInputKeys();
        io.AddKeyEvent(ImGuiMod_Shift, false);
        io.AddKeyEvent(ImGuiMod_Ctrl,  false);
        io.AddKeyEvent(ImGuiMod_Alt,   false);
        has_focus_ = false;
        return;
    }

    io.AddKeyEvent(ImGuiMod_Shift, (flags & xplm_ShiftFlag) != 0);
    io.AddKeyEvent(ImGuiMod_Ctrl,  (flags & xplm_ControlFlag) != 0);
    io.AddKeyEvent(ImGuiMod_Alt,   (flags & xplm_OptionAltFlag) != 0);

    // XPLM dispatches three flavours of key callback:
    //   Down   = initial press        (xplm_DownFlag)
    //   Up     = release              (xplm_UpFlag)
    //   Repeat = OS auto-repeat       (neither flag set; gfx_window_cocoa.mm:452
    //            deliberately strips xplm_DownFlag for isARepeat events)
    const bool is_down   = (flags & xplm_DownFlag) != 0;
    const bool is_up     = (flags & xplm_UpFlag)   != 0;
    const bool is_repeat = !is_down && !is_up;

    const ImGuiKey ik = XPLM_VK_to_ImGuiKey(static_cast<unsigned char>(vkey));
    if (ik != ImGuiKey_None) {
        if (is_down)        io.AddKeyEvent(ik, true);
        else if (is_up)     io.AddKeyEvent(ik, false);
        // Repeat: leave the key state alone. The initial Down already told
        // ImGui the key is held; its own KeyRepeatDelay/Rate timers drive
        // non-text repeat (Backspace, arrows, Delete in InputText).
    }
    // Forward typed characters on Down AND Repeat so InputText sees the
    // OS-auto-repeated 'aaaaa…' stream when a printable key is held.
    const unsigned char ukey = static_cast<unsigned char>(key);
    if ((is_down || is_repeat) && ukey >= 0x20 && ukey < 0x7f) {
        io.AddInputCharacter(static_cast<unsigned int>(ukey));
    }
}

int XplmImguiContext::HandleMouseClick(XPLMWindowID win, int x, int y, XPLMMouseStatus status, void* refcon) {
    auto* self = static_cast<XplmImguiContext*>(refcon);
    if (self == nullptr) return 0;
    return self->OnMouseButton(win, x, y, status, 0);
}

int XplmImguiContext::HandleRightClick(XPLMWindowID win, int x, int y, XPLMMouseStatus status, void* refcon) {
    auto* self = static_cast<XplmImguiContext*>(refcon);
    if (self == nullptr) return 0;
    return self->OnMouseButton(win, x, y, status, 1);
}

int XplmImguiContext::HandleMouseWheel(XPLMWindowID win, int x, int y, int wheel, int clicks, void* refcon) {
    auto* self = static_cast<XplmImguiContext*>(refcon);
    if (self == nullptr) return 0;
    return self->OnMouseWheel(win, x, y, wheel, clicks);
}

XPLMCursorStatus XplmImguiContext::HandleCursor(XPLMWindowID, int, int, void*) {
    // Position update happens in BeginFrame; the cursor callback only needs to
    // tell X-Plane what cursor to show. Default = let X-Plane pick.
    return xplm_CursorDefault;
}

void XplmImguiContext::HandleKey(XPLMWindowID, char key, XPLMKeyFlags flags, char vkey, void* refcon, int losingFocus) {
    auto* self = static_cast<XplmImguiContext*>(refcon);
    if (self == nullptr) return;
    self->OnKey(key, flags, vkey, losingFocus);
}
