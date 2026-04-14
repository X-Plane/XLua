//
//  xptimers.cpp
//  xlua
//
//  Created by Benjamin Supnik on 4/13/16.
//
//	Copyright 2016, Laminar Research
//	This source code is licensed under the MIT open source license.
//	See LICENSE.txt for the full terms of the license.

#include "xptimers.h"
#include "module.h"
#include "log.h"
#include "xpfuncs.h"
#include "shared_xpfuncs.h"

#include <XPLMDataAccess.h>

#include <list>
#include <memory>

class notify_cb_t;
class xlua_timer
{
public:
	xlua_timer() = delete;
	xlua_timer(xlua_timer_f fn, std::shared_ptr<notify_cb_t> cb) : m_func(fn), m_ref(cb) {}

	xlua_timer_f 	m_func = nullptr;
	std::shared_ptr<notify_cb_t>	m_ref = nullptr;
	
	double			m_next_fire_time = -1;
	double			m_repeat_interval = -1;	// -1 to stop after 1 timeout
};

static std::list<xlua_timer> s_timers;

xlua_timer* xlua_find_timer(lua_State* L, xlua_timer_f func, std::shared_ptr<notify_cb_t> ref)
{
	if (!ref)
	{
		return nullptr;
	}

	for (auto& t : s_timers)
	{
		if (t.m_func == func &&
			    ref->callbacks.contains(kTimerCallbackSig) &&
			t.m_ref->callbacks.contains(kTimerCallbackSig)
			)
		{
			lua_rawgeti(L, LUA_REGISTRYINDEX, ref->callbacks.at(kTimerCallbackSig));
			lua_rawgeti(L, LUA_REGISTRYINDEX, t.m_ref->callbacks.at(kTimerCallbackSig));
			bool match = lua_equal(L, -1, -2);
			lua_pop(L, 2);

			if (match)
			{
				return &t;
			}
		}
	}

	return nullptr;
}

xlua_timer* xlua_create_timer(lua_State *L, xlua_timer_f func, std::shared_ptr<notify_cb_t> ref)
{
	if (xlua_find_timer(L, func, ref) != nullptr)
	{
		log_message(L, "ERROR: timer already exists.");
		return nullptr;
	}

	xlua_timer& nt = s_timers.emplace_back(func, ref);

	if (s_timers.size() > 1000)
	{
		luaL_error(L, "%s has created more than 1000 timers. Something appears to be wrong.",
				   module::module_from_interp(L)->get_script_path().c_str());
	}
	return &nt;
}

void xlua_run_timer(lua_State* L, xlua_timer * t, double delay, double repeat)
{
	if (std::find_if(s_timers.cbegin(), s_timers.cend(), [t](xlua_timer const& st) {return t == &st; }) == s_timers.cend())
	{
		log_message(L, "ERROR: unknown timer was requested to run.");
		return;
	}

	t->m_repeat_interval = repeat;
	if(delay == -1.0)
		t->m_next_fire_time = delay;
	else
		t->m_next_fire_time = xlua_get_simulated_time() + delay;
}

int xlua_is_timer_scheduled(lua_State* L, xlua_timer* t)
{
	if (t == nullptr)
		return 0;

	if (std::find_if(s_timers.cbegin(), s_timers.cend(), [t](xlua_timer const& st) {return t == &st; }) == s_timers.cend())
	{
		log_message(L, "ERROR: unknown timer schedule was queried.");
		return 0;
	}

	if (t->m_next_fire_time == -1.0)
		return 0;

	return 1;
}

double xlua_get_timer_remaining(lua_State* L, xlua_timer* t)
{
	if (t == nullptr || t->m_next_fire_time < 0)
	{
		return -1.0;
	}

	if (std::find_if(s_timers.cbegin(), s_timers.cend(), [t](xlua_timer const& st) {return t == &st; }) == s_timers.cend())
	{
		log_message(L, "ERROR: unknown timer remaining was queried.");
		return -1.0;
	}

	if (t->m_next_fire_time < 0)
	{
		return -1.0;
	}

	return t->m_next_fire_time - xlua_get_simulated_time();
}

void xlua_do_timers_for_time(double now)
{
	for (auto ti = s_timers.begin(); ti != s_timers.end();)
	{
		xlua_timer& t = *ti;

		if (t.m_next_fire_time >= 0 && t.m_next_fire_time <= now)
		{
			// Clear the timer details _before_ the callback so that subsequent checks on expiry time or scheduling are more appropriate.
			if (t.m_repeat_interval < 0)
				t.m_next_fire_time = -1.0;
			else
				t.m_next_fire_time += t.m_repeat_interval;

			t.m_func(t.m_ref);
		}

		if (t.m_next_fire_time < 0)
		{
			// We're not being run again so unwrap the function, allowing lua to garbage collect.
			ti = s_timers.erase(ti);
		}
		else
		{
			++ti;
		}
	}
}

void xlua_timer_cleanup()
{
	s_timers.clear();
}

double xlua_get_simulated_time(void)
{
	static XPLMDataRef sim_time = XPLMFindDataRef("sim/time/total_running_time_sec");
	return XPLMGetDataf(sim_time);
}
