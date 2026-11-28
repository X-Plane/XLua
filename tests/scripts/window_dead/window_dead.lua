--[[ XLua 2.0 ]]
-- Makes an imgui window, and then fails to enable. The draw callback must not run after that.

function XPluginStart()
	return true
end

function XPluginEnable()
	XLuaCreateImguiWindow({ left = 100, top = 400, right = 300, bottom = 200,
		drawWindowFunc = function() XPLMDebugString("XLUATEST window_dead: FAIL the draw callback ran\n") end })
	return false
end
