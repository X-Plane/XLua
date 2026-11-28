--[[ XLua 2.0 ]]
-- A plain script that runs next to the script under test. Its command handler counts its calls.

local calls = 0

function XPluginStart()
	return true
end

function XPluginEnable()
	XPLMRegisterCommandHandler(XPLMCreateCommand("xluatest/second/command", "second script"),
		function(cmd, phase)
			if phase == XPLMCommandPhase.xplm_CommandBegin then calls = calls + 1 end
			return true
		end, true, nil)
	XPLMRegisterDataAccessor("xluatest/second/command_calls", XPLMDataTypeID.xplmType_Int, false,
		function() return calls end, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
	return true
end
