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

#include <string>
#include <string.h>

extern "C" {
#include <lua.h>
#include <lauxlib.h>
};

void	add_xpfuncs_to_interp(lua_State * interp);
std::string get_log_prefix(char l='I');

template <typename T>
T xlua_checkuserdata(lua_State * L, int narg, const char * msg)
{
    T* ret = static_cast<T*>(lua_touserdata(L, narg));
    if(ret == NULL)
        luaL_argerror(L, narg, msg);
    return *ret;
}

template<typename T>
void xlua_pushuserdata(lua_State * state, T data)
{
    T* ud = static_cast<T*>(lua_newuserdata(state, sizeof(T)));
    memcpy(ud, &data, sizeof(T));
}

template <typename T>
T xlua_checkfunction(lua_State* L, int narg, const char* msg)
{
    T* ret = static_cast<T*>(lua_tofunction(L, narg));
    if (ret == NULL)
        luaL_argerror(L, narg, msg);
    return *ret;
}

template <typename T>
T&& xlua_checknamedstruct(lua_State* L, int narg, const char* msg)
{
#error Lua tables are not in guaranteed order. Check the stack contains the table
#error and then create a local T, populating it by member name. Somehow.

#error Alternatively, force all struct creation to be done in XLua, returning some kind of type-safe
#error container and in this call, check the container is the expected one. Probably better solution.

    if (lua_istable(L, narg))
    {
        T* ret = static_cast<T*>(lua_totable(L, narg));
        if (ret != NULL)
            return *ret;
    }

    luaL_argerror(L, narg, msg);
}

void InitScripts(void);
void CleanupScripts(void);

#endif /* xpfuncs_h */
