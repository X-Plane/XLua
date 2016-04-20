print("Hello World starting")

function aircraft_load()
	print("Aircraft loaded!")
end

function aircraft_unload()
	print("Aircraft unloading!")
end

function flight_start()
	print("Flight init")
end

function flight_crash()
	print("Flight crash")
end

function before_physics()
	--print("Before physics")
	--print(SIM_PERIOD)
end

function after_physics()
	--print("after physics")
end

function after_replay()
	--print("after replay")
end



test_obj = {
	get = function(self)
		print("reading")
		print(self.value)
		return self.value
	end,
	set = function(self,v)
		print("writing")
		print(v)
		self.value = v
	end,
	value = 0
}


function test()
print("---test 1---")
test_obj = 5
print(test_obj)
print("---test 2---")
test2 = 6
print(test2)
end

test()



fhandle = XPLMFindDataRef("sim/cockpit2/controls/flap_handle_deploy_ratio")
engn_n1 = XPLMFindDataRef("sim/cockpit2/engine/indicators/N1_percent")
engn_n1_l = XPLMFindDataRef("sim/cockpit2/engine/indicators/N1_percent[0]")
print("Finding datarefs")
print(fhandle)
print(engn_n1)
print(engn_n1_l)
print("Dataref types")
print(XPLMGetDataRefType(fhandle));
print(XPLMGetDataRefType(engn_n1));
print(XPLMGetDataRefType(engn_n1_l));
print("Dataref values")
print(XPLMGetNumber(engn_n1_l));
print(XPLMGetArray(engn_n1,0));
print(XPLMGetNumber(fhandle));
print("-----")
ign = XPLMFindDataRef("sim/cockpit2/engine/actuators/igniter_on")
ign1 = XPLMFindDataRef("sim/cockpit2/engine/actuators/igniter_on[1]")
print(XPLMGetArray(ign,1))
print(XPLMGetNumber(ign1))
XPLMSetArray(ign1,1,1)
print(XPLMGetNumber(ign1))
XPLMSetNumber(ign1,2)
print(XPLMGetArray(ign,1))
print("-----")
f = function()
	print("callback")
	print(XPLMGetNumber(my_dref))
end
my_dref = XPLMCreateDataRef("sim/test/dref","number","yes",f)
my_dref2 = XPLMCreateDataRef("sim/test/dref2","number","no",nil)
my_dref3 = XPLMCreateDataRef("sim/test/dref3","number","yes",nil)
print(XPLMGetNumber(my_dref))
XPLMSetNumber(my_dref,10)
print(XPLMGetNumber(my_dref))
XPLMSetNumber(my_dref3,3)
XPLMSetNumber(my_dref2,2)
print("-----")
my_aref = XPLMCreateDataRef("sim/test/aref","array[4]","yes",f)
my_aref2 = XPLMCreateDataRef("sim/test/aref2","array[4]","no",nil)
my_aref3 = XPLMCreateDataRef("sim/test/aref3","array[4]","yes",nil)
XPLMSetArray(my_aref,0,0)
XPLMSetArray(my_aref,1,1)
XPLMSetArray(my_aref,2,2)

XPLMSetArray(my_aref2,0,0)
XPLMSetArray(my_aref2,1,1)
XPLMSetArray(my_aref2,2,2)

XPLMSetArray(my_aref3,0,0)
XPLMSetArray(my_aref3,1,1)
XPLMSetArray(my_aref3,2,2)

print(XPLMGetArray(my_aref,1))
print(XPLMGetArray(my_aref2,1))
print(XPLMGetArray(my_aref3,1))
print("-----")
my_sref = XPLMCreateDataRef("sim/test/sref","string","yes",function()
   print(XPLMGetString(my_sref))
end
)
XPLMSetString(my_sref,"hello")

print("--number wrapper----")
nprop = find_dataref("sim/cockpit2/engine/actuators/igniter_on[1]")
print(nprop)
nprop = 3
print(XPLMGetNumber(ign1))
sprop = find_dataref("sim/test/sref")
print(sprop)
sprop = "There"
print(XPLMGetString(my_sref))
print("------")
aprop = find_dataref("sim/cockpit2/engine/actuators/igniter_on")
print(aprop[0])
print(aprop[1])
print(aprop.len)
aprop[1]=0
aprop[0]=3
print(XPLMGetArray(ign,0))
print(nprop)

print("--created properties----")
my_int = create_dataref("sim/test/int","number",function() print(my_int) end)
my_int = 5

my_int2 = create_dataref("sim/test/int2","number")
my_int2 = 7

my_str = create_dataref("sim/test/string","string",function() print(my_str) end)
my_str = "hello"

my_arr = create_dataref("sim/test/array","array[4]",function() print(my_arr[0]) end)
my_arr[0] = 3
my_arr[1] = 2
my_arr[2] = 1
my_arr[3] = 0


print("----timers----")

function mt()
	print("Timer fired")
end

run_at_interval(mt,100)


print("----- cmds-----")
c = wrap_command("sim/operation/pause_toggle",
	function(phase,dur)
		print("pre "..phase.." "..dur)
		print(IN_REPLAY)
		if phase == 0 then
			stop_timer(mt)
		end
		if phase == 2 then
			run_after_time(mt,3.0)
		end
	end,
	function(phase, dur)
		print("post "..phase.." "..dur)
	end
)
--[[

c = find_command("sim/operation/pause_toggle")

c = replace_command("sim/operation/pause_toggle",function(phase)
	print("pause replacement "..phase)
end)
--]]

print(c)

c2 = create_command("lua/my_pause","pause from lua",function(phase)
	print("my func"..phase)
	if phase == 0 then
		c:once()
	end
end)






print("hello world done")
