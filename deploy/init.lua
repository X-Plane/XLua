-- Wanna use STP with XLua?  Copy StackTracePlus.lua to be next to init.lua in the same folder
-- https://github.com/ignacio/StackTracePlus

-- Grab STP conditionally, do not squawk if it is missing.
--if pcall(
--	function()
--		local STP_chunk = XLuaGetCode("../../StackTracePlus.lua")
--		local STP = STP_chunk()
--		debug.traceback = STP.stacktrace
--	end)
--then
--	print("Using STP as debugger.")
--end


-- Are you getting terrible Lua performance with complex scripts?
-- Just use this one secret hack to make your script 5 times faster!!!
--
-- No, seriously. LuaJIT has default maxima which are plenty for most situations
-- but not necessarily all. As of xlua.xpl 1.4.0r1, these limits have been greatly
-- increased but if you still see a huge dropoff in performance this may be the cause.
-- First, try adding 'jit.off()' to the top of your complex scripts or, if you want to
-- go nukular, this one. If performance increases, it's the limits; hitting these causes
-- the Jit to effectively try to compile the entire script and fail, on every frame.
-- These are the limits currently set in xlua.xpl, *before* calling init.lua:
--
-- jit.opt.start("maxmcode=8192", "maxtrace=4096", "maxirconst=1500", "maxside=500")
--
-- Try increasing these until you regain your Lua performance. Then increase them a little more,
-- and put this line at the top of whichever script is causing the poor performance.

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

--------------------------------------------------------------------------------
-- TIMER UTILITIES
--------------------------------------------------------------------------------
function run_timer(func,delay,rep)
	tobj = XLuaFindTimer(func)
	if tobj == nil then
		tobj = XLuaCreateTimer(func)
	end
	XLuaRunTimer(tobj,delay,rep)
end

function stop_timer(func)
	tobj = XLuaFindTimer(func)
	if tobj ~= nil then
		XLuaRunTimer(tobj, -1.0, -1.0)
	end
end

function is_timer_scheduled(func)
	tobj = XLuaFindTimer(func)
	if tobj == nil then
		return false
	end
	return XLuaIsTimerScheduled(tobj)
end

function get_timer_remaining(func)
	tobj = XLuaFindTimer(func)
	if tobj == nil then
		return 0
	end
	return XLuaGetTimerRemaining(tobj)
end

function run_at_interval(func, interval)
	run_timer(func,interval,interval)
end

function run_after_time(func,delay)
	run_timer(func,delay,-1.0)
end

function isnan(x)
    return type(x) == "number" and x == x+1
end

XPLM_NO_PLUGIN_ID  = XPLMPluginID(-1)
XPLM_PLUGIN_XPLANE = XPLMPluginID(0)
