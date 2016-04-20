-- Locate the fuel tank dataerf.  We will treat it as an array
-- so we can operate on all tanks at once.
fuel_tanks = find_dataref("sim/flightmodel/weight/m_fuel")

-- Our timer func deducts 5 liter? of fuel from each tank
-- each tiem it fires.
function leak_some_fuel()
	for i=0,fuel_tanks.len-1 do
		fuel_tanks[i] = fuel_tanks[i] - 5
	end
end

-- When the flight starts, STOP our timer in case it was
-- already running.
function flight_start()
	stop_timer(leak_some_fuel)
end

-- When the user presses downt the fuel lank command,
-- start the leak timer to leak every 10 seconds
function do_fuel_leak_cmnd(phase, duration)
	if phase == 0 then
		if is_timer_scheduled(leak_some_fuel) then
			print("scheduled")
			run_at_interval(leak_some_fuel,1)
		else
			print("unscheduled")
			run_at_interval(leak_some_fuel,10)
		end
	end
end

-- Register a new command to leak fuel
create_command("sim/test/leak_fuel","Start a fuel leak",do_fuel_leak_cmnd)

