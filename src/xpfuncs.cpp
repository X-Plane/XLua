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

#include "../log.h"

/*
	TODO: figure out when we have to resync our datarefs
	TODO: what if dref already registered before acf reload?  (maybe no harm?)
	TODO: test x-plane-side string read/write - needs test not at startup

 */

static XPLMDataRef drSimRealTime = nullptr;

static int l_my_print(lua_State* L);

// This is kind of a mess - Lua [annoyingly] doesn't give you a way to store a closure/Lua interpreter function
// in C space.  The hack is to use luaL_ref to fill a new key in the registry table with a copy of ANY value from
// the stack - since this is type agnostic and takes a strong reference it (1) prevents the closure from being 
// garbage collected and (2) works with closures.

struct notify_cb_t {
	lua_State *		L;
	int				slot;
};

// Given an interp and a stack arg that is a lua function/closure,
// this routine stashes a strong ref to the closure in the registry,
// allcoates a callback struct and stashes the slot and interp in the
// CB struct.  This CB struct is a single C ptr that we can use to 
// reconstruct the closure from C land.
//
// If the closure is actually nil, we return NULL and allocate nothing.
// The memory is tracked by the interp's module and is collected for us
// at shutdown.
notify_cb_t * wrap_lua_func(lua_State * L, int idx)
{
	if(lua_isnil(L, idx))
	{
		luaL_argerror(L, idx, "nil not allowed for callback");
		return NULL;
	}
	luaL_checktype(L, idx, LUA_TFUNCTION);
	
	module * me = module::module_from_interp(L);
	notify_cb_t * cb = (notify_cb_t *) me->module_alloc_tracked(sizeof(notify_cb_t));
	cb = new notify_cb_t;
	cb->L = L;
	lua_pushvalue (L, idx);
	cb->slot = luaL_ref(L, LUA_REGISTRYINDEX);		
	return cb;
}

notify_cb_t * wrap_lua_func_nil(lua_State * L, int idx)
{
	if(lua_isnil(L,idx))
	{
		return NULL;
	}
	return wrap_lua_func(L, idx);
}

// Given a void * that is really a CB struct, this routine either
// pushes the lua function onto the stack (so that we can then push 
// args and pcall) or returns 0 if we should not call because the CB is
// nil or borked.
lua_State * setup_lua_callback(void * ref)
{
	if(ref == NULL) 
		return NULL;
	notify_cb_t * cb = (notify_cb_t *) ref;
	lua_rawgeti (cb->L, LUA_REGISTRYINDEX, cb->slot);
	if(!lua_isfunction(cb->L, -1))
	{
#if defined (NO_LOG_MESSAGE)
		printf("ERROR: we did not persist a closure?!?");
#else
		log_message("xlua: ERROR: we did not persist a closure?!?");
#endif
		lua_pop(cb->L, 1);
		return 0;
	}
	return cb->L;
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
		const char * err_msg = luaL_checkstring(L,1);
#if defined (NO_LOG_MESSAGE)
		printf("%s: %s", name, err_msg);
#else
		log_message("xlua: %s: %s", name, err_msg);
#endif
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

static void xlua_notify_helper(xlua_dref * who, void * ref)
{
	lua_State * L = setup_lua_callback(ref);
	if(L)
	{
		fmt_pcall_stdvars(L,module::debug_proc_from_interp(L),"");
	}
}

// XPLMCreateDataRef name "array[4]" "yes" func -> dref
static int XLuaCreateDataRef(lua_State * L)
{
	const char * name = luaL_checkstring(L, 1);
	const char * typestr = luaL_checkstring(L,2);
	const char * writable = luaL_checkstring(L,3);	
	notify_cb_t * cb = wrap_lua_func_nil(L, 4);
	
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
	
	xlua_dref * r = xlua_create_dref(
							name,
							my_type,
							my_dim,
							my_writeable,
							(my_writeable && cb) ? xlua_notify_helper : NULL,
							cb);							
	assert(r);
	
    xlua_pushuserdata(L, r);
	return 1;
	
}

// dref -> "array[4]"
static int XLuaGetDataRefType(lua_State * L)
{
	xlua_dref * d = xlua_checkuserdata<xlua_dref*>(L,1,"expected dataref");

	xlua_dref_type dt = xlua_dref_get_type(d);
	
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
	double idx = luaL_checknumber(L, 2);	
	
	lua_pushnumber(L, xlua_dref_get_array(d,idx));
	return 1;	
}

// XPLMSetArray dref dix value
static int XLuaSetArray(lua_State * L)
{
	xlua_dref * d = xlua_checkuserdata<xlua_dref*>(L,1,"expected dataref");
	double idx = luaL_checknumber(L, 2);
	double v = luaL_checknumber(L, 3);
	
	xlua_dref_set_array(d,idx,v);
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

	xlua_cmd * r = xlua_create_cmd(name,desc);
	assert(r);
	
    xlua_pushuserdata(L, r);
	return 1;
}

static void cmd_cb_helper(xlua_cmd * cmd, int phase, float elapsed, void * ref)
{
	lua_State * L = setup_lua_callback(ref);
	if(L)
	{
		fmt_pcall_stdvars(L,module::debug_proc_from_interp(L),"if",phase, elapsed);
	}
}

// XPLMReplaceCommand cmd handler
static int XLuaReplaceCommand(lua_State * L)
{
	xlua_cmd * d = xlua_checkuserdata<xlua_cmd*>(L,1,"expected command");
	notify_cb_t * cb = wrap_lua_func(L, 2);
	
	xlua_cmd_install_handler(d, cmd_cb_helper, cb);
	return 0;	
}

// XPLMWrapCommand cmd handler1 handler2
static int XLuaWrapCommand(lua_State * L)
{
	xlua_cmd * d = xlua_checkuserdata<xlua_cmd*>(L,1,"expected command");
	notify_cb_t * cb1 = wrap_lua_func(L, 2);
	notify_cb_t * cb2 = wrap_lua_func(L, 3);
	
	xlua_cmd_install_pre_wrapper(d, cmd_cb_helper, cb1);
	xlua_cmd_install_post_wrapper(d, cmd_cb_helper, cb2);
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
	lua_State * L = setup_lua_callback(ref);
	if(L)
	{
		fmt_pcall_stdvars(L,module::debug_proc_from_interp(L),"");
	}	
}

// XPLMCreateTimer func -> ptr
static int XLuaCreateTimer(lua_State * L)
{
	notify_cb_t * helper = wrap_lua_func(L, -1);
	if(helper == NULL)
		return 0;
	
	xlua_timer * t = xlua_create_timer(timer_cb, helper);
	assert(t);
	
    xlua_pushuserdata(L, t);
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

#define FUNC_LIST \
	FUNC(XLuaGetCode) \
	FUNC(XLuaFindDataRef) \
	FUNC(XLuaCreateDataRef) \
	FUNC(XLuaGetDataRefType) \
	FUNC(XLuaGetNumber) \
	FUNC(XLuaSetNumber) \
	FUNC(XLuaGetArray) \
	FUNC(XLuaSetArray) \
	FUNC(XLuaGetString) \
	FUNC(XLuaSetString) \
	FUNC(XLuaFindCommand) \
	FUNC(XLuaCreateCommand) \
	FUNC(XLuaReplaceCommand) \
	FUNC(XLuaWrapCommand) \
	FUNC(XLuaCommandStart) \
	FUNC(XLuaCommandStop) \
	FUNC(XLuaCommandOnce) \
	FUNC(XLuaCreateTimer) \
	FUNC(XLuaRunTimer) \
	FUNC(XLuaIsTimerScheduled) \
	FUNC(XLuaReloadOnFlightChange)

static int l_my_print(lua_State *L)
{
	int nargs = lua_gettop(L);
	module *me = module::module_from_interp(L);

	char prefix[256];
	float hrs, min, sec, real_time = XPLMGetDataf(drSimRealTime);
	hrs = (int)(real_time / 3600.0f);
	min = (int)(real_time / 60.0f) - (int)(hrs * 60.0f);
	sec = real_time-(hrs * 3600.0f) - (min * 60.0f);
	sprintf(prefix, "%d:%02d:%06.3f LUA: ", (int)hrs, (int)min, sec);

	// Unwieldy... but on the other hand, lua debug statements could in theory come from anywhere, from
	// several different instances of xlua at the same time so the full path probably is needed.
	std::string output = prefix + me->get_log_path() + "\n";
	XPLMDebugString(output.c_str());
	output.clear();

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
	XPLMDebugString(prefix);
	XPLMDebugString(output.c_str());

	return 0;
}

static const struct luaL_Reg printlib[] = {
	{ "print", l_my_print },
	{ NULL, NULL } /* end of array */
};

void	add_xpfuncs_to_interp(lua_State * L)
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
