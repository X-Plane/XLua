//
//  xptimers.h
//  xlua
//
//  Created by Benjamin Supnik on 4/13/16.
//
//	Copyright 2016, Laminar Research
//	This source code is licensed under the MIT open source license.
//	See LICENSE.txt for the full terms of the license.

#ifndef xptimers_h
#define xptimers_h

#include "lua.h"

typedef void (* xlua_timer_f)(void * ref);
struct xlua_timer;

xlua_timer *		xlua_create_timer(lua_State* L, xlua_timer_f func, void * ref);
void				xlua_run_timer(xlua_timer * t, double delay, double repeat);
int					xlua_is_timer_scheduled(xlua_timer * t);
double				xlua_get_timer_remaining(xlua_timer* t);

void xlua_do_timers_for_time(double now);
void xlua_timer_cleanup();



double xlua_get_simulated_time();


#endif /* xptimers_h */
