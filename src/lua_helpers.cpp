#include "lua_helpers.h"
#include "module.h"

#include <XPLMDataAccess.h>

extern XPLMDataRef g_replay_active;
extern XPLMDataRef g_sim_period;

void setup_std_vars(lua_State * L, int dbg)
{
	::module const* mod = module::module_from_interp(L);
	if (mod != nullptr && mod->get_required_version()[0] == 1)
	{
		lua_pushnumber(L, XPLMGetDataf(g_sim_period));
		lua_setglobal(L, "SIM_PERIOD");

		lua_pushnumber(L, XPLMGetDatai(g_replay_active));
		lua_setglobal(L, "IN_REPLAY");
	}
}
