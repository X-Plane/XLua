//
//  xpfuncs.cpp
//  xlua
//
//  Created by Ben Supnik on 3/19/16.
//
//	Copyright 2016, Laminar Research
//	This source code is licensed under the MIT open source license.
//	See LICENSE.txt for the full terms of the license.

#include <cstdio>
#include <cstdlib>
#include <optional>

#include "xpfuncs.h"
#include "lua_helpers.h"
#include "xpdatarefs.h"
#include "xpcommands.h"
#include "xptimers.h"
#include "module.h"

#include <string.h>
#include <stdio.h>
#include <assert.h>

#include <XPLMUtilities.h>
#include <XPLMDataAccess.h>

#include "log.h"

/*
	TODO: figure out when we have to resync our datarefs
	TODO: what if dref already registered before acf reload?  (maybe no harm?)
	TODO: test x-plane-side string read/write - needs test not at startup

 */

static XPLMDataRef drSimRealTime = nullptr;
static const std::string kTimerCallbackSig("TimerCallback");
static const std::string kDatarefCallbackSig("DatarefCallback");
static const std::string kFilterCallbackSig("FilterCallback");
static const std::string kCommandCallbackSig("CmdCallback");

static int l_my_print(lua_State* L);

// Given an interp and a stack arg that is a lua function/closure,
// this routine stashes a strong ref to the closure in the registry,
// allocates a callback struct and stashes the slot and interp in the
// CB struct.  This CB struct is a single C ptr that we can use to 
// reconstruct the closure from C land.
//
// If the closure is actually nil, we return NULL and allocate nothing.
// The memory is tracked by the interp's module and is collected for us
// at shutdown.
notify_cb_t* wrap_first_lua_func(lua_State * L, int func_stack_idx, std::string const cb_typename, int refcon_reg_index)
{
	if (lua_isnil(L, func_stack_idx))
	{
		luaL_argerror(L, func_stack_idx, "nil not allowed for callback");
		return nullptr;
	}

	module* me = module::module_from_interp(L);
	notify_cb_t* cb = (notify_cb_t*)me->module_alloc_tracked(sizeof(notify_cb_t));
	cb = new (cb) notify_cb_t(L);
	cb->origRefconRegIndex = refcon_reg_index;

	wrap_next_lua_func(cb, func_stack_idx, cb_typename);

	return cb;
}

bool wrap_next_lua_func(notify_cb_t* cb_record, int func_stack_idx, std::string const cb_typename)
{
	if (lua_isnil(cb_record->L, func_stack_idx))
	{
		luaL_argerror(cb_record->L, func_stack_idx, "nil not allowed for callback");
		return false;
	}

	luaL_checktype(cb_record->L, func_stack_idx, LUA_TFUNCTION);

	// Now store the registry reference index into the callback array, in the given position.
	lua_pushvalue(cb_record->L, func_stack_idx);
	cb_record->callbacks[cb_typename] = luaL_ref(cb_record->L, LUA_REGISTRYINDEX);

	return true;
}

notify_cb_t * wrap_lua_func_nil(lua_State * L, int idx, std::string const callbackKey)
{
	if (lua_isnil(L,idx))
	{
		return nullptr;
	}

	return wrap_first_lua_func(L, idx, callbackKey, 0);
}

// Similar idea to above, but capture a value and just return the index into the registry.
int capture_lua_value(lua_State* L, int idx)
{
	lua_pushvalue(L, idx);
	return luaL_ref(L, LUA_REGISTRYINDEX);
}

// Given a void * that is really a CB struct, this routine either
// pushes the lua function onto the stack (so that we can then push 
// args and pcall) or returns 0 if we should not call because the CB is
// nil or borked.
lua_State* setup_lua_callback(void * ref, std::string const callbackKey)
{
	if (ref == nullptr)
		return nullptr;

	notify_cb_t * cb = (notify_cb_t *) ref;

	if (callbackKey.empty())
	{
		log_message(cb->L, "ERROR: Anonymous closure specified.");
		return nullptr;
	}

	auto storedKey = cb->callbacks.find(callbackKey);
	if (storedKey != cb->callbacks.end())
	{
		lua_rawgeti(cb->L, LUA_REGISTRYINDEX, storedKey->second);
		if (lua_isfunction(cb->L, -1))
		{
			return cb->L;
		}

		log_message(cb->L, "ERROR: we did not persist a closure?!?");
		lua_pop(cb->L, 1);
	}
	else
	{
		log_message(cb->L, "ERROR: Callback %s is not recognised!", callbackKey.c_str());
	}

	return nullptr;
}

//----------------------------------------------------------------
// MISC
//----------------------------------------------------------------

static int XLuaGetCode(lua_State * L)
{
	module * me = module::module_from_interp(L);
	assert(me);
	
	const char * name = luaL_checkstring(L, 1);
	
	int result = me->load_module_relative_path(name);
	
	if(result)
	{
		const char * err_msg = luaL_checkstring(L, 2);
		log_message(L, "%s: %s\n", name, err_msg);

		return 0;
	}
	
	return 1;
}


//----------------------------------------------------------------
// DATAREFS
//----------------------------------------------------------------

// XPLMFindDataRef "foo" -> dref
static int XLuaFindDataRef(lua_State * L)
{
	const char * name = luaL_checkstring(L, -1);

	xlua_dref * r = xlua_find_dref(name);
	assert(r);
	
    xlua_pushuserdata(L, r);
	return 1;
}

static void xlua_dataref_notify_helper(xlua_dref* who, void* ref)
{
	lua_State * L = setup_lua_callback(ref, kDatarefCallbackSig);
	if (L)
	{
		fmt_pcall_stdvars(L, module::debug_proc_from_interp(L), false, "");
	}
}

// XPLMCreateDataRef name "array[4]" "yes" func -> dref
static int XLuaCreateDataRef(lua_State * L)
{
	const char * name = luaL_checkstring(L, 1);
	const char * typestr = luaL_checkstring(L,2);
	const char * writable = luaL_checkstring(L,3);
	notify_cb_t * cb = wrap_lua_func_nil(L, 4, kDatarefCallbackSig);
	
	if(strlen(name) == 0)
		return luaL_argerror(L, 1, "dataref name must not be an empty string.");

	int my_writeable;
	if(strcmp(writable,"yes")==0)
		my_writeable = 1;
	else if (strcmp(writable,"no")==0)
		my_writeable = 0;
	else 
		return luaL_argerror(L, 3, "writable must be 'yes' or 'no'");
	
	xlua_dref_type my_type = xlua_none;
	int my_dim = 1;
	const char * c = typestr;
	if(strcmp(c,"string") == 0)
		my_type = xlua_string;
	else if(strcmp(c,"number")==0)
		my_type = xlua_number;
	else if (strncmp(c,"array[",6) == 0)
	{
		while(*c && *c != '[') ++c;
		if(*c == '[')
		{
			++c;
			my_dim = atoi(c);
			my_type = xlua_array;
		}
	}
	else
		return luaL_argerror(L, 2, "Type must be number, string, or array[n]");
	
	xlua_dref * r = xlua_create_dref(L,
							name,
							my_type,
							my_dim,
							my_writeable,
							(my_writeable && cb) ? xlua_dataref_notify_helper : NULL,
							cb);
	assert(r);
	
    xlua_pushuserdata(L, r);
	return 1;
	
}

// dref -> "array[4]"
static int XLuaGetDataRefType(lua_State * L)
{
	xlua_dref_type dt = xlua_none;

	xlua_dref * d = xlua_checkuserdata<xlua_dref*>(L,1,"expected dataref");
	if (d != nullptr)
	{
		dt = xlua_dref_get_type(d);
	}

	switch(dt) {
	case xlua_none:
		lua_pushstring(L, "none");
		break;
	case xlua_number:
		lua_pushstring(L, "number");
		break;
	case xlua_array:
		{
			char buf[256];
			sprintf(buf,"array[%d]",xlua_dref_get_dim(d));
			lua_pushstring(L,buf);
		}
		break;
	case xlua_string:
		lua_pushstring(L, "string");
		break;
	}	
	return 1;
}

// XPLMGetNumber dref -> value
static int XLuaGetNumber(lua_State * L)
{
	xlua_dref * d = xlua_checkuserdata<xlua_dref*>(L,1,"expected dataref");
	
	lua_pushnumber(L, xlua_dref_get_number(d));
	return 1;	
}

// XPLMSetNumber dref value
static int XLuaSetNumber(lua_State * L)
{
	xlua_dref * d = xlua_checkuserdata<xlua_dref*>(L,1,"expected dataref");
	double v = luaL_checknumber(L, 2);
	
	xlua_dref_set_number(d,v);
	return 0;	
}

// XPLMGetArray dref idx -> value
static int XLuaGetArray(lua_State * L)
{
	xlua_dref * d = xlua_checkuserdata<xlua_dref*>(L,1,"expected dataref");
	int idx = static_cast<int>(luaL_checknumber(L, 2));
	
	lua_pushnumber(L, xlua_dref_get_array(d,idx));
	return 1;	
}

// XPLMSetArray dref idx value
static int XLuaSetArray(lua_State * L)
{
	xlua_dref * d = xlua_checkuserdata<xlua_dref*>(L,1,"expected dataref");
	int idx = static_cast<int>(luaL_checknumber(L, 2));
	double v = luaL_checknumber(L, 3);

	xlua_dref_set_array(d,idx,v);
	return 0;		
}

// XLuaSetArrayFromArray dref value_array
static int XLuaSetArrayFromArray(lua_State* L)
{
	xlua_dref* d = xlua_checkuserdata<xlua_dref*>(L, 1, "expected dataref");
	luaL_checktype(L, 2, LUA_TTABLE);

	lua_pushvalue(L, 2);
	lua_pushnil(L);

	std::vector<double> tableVals;
	while (lua_next(L, -2))
	{
		tableVals.emplace_back(lua_tonumber(L, -1));
		lua_pop(L, 1);
	}
	lua_pop(L, 1);

	xlua_dref_set_array(d, tableVals);
	return 0;
}

// XPLMGetString dref -> value
static int XLuaGetString(lua_State * L)
{
	xlua_dref * d = xlua_checkuserdata<xlua_dref*>(L,1,"expected dataref");
	
	lua_pushstring(L, xlua_dref_get_string(d).c_str());
	return 1;	
}

// XPLMSetString dref value
static int XLuaSetString(lua_State * L)
{
	xlua_dref * d = xlua_checkuserdata<xlua_dref*>(L,1,"expected dataref");
	const char * s = luaL_checkstring(L, 2);
	xlua_dref_set_string(d,string(s));
	return 0;	
}

//----------------------------------------------------------------
// COMMANDS
//----------------------------------------------------------------

// XPLMFindCommand name
static int XLuaFindCommand(lua_State * L)
{
	const char * name = luaL_checkstring(L, 1);
	xlua_cmd * r = xlua_find_cmd(name);
	if(!r)
	{
		lua_pushnil(L);
		return 1;
	}
	assert(r);
	
    xlua_pushuserdata(L, r);
	return 1;
}

// XPLMCreateCommand name desc
static int XLuaCreateCommand(lua_State * L)
{
	const char * name = luaL_checkstring(L, 1);
	const char * desc = luaL_checkstring(L, 2);

	xlua_cmd * r = xlua_create_cmd(L,name,desc);
	assert(r);
	
    xlua_pushuserdata(L, r);
	return 1;
}

static int cmd_filter_cb_helper(xlua_cmd* cmd, int phase, float elapsed, void* ref)
{
	int res = 1;

	lua_State* L = setup_lua_callback(ref, kFilterCallbackSig);
	if (L)
	{
		int e = lua_pcall(L, 0, 1, module::debug_proc_from_interp(L));
		if (e != 0)
		{
			l_my_print(L);
		}
		else
		{
			res = lua_toboolean(L, -1);
		}

		lua_pop(L, 1);
	}

	return res;
}

static int cmd_cb_helper(xlua_cmd * cmd, int phase, float elapsed, void * ref)
{
	lua_State * L = setup_lua_callback(ref, kCommandCallbackSig);
	if (L)
	{
		fmt_pcall_stdvars(L, module::debug_proc_from_interp(L), false, "if", phase, elapsed);
	}

	return 1;
}

// XPLMFilterCommand handler
static int XLuaFilterCommand(lua_State* L)
{
	xlua_cmd* cmd = xlua_checkuserdata<xlua_cmd*>(L, 1, "expected command");
	notify_cb_t* cb_filter = wrap_first_lua_func(L, 2, kFilterCallbackSig, 0);

	xlua_cmd_install_filter(L, cmd, cmd_filter_cb_helper, cb_filter);

	return 0;
}

// XPLMReplaceCommand cmd handler
static int XLuaReplaceCommand(lua_State * L)
{
	xlua_cmd * d = xlua_checkuserdata<xlua_cmd*>(L,1,"expected command");
	notify_cb_t * cb = wrap_first_lua_func(L, 2, kCommandCallbackSig, 0);
	
	xlua_cmd_install_handler(L, d, cmd_cb_helper, cb);
	return 0;
}

// XPLMWrapCommand cmd handler1 handler2
static int XLuaWrapCommand(lua_State * L)
{
	xlua_cmd * d = xlua_checkuserdata<xlua_cmd*>(L,1,"expected command");
	notify_cb_t * cb1 = wrap_first_lua_func(L, 2, kCommandCallbackSig, 0);
	notify_cb_t * cb2 = wrap_first_lua_func(L, 3, kCommandCallbackSig, 0);
	
	xlua_cmd_install_pre_wrapper(L, d, cmd_cb_helper, cb1);
	xlua_cmd_install_post_wrapper(L, d, cmd_cb_helper, cb2);
	return 0;	
}

// XPLMCommandStart cmd
static int XLuaCommandStart(lua_State * L)
{
	xlua_cmd * d = xlua_checkuserdata<xlua_cmd*>(L,1,"expected command");
	xlua_cmd_start(d);
	return 0;
}

// XPLMCommandStop cmd
static int XLuaCommandStop(lua_State * L)
{
	xlua_cmd * d = xlua_checkuserdata<xlua_cmd*>(L,1,"expected command");
	xlua_cmd_stop(d);
	return 0;
}

// XPLMCommandOnce cmd
static int XLuaCommandOnce(lua_State * L)
{
	xlua_cmd * d = xlua_checkuserdata<xlua_cmd*>(L,1,"expected command");
	xlua_cmd_once(d);
	return 0;
}

//----------------------------------------------------------------
// TIMERS
//----------------------------------------------------------------

static void timer_cb(void * ref)
{
	lua_State * L = setup_lua_callback(ref, kTimerCallbackSig);
	if (L)
	{
		fmt_pcall_stdvars(L, module::debug_proc_from_interp(L), false, "");
	}
}

// XPLMCreateTimer func -> ptr
static int XLuaCreateTimer(lua_State * L)
{
	notify_cb_t * helper = wrap_first_lua_func(L, -1, kTimerCallbackSig, 0);
	if(helper == NULL)
		return 0;
	
	xlua_timer * t = xlua_create_timer(L, timer_cb, helper);
	assert(t);
	
    xlua_pushuserdata(L, t);
	return 1;
}

// Get the number of seconds a timer has to go, or -1 if not scheduled.
static int XLuaGetTimerRemaining(lua_State* L)
{
	xlua_timer* t = xlua_checkuserdata<xlua_timer*>(L, 1, "expected timer");
	if (t == nullptr)
	{
		lua_pushnumber(L, -1);
	}
	else
	{
		lua_pushnumber(L, xlua_get_timer_remaining(t));
	}

	return 1;
}

// XPLMRunTimer timer delay repeat
static int XLuaRunTimer(lua_State * L)
{
	xlua_timer * t = xlua_checkuserdata<xlua_timer*>(L,1,"expected timer");
	if(!t)
		return 0;
	
	xlua_run_timer(t, lua_tonumber(L, -2), lua_tonumber(L, -1));
	return 0;
}

// XPLMIsTimerScheduled ptr -> int
static int XLuaIsTimerScheduled(lua_State * L)
{
	xlua_timer * t = xlua_checkuserdata<xlua_timer*>(L,1,"expected timer");
	int sched = xlua_is_timer_scheduled(t);
	lua_pushboolean(L, sched);
	return 1;
}

static int XLuaReloadOnFlightChange(lua_State* L)
{
	char log[512];
	sprintf(log, "Aircraft scripts will be fully reloaded when flight details change.");

	// Log the fact that the plugin's been put into reinit-on-flight-change mode.
	lua_pushstring(L, log);
	l_my_print(L);
	lua_pop(L, 1);

	xlua_cmd_mark_reload_on_change();

	return 0;
}

std::map<std::pair<lua_State const*, std::string>, xlua_dref*> cachedDrefs;

#define NS_READ_STATS 1
static int namespace_read_native(lua_State* L)
{
	// The namespace is a table containing 'functions', 'values', 'raw_table_keys' etc.
	// That table has a custom metatable with overrides for __index, __newindex etc.
	luaL_checktype(L, 1, LUA_TTABLE);

#if NS_READ_STATS
	static size_t c_values = 0, c_funcs = 0, c_cache_reads = 0, c_cache_writes = 0;
	static std::map<std::string, size_t> c_val_reads;
#endif
	char const* wanted_key = lua_tostring(L, 2);

	lua_pushstring(L, "values");
	lua_rawget(L, 1);					// Pops 'values', pushes the result.

	lua_pushvalue(L, 2);				// Re-push the index, i.e. put at -1
	lua_gettable(L, -2);
	lua_remove(L, -2);					// Dump the 'values' table from the stack
	if (lua_type(L, -1) != LUA_TNIL)
	{
#if NS_READ_STATS
		++c_values;
		if (wanted_key != nullptr)
		{
			c_val_reads[wanted_key]++;
		}
		else
		{
			c_val_reads["<None>"]++;
		}
#endif
		return 1;						// Topmost item is the value we need.
	}
	lua_pop(L, 1);						// Pop the 'nil'

	if (wanted_key != nullptr)
	{
		auto cache = cachedDrefs.find({ L, wanted_key });
		if (cache != cachedDrefs.end())
		{
			xlua_dref_type dt = xlua_dref_get_type(cache->second);
			if (dt == xlua_dref_type::xlua_number)
			{
				lua_pushnumber(L, xlua_dref_get_number(cache->second));
			}
			else
			{
				lua_pushstring(L, xlua_dref_get_string(cache->second).c_str());
			}

#if NS_READ_STATS
			++c_cache_reads;
#endif
			return 1;
		}
	}

	lua_pushstring(L, "functions");
	lua_rawget(L, 1);					// Pops 'functions', pushes the result.

	lua_pushvalue(L, 2);				// Re-push the index, i.e. put at -1
	lua_gettable(L, -2);
	lua_remove(L, -2);					// Dump the 'functions' table from the stack
	if (lua_type(L, -1) != LUA_TNIL)
	{
		// If should have a '__get' method - this is a lua stub referencing the C call i.e. XLuaGetNumber() .
		lua_pushstring(L, "__get");
		lua_rawget(L, -2);				// Pops '__get', pushes the result, which should be a function.

		/////
		lua_pushstring(L, "dref");		// Test to see if there's a dref value. If so, we can shortcut the whole process next time.
		lua_rawget(L, -3);
		if (lua_type(L, -1) == LUA_TUSERDATA)
		{
			xlua_dref** actual_dref = static_cast<xlua_dref**>(lua_touserdata(L, -1));
			xlua_dref_type dt = xlua_dref_get_type(*actual_dref);
			if (dt == xlua_dref_type::xlua_number || dt == xlua_dref_type::xlua_string)
			{
				cachedDrefs.emplace(std::pair<lua_State const*, std::string>{ L, wanted_key }, *actual_dref);
#if NS_READ_STATS
				++c_cache_writes;
#endif
			}
		}
		lua_pop(L, 1);
		/////

		lua_pushvalue(L, -2);			// Push the table again as a parameter.
		lua_call(L, 1, 1);

#if NS_READ_STATS
		++c_funcs;
#endif

		return 1;						// Topmost item is the value we need.
	}
	lua_pop(L, 1);						// Pop the 'nil'

	lua_pushstring(L, "parent");
	lua_rawget(L, 1);					// Pops 'parent', pushes the result.
	if (lua_type(L, -1) != LUA_TNIL)
	{
		lua_pushvalue(L, 2);				// Re-push the index, i.e. put at -1
		lua_gettable(L, -2);
	}
	else
	{
		lua_pushnil(L);
	}

	lua_remove(L, -2);					// Dump the 'parent' table from the stack

	return 1;
}

#define FUNC_LIST \
	FUNC(XLuaGetCode) \
	FUNC(XLuaFindDataRef) \
	FUNC(XLuaCreateDataRef) \
	FUNC(XLuaGetDataRefType) \
	FUNC(XLuaGetNumber) \
	FUNC(XLuaSetNumber) \
	FUNC(XLuaGetArray) \
	FUNC(XLuaSetArray) \
	FUNC(XLuaSetArrayFromArray) \
	FUNC(XLuaGetString) \
	FUNC(XLuaSetString) \
	FUNC(XLuaFindCommand) \
	FUNC(XLuaCreateCommand) \
	FUNC(XLuaReplaceCommand) \
	FUNC(XLuaWrapCommand) \
	FUNC(XLuaFilterCommand) \
	FUNC(XLuaCommandStart) \
	FUNC(XLuaCommandStop) \
	FUNC(XLuaCommandOnce) \
	FUNC(XLuaCreateTimer) \
	FUNC(XLuaRunTimer) \
	FUNC(XLuaIsTimerScheduled) \
	FUNC(XLuaGetTimerRemaining) \
	FUNC(XLuaReloadOnFlightChange) \
	FUNC(namespace_read_native)

std::string get_log_prefix(char l)
{
	char prefix[256];
	int hrs, min;
	float sec, real_time = XPLMGetDataf(drSimRealTime);
	hrs = static_cast<int>(real_time / 3600.0f);
	min = static_cast<int>(real_time / 60.0f) - (int)(hrs * 60.0f);
	sec = real_time - (hrs * 3600.0f) - (min * 60.0f);
	sprintf(prefix, "%d:%02d:%06.3f %c/LUA: ", (int)hrs, (int)min, sec, l);

	return std::string(prefix);
}

static int l_my_print(lua_State *L)
{
	int nargs = lua_gettop(L);
	module *me = module::module_from_interp(L);

	std::string prefix = get_log_prefix();

	// Unwieldy... but on the other hand, lua debug statements could in theory come from anywhere, from
	// several different instances of xlua at the same time so the full path probably is needed.
	XPLMDebugString((prefix + me->get_log_path() + "\n").c_str());

	std::string output;
	char num_buf[128];

	for (int i = 1; i <= nargs; i++)
	{
		switch (lua_type(L, i))
		{
			case LUA_TNIL:
				output += "(nil)";
				break;

			case LUA_TBOOLEAN:
				output += lua_toboolean(L, i) ? "true" : "false";
				break;

			case LUA_TNUMBER:
				lua_number2str(num_buf, lua_tonumber(L, i));
				output += num_buf;
				break;

			case LUA_TSTRING:
				output += lua_tostring(L, i);
				break;

			case LUA_TTABLE:
				// At least let people know that tables need to be split down for print() .
				output += "(table)";
				break;

			default:
				output += "(???)";
		}

		output += " ";
	}

	// Keep the console output too.
	puts(output.c_str());

	output += "\n";
	XPLMDebugString((prefix + output).c_str());

	return 0;
}

int log_message(lua_State *L, char const* const format, ...)
{
	char buffer[2048];
	char lp = 'I';
	std::string prefix(get_log_prefix());

	if (L != nullptr)
	{
		lua_Debug ar = {};
		char const* line_prefix = "";

		for (int level = 0; lua_getstack(L, level, &ar); ++level)
		{
			if (lp == 'I')
			{
				lp = 'E';
				prefix = get_log_prefix(lp);
			}

			lua_getinfo(L, "nSl", &ar);

			char const* source_name = (ar.short_src[0] == 0 ? "memory" : ar.short_src);
			if (ar.source != nullptr && ar.source[0] == '=')
			{
				source_name = &ar.source[1];
			}

			if (ar.name == nullptr)
			{
				snprintf(buffer, sizeof(buffer), "%sOn line %d of '%s':\n", line_prefix, ar.currentline, source_name);
			}
			else
			{
				snprintf(buffer, sizeof(buffer), "%sIn %s on line %d of '%s':\n", line_prefix, ar.name, ar.currentline, source_name);
			}

			XPLMDebugString(prefix.c_str()); XPLMDebugString(buffer);
			printf("%s", prefix.c_str()); printf("%s", buffer);
			buffer[0] = 0;

			line_prefix = " -> ";
			memset(&ar, 0, sizeof(ar));
		}
	}

	va_list args;
	va_start(args, format);
	int result = vsnprintf(buffer, sizeof(buffer), format, args);
	va_end(args);

	std::string output(prefix);
	output += buffer;

	XPLMDebugString(output.c_str());
	printf("%s", output.c_str());

	return result;
}

static const struct luaL_Reg printlib[] = {
	{ "print", l_my_print },
	{ NULL, NULL } /* end of array */
};

void	add_xlua_funcs_to_interp(lua_State * L)
{
	#define FUNC(x) \
		lua_register(L,#x,x);
		
	FUNC_LIST

	// For logging
	drSimRealTime = XPLMFindDataRef("sim/network/misc/network_time_sec");

	// Register the custom print handler
	lua_getglobal(L, "_G");
	luaL_register(L, NULL, printlib);
	lua_pop(L, 1);
}

std::map<void*, notify_cb_t*> allRegisteredCallbacks;

void CleanupStoredCallbacks(lua_State* L, int keyIndexInRegistry)
{
	// Get the value. Could be any type but most likely void*.
	// If it isn't a void* then convert it somehow; straight cast for numbers, maybe a hash for strings?
	// Can't assume that we get the same value from lua - could be a string, for example.
	void* key;

	module* me = module::module_from_interp(L);

	auto exists = allRegisteredCallbacks.find(key);
	if (exists != allRegisteredCallbacks.end())
	{
		// Un-pin all functions.
		for (auto const& [name, regidx] : exists->second->callbacks)
		{
			luaL_unref(L, LUA_REGISTRYINDEX, regidx);
		}

		luaL_unref(L, LUA_REGISTRYINDEX, exists->second->origRefconRegIndex);

		// me->module_free_tracked(*exists);		// Hah! A dealloc function? Yeah, right.
	}
}

std::optional<std::string> xlua_checkoptstring(lua_State* L, int narg)
{
	if (lua_isnil(L, narg))
	{
		return std::nullopt;
	}

	return std::make_optional<std::string>(luaL_checkstring(L, narg));
}

std::optional<float> xlua_checkoptfloat(lua_State* L, int narg)
{
	if (lua_isnil(L, narg))
	{
		return std::nullopt;
	}

	return std::make_optional<float>(static_cast<float>(luaL_checknumber(L, narg)));
}

std::optional<double> xlua_checkoptdouble(lua_State* L, int narg)
{
	if (lua_isnil(L, narg))
	{
		return std::nullopt;
	}

	return std::make_optional<double>(static_cast<double>(luaL_checknumber(L, narg)));
}

std::optional<int> xlua_checkoptint(lua_State* L, int narg)
{
	if (lua_isnil(L, narg))
	{
		return std::nullopt;
	}

	return std::make_optional<int>(static_cast<int>(luaL_checkinteger(L, narg)));
}
