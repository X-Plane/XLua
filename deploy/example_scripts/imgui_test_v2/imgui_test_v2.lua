-- imgui_test_v2.lua
--
-- ImGui-on-panel-graphics test plugin written against the XPLM API directly.
-- Loadable two ways without modification:
--   * As an XLua module: place this file at scripts/imgui_test_v2/imgui_test_v2.lua
--     (XLua's discovery scans scripts/<name>/<name>.lua).
--   * As a host-loaded Lua plugin: place this file at
--     Resources/plugins/imgui_test_v2/main.lua (DEV builds only).
--
-- The window is a panel-graphics window; widgets are issued between explicit
-- imgui.NewFrame(width, height) and imgui.Render() calls. imgui.Render() walks
-- ImDrawData and calls XPLMDrawCalls under the hood — no FloatingWindow shim.
--
-- imgui_test_v2 mirrors the widget breadth of XLua's older imgui_test.lua
-- (text, buttons, sliders, table, draw-list lines, styled text).

-- ─────────────────────────────────────────────────────────────────────────────
-- XPLM enum values (not auto-registered as Lua globals; use the raw integers
-- from XPLMDisplay.h). See the comments alongside each constant if changing.
-- ─────────────────────────────────────────────────────────────────────────────
local XPLM = {
    WindowLayerFloatingWindows         = 1,
    WindowDecorationRoundRectangle     = 1,
    WindowContentTypePanelGraphics     = 1,
    CursorDefault                      = 0,
}

local g_window  = nil
local g_counter = 0
local g_slider  = 0.5
local g_check   = false
local g_color   = { 0.4, 0.7, 1.0, 1.0 }
local g_tab     = 1
local g_in_int  = 0
local g_in_flt  = 1.5

local function draw_window(win_id, refcon)
    -- Window geometry → ImGui DisplaySize. Coordinates are window-local
    -- (top-left origin); the host translates against the panel-graphics origin.
    -- XPLMGetWindowGeometry returns a single table with the four out params.
    local geom = XPLMGetWindowGeometry(win_id)
    local w = geom.outRight - geom.outLeft
    local h = geom.outTop - geom.outBottom

    imgui.NewFrame(w, h, win_id)

    -- Fill the entire window with one ImGui::Begin window so widget positions
    -- come out predictable.
    imgui.SetNextWindowPos(0, 0)
    imgui.SetNextWindowSize(w, h)
    if imgui.Begin("imgui_test_v2") then
        if imgui.BeginTabBar("tabs") then
            if imgui.BeginTabItem("widgets") then
                g_tab = 1
                imgui.TextUnformatted("Hello from Lua!")
                if imgui.Button("Click me") then
                    g_counter = g_counter + 1
                end
                imgui.SameLine()
                imgui.TextUnformatted(string.format("clicks: %d", g_counter))

                -- SliderFloat / Checkbox return (changed_bool, new_value).
                local _, sv = imgui.SliderFloat("slider", g_slider, 0.0, 1.0, "%.3f")
                g_slider = sv
                local _, cv = imgui.Checkbox("checkbox", g_check)
                g_check = cv

                -- Text input — keyboard focus is auto-managed: clicking these
                -- widgets makes ImGui set io.WantTextInput=true, which the
                -- host-side wrapper translates to XPLMTakeKeyboardFocus.
                local _, iv = imgui.InputInt("input int", g_in_int)
                g_in_int = iv
                local _, fv = imgui.InputFloat("input float", g_in_flt, 0.1, 1.0, "%.3f")
                g_in_flt = fv

                imgui.PushStyleColor(imgui.constant.Col.Text,
                    imgui.GetColorU32_1(g_color[1], g_color[2], g_color[3], g_color[4]))
                imgui.TextUnformatted(string.format(
                    "styled text: r=%.2f g=%.2f b=%.2f a=%.2f",
                    g_color[1], g_color[2], g_color[3], g_color[4]))
                imgui.PopStyleColor()

                imgui.EndTabItem()
            end

            if imgui.BeginTabItem("table") then
                g_tab = 2
                if imgui.BeginTable("metrics", 2, imgui.constant.TableFlags.Borders) then
                    imgui.TableNextRow() ; imgui.TableNextColumn()
                    imgui.Text("counter") ; imgui.TableNextColumn()
                    imgui.Text(tostring(g_counter))

                    imgui.TableNextRow() ; imgui.TableNextColumn()
                    imgui.Text("slider")  ; imgui.TableNextColumn()
                    imgui.Text(string.format("%.3f", g_slider))

                    imgui.TableNextRow() ; imgui.TableNextColumn()
                    imgui.Text("checkbox") ; imgui.TableNextColumn()
                    imgui.Text(g_check and "true" or "false")

                    imgui.EndTable()
                end
                imgui.EndTabItem()
            end

            if imgui.BeginTabItem("draw list") then
                g_tab = 3
                imgui.TextUnformatted("Lines drawn straight to the window's draw list:")
                local cx, cy = imgui.GetCursorScreenPos()
                local color  = imgui.GetColorU32_1(1.0, 0.6, 0.2, 1.0)
                for i = 0, 7 do
                    imgui.DrawList_AddLine(
                        cx + i * 30, cy,
                        cx + i * 30 + 100, cy + 80,
                        color, 2)
                end
                imgui.Dummy(300, 90)
                imgui.EndTabItem()
            end

            imgui.EndTabBar()
        end
    end
    imgui.End()

    imgui.Render()
end

-- Drop-in mouse/keyboard handlers from imgui_lua_bindings — each has the exact
-- signature of the corresponding XPLMCreateWindow_t callback field.

function XPluginStart()
    g_window = XPLMCreateWindowEx({
        left   = 100,
        top    = 600,
        right  = 600,
        bottom = 200,
        visible                  = true,
        drawWindowFunc           = draw_window,
        handleMouseClickFunc     = imgui.HandleMouseClick,
        handleRightClickFunc     = imgui.HandleMouseRightClick,
        handleKeyFunc            = imgui.HandleKey,
        handleCursorFunc         = imgui.HandleCursor,
        handleMouseWheelFunc     = imgui.HandleMouseWheel,
        layer                    = XPLM.WindowLayerFloatingWindows,
        decorateAsFloatingWindow = XPLM.WindowDecorationRoundRectangle,
        windowContentType        = XPLM.WindowContentTypePanelGraphics,
    })
    XPLMSetWindowTitle(g_window, "imgui_test_v2")
    return "imgui_test_v2", "com.x-plane.test.imgui-lua-v2", "Lua imgui test plugin"
end

function XPluginEnable()
    return 1
end

function XPluginDisable()
end

function XPluginStop()
    if g_window ~= nil then
        XPLMDestroyWindow(g_window)
        g_window = nil
    end
end

function XPluginReceiveMessage(from, msg, param)
end
