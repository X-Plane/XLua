#include "shared_xpfuncs.h"

#include "XPLMUtilities.h"

#include <memory>
#include <cassert>
#include <unordered_set>

int notify_cb_t::nilRefCount = -100;

notify_cb_t::notify_cb_t(lua_State* inL, int s) : L(inL), origRefconRegIndex(s)
{
	// This will normally be a return from a luaL_ref call, always 0 or higher. However, if the refcon is nil then
	// luaL_ref returns LUA_REFNIL. We can't have all these mapping onto each other.
	if (origRefconRegIndex == LUA_REFNIL)
	{
		origRefconRegIndex = --nilRefCount;
	}
	else if (origRefconRegIndex != kNeverPersist && origRefconRegIndex < 0)
	{
		// If we've been created with any negative value except for LUA_REFNIL, or kNeverPersist, this is an XLua bug.
		assert(false);

		origRefconRegIndex = kNeverPersist;
	}
}

notify_cb_t::~notify_cb_t()
{
	if (L != nullptr)
	{
		if (origRefconRegIndex > 0)
		{
			luaL_unref(L, LUA_REGISTRYINDEX, origRefconRegIndex);
		}

		// Un-pin all functions.
		for (auto const& [name, regidx] : callbacks)
		{
			if (regidx > 0)
			{
				luaL_unref(L, LUA_REGISTRYINDEX, regidx);
			}
		}
	}
}

// Similar idea to above, but capture a value and just return the index into the registry.
std::shared_ptr<notify_cb_t> capture_lua_value(lua_State* L, int idx)
{
	lua_pushvalue(L, idx);
	return std::make_shared<notify_cb_t>(L, luaL_ref(L, LUA_REGISTRYINDEX));
}

int log_message(lua_State *L, char const* const format, ...)
{
	char buffer[2048];
	char lp = 'I';
	std::string prefix(get_log_prefix());

	if (L != nullptr)
	{
		lua_Debug ar = {};
		char const* line_prefix = "";

		for (int level = 0; lua_getstack(L, level, &ar); ++level)
		{
			if (lp == 'I')
			{
				lp = 'E';
				prefix = get_log_prefix(lp);
			}

			lua_getinfo(L, "nSl", &ar);

			char const* source_name = (ar.short_src[0] == 0 ? "memory" : ar.short_src);
			if (ar.source != nullptr && ar.source[0] == '=')
			{
				source_name = &ar.source[1];
			}

			if (ar.name == nullptr)
			{
				snprintf(buffer, sizeof(buffer), "%sOn line %d of '%s':\n", line_prefix, ar.currentline, source_name);
			}
			else
			{
				snprintf(buffer, sizeof(buffer), "%sIn %s on line %d of '%s':\n", line_prefix, ar.name, ar.currentline, source_name);
			}

			XPLMDebugString(prefix.c_str()); XPLMDebugString(buffer);
			printf("%s", prefix.c_str()); printf("%s", buffer);
			buffer[0] = 0;

			line_prefix = " -> ";
			memset(&ar, 0, sizeof(ar));
		}
	}

	va_list args;
	va_start(args, format);
	int result = vsnprintf(buffer, sizeof(buffer), format, args);
	va_end(args);

	std::string output(prefix);
	output += buffer;

	XPLMDebugString(output.c_str());
	printf("%s", output.c_str());

	return result;
}

bool wrap_next_lua_func(std::shared_ptr<notify_cb_t> cb_record, int func_stack_idx, bool optional, std::string const& cb_typename)
{
	if (!lua_isfunction(cb_record->L, func_stack_idx) && !lua_isnil(cb_record->L, func_stack_idx))
	{
		std::string extra_msg = cb_typename + " callback must be a function or nil";
		luaL_argerror(cb_record->L, func_stack_idx, extra_msg.c_str());
		return false;
	}

	if (!optional && lua_isnil(cb_record->L, func_stack_idx))
	{
		std::string extra_msg = cb_typename + " callback must be a function";
		luaL_argerror(cb_record->L, func_stack_idx, extra_msg.c_str());
		return false;
	}

	// Now store the registry reference index into the callback array, in the given position.
	lua_pushvalue(cb_record->L, func_stack_idx);
	cb_record->callbacks[cb_typename] = luaL_ref(cb_record->L, LUA_REGISTRYINDEX);

	return (cb_record->callbacks[cb_typename] != LUA_REFNIL);
}

// Given a void * that is really a CB struct, this routine either
// pushes the lua function onto the stack (so that we can then push
// args and pcall) or returns 0 if we should not call because the CB is
// nil or borked.
lua_State* setup_lua_callback(notify_cb_t const* cb, std::string const callbackKey)
{
	if (!cb)
		return nullptr;

	if (!xlua_is_callback_valid(cb))
	{
		log_message(nullptr, "ERROR: A closure '%s' cas called which was invalid. This is a plugin bug, not a script bug. Please report it.\n",
					callbackKey.c_str());
		return nullptr;
	}

	if (callbackKey.empty())
	{
		log_message(cb->L, "ERROR: Anonymous closure specified.\n");
		return nullptr;
	}

	auto storedKey = cb->callbacks.find(callbackKey);
	if (storedKey != cb->callbacks.end())
	{
		if (storedKey->second == LUA_REFNIL)
		{
			// The stored function was a nil - an optional function. Return nullptr but don't raise an error.
			return nullptr;
		}

		lua_rawgeti(cb->L, LUA_REGISTRYINDEX, storedKey->second);
		if (lua_isfunction(cb->L, -1))
		{
			return cb->L;
		}

		log_message(cb->L, "ERROR: we did not persist a closure?!?\n");
		lua_pop(cb->L, 1);
	}
	else
	{
		log_message(cb->L, "ERROR: Callback %s is not recognised!\n", callbackKey.c_str());
	}

	return nullptr;
}

// Transparent hash/equality keyed on the pointee address, so the owning set can be probed by a bare
// notify_cb_t*
struct cb_ref_hash
{
	using is_transparent = void;
	size_t operator()(notify_cb_t const* p)                 const noexcept { return std::hash<notify_cb_t const*>{}(p); }
	size_t operator()(std::shared_ptr<notify_cb_t> const& p) const noexcept { return std::hash<notify_cb_t const*>{}(p.get()); }
};

struct cb_ref_eq
{
	using is_transparent = void;
	static notify_cb_t const* addr(notify_cb_t const* p)                 noexcept { return p; }
	static notify_cb_t const* addr(std::shared_ptr<notify_cb_t> const& p) noexcept { return p.get(); }

	template <typename A, typename B>
	bool operator()(A const& a, B const& b) const noexcept { return addr(a) == addr(b); }
};

/*
* Note for Claude or other enthusiastic entities planning on changing how this set is used:
*
* Don't.
*
* This is an owning set of notify_cb_t records. Each element is a shared_ptr, and its identity - for hashing
* and equality - is the address of the pointee, which is exactly the opaque void* refcon XPLM holds. There is
* therefore no separate key that could be emplaced mismatched, or reseated out of sync with the value it points
* at, and set elements are const so the owning shared_ptr can never be repointed from under the registry.
* The one and only way to create a persistable entry here is using the same pattern that's used throughout:
* 
*  1) Capture a value from Lua's stack, pinning it to Lua's registry;
*     std::shared_ptr<notify_cb_t> cb_capture_0 = capture_lua_value(L, 16);
* 
*  2) Persist that value, including the registry index;
*     xlua_persist_userref(L, cb_capture_0);
* 
*  3) If a callback is needed, append it so that it's associated with this userref. Multiple different callbacks are fine.
*     wrap_next_lua_func(cb_capture_0, 4, true, "XPLMGetDatai_f");
* 
* Why is this?
* 
* Lua is a managed/garbage-collected language. Any XPLM function which accepts a "userref" or "refcon" value (different names,
* same function) treat that value as a black box; it is opaque to XPLM and the simulator. Lua is perfectly free to pass anything
* it likes - functions, strings, tables of tables of functions and strings... This means that the userref itself MUST
* be persisted to prevent it being potentially GC'd.
* 
* The problem is with lifetime. There is no standard usage pattern in XPLM for functions which accept a userref, except
* that they might at some point pass that userref back to the plugin that passed it.
* Some might use a callback synchronously. Some might use a callback asynchronously. Some might call it once, some many times,
* some only if specific events or user input occurs (i.e. potentially never). This is why they're _persisted_ - for most calls,
* the only thing that's certain about the required lifetime of the userref value is that it is unknown.
* 
* Some XPLM calls may have a recognisable deregister/deallocate function. That might not result in any callback, or it might
* use a callback synchronously, or it might trigger an action in the sim/XPLM which might or might not use a callback at some
* later point.
* 
* Cleaning this registry down
* ===========================
* userref values are, as noted, passed to XPLM as black boxes. They are void* . There is no retention at this level. When
* control is passed back to XLua, that void* must retain enough information to safely identify it, recover the Lua instance
* handle (many instances may be running at the same time), recover the (potentially complex) userdata value itself, and
* recover any persisted callbacks in Lua (because we need the function's persisted index in the Lua registry because the function
* itself might have been a lambda, and subject to GC without this). We have a naked pointer to a shared_pointer to a collection of
* lua registry indices to actual usable data which may or may not be garbage collected at an unpredictable time if ownership
* is removed. Clear s_RegisteredCallbacks down too eagerly and random bugs - crashes or, more likely now, callbacks just not
* being called - are going to happen.
* 
* Given that even in the case where there is a clear deregister/deallocate function there are no documented guarantees about
* when or if a userref value might be used, there are extremely few cases where clearing down a fast-lookup container expected to pick
* up a few hundred entries is worth the risk. Annotating each individual function group as to the exact sequence of potential calls
* to a cleardown-related callback is brittle, subject to mistakes, likely to break if the sim's implementation changes etc.
* 
*/
static std::unordered_set<std::shared_ptr<notify_cb_t>, cb_ref_hash, cb_ref_eq> s_RegisteredCallbacks;

bool xlua_is_callback_valid(notify_cb_t const* probe_cb)
{
	// Heterogeneous (C++20) lookup: probe by the bare pointer without building a throwaway shared_ptr.
	return s_RegisteredCallbacks.contains(probe_cb);
}

void xlua_callback_shutdown(void)
{
	// In theory, on shutdown there should be _no_ callbacks remaining.
	assert(s_RegisteredCallbacks.empty());

	// ... but if there is, ensure the interpreter pointer is null so the destructor is a no-op. This function should only ever be
	// called if there are no modules/interpreters left.
	for (auto& cb : s_RegisteredCallbacks)
	{
		cb->L = nullptr;
	}
}

void xlua_callback_cleanup(lua_State* L)
{
	for (auto it = s_RegisteredCallbacks.begin(); it != s_RegisteredCallbacks.end(); )
	{
		if (*it && (*it)->L == L)
			it = s_RegisteredCallbacks.erase(it);
		else
			++it;
	}
}

void xlua_remove_callback(std::shared_ptr<notify_cb_t> cb)
{
	assert(cb->get_capture() != notify_cb_t::kNeverPersist);
	assert(s_RegisteredCallbacks.contains(cb));

	s_RegisteredCallbacks.erase(cb);
}

void xlua_persist_userref(lua_State* L, std::shared_ptr<notify_cb_t> cb)
{
	// s_RegisteredCallbacks should only be used to store notify_cb_t structs with a persisted registry ID. Without that,
	// every persisted value would have a key of 0 (deliberately uninitialised and not LUA_REFNIL).
	assert(cb->get_capture() != notify_cb_t::kNeverPersist);
	assert(cb);
	s_RegisteredCallbacks.emplace(cb);

	if (s_RegisteredCallbacks.size() > 500)
	{
		luaL_error(L, "%s has persisted more than 500 callbacks. Something appears to be wrong.",
				   get_current_script_path(L).c_str());
	}
}

std::shared_ptr<notify_cb_t> wrap_lua_func_no_userref(lua_State * L, int idx, std::string const callbackKey)
{
	// This captures a function in a notify_cb_t which should NEVER be persisted in s_RegisteredCallbacks .
	if (lua_isnil(L,idx))
	{
		return nullptr;
	}

	auto cb = std::make_shared<notify_cb_t>(L, notify_cb_t::kNeverPersist);
	wrap_next_lua_func(cb, idx, false, callbackKey);
	return cb;
}

std::optional<std::string> xlua_checkoptstring(lua_State* L, int narg)
{
	if (lua_isnil(L, narg))
	{
		return std::nullopt;
	}

	return std::make_optional<std::string>(luaL_checkstring(L, narg));
}

std::optional<float> xlua_checkoptfloat(lua_State* L, int narg)
{
	if (lua_isnil(L, narg))
	{
		return std::nullopt;
	}

	return std::make_optional<float>(static_cast<float>(luaL_checknumber(L, narg)));
}

std::optional<double> xlua_checkoptdouble(lua_State* L, int narg)
{
	if (lua_isnil(L, narg))
	{
		return std::nullopt;
	}

	return std::make_optional<double>(static_cast<double>(luaL_checknumber(L, narg)));
}

std::optional<int> xlua_checkoptint(lua_State* L, int narg)
{
	if (lua_isnil(L, narg))
	{
		return std::nullopt;
	}

	return std::make_optional<int>(static_cast<int>(luaL_checkinteger(L, narg)));
}

// ---------------------------------------------------------------------------
// Panic handler
//
// LuaJIT calls the panic function whenever a Lua error is thrown with no
// pcall on the stack to catch it. After panic returns, LuaJIT calls abort()
// — the state is undefined and execution can't safely continue. So our
// handler can't recover; what it can do is identify the offending script
// and surface the error message before the abort, turning a silent exit
// into a filable crash report.
// ---------------------------------------------------------------------------
static int xlua_panic_handler(lua_State* L)
{
	const char * msg = lua_tostring(L, -1);
	log_message(L, "FATAL: unprotected Lua error escaped to panic handler.\n");
	log_message(L, "FATAL:   message: %s\n", msg ? msg : "(no message on stack)");
	log_message(L, "FATAL: this is a host bug -- Lua errors should never reach panic.\n");
	log_message(L, "FATAL: please report with the lua script path above and the X-Plane version.\n");
	// Returning continues to LuaJIT's default abort(); the log lines above
	// turn that abort from a mystery into actionable diagnostics.
	return 0;
}

void xlua_install_panic_handler(lua_State* L)
{
	lua_atpanic(L, xlua_panic_handler);
}
