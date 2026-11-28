--[[ XLua 2.0 ]]
-- A script whose XPluginEnable returns false.
-- Registers a dataref, a command handler, a timer and a callout, and then fails. After the failure, XLua must
-- run none of them. The dataref and the command stay registered with XPLM, so the dataref must read zero and
-- the command must go on to the next handler.
local function fail(what) XPLMDebugString("XLUATEST dead: FAIL the " .. what .. " ran\n") end

local function register()
	XPLMRegisterDataAccessor("xluatest/dead/value", XPLMDataTypeID.xplmType_Int, false,
		function() fail("dataref accessor") return 7 end, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
	XPLMRegisterCommandHandler(XPLMCreateCommand("xluatest/dead/command", "dead script"),
		function() fail("command handler") return false end, true, nil)
	XLuaRunTimer(XLuaCreateTimer(function() fail("timer") end), 0.05, 0.05)
end

function after_physics() fail("after_physics callout") end

function XPluginStart()
	return true
end

function XPluginEnable()
	register()
	return false
end
