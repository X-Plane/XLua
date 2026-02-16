//
//  lua_helpers.cpp
//  xlua
//
//  Created by Benjamin Supnik on 4/13/16.
//
//	Copyright 2016, Laminar Research
//	This source code is licensed under the MIT open source license.
//	See LICENSE.txt for the full terms of the license.

#include "lua_helpers.h"
#include <string.h>
#include <stdarg.h>
#include <XPLMDataAccess.h>
#include <XPLMUtilities.h>
#include <XPLMPlugin.h>
#include <XPLMDisplay.h>

#include "log.h"
#include "xpfuncs.h"

extern XPLMDataRef				g_replay_active;
extern XPLMDataRef				g_sim_period;

#if 0
int validate_args(lua_State * L, const char * fmt)
{
	if(strlen(fmt) != lua_gettop(L))
	{
		printf("Wrong numer of args: expected %d, got %d\n", (int) strlen(fmt), lua_gettop(L));
		return 0;
	}
	
	int i = 1;
	while(*fmt)
	{
		switch(*fmt) {
		case 's':
			if (!lua_isstring(L, i))
			{
				printf("Argument %d should be a string.\n", i);
				return 0;
			}
			break;
		case 'n':
			if (!lua_isnumber(L, i))
			{
				printf("Argument %d should be a number.\n", i);
				return 0;
			}
			break;
		case 't':
			if (!lua_istable(L, i))
			{
				printf("Argument %d should be a table.\n", i);
				return 0;
			}
			break;
		case 'p':
			if (!lua_islightuserdata(L, i))
			{
				printf("Argument %d should be a command or dataref.\n", i);
				return 0;
			}
			break;
		case 'f':
			if (!lua_isfunction(L, i) && !lua_isnil(L, i))
			{
				printf("Argument %d should be a command or dataref.\n", i);
				return 0;
			}
			break;		
		}
		++fmt;
		++i;
	}
	
	return 1;
}
#endif

static int traceback(lua_State * L)
{
	luaL_traceback(L, L, lua_tostring(L, 1), 2);			// Push the traceback
	lua_getfield(L, LUA_GLOBALSINDEX, "debug");				// The table of debug functions
	lua_getfield(L, -1, "traceback");						// Function debug.traceback
	lua_remove(L, -2);										// Kill the debug table entry

	lua_pushvalue(L, 1);									// Passed-in parameter 1, the error description string
	lua_pushinteger(L, 1);									// Trace depth

	lua_call(L,2,1);

	// IMC make sure we see the message in the log file!
	// Pass nullptr here so we don't get a duplicate stack trace.
	log_message(nullptr, "traceback: %s\n", lua_tostring(L, -1));

	return 1;
}

int lua_pushtraceback(lua_State * L)
{
	lua_pushcfunction(L, traceback);
	return lua_gettop(L);
}

void setup_std_vars(lua_State * L, int dbg)
{
	lua_pushnumber(L, XPLMGetDataf(g_sim_period));
	lua_setglobal(L, "SIM_PERIOD");

	lua_pushnumber(L, XPLMGetDatai(g_replay_active));
	lua_setglobal(L, "IN_REPLAY");
}

template<>
int vfmt_pcall(lua_State* L, int dbg, bool expects_returnval, const char* fmt, va_list va)
{
	const char * f = fmt;
	int arg_count = 0;
	while(*f)
	{
		switch(*f) {
		case 'f':
		case 'd':
			lua_pushnumber(L, va_arg(va, double));
			break;
		case 'i':
			lua_pushinteger(L, va_arg(va, int));
			break;
		case 'b':
			lua_pushboolean(L, va_arg(va, bool));
			break;
		case 's':
			lua_pushstring(L, va_arg(va, const char *));
			break;
		case 'n':
			lua_pushnil(L);
			break;
		case 'r':
			lua_rawgeti(L, LUA_REGISTRYINDEX, va_arg(va, int));
			break;
		case 'u':		// userdata
			xlua_pushuserdata<void*>(L, va_arg(va, void*));
			break;
		default:
			xlua_pushuserdata<void*>(L, va_arg(va, void*));
			break;
		}

		++f;
		++arg_count;
	}
	int e = lua_pcall(L, arg_count, expects_returnval ? 1 : 0, dbg);
	if(e != 0)
	{
		const char* msg = lua_tostring(L, -1);
		if (dbg == 0 || e == LUA_ERRERR)
		{
			// In dbg mode the traceback handler will have been called, which already prints this message.
			log_message(L, "lua call failed code: %d, msg: %s\n", e, msg);
		}
		lua_pop(L, 1);
	}
	return e;
}

void clear_table(lua_State* L, int idx)
{
	if (idx > 0)
	{
		lua_pushnil(L);  // First key

		while (lua_next(L, idx) != 0)
		{
			lua_pop(L, 1);           // Remove value, keep key
			lua_pushvalue(L, -1);    // Duplicate key
			lua_pushnil(L);          // Push nil as new value
			lua_settable(L, idx);	 // table[key] = nil
		}
	}
}

////////////////////////////////////////////////////
// Custom tostring functions for XPLM defined types.
////////////////////////////////////////////////////

extern "C" int _XPLMPluginID_tostring(lua_State* L)
{
	XPLMPluginID const test1 = xlua_checkuserdata<XPLMPluginID>(L, 1, "Expected XPLMPluginID");
	
	char pname[256] = "";
	XPLMGetPluginInfo(test1, pname, nullptr, nullptr, nullptr);
	lua_pop(L, 1);

	lua_pushstring(L, pname);
	return 1;
}

extern "C" int _XPLMHotKeyID_tostring(lua_State* L)
{
	XPLMHotKeyID const test1 = xlua_checkuserdata<XPLMHotKeyID>(L, 1, "Expected XPLMHotKeyID");

	char kname[256] = "";
	XPLMGetHotKeyInfo(test1, nullptr, nullptr, kname, nullptr);
	lua_pop(L, 1);

	lua_pushstring(L, kname);
	return 1;
}

extern "C" int _XPLMDataRef_tostring(lua_State* L)
{
	XPLMDataRef const test1 = xlua_checkuserdata<XPLMDataRef>(L, 1, "Expected XPLMDataRef");

	XPLMDataRefInfo_t info = { .structSize = sizeof(XPLMDataRefInfo_t) };
	XPLMGetDataRefInfo(test1, &info);
	lua_pop(L, 1);

	lua_pushstring(L, info.name);
	return 1;
}
