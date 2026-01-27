//
//  lua_helpers.h
//  xlua
//
//  Created by Benjamin Supnik on 4/13/16.
//
//	Copyright 2016, Laminar Research
//	This source code is licensed under the MIT open source license.
//	See LICENSE.txt for the full terms of the license.

#ifndef lua_helpers_h
#define lua_helpers_h

#include <stdarg.h>
#include <type_traits>

extern "C" {
	#include <lua.h>
	#include <lauxlib.h>
};

void setup_std_vars(lua_State* L, int dbg);

// Calls the lua func at the stack top with "fmt" args, passed as var-args.
// Returns the lua error if there is one or 0 if success; lua error message
// is printed automagically.
// i - int passed as number
// If there is a returnval, it will be left on the lua stack.

// Absolutely, positively, no unexpected, silent int/bool conversions.
template<typename B>
concept BoolOnly = std::is_same_v<B, bool>;

template<BoolOnly B>
int vfmt_pcall(lua_State* L, int dbg, B expects_returnval, const char* fmt, va_list va);

template<BoolOnly B>
int fmt_pcall(lua_State* L, int dbg, B expects_returnval, const char* fmt, ...)
{
	va_list va;
	va_start(va, fmt);
	int r = vfmt_pcall<B>(L, dbg, expects_returnval, fmt, va);
	va_end(va);
	return r;
}

template<BoolOnly B>
int fmt_pcall_stdvars(lua_State* L, int dbg, B expects_returnval, const char* fmt, ...)
{
	setup_std_vars(L, dbg);
	va_list va;
	va_start(va, fmt);
	int r = vfmt_pcall<B>(L, dbg, expects_returnval, fmt, va);
	va_end(va);
	return r;
}

int lua_pushtraceback(lua_State* L);

void clear_table(lua_State* L, int idx);

#endif /* lua_helpers_h */
