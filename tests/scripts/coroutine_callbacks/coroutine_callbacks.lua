--[[ XLua 2.0 ]]
-- Callbacks that a script registers from inside a Lua coroutine.
--
-- A callback must run on the main state of the script, not on the coroutine that registered it. The
-- coroutine can be suspended, ended, or collected when the callback runs.
--
-- Cases. Each one registers a flight loop, a timer, a command handler and an int dataref accessor:
--   main       from the main state (the control case);
--   suspended  inside a coroutine that is suspended while the callbacks run, and is resumed at the end;
--   ended      inside a coroutine that ended, and that the script keeps;
--   running    inside a coroutine that then causes the callbacks itself while it runs.
-- Error cases: a command handler that raises an error, registered from the main state, from an ended
-- coroutine and from a running coroutine. XLua must not call the handler as its own error handler.
--
-- The script checks itself and writes XLUATEST coroutine_callbacks: DONE pass=<n> fail=<n> at frame 80.
--
-- Collected case: the command xluatest/coroutines/collect_<kind> (kind is dataref, command, flightloop or
-- timer) registers one callback inside a coroutine, collects the coroutine, and then causes the callback.
-- It writes XLUATEST coroutine_callbacks_collected: DONE pass=<n> fail=<n>.

local NAME = "coroutine_callbacks"
local pass, fail = 0, 0
local function check(name, what, ok)
	if ok then
		pass = pass + 1
	else
		fail = fail + 1
		XPLMDebugString("XLUATEST " .. name .. ": FAIL " .. what .. "\n")
	end
end

-- The name of the thread that runs now. It keeps no reference to the thread.
local function current_thread()
	local co, is_main = coroutine.running()
	if co == nil or is_main == true then return "main" end
	return "coroutine"
end

local cases = {}

local function new_record() return { calls = 0, thread = "-" } end
local function ran(r) r.calls = r.calls + 1; r.thread = current_thread() end

-- Registers the callbacks of one case from the thread that calls it.
local function register(name, kinds)
	local c = { kinds = {}, stop = false }
	cases[name] = c
	for _, k in ipairs(kinds) do c.kinds[k] = new_record() end

	if c.kinds.flightloop then
		c.loop = XPLMCreateFlightLoop({
			phase = XPLMFlightLoopPhaseType.xplm_FlightLoop_Phase_AfterFlightModel,
			refcon = nil,
			callbackFunc = function()
				ran(c.kinds.flightloop)
				return c.stop and 0 or -1
			end })
		XPLMScheduleFlightLoop(c.loop, -1, true)
	end
	if c.kinds.timer then
		c.timer = XLuaCreateTimer(function() ran(c.kinds.timer) end)
		XLuaRunTimer(c.timer, 0.5, -1)
	end
	if c.kinds.command then
		XPLMRegisterCommandHandler(XPLMCreateCommand("xluatest/coroutines/" .. name, name),
			function(cmd, phase)
				if phase == XPLMCommandPhase.xplm_CommandBegin then ran(c.kinds.command) end
				return true
			end, true, nil)
	end
	if c.kinds.dataref then
		XPLMRegisterDataAccessor("xluatest/coroutines/" .. name, XPLMDataTypeID.xplmType_Int, false,
			function() ran(c.kinds.dataref) return 4242 end, nil,
			nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
	end
	if c.kinds.error then
		-- If XLua calls this handler as its error handler, the first argument is the error message.
		c.kinds.error.as_error_handler = 0
		XPLMRegisterCommandHandler(XPLMCreateCommand("xluatest/coroutines/" .. name .. "_error", name),
			function(a1, phase)
				if type(a1) == "string" then
					c.kinds.error.as_error_handler = c.kinds.error.as_error_handler + 1
					return a1
				end
				if phase ~= XPLMCommandPhase.xplm_CommandBegin then return true end
				ran(c.kinds.error)
				error("this handler fails on purpose")
			end, true, nil)
	end
	return c
end

local function fire(name)
	XPLMCommandOnce(XPLMFindCommand("xluatest/coroutines/" .. name))
end

local function read(name)
	return XPLMGetDatai(XPLMFindDataRef("xluatest/coroutines/" .. name))
end

local ALL = { "flightloop", "timer", "command", "dataref" }

-- Each callback of the case ran, and ran on the main state.
local function check_case(name)
	for _, k in ipairs(ALL) do
		local r = cases[name].kinds[k]
		if r then
			check(NAME, name .. " " .. k .. " ran", r.calls > 0)
			check(NAME, name .. " " .. k .. " ran on the main state (ran on " .. r.thread .. ")", r.thread == "main")
		end
	end
end

local function check_error_case(name)
	local r = cases[name].kinds.error
	check(NAME, name .. " error handler ran", r.calls == 1)
	check(NAME, name .. " error handler was not called as the error function", r.as_error_handler == 0)
end

local suspended, ended

local function running_case()
	local co = coroutine.create(function()
		local sentinel = "locals ok"
		register("running", { "command", "dataref" })
		register("running_error", { "error" })
		fire("running")
		local value = read("running")
		fire("running_error_error")
		local got = coroutine.yield("yielded")
		return sentinel .. " " .. tostring(value) .. " " .. tostring(got)
	end)
	local ok1, y = coroutine.resume(co)
	local ok2, result = coroutine.resume(co, "token")
	check(NAME, "running coroutine yields", ok1 and y == "yielded")
	check(NAME, "running coroutine ends with its locals", ok2 and result == "locals ok 4242 token")
	check_case("running")
	check_error_case("running_error")
end

------------------------------------------------------------------------------
-- Collected case
------------------------------------------------------------------------------

local collect_kind, collect_step = nil, 0

local function collect_setup(kind)
	local weak = setmetatable({}, { __mode = "k" })
	local co = coroutine.create(function() register("collected", { kind }) end)
	coroutine.resume(co)
	weak[co] = true
	co = nil
	cases.collected.stop = true
	for _ = 1, 5 do collectgarbage("collect") end
	-- Make many new threads, so that the memory of the old thread is used again.
	local churn = {}
	for i = 1, 20000 do churn[i] = coroutine.create(function() end) end
	churn = nil
	for _ = 1, 5 do collectgarbage("collect") end
	check(NAME .. "_collected", "the coroutine was collected", next(weak) == nil)
end

local function collect_fire(kind)
	if kind == "dataref" then
		check(NAME .. "_collected", "dataref value", read("collected") == 4242)
	elseif kind == "command" then
		fire("collected")
	end
	-- The flight loop runs each frame, and the timer fires after 0.5 seconds.
end

local function collect_report(kind)
	local r = cases.collected.kinds[kind]
	check(NAME .. "_collected", kind .. " ran", r.calls > 0)
	check(NAME .. "_collected", kind .. " ran on the main state (ran on " .. r.thread .. ")", r.thread == "main")
	XPLMDebugString("XLUATEST " .. NAME .. "_collected: DONE pass=" .. pass .. " fail=" .. fail .. "\n")
end

------------------------------------------------------------------------------
-- The driver: a flight loop on the main state that runs the steps in order.
------------------------------------------------------------------------------

local frame = 0

local function driver()
	frame = frame + 1
	if frame == 40 then
		for _, name in ipairs({ "main", "suspended", "ended" }) do fire(name) end
		for _, name in ipairs({ "main", "suspended", "ended" }) do
			check(NAME, name .. " dataref value", read(name) == 4242)
		end
		running_case()
	elseif frame == 45 then
		fire("main_error_error")
		fire("ended_error_error")
		check_error_case("main_error")
		check_error_case("ended_error")
	elseif frame == 80 then
		for _, name in ipairs({ "main", "suspended", "ended" }) do
			cases[name].stop = true
			check_case(name)
		end
		local ok, result = coroutine.resume(suspended, "token")
		check(NAME, "suspended coroutine resumes with its locals", ok and result == "locals ok token")
		XPLMDebugString("XLUATEST " .. NAME .. ": DONE pass=" .. pass .. " fail=" .. fail .. "\n")
	end

	if collect_kind then
		collect_step = collect_step + 1
		if collect_step == 1 then
			collect_setup(collect_kind)
		elseif collect_step == 2 then
			collect_fire(collect_kind)
		elseif collect_step == 30 then
			collect_report(collect_kind)
			collect_kind = nil
		end
	end
	return -1
end

function XPluginStart()
	return true
end

function XPluginEnable()
	-- The main state registers first, so that XLua makes its state for this script on the main state.
	register("main", ALL)
	register("main_error", { "error" })

	suspended = coroutine.create(function()
		local sentinel = "locals ok"
		register("suspended", ALL)
		local got = coroutine.yield()
		return sentinel .. " " .. tostring(got)
	end)
	coroutine.resume(suspended)

	ended = coroutine.create(function()
		register("ended", ALL)
		register("ended_error", { "error" })
	end)
	coroutine.resume(ended)

	for _, kind in ipairs(ALL) do
		XPLMRegisterCommandHandler(XPLMCreateCommand("xluatest/coroutines/collect_" .. kind, "collect " .. kind),
			function(cmd, phase)
				if phase == XPLMCommandPhase.xplm_CommandBegin then
					collect_kind, collect_step, pass, fail = kind, 0, 0, 0
				end
				return true
			end, true, nil)
	end

	XPLMScheduleFlightLoop(XPLMCreateFlightLoop({
		phase = XPLMFlightLoopPhaseType.xplm_FlightLoop_Phase_AfterFlightModel,
		refcon = nil,
		callbackFunc = driver }), -1, true)
	return true
end
