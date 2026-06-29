#ifndef LEGACY_XPFUNCS_HEADER
#define LEGACY_XPFUNCS_HEADER

extern "C" {
	#include <lua.h>
	#include <lauxlib.h>
}

#include <cstring>
#include <string>
#include <algorithm>
#include <map>
#include <memory>
#include <optional>
#include <filesystem>

// This is kind of a mess - Lua [annoyingly] doesn't give you a way to store a closure/Lua interpreter function
// in C space.  The hack is to use luaL_ref to fill a new key in the registry table with a copy of ANY value from
// the stack - since this is type agnostic and takes a strong reference it (1) prevents the closure from being
// garbage collected and (2) works with closures.

class notify_cb_t
{
public:
	notify_cb_t() = delete;
	notify_cb_t(lua_State* inL, int s);
	~notify_cb_t();

	int get_capture(void) const { return origRefconRegIndex; }
	lua_State* L = nullptr;
	std::map<std::string, int> callbacks;       // Map from function definition to registry index for the callback;

	static constexpr int kNeverPersist = 0;

private:
	int origRefconRegIndex = kNeverPersist;
	static int nilRefCount;
};

std::string get_log_prefix(char l='I');
std::filesystem::path get_current_script_path(lua_State* L);

int log_message(lua_State *L, char const* format, ...);

std::shared_ptr<notify_cb_t> wrap_lua_func_no_userref(lua_State* L, int idx, std::string const callbackKey);
lua_State* setup_lua_callback(notify_cb_t const* cb, std::string const callbackKey);
std::shared_ptr<notify_cb_t> capture_lua_value(lua_State* L, int idx);

bool wrap_next_lua_func(std::shared_ptr<notify_cb_t> cb, int func_stack_idx, bool optional, std::string const& cb_typename);
void xlua_remove_callback(std::shared_ptr<notify_cb_t> cb);

std::optional<std::string> xlua_checkoptstring(lua_State* L, int narg);
std::optional<float>       xlua_checkoptfloat(lua_State* L, int narg);
std::optional<double>      xlua_checkoptdouble(lua_State* L, int narg);
std::optional<int>         xlua_checkoptint(lua_State* L, int narg);

// Syntactic sugar to make the code-generation simpler.
inline bool         xlua_checkboolean(lua_State* L, int narg)   { luaL_checktype(L, narg, LUA_TBOOLEAN); return lua_toboolean(L, narg); }
inline int          xlua_checkinteger(lua_State* L, int narg)   { return static_cast<int>(luaL_checkinteger(L, narg)); }
inline lua_Number   xlua_checknumber (lua_State* L, int narg)   { return luaL_checknumber(L, narg); }
inline char const*  xlua_checkstring (lua_State* L, int narg)   { return luaL_checkstring(L, narg); }
inline uint8_t      xlua_checkbyte   (lua_State* L, int narg)   { return static_cast<uint8_t>(std::clamp(luaL_checkinteger(L, narg), static_cast<lua_Integer>(0), static_cast<lua_Integer>(255))); }

inline void         xlua_pushinteger (lua_State* L, lua_Integer v)  { lua_pushinteger(L, v); }
inline void         xlua_pushnumber  (lua_State* L, lua_Number v)   { lua_pushnumber(L, v); }
inline void         xlua_pushbyte    (lua_State* L, lua_Integer v)  { lua_pushinteger(L, std::clamp(v, static_cast<lua_Integer>(0), static_cast<lua_Integer>(255))); }

template <typename T>
T xlua_checkuserdata(lua_State * L, int narg, const char * msg)
{
	T* ret = static_cast<T*>(lua_touserdata(L, narg));
	if (ret == NULL)
	{
		luaL_argerror(L, narg, msg);			// never returns
		return T{};								// Keeps compiler happy
	}
	return *ret;
}

template<typename T>
void xlua_pushuserdata(lua_State * state, T data)
{
	T* ud = static_cast<T*>(lua_newuserdata(state, sizeof(T)));
	memcpy(ud, &data, sizeof(T));
}

void xlua_persist_userref(lua_State* L, std::shared_ptr<notify_cb_t> cb);
void xlua_callback_cleanup(lua_State* L);
bool xlua_is_callback_valid(notify_cb_t const* probe_cb);
void xlua_callback_shutdown(void);

// Install a panic handler that logs the unprotected-Lua-error context (the
// error message, the script path) before LuaJIT's default abort fires. Call
// this once on every fresh lua_State produced by luaL_newstate().
//
// Without this, an unprotected Lua throw (a luaL_check* called outside any
// pcall, a lua_error from a bad host binding, etc.) hits LuaJIT's default
// panic which exit()s the sim with no diagnostic — silently killing the
// process mid-frame and obscuring which script triggered the fault.
void xlua_install_panic_handler(lua_State* L);

#endif
