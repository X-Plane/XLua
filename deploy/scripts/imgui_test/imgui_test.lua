--[[ XLua 2.0 ]]

local simDR_flight_time = XPLMFindDataRef("sim/time/total_flight_time_sec")

if not SUPPORTS_FLOATING_WINDOWS then
    print("imgui not supported")
else
    -- See https://github.com/casssoft/imgui_lua_bindings
    function closed_hello_world(wnd)
        local _ = wnd -- Reference to window, which triggered the call.
        -- This function is called when the user closes the window. Drawing or calling imgui
        -- functions is not allowed in this function as the window is already destroyed.
        print("imgui window closed")
    end
    -- Example below is identical to the above, but passes references to callback functions instead of their names.
    -- This allows using non-global and even anonymous functions to handle window events.
    lastClickX3 = 200 / 2
    lastClickY3 = 100 / 2
    local function ihd2_on_build(wnd, x, y)
        imgui.TextUnformatted(string.format("Hello World from callback:\n  wnd=%s\n  x=%d\n  y=%d", wnd, x, y))
        local line_y_inc = 50
        -- Drawing is 0-top, +ve down; click is 0-bottom, +ve up.
        local win_height = imgui.GetWindowHeight()
        imgui.DrawList_AddLine(0, 0, lastClickX3, win_height - lastClickY3, imgui.GetColorU32_1(1,0,0,0.75), 2)
        imgui.SetCursorPos(lastClickX3, (win_height - lastClickY3) + (line_y_inc * 1))
        imgui.PushStyleColor(imgui.constant.Col.Text, imgui.GetColorU32_1(1,1,0,1))
        imgui.TextUnformatted("Line One")
        imgui.TextUnformatted("Line Two")
        imgui.PopStyleColor()
        if imgui.BeginTable("table1", 2, imgui.constant.TableFlags.Borders) then
            imgui.TableNextRow()
            imgui.TableNextColumn()
            imgui.Text("sim_flight_time")
            imgui.TableNextColumn()
            imgui.Text("" .. XPLMGetDataf(simDR_flight_time))
            for r = 1,5 do
                imgui.TableNextRow()
                imgui.TableNextColumn()
                imgui.Text("Row " .. r)
                imgui.TableNextColumn()
                imgui.Text("Value")
            end
            imgui.EndTable()
        end
    end
    local function on_click_floating_window(wnd, x3, y3)
--      print("Click at " .. x3 .. ", " .. y3)
        lastClickX3 = x3
        lastClickY3 = y3
    end
    ihd_wnd2 = float_wnd_create(500, 300, 1, true)
    float_wnd_set_position(ihd_wnd2, 400, 500)
    float_wnd_set_title(ihd_wnd2, "Imgui Hello World 2")
    float_wnd_set_imgui_builder(ihd_wnd2, ihd2_on_build)
    float_wnd_set_onclick(ihd_wnd2, on_click_floating_window)
end
