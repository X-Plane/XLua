-- An XLua 1 script starts, and gets its callouts in order.

local calls = {}

function aircraft_load() calls[#calls + 1] = "aircraft_load" end
function flight_start() calls[#calls + 1] = "flight_start" end
function before_physics() if calls[#calls] ~= "before_physics" then calls[#calls + 1] = "before_physics" end end

function after_physics()
	if calls.done then return end
	calls.done = true
	local order = table.concat(calls, ",")
	local pass = (order == "aircraft_load,flight_start,before_physics") and 1 or 0
	print("XLUATEST start_v1: callouts " .. order)
	print("XLUATEST start_v1: DONE pass=" .. pass .. " fail=" .. (1 - pass))
end
