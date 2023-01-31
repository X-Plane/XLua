//
//  xpfuncs.h
//  xlua
//
//  Created by Ben Supnik on 3/19/16.
//
//	Copyright 2016, Laminar Research
//	This source code is licensed under the MIT open source license.
//	See LICENSE.txt for the full terms of the license.

#ifndef xpfuncs_h
#define xpfuncs_h

#include <cstring>

extern "C" {
#include <lua.h>
#include <lauxlib.h>
};

void	add_xpfuncs_to_interp(lua_State * interp);

template <typename T>
T xlua_checkuserdata(lua_State * L, int narg, const char * msg)
{
    void * ret = lua_touserdata(L, narg);
    if(ret == NULL)
        luaL_argerror(L, narg, msg);
    return *((T*)ret);
}

template<typename T>
void xlua_pushuserdata(lua_State * state, T data)
{
    void* ud = lua_newuserdata(state, sizeof(T));
    memcpy(ud, &data, sizeof(T));
}

void InitScripts(void);
void CleanupScripts(void);

#endif /* xpfuncs_h */
