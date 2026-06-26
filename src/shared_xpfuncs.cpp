#include "shared_xpfuncs.h"

#include "XPLMUtilities.h"

#include <memory>
#include <cassert>

int notify_cb_t::nilRefCount = -1;

notify_cb_t::notify_cb_t(lua_State* inL, int s) : L(inL), origRefconRegIndex(s)
{
	// This will normally be a return from a luaL_ref call, always 0 or higher. However, if the refcon is nil then
	// luaL_ref returns LUA_REFNIL. We can't have all these mapping onto each other.
	if (origRefconRegIndex < 0)
	{
		origRefconRegIndex = --nilRefCount;
	}
}

notify_cb_t::~notify_cb_t()
{
	if (L != nullptr)
	{
		if (origRefconRegIndex != 0)
		{
			luaL_unref(L, LUA_REGISTRYINDEX, origRefconRegIndex);
		}

		// Un-pin all functions.
		for (auto const& [name, regidx] : callbacks)
		{
			luaL_unref(L, LUA_REGISTRYINDEX, regidx);
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

// Given an interp and a stack arg that is a lua function/closure,
// this routine stashes a strong ref to the closure in the registry,
// allocates a callback struct and stashes the slot and interp in the
// CB struct.  This CB struct is a single C ptr that we can use to
// reconstruct the closure from C land.
//
// If the closure is actually nil, we return NULL and allocate nothing.

std::shared_ptr<notify_cb_t> wrap_lua_func(lua_State* L, int func_stack_idx, bool optional, std::string const& cb_typename)
{
	auto cb = std::make_shared<notify_cb_t>(L, 0);
	wrap_next_lua_func(cb, func_stack_idx, optional, cb_typename);

	return cb;
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

static std::map<int, std::shared_ptr<notify_cb_t>> s_RegisteredCallbacks;

void xlua_callback_shutdown(void)
{
	// In theory, on shutdown there should be _no_ callbacks remaining.
	assert(s_RegisteredCallbacks.empty());

	// ... but if there is, ensure the interpreter pointer is null so the destructor is a no-op. This function should only ever be
	// called if there are no modules/interpreters left.
	for (auto& cb : s_RegisteredCallbacks)
	{
		cb.second->L = nullptr;
	}
}

void xlua_callback_cleanup(lua_State* L)
{
	for (auto it = s_RegisteredCallbacks.begin(); it != s_RegisteredCallbacks.end(); )
	{
		if (it->second && it->second->L == L)
			it = s_RegisteredCallbacks.erase(it);
		else
			++it;
	}
}

void xlua_remove_callback(std::shared_ptr<notify_cb_t> cb)
{
	assert(cb->get_capture() != 0);
	assert(s_RegisteredCallbacks.contains(cb->get_capture()));

	s_RegisteredCallbacks.erase(cb->get_capture());
}

void xlua_persist_userref(lua_State* L, std::shared_ptr<notify_cb_t> cb)
{
	s_RegisteredCallbacks[cb->get_capture()] = cb;

	if (s_RegisteredCallbacks.size() > 500)
	{
		luaL_error(L, "%s has persisted more than 500 callbacks. Something appears to be wrong.",
				   get_current_script_path(L).c_str());
	}
}

std::shared_ptr<notify_cb_t> wrap_lua_func_nil(lua_State * L, int idx, std::string const callbackKey)
{
	if (lua_isnil(L,idx))
	{
		return nullptr;
	}

	auto cb = std::make_shared<notify_cb_t>(L, 0);
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
