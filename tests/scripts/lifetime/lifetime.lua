--[[ XLua 2.0 ]]
-- Registers one callback of each kind: a flight loop, a dataref accessor, a command handler and a timer.
-- The command xluatest/lifetime/unregister makes the script unregister all four. After that, a callback
-- that runs writes a FAIL line.

local calls = { loop = 0, command = 0, timer = 0 }
local unregistered = false
local loop, value_ref, command, timer

local function ran(kind)
	if unregistered then
		XPLMDebugString("XLUATEST lifetime: FAIL the " .. kind .. " ran after it was unregistered\n")
	end
end

local function on_command(cmd, phase, refcon)
	ran("command handler")
	if phase == XPLMCommandPhase.xplm_CommandBegin then calls.command = calls.command + 1 end
	return true
end

local function counter(kind)
	return XPLMRegisterDataAccessor("xluatest/lifetime/" .. kind .. "_calls", XPLMDataTypeID.xplmType_Int, false,
		function() return calls[kind] end, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
end

function XPluginStart()
	return true
end

function XPluginEnable()
	loop = XPLMCreateFlightLoop({
		phase = XPLMFlightLoopPhaseType.xplm_FlightLoop_Phase_AfterFlightModel,
		refcon = nil,
		callbackFunc = function()
			ran("flight loop")
			calls.loop = calls.loop + 1
			return -1
		end })
	XPLMScheduleFlightLoop(loop, -1, true)

	value_ref = XPLMRegisterDataAccessor("xluatest/lifetime/value", XPLMDataTypeID.xplmType_Int, false,
		function() ran("dataref accessor") return 42 end, nil,
		nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)

	command = XPLMCreateCommand("xluatest/lifetime/command", "lifetime test")
	XPLMRegisterCommandHandler(command, on_command, true, nil)

	timer = XLuaCreateTimer(function()
		ran("timer")
		calls.timer = calls.timer + 1
	end)
	XLuaRunTimer(timer, 0.05, 0.05)

	counter("loop")
	counter("command")
	counter("timer")

	XPLMRegisterCommandHandler(XPLMCreateCommand("xluatest/lifetime/unregister", "unregister all"),
		function(cmd, phase)
			if phase == XPLMCommandPhase.xplm_CommandBegin then
				XPLMDestroyFlightLoop(loop)
				XPLMUnregisterDataAccessor(value_ref)
				XPLMUnregisterCommandHandler(command, on_command, true, nil)
				XLuaRunTimer(timer, -1, -1)
				unregistered = true
			end
			return true
		end, true, nil)
	return true
end
