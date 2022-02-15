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

extern "C" {
#include <lua.h>
#include <lauxlib.h>
};

void	add_xpfuncs_to_interp(lua_State * interp);

void InitScripts(void);
void CleanupScripts(void);

#endif /* xpfuncs_h */
