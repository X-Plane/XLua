--[[ XLua 2.0 ]]
-- Command handlers for the command binding tests.
--   xluatest/commands/returns_true, returns_false, returns_nil, raises_error: a handler that does what the
--   name says. The test checks if the command goes on to the next handler.
--   xluatest/commands/unregister_wrong_function, unregister_wrong_refcon, unregister_wrong_phase and
--   unregister_correct: each one unregisters the handler of xluatest/commands/target with these values.

local function returns(value)
	return function() return value end
end

local target_refcon = {}
local function target_handler() return true end

function XPluginStart()
	return true
end

function XPluginEnable()
	local function add(name, handler)
		XPLMRegisterCommandHandler(XPLMCreateCommand("xluatest/commands/" .. name, name), handler, true, nil)
	end
	add("returns_true", returns(true))
	add("returns_false", returns(false))
	add("returns_nil", returns(nil))
	add("raises_error", function() error("this handler fails on purpose") end)

	local target = XPLMCreateCommand("xluatest/commands/target", "target")
	XPLMRegisterCommandHandler(target, target_handler, true, target_refcon)

	-- Each command makes one unregister call. Only the last one has the correct values.
	local function unregister(name, handler, before, refcon)
		add("unregister_" .. name, function(cmd, phase)
			if phase == XPLMCommandPhase.xplm_CommandBegin then
				XPLMUnregisterCommandHandler(target, handler, before, refcon)
			end
			return true
		end)
	end
	unregister("wrong_function", function() return true end, true, target_refcon)
	unregister("wrong_refcon", target_handler, true, {})
	unregister("wrong_phase", target_handler, false, target_refcon)
	unregister("correct", target_handler, true, target_refcon)
	return true
end
