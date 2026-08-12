// KEEP IN SYNC WITH XPLMUtilities.xml: these hand-written bodies back the
// lua_impl="external" declarations of XPLMRegisterCommandHandler and
// XPLMUnregisterCommandHandler there. A missing/renamed impl fails the link - but
// the XML's params/return/desc (which become the published EmmyLua docs) are NOT
// checked, so if you change what these take or return, update the XML too or the
// docs silently go stale.
//
// See xlua_command_bindings.h for why these two are not auto-generated.
//
// Note the <callback name="XPLMCommandCallback_f"> element in XPLMUtilities.xml is
// deliberately left alone, so the generated glue still emits its now-uncalled static
// cb_XPLMCommandCallback_f thunk. That orphan is intentional: removing it means
// exclude="lua" on the callback, which also deletes the ---@alias
// XPLMCommandCallback_f that both functions' published ---@field signatures
// reference, i.e. it trades a dead static for broken user-facing type docs. Clang
// does not warn about it as built here; if some toolchain does, that is the reason
// it stays.

#include "shared_xpfuncs.h"
#include "shared_lua_helpers.h"
#include "xlua_command_bindings.h"

#include <XPLMUtilities.h>

extern "C" {
	#include <lauxlib.h>
}

#include <vector>

// Defined in the generated XPLMUtilities_glue.cpp, which every build that compiles
// this file also compiles.
extern "C" XPLMCommandRef* Make_XPLMCommandRef(lua_State* L, XPLMCommandRef const& init);

namespace {

// Must match the name the codegen uses for this callback type: it is the key under
// which the closure is stored in notify_cb_t::callbacks.
char const* const kCommandCallbackSig = "XPLMCommandCallback_f";

// One handler registration, as XPLM sees it. `cb` is the record whose address was
// handed to XPLM as the refcon, so keeping it here is what makes an exact
// unregister possible. Holding the shared_ptr also keeps the Lua closure pinned for
// as long as XPLM can still call us, independent of s_RegisteredCallbacks.
struct cmd_binding {
	lua_State*                   L;
	XPLMCommandRef               cmd;
	bool                         before;
	std::shared_ptr<notify_cb_t> cb;
};

// INVARIANT: exactly one s_bindings instance per process module - same rule as
// s_timers in xptimers.cpp, and for the same reason. This is a static in a TU
// compiled separately into xlua.xpl and into the host's glua library. That is
// correct here rather than merely tolerable: each binary registers its handlers
// with its OWN xlua_command_handler address, so a list is only ever asked about
// registrations made through the copy of the thunk it shares a TU with.
std::vector<cmd_binding> s_bindings;

// Resolve the traceback handler for fmt_pcall_stdvars from the shared __debug_proc
// global that both loaders plant. Same helper as xptimers.cpp / the imgui window
// helpers - kept local so this file stays free of the module.h dependency, which
// would lock it to the xlua.xpl per-aircraft context (the host's glua does not
// compile module.cpp).
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

// The C thunk XPLM calls. Mirrors the body the codegen used to emit for this
// callback type, except for find_debug_proc (see above).
int xlua_command_handler(XPLMCommandRef inCommand, XPLMCommandPhase inPhase, void* inRefcon)
{
	int res = {};
	notify_cb_t const* inRefcon_cb = static_cast<notify_cb_t*>(inRefcon);

	lua_State* L = setup_lua_callback(inRefcon_cb, kCommandCallbackSig);
	if (L)
	{
		Make_XPLMCommandRef(L, inCommand);
		int inCommand_typed_ref = luaL_ref(L, LUA_REGISTRYINDEX);

		if (0 == fmt_pcall_stdvars(L, find_debug_proc(L), true, "rir", inCommand_typed_ref, inPhase, inRefcon_cb->get_capture()))
		{
			res = lua_toboolean(L, -1) ? 1 : 0;
			lua_pop(L, 1);
		}
		luaL_unref(L, LUA_REGISTRYINDEX, inCommand_typed_ref);
	}

	return res;
}

// Raw-identity comparison of a stored registry ref against a stack slot. Identity,
// not equality, is the right test: XPLM matches a registration on the exact
// callback+refcon it was given, so two structurally-equal-but-distinct Lua values
// are two different registrations, exactly as two C function pointers would be.
bool ref_matches_arg(lua_State* L, int stored_ref, int arg_idx)
{
	bool const arg_is_nil = lua_isnoneornil(L, arg_idx);

	// A nil value round-trips through luaL_ref as LUA_REFNIL, which notify_cb_t
	// remaps to a unique negative sentinel - not a registry index, so there is
	// nothing to fetch. Anything <= 0 therefore means "was nil".
	if (stored_ref <= 0)
		return arg_is_nil;

	if (arg_is_nil)
		return false;

	lua_rawgeti(L, LUA_REGISTRYINDEX, stored_ref);
	bool const eq = lua_rawequal(L, -1, arg_idx);
	lua_pop(L, 1);
	return eq;
}

// Does this binding correspond to the (handler, refcon) pair on the stack?
bool binding_matches_args(lua_State* L, cmd_binding const& b, int handler_idx, int refcon_idx)
{
	auto const stored = b.cb->callbacks.find(kCommandCallbackSig);
	if (stored == b.cb->callbacks.end())
		return false;

	return ref_matches_arg(L, stored->second, handler_idx)
		&& ref_matches_arg(L, b.cb->get_capture(), refcon_idx);
}

} // namespace

extern "C" int XLuaRegisterCommandHandler(lua_State* L)
{
	XPLMCommandRef inComand = {};
	if (lua_isuserdata(L, 1))
	{
		inComand = xlua_checkuserdata<XPLMCommandRef>(L, 1, "Expected XPLMCommandRef");
	}

	// Validate the plain scalar first. The codegen emitted this check last purely
	// because of the order its parameter loop runs in; doing it up front means a bad
	// call cannot leave a pinned userref behind when luaL_checktype longjmps out.
	bool const inBefore = xlua_checkboolean(L, 3);

	std::shared_ptr<notify_cb_t> cb_capture_0 = capture_lua_value(L, 4);
	xlua_persist_userref(L, cb_capture_0);
	wrap_next_lua_func(cb_capture_0, 2, false, kCommandCallbackSig);

	// Record before registering: XPLM can dispatch the moment the handler is in, and
	// a handler that runs before its association exists would be un-unregisterable.
	s_bindings.push_back({ L, inComand, inBefore, cb_capture_0 });

	XPLMRegisterCommandHandler(inComand, xlua_command_handler, inBefore, cb_capture_0.get());

	return 0;
}

extern "C" int XLuaUnregisterCommandHandler(lua_State* L)
{
	XPLMCommandRef inComand = {};
	if (lua_isuserdata(L, 1))
	{
		inComand = xlua_checkuserdata<XPLMCommandRef>(L, 1, "Expected XPLMCommandRef");
	}

	luaL_checktype(L, 2, LUA_TFUNCTION);			// Never returns if it is not one.
	bool const inBefore = xlua_checkboolean(L, 3);

	for (auto it = s_bindings.begin(); it != s_bindings.end(); ++it)
	{
		if (it->L != L || it->cmd != inComand || it->before != inBefore)
			continue;
		if (!binding_matches_args(L, *it, 2, 4))
			continue;

		XPLMUnregisterCommandHandler(inComand, xlua_command_handler, inBefore, it->cb.get());
		xlua_remove_callback(it->cb);
		s_bindings.erase(it);
		return 0;
	}

	// Deliberately no XPLM call on a miss. Passing a refcon XPLM never saw is what
	// broke this in the first place, and staying quiet about it is what made the
	// breakage so hard to spot from a script.
	log_message(L, "ERROR: XPLMUnregisterCommandHandler found no handler registered with this exact function and refcon. Pass the same values you registered with.\n");
	return 0;
}

void xlua_command_bindings_cleanup(lua_State* L)
{
	// Unregistering here is the point, not housekeeping. A plugin unload would have
	// XPLMCommandCleanupHook scrub these by plugin ID, but a plain disable/enable
	// does not - and the notify_cb_t each refcon points at is freed by
	// xlua_callback_cleanup immediately after this returns. Leaving the registration
	// in place would hand the next dispatch a dangling refcon.
	for (auto it = s_bindings.begin(); it != s_bindings.end(); )
	{
		if (it->L == L)
		{
			XPLMUnregisterCommandHandler(it->cmd, xlua_command_handler, it->before, it->cb.get());
			it = s_bindings.erase(it);
		}
		else
		{
			++it;
		}
	}
}
