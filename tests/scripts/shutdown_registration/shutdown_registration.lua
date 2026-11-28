--[[ XLua 2.0 ]]
-- Registers callbacks while it stops: in XPluginDisable and in XPluginStop. XLua closes the script right after,
-- so these callbacks must not run. If one runs, it writes a FAIL line.

local calls = 0
local value_ref

local function register_late(when)
	local function fail(what) XPLMDebugString("XLUATEST shutdown_registration: FAIL the " .. what .. " from " .. when .. " ran\n") end
	XPLMRegisterCommandHandler(XPLMCreateCommand("xluatest/shutdown/command", "shutdown test"),
		function() fail("command handler") return true end, true, nil)
	XLuaRunTimer(XLuaCreateTimer(function() fail("timer") end), 0.05, 0.05)
	XPLMScheduleFlightLoop(XPLMCreateFlightLoop({
		phase = XPLMFlightLoopPhaseType.xplm_FlightLoop_Phase_AfterFlightModel,
		refcon = nil,
		callbackFunc = function() fail("flight loop") return -1 end }), -1, true)
end

function XPluginStart()
	return true
end

function XPluginEnable()
	XPLMRegisterCommandHandler(XPLMCreateCommand("xluatest/shutdown/command", "shutdown test"),
		function(cmd, phase)
			if phase == XPLMCommandPhase.xplm_CommandBegin then calls = calls + 1 end
			return true
		end, true, nil)
	value_ref = XPLMRegisterDataAccessor("xluatest/shutdown/command_calls", XPLMDataTypeID.xplmType_Int, false,
		function() return calls end, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
	return true
end

function XPluginDisable()
	XPLMUnregisterDataAccessor(value_ref)
	register_late("XPluginDisable")
end

function XPluginStop()
	register_late("XPluginStop")
end
