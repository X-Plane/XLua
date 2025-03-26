/*
 *   Floating Windows with imgui integration for FlyWithLua
 *   Copyright (C) 2018 Folke Will <folko@solhost.org>
 *   Released as public domain code.
 *
 */
#ifndef FLOATINGWINDOWS_FLWINTEGRATION_H_
#define FLOATINGWINDOWS_FLWINTEGRATION_H_

#include "../../LuaJIT-2.1.0/src/lua.hpp"

void LoadImguiBindings(lua_State* lState);

namespace flwnd {

void initFloatingWindowSupport(lua_State* L);
void deinitFloatingWindowSupport(lua_State* L);
void onFlightLoop(lua_State* L);

}

#endif /* FLOATINGWINDOWS_FLWINTEGRATION_H_ */
