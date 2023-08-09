//
//  xpdatarefs.h
//  xlua
//
//  Created by Ben Supnik on 3/20/16.
//
//	Copyright 2016, Laminar Research
//	This source code is licensed under the MIT open source license.
//	See LICENSE.txt for the full terms of the license.

#ifndef xpdatarefs_h
#define xpdatarefs_h

#include <string>
#include "lua.h"

using std::string;

struct	xlua_dref;

enum xlua_dref_type {
	xlua_none,
	xlua_number,
	xlua_array,
	xlua_string
};

typedef void (* xlua_dref_notify_f)(xlua_dref * who, void * ref);

xlua_dref *		xlua_find_dref(const char * name);
xlua_dref *		xlua_create_dref(lua_State* L,
						const char *				name, 
						xlua_dref_type			type, 
						int						dim, 
						int						writable, 
						xlua_dref_notify_f		func, 
						void *					ref);

xlua_dref_type	xlua_dref_get_type(xlua_dref * who);
int				xlua_dref_get_dim(xlua_dref * who);

double			xlua_dref_get_number(xlua_dref * who);
void			xlua_dref_set_number(xlua_dref * who, double value);
double			xlua_dref_get_array(xlua_dref * who, int n);
void			xlua_dref_set_array(xlua_dref * who, int n, double value);
string			xlua_dref_get_string(xlua_dref * who);
void			xlua_dref_set_string(xlua_dref * who, const string& value);

// This attempts to re-establish the name->dref link for any unresolved drefs.  This can be used if we declare
// our dref early and then ANOTHER add-on is loaded that defines it.
void			xlua_relink_all_drefs();

// This deletes EVERY dataref, reclaiming all memory - used once at cleanup.
void			xlua_dref_cleanup();

// Iterates every dataref that Lua knows about and makes sure that they're all valid.
void			xlua_validate_drefs();

#endif /* xpdatarefs_h */
