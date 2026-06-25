// XLua timers — one home for the timer subsystem AND its Lua bindings.
//
// These timer functions (XLuaCreateTimer / XLuaRunTimer / etc.) are shared by
// BOTH XLua flavours:
//   * Legacy XLua 1.x (compat): init.lua's run_timer / run_after_time sugar calls
//     straight into them; xpfuncs.cpp hand-registers them for v1 scripts.
//   * XLua 2.x AND the XPLM direct loader: exposed as lua-only SDK functions via
//     the codegen (declared lua_impl="external" in XPLMProcessing.xml, registered
//     by add_xplm_to_interp).
// So this is deliberately NOT named "xlua2_*": the bindings predate XLua 2 and
// stay available to 1.x. Implementations live in xptimers.cpp.

#ifndef XPTIMERS_H
#define XPTIMERS_H

extern "C" {
#include "lua.h"
}

#include <memory>

class xlua_timer;
class notify_cb_t;

// ── XLua timer subsystem ───────────────────────────────────────────────────
// The live-timer list + the pump that fires them. Each process module (xlua.xpl,
// the host's glua) compiles its own copy with its own static timer list — see the
// INVARIANT note at s_timers in xptimers.cpp.
typedef void (* xlua_timer_f)(std::shared_ptr<notify_cb_t> ref);

xlua_timer*  xlua_find_timer(lua_State* L, xlua_timer_f func, std::shared_ptr<notify_cb_t> ref);
xlua_timer*  xlua_create_timer(lua_State* L, xlua_timer_f func, std::shared_ptr<notify_cb_t> ref);
void         xlua_run_timer(lua_State* L, xlua_timer* t, double delay, double repeat);
int          xlua_is_timer_scheduled(lua_State* L, xlua_timer* t);
double       xlua_get_timer_remaining(lua_State* L, xlua_timer* t);

void xlua_do_timers_for_time(double now);

// Fire only the timers bound to interpreter `L`. The XPLM direct loader hosts each
// .lua plugin in its own lua_State with its own per-plugin flight loop, so it ticks
// each interpreter's timers independently (xlua.xpl shares one flight loop across
// all modules and uses xlua_do_timers_for_time instead).
void xlua_do_timers_for_time_for_state(lua_State* L, double now);

void xlua_timer_cleanup();

// Remove every timer whose callback is bound to interpreter `L`. The XPLM direct
// loader can unload one .lua plugin while others keep running, so it drops just
// that interpreter's timers before lua_close. (xlua.xpl tears all modules down
// together and uses xlua_timer_cleanup instead.)
void xlua_remove_timers_for_state(lua_State* L);

double xlua_get_simulated_time();

// ── XLua timer Lua bindings (lua_impl="external" in XPLMProcessing.xml) ─────
// The generated register glue points at the hand-written extern "C" definitions
// in xptimers.cpp. Also referenced directly by xpfuncs.cpp to register them for
// XLua 1.x scripts, which do not run add_xplm_to_interp.
extern "C" {
	int XLuaCreateTimer(lua_State* L);
	int XLuaRunTimer(lua_State* L);
	int XLuaFindTimer(lua_State* L);
	int XLuaIsTimerScheduled(lua_State* L);
	int XLuaGetTimerRemaining(lua_State* L);
	int XLuaReloadOnFlightChange(lua_State* L);
}

#endif /* XLUA2_TIMERS_H */
