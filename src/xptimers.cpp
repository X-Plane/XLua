//
//  xptimers.cpp
//  xlua
//
//  Created by Benjamin Supnik on 4/13/16.
//
//	Copyright 2016, Laminar Research
//	This source code is licensed under the MIT open source license.
//	See LICENSE.txt for the full terms of the license.

#include <cstdio>
#include "xptimers.h"
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <XPLMProcessing.h>
#include <XPLMDataAccess.h>

#include "log.h"

struct xlua_timer {
	xlua_timer *	m_next = nullptr;
	xlua_timer_f 	m_func;
	void *			m_ref;
	
	double			m_next_fire_time;
	double			m_repeat_interval;	// -1 to stop after 1
};

static xlua_timer * s_timers = nullptr;

xlua_timer * xlua_create_timer(xlua_timer_f func, void * ref)
{
	for(xlua_timer * t = s_timers; t; t = t->m_next)
	if(t->m_func == func && t->m_ref == ref)
	{
		printf("ERROR: timer already exists.");
		log_message("ERROR: timer already exists.");
		return NULL;
	}

	xlua_timer * nt = new xlua_timer;
	nt->m_next = s_timers;
	s_timers = nt;
	nt->m_next_fire_time = -1.0;
	nt->m_repeat_interval = -1.0;
	nt->m_func = func;
	nt->m_ref = ref;
	return nt;
}

void xlua_run_timer(xlua_timer * t, double delay, double repeat)
{
	t->m_repeat_interval = repeat;
	if(delay == -1.0)
		t->m_next_fire_time = delay;
	else
		t->m_next_fire_time = xlua_get_simulated_time() + delay;
}

int xlua_is_timer_scheduled(xlua_timer * t)
{
	if(t == NULL)
		return 0;
	if(t->m_next_fire_time == -1.0)
		return 0;
	return 1;	
}


void xlua_do_timers_for_time(double now)
{
	for(xlua_timer * t = s_timers; t; t = t->m_next)
	if(t->m_next_fire_time != -1.0 && t->m_next_fire_time <= now)
	{
		t->m_func(t->m_ref);
		if(t->m_repeat_interval == -1.0)
			t->m_next_fire_time = -1.0;
		else
			t->m_next_fire_time += t->m_repeat_interval;
	}	
}

void xlua_timer_cleanup()
{
	while(s_timers)
	{
		xlua_timer * k = s_timers;
		s_timers = s_timers->m_next;
		delete k;
	}

	assert(s_timers == nullptr);
}


double xlua_get_simulated_time(void)
{
	static XPLMDataRef sim_time = XPLMFindDataRef("sim/time/total_running_time_sec");
	return XPLMGetDataf(sim_time);
}
