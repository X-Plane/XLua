--[[ XLua 2.0 ]]
-- Makes an imgui window with XLuaCreateImguiWindow, and destroys it in XPluginDisable. The draw callback
-- counts its calls.

local draws = 0
local window

function XPluginStart()
	return true
end

function XPluginEnable()
	window = XLuaCreateImguiWindow({ left = 100, top = 400, right = 300, bottom = 200,
		drawWindowFunc = function() draws = draws + 1 end })
	XPLMRegisterDataAccessor("xluatest/window/draws", XPLMDataTypeID.xplmType_Int, false,
		function() return draws end, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
	return true
end

function XPluginDisable()
	XLuaDestroyImguiWindow(window)
end
