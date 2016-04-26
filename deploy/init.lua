print("Running init script")

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
-- DATAREF LUA GLUE
--------------------------------------------------------------------------------
-- This code creates property objects (or MT-enhanced tables) for arrays that
-- let authors work with 

function wrap_dref_number(in_dref)
	return {
		get = function(self)
			return XLuaGetNumber(self.dref)
		end,
		set = function(self,v)
			XLuaSetNumber(self.dref,v)
		end,
		dref = in_dref
	}
end

function wrap_dref_string(in_dref)
	return {
		get = function(self)
			return XLuaGetString(self.dref)
		end,
		set = function(self,v)
			XLuaSetString(self.dref,v)
		end,
		dref = in_dref
	}
end

function dref_array_read(table,key)
	idx = tonumber(key)
	if idx == nil then
		return nil
	end
	return XLuaGetArray(table.dref,idx)
end

function dref_array_write(table,key,value)
	idx = tonumber(key)
	if idx == nil then
		return
	end
	XLuaSetArray(table.dref,idx,value)
end

function wrap_dref_array(in_dref, dim)
	dr = {
		dref = in_dref,
		len = dim
	}
	mt = { __index = dref_array_read, __newindex = dref_array_write }
	setmetatable(dr,mt)
	return dr
end
	
function wrap_dref_any(dref,t)	
	b = string.find(t,"%[")
	if b ~= nil then
		dim = tonumber(string.sub(t,b+1,-2))
		if dim == nil then
			return nil
		end
		return wrap_dref_array(dref,dim)
	end
	if t == "string" then
		return wrap_dref_string(dref)
	end
	if t == "number" then
		return wrap_dref_number(dref)
	end
	return nil
end

function find_dataref(name)
	dref = XLuaFindDataRef(name)
	t = XLuaGetDataRefType(dref)
	return wrap_dref_any(dref,t)
end

function create_dataref(name,type,notifier)
	if notifier == nil then
		dref = XLuaCreateDataRef(name,type,"no",nil)
	else
		dref = XLuaCreateDataRef(name,type,"yes",notifier)
	end
	return wrap_dref_any(dref,type)
end

--------------------------------------------------------------------------------
-- COMMAND LUA GLUE
--------------------------------------------------------------------------------

function make_command_obj(in_cmd)
	return { 
		start = function(self)
			XLuaCommandStart(self.cmd)
		end,
		stop = function(self)
			XLuaCommandStop(self.cmd)
		end,
		once = function(self)
			XLuaCommandOnce(self.cmd)
		end,
		cmd = in_cmd
	}
end

function find_command(name)
	c = XLuaFindCommand(name)
	return make_command_obj(c)
end

function create_command(name,desc,handler)
	c = XLuaCreateCommand(name,desc)
	XLuaReplaceCommand(c,handler)
	return make_command_obj(c)
end

function replace_command(name, func)
	c = XLuaFindCommand(name)
	XLuaReplaceCommand(c,func)
	return make_command_obj(c)
end	

function wrap_command(name, before, after)
	c = XLuaFindCommand(name)
	XLuaWrapCommand(c,before,after)
	return make_command_obj(c)
end

--------------------------------------------------------------------------------
-- TIMER UTILITIES
--------------------------------------------------------------------------------

function run_timer(func,delay,rep)
	tobj = all_timers[func]
	if tobj == nil then
		tobj = XLuaCreateTimer(func)
		all_timers[func] = tobj
	end
	XLuaRunTimer(tobj,delay,rep)
end

function stop_timer(func)
	tobj = all_timers[func]
	if tobj ~= nil then
		XLuaRunTimer(tobj, -1.0, -1.0)
	end
end

function is_timer_scheduled(func)
	tobj = all_timers[func]
	if tobj == nil then
		return false
	end
	return XLuaIsTimerScheduled(tobj)
end

function run_at_interval(func, interval)
	run_timer(func,interval,interval)
end

function run_after_time(func,delay)
	run_timer(func,delay,-1.0)
end

--------------------------------------------------------------------------------
-- NAMESPACE UTILITIES
--------------------------------------------------------------------------------
-- These put all script actions in a private namespace with meta-table 
-- enhancements.

function seems_like_prop(p)
	if type(p) ~= "table" then
		return false
	end
	if p.get == nil then
		return false
	end
	if p.set == nil then
		return false
	end
	return true
end

function namespace_write(table, key, value)
	func = table.functions[key]
	if func ~= nil then
		func.set(func,value)
	else
		if seems_like_prop(value) then
			table.functions[key] = value
		else
			table.values[key] = value
		end
	end
end

function namespace_read(table,key)
	func = table.functions[key]
	if func ~= nil then
		return func.get(func)
	end
	var = table.values[key]
	if var ~= nil then
		return var
	end
	return table.parent[key]
end

function create_namespace()
	ret = { 
		functions = {}, 
		values = {},
		create_prop = function(self,name, func)
			self.functions[name] = func
		end,
		parent = _G
	}
	mt = { __index = namespace_read, __newindex = namespace_write }
	setmetatable(ret,mt)
	return ret
end

-- Build a custom-built closure replacement for dofile that uses get-path to
-- find same-dir scripts and does a setfenv to our NS
function get_run_file_in_namespace(ns)
	return function(fname)
		full_path = XLuaGetPath()..fname
		chunk = loadfile(full_path)
		setfenv(chunk,ns)
		chunk()
	end
end

--------------------------------------------------------------------------------

function run_module_in_namespace(fn)
	print("Running module in namespace")

	n = create_namespace()
	all_timers = { }
	
	n.make_prop = function(name,func)
		n:create_prop(name,func)
	end
	
	n.find_dataref = find_dataref
	n.create_command = create_command
	n.find_command = find_command
	n.wrap_command = wrap_command
	n.replace_command = replace_command
	
	n.run_timer = run_timer
	n.stop_timer = stop_timer
	n.is_timer_scheduled = is_timer_scheduled
	n.run_after_time = run_after_time
	n.run_at_interval = run_at_interval
	n.dofile = get_run_file_in_namespace(n)
	
	setfenv(fn,n)
	fn()
end

function setup_callback_var(var_name,var_value)
	n[var_name] = var_value
end

function do_callout(fname)
	func=n[fname]
	if func ~= nil then
		func()
	end
end

print("init script complete")


