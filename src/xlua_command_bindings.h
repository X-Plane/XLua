// XLua command-handler Lua bindings.
//
// XPLMRegisterCommandHandler / XPLMUnregisterCommandHandler are declared
// lua_impl="external" in XPLMUtilities.xml, so header_parser emits no marshalling
// glue for them - only the EmmyLua stub and a registration entry in the generated
// XLua_Register_glue.cpp pointing at the extern "C" definitions in
// xlua_command_bindings.cpp.
//
// Why hand-written: XPLM matches a handler for removal on the exact
// (callback, plugin, refcon) triple, and the refcon it holds is the address of the
// notify_cb_t that pins the Lua closure. The codegen has no notion of a
// deregistration, so it captured a *fresh* Lua value and handed XPLM that new
// pointer - which never matched, so the unregister was a silent no-op that leaked a
// pinned userref and left a registration holding a refcon XLua later freed
// (XPD-18356). Recovering the right pointer needs the (command, before, handler,
// refcon) association recorded at registration time, which is what this file owns.

#ifndef XLUA_COMMAND_BINDINGS_H
#define XLUA_COMMAND_BINDINGS_H

extern "C" {
#include "lua.h"
}

// Drop every association owned by interpreter `L`, unregistering each handler from
// XPLM on the way out. Call this while `L` is still open and BEFORE
// xlua_callback_cleanup(L), which frees the notify_cb_t records XPLM still holds as
// refcons. Both loaders must call it: module::shutdown_lua for xlua.xpl, and
// close_lua_interp for the XPLM direct loader.
void xlua_command_bindings_cleanup(lua_State* L);

extern "C" {
	int XLuaRegisterCommandHandler(lua_State* L);
	int XLuaUnregisterCommandHandler(lua_State* L);
}

#endif /* XLUA_COMMAND_BINDINGS_H */
