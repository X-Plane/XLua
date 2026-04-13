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

#include <map>
#include <string>

extern "C" {
	#include <lua.h>
};

void	add_xlua_funcs_to_interp(lua_State * interp, int compat_version);
extern std::map<int, char const*> gXPMessageParamTypes;

extern std::string const kTimerCallbackSig;
extern std::string const kDatarefCallbackSig;
extern std::string const kFilterCallbackSig;
extern std::string const kCommandCallbackSig;

void InitScripts();
void CleanupScripts();

#endif /* xpfuncs_h */
