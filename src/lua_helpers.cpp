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


#include "../log.h"

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
	luaL_traceback(L, L, lua_tostring(L, -1), 2);
	lua_getfield(L, LUA_GLOBALSINDEX, "debug");
	lua_getfield(L, -1, "traceback");
	lua_pushvalue(L, 1);
	lua_pushinteger(L, 1);
	lua_call(L,2,1);

#if !defined (NO_LOG_MESSAGE)
	// IMC make sure we see the message in the log file!
	log_message("xlua: traceback: %s\n", lua_tostring(L, -1));
#endif

//	lua_getfield(L, LUA_GLOBALSINDEX, "STP");
//	lua_getfield(L, -1, "stacktrace");
//	lua_pushvalue(L, 1);
//	lua_pushinteger(L, 2);
//	lua_call(L,2,1);
//
	return 1;
}

int lua_pushtraceback(lua_State * L)
{
	lua_pushcfunction(L, traceback);
	return lua_gettop(L);
}

static void setup_std_vars(lua_State * L, int dbg)
{
	 lua_getfield(L, LUA_GLOBALSINDEX, "setup_callback_var");
	 fmt_pcall(L,dbg,"sf","SIM_PERIOD",XPLMGetDataf(g_sim_period));

	 lua_getfield(L, LUA_GLOBALSINDEX, "setup_callback_var");
	 fmt_pcall(L,dbg,"si","IN_REPLAY",XPLMGetDatai(g_replay_active) != 0 ?  1 : 0);
}	

int fmt_pcall(lua_State * L, int dbg, const char * fmt, ...)
{
	va_list va;
	va_start(va, fmt);
	int r = vfmt_pcall(L, dbg, fmt, va);
	va_end(va);
	return r;
}

int vfmt_pcall(lua_State * L, int dbg, const char * fmt, va_list va)
{
	const char * f = fmt;
	int count = 0;
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
		case 's':
			lua_pushstring(L, va_arg(va, const char *));
			break;
		}
		++f;
		++count;
	}
	int e = lua_pcall(L, count, 0, dbg);
	if(e != 0)
	{
#if defined (NO_LOG_MESSAGE)
		printf("%s\n", lua_tostring(L, -1));
#else
		//char buffer[2048];
		//sprintf_s(buffer, sizeof(buffer), "xlua: call failed: %s\n", lua_tostring(L, -1));
		//XPLMDebugString(buffer);
		const char* msg = lua_tostring(L, -1);
		log_message("xlua: call failed code: %d, msg: %s\n", e, msg);
#endif
		lua_pop(L,-1);
	}
	return e;
}

int fmt_pcall_stdvars(lua_State * L, int dbg, const char * fmt, ...)
{
	setup_std_vars(L, dbg);
	va_list va;
	va_start(va, fmt);
	int r = vfmt_pcall(L, dbg, fmt, va);
	va_end(va);
	return r;
}
