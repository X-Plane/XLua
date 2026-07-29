// KEEP IN SYNC WITH XPLMStore.xml: this hand-written body backs the
// lua_impl="external" XPLMStoreLoadFile declaration there. A missing/renamed
// impl fails the link — but the XML's params/return/desc (which become the
// published EmmyLua docs) are NOT checked, so if you change what this function
// takes or returns, update the XML too or the docs silently go stale.
//
// Registered as XLuaStoreLoadFile via the generated XLua_Register_glue.cpp.
// Returns the file contents as a Lua string (or nil + error code); the C
// buffer is freed here, which is why XPLMStoreFileFree has no Lua binding.

#include <XPLMStore.h>

extern "C" {
	#include <lauxlib.h>
}

extern "C" int XLuaStoreLoadFile(lua_State* L)
{
	char const* path = luaL_checkstring(L, 1);

	void* buf = nullptr;
	int buf_size = 0;
	int res = XPLMStoreLoadFile(path, &buf, &buf_size);
	if (res != 1)
	{
		lua_pushnil(L);
		lua_pushinteger(L, res);
		return 2;
	}

	// success with no buffer = empty file
	if (buf == nullptr)
	{
		lua_pushliteral(L, "");
		return 1;
	}

	lua_pushlstring(L, static_cast<char const*>(buf), static_cast<size_t>(buf_size));
	XPLMStoreFileFree(buf);
	return 1;
}
