// KEEP IN SYNC WITH XPLMProcessing.xml: these hand-written bodies back the
// lua_impl="external" timer declarations there. A missing/renamed impl fails the
// link — but the XML's params/return/desc (which become the published EmmyLua
// docs) are NOT checked, so if you change what a function takes or returns here,
// update the XML too or the docs silently go stale.
//
// XLua timer bindings (XLuaCreateTimer / XLuaRunTimer / XLuaFindTimer /
// XLuaIsTimerScheduled / XLuaGetTimerRemaining) plus XLuaReloadOnFlightChange.
//
// Declared in XPLMProcessing.xml with lua_impl="external" exclude="c|pascal|php",
// so header_parser emits no marshalling glue — only the EmmyLua stub and a
// registration entry in the generated XLua_Register_glue.cpp that points at the
// extern "C" definitions below.
//
// This file owns the whole XLua timer story (see xptimers.h for who uses it): the
// timer subsystem (the live-timer list + pump) AND the Lua bindings. It is
// compiled into BOTH the host's glua library and xlua.xpl; the shared callback
// infrastructure (shared_xpfuncs.cpp) is likewise present in both. The bindings
// were relocated here from xpfuncs.cpp so the host (which does not compile the
// module-coupled xpfuncs.cpp) can link them.

#include "shared_xpfuncs.h"
#include "shared_lua_helpers.h"
#include "xptimers.h"
#include "xpfuncs.h"      // extern decl of kTimerCallbackSig (defined below)

#include <XPLMDataAccess.h>

extern "C" {
	#include <lauxlib.h>
}

#include <cassert>
#include <list>
#include <memory>

std::string const kTimerCallbackSig("TimerCallback");

// ───────────────────────────────────────────────────────────────────────────
// Timer subsystem (the live-timer list + pump). Formerly xptimers.{h,cpp}.
// ───────────────────────────────────────────────────────────────────────────

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

// INVARIANT: exactly one s_timers instance per process module. This is a static
// in a TU compiled separately into xlua.xpl and into the host's glua library —
// two separate binaries, two separate lists, each driven by its own flight loop
// (xlua.cpp's master cb for xlua.xpl; the host driver in XPLMDLLUtils.cpp for
// the direct loader). NEVER link this TU into a single target that also loads
// xlua.xpl, or the two timer sets merge and every timer fires twice.
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
				   get_current_script_path(L).generic_string().c_str());
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

// Shared timer pump. only_state == nullptr fires every timer (xlua.xpl, one
// flight loop for all modules); a non-null only_state fires just that
// interpreter's timers (the XPLM direct loader, one flight loop per plugin).
static void do_timers_for_time(double now, lua_State* only_state)
{
	for (auto ti = s_timers.begin(); ti != s_timers.end();)
	{
		xlua_timer& t = *ti;

		if (only_state && (!t.m_ref || t.m_ref->L != only_state))
		{
			++ti;
			continue;
		}

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

void xlua_do_timers_for_time(double now)
{
	do_timers_for_time(now, nullptr);
}

void xlua_do_timers_for_time_for_state(lua_State* L, double now)
{
	do_timers_for_time(now, L);
}

void xlua_timer_cleanup()
{
	s_timers.clear();
}

void xlua_remove_timers_for_state(lua_State* L)
{
	// Erase before the caller closes L: ~notify_cb_t luaL_unrefs into L, so the
	// interpreter must still be open when the shared_ptr drops here.
	s_timers.remove_if([L](xlua_timer const& t) {
		return t.m_ref && t.m_ref->L == L;
	});
}

double xlua_get_simulated_time(void)
{
	static XPLMDataRef sim_time = XPLMFindDataRef("sim/time/total_running_time_sec");
	return XPLMGetDataf(sim_time);
}

// ───────────────────────────────────────────────────────────────────────────
// Lua bindings
// ───────────────────────────────────────────────────────────────────────────

namespace {

// Resolve the traceback handler for fmt_pcall_stdvars from the shared
// __debug_proc global that both loaders plant (XPLMDLLUtils.cpp / module.cpp).
// This is the same helper as xlua2_window_helpers.cpp's find_debug_proc — kept
// local so this file stays free of the module.h dependency, which would lock it
// to the xlua.xpl per-aircraft context.
int find_debug_proc(lua_State* L)
{
	lua_getglobal(L, "__debug_proc");
	int v = 0;
	if (lua_isuserdata(L, -1))
	{
		if (int* p = static_cast<int*>(lua_touserdata(L, -1))) v = *p;
	}
	lua_pop(L, 1);
	return v;
}

void timer_callback(std::shared_ptr<notify_cb_t> ref)
{
	lua_State* L = setup_lua_callback(ref.get(), kTimerCallbackSig);
	if (L)
	{
		fmt_pcall_stdvars(L, find_debug_proc(L), false, "");
	}
}

} // namespace

// XPLMCreateTimer func -> ptr
extern "C" int XLuaCreateTimer(lua_State* L)
{
	std::shared_ptr<notify_cb_t> timer_cb = std::make_shared<notify_cb_t>(L, 0);
	if (!wrap_next_lua_func(timer_cb, -1, false, kTimerCallbackSig))
	{
		return 0;
	}

	xlua_timer* t = xlua_create_timer(L, timer_callback, timer_cb);
	assert(t);

	xlua_pushuserdata(L, t);
	return 1;
}

extern "C" int XLuaFindTimer(lua_State* L)
{
	std::shared_ptr<notify_cb_t> timer_cb = std::make_shared<notify_cb_t>(L, 0);
	wrap_next_lua_func(timer_cb, -1, false, kTimerCallbackSig);

	xlua_timer* timer = xlua_find_timer(L, timer_callback, timer_cb);
	if (timer == nullptr)
	{
		lua_pushnil(L);
	}
	else
	{
		xlua_pushuserdata(L, timer);
	}

	return 1;
}

// Get the number of seconds a timer has to go, or -1 if not scheduled.
extern "C" int XLuaGetTimerRemaining(lua_State* L)
{
	xlua_timer* t = xlua_checkuserdata<xlua_timer*>(L, 1, "expected timer");
	if (t == nullptr)
	{
		lua_pushnumber(L, -1);
	}
	else
	{
		lua_pushnumber(L, xlua_get_timer_remaining(L, t));
	}

	return 1;
}

// XPLMRunTimer timer delay repeat
extern "C" int XLuaRunTimer(lua_State* L)
{
	xlua_timer* t = xlua_checkuserdata<xlua_timer*>(L, 1, "expected timer");
	if (!t)
		return 0;

	xlua_run_timer(L, t, lua_tonumber(L, -2), lua_tonumber(L, -1));
	return 0;
}

// XPLMIsTimerScheduled ptr -> int
extern "C" int XLuaIsTimerScheduled(lua_State* L)
{
	xlua_timer* t = xlua_checkuserdata<xlua_timer*>(L, 1, "expected timer");
	int sched = xlua_is_timer_scheduled(L, t);
	lua_pushboolean(L, sched);
	return 1;
}

// XLuaReloadOnFlightChange marks the aircraft's scripts for full reload whenever
// flight details change — meaningful only where the XLua command/reload subsystem
// exists (xlua.xpl and mobile, which compile xpcommands.cpp's real definition).
// The host/direct-loader build has no such subsystem, so it provides a host-side
// no-op in XPLMDLLUtils.cpp (which glua links against). Only declared here; never
// defined in this TU, so there's no duplicate-symbol clash in any build.
void xlua_cmd_mark_reload_on_change(void);

extern "C" int XLuaReloadOnFlightChange(lua_State* L)
{
	// Informational, not an error — pass nullptr so log_message uses the "LUA I:"
	// prefix (a non-null L makes it walk the stack and switch to "LUA E:").
	log_message(nullptr, "Aircraft scripts will be fully reloaded when flight details change.");
	xlua_cmd_mark_reload_on_change();
	return 0;
}
