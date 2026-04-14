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

#ifndef XPLM200
#define XPLM200
#endif
#ifndef XPLM210
#define XPLM210
#endif
#ifndef XPLM300
#define XPLM300
#endif

#include <XPLMUtilities.h>
#include <XPLMDataAccess.h>

#include "log.h"

/*
	TODO: figure out when we have to resync our datarefs
	TODO: what if dref already registered before acf reload?  (maybe no harm?)
	TODO: test x-plane-side string read/write - needs test not at startup

 */

static XPLMDataRef drSimRealTime = nullptr;
void xlua_apply_jit_setting(bool enable);

static int l_my_print(lua_State* L);
static void output_log_line(const std::string& line, const std::string& dedupe_key, char level);
static void emit_repeat_summary();

static std::string g_last_log_line;
static std::string g_last_log_key;
static size_t g_last_log_repeats = 0;
static const size_t kRepeatSummaryInterval = 64;
static int g_logging_enabled = 1;
static XPLMDataRef drLogEnabled = nullptr;
static int g_jit_enabled = 0;
static XPLMDataRef drJitEnabled = nullptr;
static XPLMCommandRef g_log_toggle_cmd = nullptr;
static XPLMCommandRef g_jit_toggle_cmd = nullptr;
static char g_last_log_level = 'I';

static int xlua_get_log_enabled(void* /*ref*/)
{
	return g_logging_enabled;
}

static int xlua_get_jit_enabled(void* /*ref*/)
{
	return g_jit_enabled;
}

static void xlua_set_log_enabled(void* /*ref*/, int value)
{
	g_logging_enabled = (value != 0);
	emit_repeat_summary();
}

static void xlua_set_jit_enabled(void* /*ref*/, int value)
{
	g_jit_enabled = (value != 0);
	xlua_apply_jit_setting(g_jit_enabled != 0);
}

static int xlua_log_toggle_cb(XPLMCommandRef /*inCommand*/, XPLMCommandPhase inPhase, void* /*inRefcon*/)
{
	if (inPhase != xplm_CommandBegin)
		return 1;
	g_logging_enabled = !g_logging_enabled;
	emit_repeat_summary();
	char buf[96];
	snprintf(buf, sizeof(buf), "%s logging %s\n", get_log_prefix().c_str(), g_logging_enabled ? "enabled" : "disabled");
	XPLMDebugString(buf);
	return 1;
}

static int xlua_jit_toggle_cb(XPLMCommandRef /*inCommand*/, XPLMCommandPhase inPhase, void* /*inRefcon*/)
{
	if (inPhase != xplm_CommandBegin)
		return 1;
	g_jit_enabled = !g_jit_enabled;
	xlua_apply_jit_setting(g_jit_enabled != 0);
	return 1;
}

static int xlua_absindex(lua_State* L, int idx)
{
	if (idx < 0 && idx > LUA_REGISTRYINDEX)
		return lua_gettop(L) + idx + 1;
	return idx;
}

static bool xlua_ns_has_metatable(lua_State* L, int idx)
{
	int abs_idx = xlua_absindex(L, idx);
	if (lua_getmetatable(L, abs_idx) == 0)
		return false;
	lua_pop(L, 1);
	return true;
}

static bool xlua_ns_seems_like_prop(lua_State* L, int idx)
{
	int abs_idx = xlua_absindex(L, idx);
	if (!lua_istable(L, abs_idx))
		return false;
	lua_getfield(L, abs_idx, "__get");
	bool has_get = lua_isfunction(L, -1);
	lua_pop(L, 1);
	if (!has_get)
		return false;
	lua_getfield(L, abs_idx, "__set");
	bool has_set = lua_isfunction(L, -1);
	lua_pop(L, 1);
	return has_set;
}

static bool xlua_ns_seems_like_object(lua_State* L, int idx)
{
	int abs_idx = xlua_absindex(L, idx);
	if (!lua_istable(L, abs_idx))
		return false;
	if (xlua_ns_has_metatable(L, abs_idx))
		return true;
	lua_pushnil(L);
	while (lua_next(L, abs_idx) != 0)
	{
		if (lua_isfunction(L, -1))
		{
			lua_pop(L, 2);
			return true;
		}
		lua_pop(L, 1);
	}
	return false;
}

static void xlua_ns_rawset_field(lua_State* L, int table_idx, int key_idx, int value_idx)
{
	int abs_table = xlua_absindex(L, table_idx);
	lua_pushvalue(L, key_idx);
	lua_pushvalue(L, value_idx);
	lua_rawset(L, abs_table);
}

static int xlua_ns_index(lua_State* L)
{
	if (!lua_istable(L, 1))
	{
		lua_pushnil(L);
		return 1;
	}

	lua_getfield(L, 1, "functions");
	int func_tbl = lua_gettop(L);
	lua_pushvalue(L, 2);
	lua_rawget(L, func_tbl); // -> functions[key]
	if (lua_istable(L, -1))
	{
		lua_getfield(L, -1, "__get");
		if (lua_isfunction(L, -1))
		{
			lua_pushvalue(L, -2);
			lua_call(L, 1, 1);
			lua_remove(L, func_tbl); // remove functions table
			return 1;
		}
		lua_pop(L, 1); // pop __get
	}
	lua_pop(L, 2); // pop functions[key] and functions table

	lua_getfield(L, 1, "values");
	int val_tbl = lua_gettop(L);
	lua_pushvalue(L, 2);
	lua_rawget(L, val_tbl);
	if (!lua_isnil(L, -1))
	{
		lua_remove(L, val_tbl);
		return 1;
	}
	lua_pop(L, 2);

	lua_getfield(L, 1, "parent");
	if (!lua_isnil(L, -1))
	{
		lua_pushvalue(L, 2);
		lua_gettable(L, -2);
		return 1;
	}
	lua_pop(L, 1);
	lua_pushnil(L);
	return 1;
}

static void xlua_ns_wrap_table(lua_State* L, int ns_idx, int value_idx)
{
	int abs_val = xlua_absindex(L, value_idx);
	lua_newtable(L);
	int new_ns = lua_gettop(L);

	lua_newtable(L);
	lua_setfield(L, new_ns, "functions");
	lua_newtable(L);
	lua_setfield(L, new_ns, "values");
	lua_newtable(L);
	lua_setfield(L, new_ns, "raw_table_keys");
	lua_pushnil(L);
	lua_setfield(L, new_ns, "parent");

	if (lua_getmetatable(L, xlua_absindex(L, ns_idx)))
		lua_setmetatable(L, new_ns);

	lua_getfield(L, new_ns, "functions");
	int new_funcs = lua_gettop(L);
	lua_getfield(L, new_ns, "values");
	int new_vals = lua_gettop(L);

	lua_pushnil(L);
	while (lua_next(L, abs_val) != 0)
	{
		int key_idx = lua_gettop(L) - 1;
		int val_idx = lua_gettop(L);
		if (xlua_ns_seems_like_prop(L, val_idx))
		{
			xlua_ns_rawset_field(L, new_funcs, key_idx, val_idx);
		}
		else
		{
			xlua_ns_rawset_field(L, new_vals, key_idx, val_idx);
		}
		lua_pop(L, 1);
	}

	lua_pop(L, 2); // functions and values tables
}

static int xlua_ns_newindex(lua_State* L)
{
	if (!lua_istable(L, 1))
		return 0;

	lua_getfield(L, 1, "functions");
	int func_tbl = lua_gettop(L);
	lua_pushvalue(L, 2);
	lua_rawget(L, func_tbl);
	if (!lua_isnil(L, -1))
	{
		lua_getfield(L, -1, "__set");
		if (lua_isfunction(L, -1))
		{
			lua_pushvalue(L, -2);
			lua_pushvalue(L, 3);
			lua_call(L, 2, 0);
		}
		lua_pop(L, 2); // prop + functions table
		return 0;
	}
	lua_pop(L, 1); // pop nil
	lua_pop(L, 1); // pop functions table

	bool keep_table_verbatim = false;
	lua_getfield(L, 1, "raw_table_keys");
	if (lua_istable(L, -1))
	{
		lua_pushvalue(L, 2);
		lua_rawget(L, -2);
		keep_table_verbatim = !lua_isnil(L, -1);
		lua_pop(L, 1);
	}
	lua_pop(L, 1); // raw_table_keys

	lua_getfield(L, 1, "values");
	int values_tbl = lua_gettop(L);

	if (!keep_table_verbatim &&
		lua_istable(L, 3) &&
		!xlua_ns_seems_like_object(L, 3) &&
		!xlua_ns_has_metatable(L, 3))
	{
		xlua_ns_wrap_table(L, 1, 3);
		int wrapped_idx = lua_gettop(L);
		lua_pushvalue(L, 2);
		lua_pushvalue(L, wrapped_idx);
		lua_rawset(L, values_tbl);
		lua_pop(L, 2); // wrapped + values table
		return 0;
	}

	lua_pushvalue(L, 2);
	lua_pushvalue(L, 3);
	lua_rawset(L, values_tbl);
	lua_pop(L, 1); // values table
	return 0;
}

static int xlua_ns_create_prop(lua_State* L)
{
	luaL_checktype(L, 1, LUA_TTABLE);
	const char * name = luaL_checkstring(L, 2);
	if (!lua_istable(L, 3) && !lua_isfunction(L, 3))
		luaL_argerror(L, 3, "expected property or function");
	lua_getfield(L, 1, "functions");
	lua_pushvalue(L, 3);
	lua_setfield(L, -2, name);
	lua_pop(L, 1);
	return 0;
}

static int XLuaCreateNamespace(lua_State* L)
{
	lua_newtable(L);
	int ns = lua_gettop(L);

	lua_newtable(L);
	lua_setfield(L, ns, "functions");
	lua_newtable(L);
	lua_setfield(L, ns, "values");
	lua_newtable(L);
	lua_setfield(L, ns, "raw_table_keys");

	lua_pushvalue(L, LUA_GLOBALSINDEX);
	lua_setfield(L, ns, "parent");

	lua_pushcfunction(L, xlua_ns_create_prop);
	lua_setfield(L, ns, "create_prop");

	lua_newtable(L);
	int mt = lua_gettop(L);
	lua_pushcfunction(L, xlua_ns_index);
	lua_setfield(L, mt, "__index");
	lua_pushcfunction(L, xlua_ns_newindex);
	lua_setfield(L, mt, "__newindex");

	// Defer pairs/ipairs/len to existing Lua helpers to keep behavior intact.
	lua_getglobal(L, "namespace_pairs");
	if (lua_isfunction(L, -1))
		lua_setfield(L, mt, "__pairs");
	else
		lua_pop(L, 1);
	lua_getglobal(L, "namespace_ipairs");
	if (lua_isfunction(L, -1))
		lua_setfield(L, mt, "__ipairs");
	else
		lua_pop(L, 1);
	lua_getglobal(L, "namespace_len");
	if (lua_isfunction(L, -1))
		lua_setfield(L, mt, "__len");
	else
		lua_pop(L, 1);

	lua_setmetatable(L, ns);
	return 1;
}

// Helpers for namespace metamethods
static int XLuaCreateNamespace(lua_State* L);
static int xlua_ns_index(lua_State* L);
static int xlua_ns_newindex(lua_State* L);

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
		log_message(cb->L, "ERROR: we did not persist a closure?!?");
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
	
	xlua_dref * r = xlua_create_dref(L,
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
			snprintf(buf, sizeof(buf), "array[%d]", xlua_dref_get_dim(d));
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

	xlua_cmd * r = xlua_create_cmd(L,name,desc);
	assert(r);
	
    xlua_pushuserdata(L, r);
	return 1;
}

static int cmd_filter_cb_helper(xlua_cmd* cmd, int phase, float elapsed, void* ref)
{
	int res = 1;

	lua_State* L = setup_lua_callback(ref);
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
	lua_State * L = setup_lua_callback(ref);
	if(L)
	{
		fmt_pcall_stdvars(L, module::debug_proc_from_interp(L),"if",phase, elapsed);
	}

	return 1;
}

// XPLMFilterCommand handler
static int XLuaFilterCommand(lua_State* L)
{
	xlua_cmd* cmd = xlua_checkuserdata<xlua_cmd*>(L, 1, "expected command");
	notify_cb_t* cb_filter = wrap_lua_func(L, 2);

	xlua_cmd_install_filter(L, cmd, cmd_filter_cb_helper, cb_filter);

	return 0;
}

// XPLMReplaceCommand cmd handler
static int XLuaReplaceCommand(lua_State * L)
{
	xlua_cmd * d = xlua_checkuserdata<xlua_cmd*>(L,1,"expected command");
	notify_cb_t * cb = wrap_lua_func(L, 2);
	
	xlua_cmd_install_handler(L,d, cmd_cb_helper, cb);
	return 0;	
}

// XPLMWrapCommand cmd handler1 handler2
static int XLuaWrapCommand(lua_State * L)
{
	xlua_cmd * d = xlua_checkuserdata<xlua_cmd*>(L,1,"expected command");
	notify_cb_t * cb1 = wrap_lua_func(L, 2);
	notify_cb_t * cb2 = wrap_lua_func(L, 3);
	
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
	snprintf(log, sizeof(log), "Aircraft scripts will be fully reloaded when flight details change.");

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
	FUNC(XLuaFilterCommand) \
	FUNC(XLuaCommandStart) \
	FUNC(XLuaCommandStop) \
	FUNC(XLuaCommandOnce) \
	FUNC(XLuaCreateTimer) \
	FUNC(XLuaRunTimer) \
	FUNC(XLuaIsTimerScheduled) \
	FUNC(XLuaGetTimerRemaining) \
	FUNC(XLuaReloadOnFlightChange) \
	FUNC(XLuaCreateNamespace)

std::string get_log_prefix(char l)
{
	char prefix[256];
	float hrs, min, sec, real_time = XPLMGetDataf(drSimRealTime);
	hrs = (int)(real_time / 3600.0f);
	min = (int)(real_time / 60.0f) - (int)(hrs * 60.0f);
	sec = real_time - (hrs * 3600.0f) - (min * 60.0f);
	snprintf(prefix, sizeof(prefix), "%d:%02d:%06.3f %c/LUA: ", (int)hrs, (int)min, sec, l);

	return std::string(prefix);
}

static int l_my_print(lua_State *L)
{
	int nargs = lua_gettop(L);
	module *me = module::module_from_interp(L);

	std::string prefix = get_log_prefix();

	// Unwieldy... but on the other hand, lua debug statements could in theory come from anywhere, from
	// several different instances of xlua at the same time so the full path probably is needed.
	output_log_line(prefix + me->get_log_path() + "\n", me->get_log_path() + "\n", 'I');

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

	output += "\n";
	output_log_line(prefix + output, output, 'I');

	return 0;
}

int log_message(lua_State *L, char const* const format, ...)
{
	if (!g_logging_enabled)
		return 0;
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
			
			std::string stack_line(prefix);
			stack_line += buffer;
			output_log_line(stack_line, buffer, lp);
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

	output_log_line(output, buffer, lp);

	return result;
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
	if (drLogEnabled == nullptr)
	{
		drLogEnabled = XPLMRegisterDataAccessor(
			"xlua/logging_enabled",
			xplmType_Int,
			1,
			xlua_get_log_enabled,
			xlua_set_log_enabled,
			nullptr, nullptr,
			nullptr, nullptr,
			nullptr, nullptr,
			nullptr, nullptr,
			nullptr, nullptr,
			nullptr,
			nullptr);
	}
	if (drJitEnabled == nullptr)
	{
		drJitEnabled = XPLMRegisterDataAccessor(
			"xlua/jit_enabled",
			xplmType_Int,
			1,
			xlua_get_jit_enabled,
			xlua_set_jit_enabled,
			nullptr, nullptr,
			nullptr, nullptr,
			nullptr, nullptr,
			nullptr, nullptr,
			nullptr, nullptr,
			nullptr,
			nullptr);
	}
	if (g_log_toggle_cmd == 0)
	{
		g_log_toggle_cmd = XPLMCreateCommand("xlua/logging_toggle", "Toggle XLua logging output");
		XPLMRegisterCommandHandler(g_log_toggle_cmd, xlua_log_toggle_cb, 1, nullptr);
	}
	if (g_jit_toggle_cmd == 0)
	{
		g_jit_toggle_cmd = XPLMCreateCommand("xlua/jit_toggle", "Toggle XLua JIT runtime");
		XPLMRegisterCommandHandler(g_jit_toggle_cmd, xlua_jit_toggle_cb, 1, nullptr);
	}

	// Register the custom print handler
	lua_getglobal(L, "_G");
	luaL_register(L, NULL, printlib);
	lua_pop(L, 1);
}

static void emit_repeat_summary()
{
	if (g_last_log_line.empty() || g_last_log_repeats == 0)
		return;

	char buffer[128];
	snprintf(buffer, sizeof(buffer), "Previous message repeated %zu additional times\n", g_last_log_repeats);
	std::string summary = get_log_prefix(g_last_log_level);
	summary += buffer;
	XPLMDebugString(summary.c_str());
	printf("%s", summary.c_str());
	g_last_log_repeats = 0;
}

static void output_log_line(const std::string& line, const std::string& dedupe_key, char level)
{
	if (!g_logging_enabled)
		return;
	if (level == g_last_log_level && dedupe_key == g_last_log_key)
	{
		++g_last_log_repeats;
		if (g_last_log_repeats >= kRepeatSummaryInterval)
		{
			emit_repeat_summary();
		}
		return;
	}

	emit_repeat_summary();
	g_last_log_line = line;
	g_last_log_key = dedupe_key;
	g_last_log_level = level;
	g_last_log_repeats = 0;
	XPLMDebugString(line.c_str());
	printf("%s", line.c_str());
}

void xlua_flush_log_queue(void)
{
	emit_repeat_summary();
	g_last_log_line.clear();
	g_last_log_key.clear();
	g_last_log_level = 'I';
}
