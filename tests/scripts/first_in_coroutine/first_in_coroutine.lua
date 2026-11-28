--[[ XLua 2.0 ]]
-- The first callback of this script is registered inside a coroutine, which the script keeps. Then the
-- main state registers a command handler and a timer. When the script closes, XLua must remove both.

local first

function XPluginStart()
	first = coroutine.create(function()
		XPLMCreateFlightLoop({
			phase = XPLMFlightLoopPhaseType.xplm_FlightLoop_Phase_AfterFlightModel,
			refcon = nil,
			callbackFunc = function() return 0 end })
	end)
	coroutine.resume(first)

	XPLMRegisterCommandHandler(XPLMCreateCommand("xluatest/first_in_coroutine/command", "first in coroutine"),
		function() XPLMDebugString("XLUATEST first_in_coroutine: the command handler ran\n") return true end, true, nil)
	XLuaRunTimer(XLuaCreateTimer(function()
		XPLMDebugString("XLUATEST first_in_coroutine: the timer ran\n")
	end), 0.05, 0.05)
	return true
end
