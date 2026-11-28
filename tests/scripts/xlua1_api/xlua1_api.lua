-- XLua 1 API: the dataref, command and timer functions that init.lua gives to XLua 1 scripts.
-- The test works with the other side: it reads and writes the datarefs and fires the commands through XPLM.
--
-- Frame 10: the script checks the timers and sets its datarefs. The test then reads them, writes
--           xluatest/xlua1/writable and fires the commands.
-- Frame 20: the script checks what the test did, and writes
--           XLUATEST xlua1_api: DONE pass=<n> fail=<n>

local pass, fail = 0, 0
local function check(what, ok)
	if ok then
		pass = pass + 1
	else
		fail = fail + 1
		print("XLUATEST xlua1_api: FAIL " .. what)
	end
end

writes = 0
writable = create_dataref("xluatest/xlua1/writable", "number", function() writes = writes + 1 end)
number = create_dataref("xluatest/xlua1/number", "number")
array = create_dataref("xluatest/xlua1/array", "array[4]")
text = create_dataref("xluatest/xlua1/text", "string")
sim_time = find_dataref("sim/time/total_running_time_sec")

begins = 0
create_command("xluatest/xlua1/command", "XLua 1 command", function(phase, duration)
	if phase == 0 then begins = begins + 1 end
end)

-- Commands that the test made before the script started.
replaced = 0
replace_command("xluatest/other/replace", function(phase, duration)
	if phase == 0 then replaced = replaced + 1 end
end)
wrapped_before, wrapped_after = 0, 0
wrap_command("xluatest/other/wrap",
	function(phase, duration) if phase == 0 then wrapped_before = wrapped_before + 1 end end,
	function(phase, duration) if phase == 0 then wrapped_after = wrapped_after + 1 end end)

ticks, shots = 0, 0
function tick() ticks = ticks + 1 end
function shot() shots = shots + 1 end

function flight_start()
	run_at_interval(tick, 0.1)
	run_after_time(shot, 0.1)
end

frames = 0
function after_physics()
	frames = frames + 1
	if frames == 10 then
		check("an interval timer runs", ticks >= 3)
		check("a run_after_time timer runs one time", shots == 1)
		check("is_timer_scheduled of a running timer", is_timer_scheduled(tick) == true)
		stop_timer(tick)
		check("is_timer_scheduled of a stopped timer", is_timer_scheduled(tick) == false)
		check("a sim dataref reads the sim time", sim_time > 0)

		number = 7
		array[0] = 1
		array[3] = 4
		text = "hello"
	elseif frames == 20 then
		check("a write through XPLM calls the handler", writes == 1)
		check("a write through XPLM sets the value", writable == 2.5)
		check("the command handler runs", begins == 1)
		check("the replaced command runs the new handler", replaced == 1)
		check("the wrapped command runs the before handler", wrapped_before == 1)
		check("the wrapped command runs the after handler", wrapped_after == 1)
		print("XLUATEST xlua1_api: DONE pass=" .. pass .. " fail=" .. fail)
	end
end
