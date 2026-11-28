--[[ XLua 2.0 ]]
-- An XLua 2 script starts, and its flight loop runs with its refcon.

local calls = 0
local refcon_ok = true

function XPluginStart()
	return true
end

function XPluginEnable()
	local loop = XPLMCreateFlightLoop({
		phase = XPLMFlightLoopPhaseType.xplm_FlightLoop_Phase_AfterFlightModel,
		refcon = "start_v2",
		callbackFunc = function(since_last_call, since_last_loop, counter, refcon)
			calls = calls + 1
			refcon_ok = refcon_ok and refcon == "start_v2"
			if calls == 3 then
				local pass = refcon_ok and 1 or 0
				XPLMDebugString("XLUATEST start_v2: DONE pass=" .. pass .. " fail=" .. (1 - pass) .. "\n")
				return 0
			end
			return -1
		end })
	XPLMScheduleFlightLoop(loop, -1, true)
	return true
end
