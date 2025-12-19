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

#define NOMINMAX

#include <string>
#include <string.h>
#include <map>
#include <optional>
#include <algorithm>

extern "C" {
#include <lua.h>
#include <lauxlib.h>
};

void	add_xlua_funcs_to_interp(lua_State * interp);
std::string get_log_prefix(char l='I');

// This is kind of a mess - Lua [annoyingly] doesn't give you a way to store a closure/Lua interpreter function
// in C space.  The hack is to use luaL_ref to fill a new key in the registry table with a copy of ANY value from
// the stack - since this is type agnostic and takes a strong reference it (1) prevents the closure from being 
// garbage collected and (2) works with closures.

struct notify_cb_t
{
    notify_cb_t() = delete;
    notify_cb_t(lua_State* inL)
    {
        L = inL;
    }

    lua_State*  L;
    int origRefconRegIndex;                     // Registry index for the captured original refcon value.
    std::map<std::string, int> callbacks;       // Map from function definition to registry index for the callback;
};

extern std::map<void*, notify_cb_t*> allRegisteredCallbacks;

notify_cb_t* wrap_lua_func_nil(lua_State* L, int idx, std::string const callbackKey);
notify_cb_t* wrap_lua_func(lua_State* L, int idx, std::string const callbackKey);
lua_State* setup_lua_callback(void* ref, std::string const callbackKey);
int capture_lua_value(lua_State* L, int idx);

void CleanupStoredCallbacks(lua_State* L, int keyIndexInRegistry);
notify_cb_t* wrap_first_lua_func(lua_State* L, int func_stack_idx, std::string const cb_typename, int refcon_reg_index);
bool wrap_next_lua_func(notify_cb_t* cb_record, int func_stack_idx, std::string const cb_typename);

// Syntactic sugar to make the code-generation simpler.
inline bool         xlua_checkboolean(lua_State* L, int narg)   { luaL_checktype(L, narg, LUA_TBOOLEAN); return lua_toboolean(L, narg); }
inline int          xlua_checkinteger(lua_State* L, int narg)   { return luaL_checkinteger(L, narg); }
inline lua_Number   xlua_checknumber (lua_State* L, int narg)   { return luaL_checknumber(L, narg); }
inline char const*  xlua_checkstring (lua_State* L, int narg)   { return luaL_checkstring(L, narg); }
inline uint8_t      xlua_checkbyte   (lua_State* L, int narg)   { return static_cast<uint8_t>(std::clamp(luaL_checkinteger(L, narg), static_cast<lua_Integer>(0), static_cast<lua_Integer>(255))); }

inline void         xlua_pushinteger (lua_State* L, lua_Integer v)  { lua_pushinteger(L, v); }
inline void         xlua_pushnumber  (lua_State* L, lua_Number v)   { lua_pushnumber(L, v); }
inline void         xlua_pushbyte    (lua_State* L, lua_Integer v)  { lua_pushinteger(L, std::clamp(v, static_cast<lua_Integer>(0), static_cast<lua_Integer>(255))); }

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

std::optional<std::string> xlua_checkoptstring(lua_State* L, int narg);
std::optional<float>       xlua_checkoptfloat(lua_State* L, int narg);
std::optional<double>      xlua_checkoptdouble(lua_State* L, int narg);
std::optional<int>         xlua_checkoptint(lua_State* L, int narg);

void InitScripts(void);
void CleanupScripts(void);

#endif /* xpfuncs_h */
