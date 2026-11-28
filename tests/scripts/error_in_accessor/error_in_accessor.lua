--[[ XLua 2.0 ]]
-- A dataref accessor raises an error. The script reads the dataref itself, so the accessor runs inside a
-- Lua call. The log must show the error message of the accessor.

local frame = 0

function XPluginStart()
	XPLMRegisterDataAccessor("xluatest/error_in_accessor/value", XPLMDataTypeID.xplmType_Int, false,
		function() error("this accessor fails on purpose") end, nil,
		nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
	XPLMScheduleFlightLoop(XPLMCreateFlightLoop({
		phase = XPLMFlightLoopPhaseType.xplm_FlightLoop_Phase_AfterFlightModel,
		refcon = nil,
		callbackFunc = function()
			frame = frame + 1
			if frame == 3 then
				local value = XPLMGetDatai(XPLMFindDataRef("xluatest/error_in_accessor/value"))
				XPLMDebugString("XLUATEST error_in_accessor: the read gave " .. tostring(value) .. "\n")
				return 0
			end
			return -1
		end }), -1, true)
	return true
end
