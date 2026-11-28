--[[ XLua 2.0 ]]
-- Array datarefs whose accessors are Lua functions, read and written through XPLM with C buffers.
--
-- The script checks itself and needs no host support. It runs the same checks from three call contexts:
-- XPluginEnable, a flight loop and a command handler. Then it writes
--   XLUATEST array_datarefs: DONE pass=<n> fail=<n>
-- Each check that fails writes a FAIL line first.
--
-- What it checks:
--   - A read with a buffer gets the values that the accessor wrote, also at an offset.
--   - Buffer slots that the accessor does not fill are zero.
--   - A read with no buffer gets the size of the array.
--   - If an accessor returns a count larger than the buffer, the caller gets the buffer size.
--   - If a script writes fewer values than the count it gives, the accessor gets the number of values.

local NAME = "array_datarefs"
local SIZE = 10

local pass, fail = 0, 0
local floats, ints, bytes, liar
local last_write_count = -1

local function check(context, what, ok)
	if ok then
		pass = pass + 1
	else
		fail = fail + 1
		XPLMDebugString("XLUATEST " .. NAME .. ": FAIL " .. what .. " (" .. context .. ")\n")
	end
end

-- True if t[1..count] is first, first + 1, and so on.
local function is_sequence(t, first, count)
	for i = 1, count do
		if t[i] ~= first + i - 1 then return false end
	end
	return true
end

local function is_zero(t, from, to)
	for i = from, to do
		if t[i] ~= 0 then return false end
	end
	return true
end

-- Writes value offset + i to slot i, as far as the array goes, and returns the count written.
local function reader(refcon, out, offset, max)
	if out == nil then return SIZE end
	if offset >= SIZE then return 0 end
	local n = math.min(max, SIZE - offset)
	for i = 1, n do out[i] = offset + i end
	return n
end

local function writer(refcon, values, offset, count)
	last_write_count = count
end

-- Writes nothing and returns a count that is larger than any buffer.
local function lying_reader(refcon, out, offset, max)
	if out == nil then return SIZE end
	return 10000
end

local function run_checks(context)
	local function c(what, ok) check(context, what, ok) end

	c("float size query", XPLMGetDatavf(floats, nil, 0, 0) == SIZE)
	c("int size query", XPLMGetDatavi(ints, nil, 0, 0) == SIZE)
	c("byte size query", XPLMGetDatab(bytes, nil, 0, 0) == SIZE)

	local t = {}
	c("float read count", XPLMGetDatavf(floats, t, 0, 5) == 5)
	c("float read values", is_sequence(t, 1, 5))
	t = {}
	c("int read count", XPLMGetDatavi(ints, t, 0, 5) == 5)
	c("int read values", is_sequence(t, 1, 5))
	t = {}
	c("byte read count", XPLMGetDatab(bytes, t, 0, 5) == 5)
	c("byte read values", is_sequence(t, 1, 5))

	t = {}
	c("float read at offset count", XPLMGetDatavf(floats, t, 3, 5) == 5)
	c("float read at offset values", is_sequence(t, 4, 5))

	-- The accessor fills 4 of 8 slots.
	t = {}
	c("float short read count", XPLMGetDatavf(floats, t, 6, 8) == 4)
	c("float short read values", is_sequence(t, 7, 4))
	c("float short read zero tail", is_zero(t, 5, 8))

	-- The accessor fills nothing.
	t = {}
	c("float read past the end count", XPLMGetDatavf(floats, t, SIZE, 4) == 0)
	c("float read past the end zero", is_zero(t, 1, 4))
	t = {}
	c("byte read past the end count", XPLMGetDatab(bytes, t, SIZE, 4) == 0)
	c("byte read past the end zero", is_zero(t, 1, 4))

	t = {}
	c("count larger than the buffer is clamped", XPLMGetDatavf(liar, t, 0, 5) == 5)
	c("size query of the same accessor", XPLMGetDatavf(liar, nil, 0, 0) == SIZE)

	last_write_count = -1
	XPLMSetDatavf(floats, { 1.0, 2.0 }, 0, 10000)
	c("float write count is the table size", last_write_count == 2)
	last_write_count = -1
	XPLMSetDatavi(ints, { 1, 2, 3 }, 0, 10000)
	c("int write count is the table size", last_write_count == 3)
end

local function register(name, type, read)
	-- The accessor table of XPLMRegisterDataAccessor: int, float, double, int array, float array, bytes.
	local fns = {}
	local index = ({ [XPLMDataTypeID.xplmType_IntArray] = 7, [XPLMDataTypeID.xplmType_FloatArray] = 9,
					 [XPLMDataTypeID.xplmType_Data] = 11 })[type]
	fns[index], fns[index + 1] = read, writer
	return XPLMRegisterDataAccessor("xluatest/arrays/" .. name, type, true,
		fns[1], fns[2], fns[3], fns[4], fns[5], fns[6], fns[7], fns[8], fns[9], fns[10], fns[11], fns[12],
		"read refcon", "write refcon")
end

function XPluginStart()
	return true
end

function XPluginEnable()
	floats = register("floats", XPLMDataTypeID.xplmType_FloatArray, reader)
	ints = register("ints", XPLMDataTypeID.xplmType_IntArray, reader)
	bytes = register("bytes", XPLMDataTypeID.xplmType_Data, reader)
	liar = register("liar", XPLMDataTypeID.xplmType_FloatArray, lying_reader)

	run_checks("XPluginEnable")

	local command = XPLMCreateCommand("xluatest/arrays/run", "run the array checks")
	XPLMRegisterCommandHandler(command, function(cmd, phase)
		if phase == XPLMCommandPhase.xplm_CommandBegin then run_checks("command handler") end
		return true
	end, true, nil)

	XPLMScheduleFlightLoop(XPLMCreateFlightLoop({
		phase = XPLMFlightLoopPhaseType.xplm_FlightLoop_Phase_AfterFlightModel,
		refcon = nil,
		callbackFunc = function()
			run_checks("flight loop")
			XPLMCommandOnce(command)
			XPLMDebugString("XLUATEST " .. NAME .. ": DONE pass=" .. pass .. " fail=" .. fail .. "\n")
			return 0
		end }), -1, true)
	return true
end
