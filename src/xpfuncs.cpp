//
//  xpfuncs.cpp
//  xlua
//
//  Created by Ben Supnik on 3/19/16.
//
//	Copyright 2016, Laminar Research
//	This source code is licensed under the MIT open source license.
//	See LICENSE.txt for the full terms of the license.

#include <cstdio>
#include <cstdlib>
#include <optional>
#include <filesystem>

#include "xpfuncs.h"
#include "shared_xpfuncs.h"
#include "shared_lua_helpers.h"
#include "xpdatarefs.h"
#include "xpcommands.h"
#include "xptimers.h"
#include "module.h"

#include <XPLMUtilities.h>
#include <XPLMDataAccess.h>
#if !MOBILE
#include <XPLMStore.h>
#endif

#include <cassert>

#if MOBILE
	#include "xmap.h"
#endif

/*
	TODO: figure out when we have to resync our datarefs
	TODO: what if dref already registered before acf reload?  (maybe no harm?)
	TODO: test x-plane-side string read/write - needs test not at startup

 */

static XPLMDataRef drSimRealTime = nullptr;
// kTimerCallbackSig is defined in xptimers.cpp (shared with the host loader);
// declared extern in xpfuncs.h.
std::string const kDatarefCallbackSig("DatarefCallback");
std::string const kFilterCallbackSig("FilterCallback");
std::string const kCommandCallbackSig("CmdCallback");

static int l_my_print(lua_State* L);

std::filesystem::path get_current_script_path(lua_State* L)
{
	return module::module_from_interp(L)->get_script_path();
}

namespace XLua1
{
	//----------------------------------------------------------------
	// MISC
	//----------------------------------------------------------------

	static int XLuaGetCode(lua_State* L)
	{
		module* me = module::module_from_interp(L);
		assert(me);

		const char* name = luaL_checkstring(L, 1);

		int result = me->load_module_relative_path(name);

		if (result)
		{
			const char* err_msg = luaL_checkstring(L, 2);
			log_message(L, "%s: %s\n", name, err_msg);

			return 0;
		}

		return 1;
	}

	//----------------------------------------------------------------
	// DATAREFS
	//----------------------------------------------------------------

	// XPLMFindDataRef "foo" -> dref
	static int XLuaFindDataRef(lua_State* L)
	{
		const char* name = luaL_checkstring(L, -1);

		xlua_dref* r = xlua_find_dref(name);
		assert(r);

		xlua_pushuserdata(L, r);
		return 1;
	}

	static void xlua_dataref_notify_helper(xlua_dref* who, std::shared_ptr<notify_cb_t> ref)
	{
		lua_State* L = setup_lua_callback(ref.get(), kDatarefCallbackSig);
		if (L)
		{
			fmt_pcall_stdvars(L, module::debug_proc_from_interp(L), false, "");
		}
	}

	// XPLMCreateDataRef name "array[4]" "yes" func -> dref
	static int XLuaCreateDataRef(lua_State* L)
	{
		const char* name = luaL_checkstring(L, 1);
		const char* typestr = luaL_checkstring(L, 2);
		const char* writable = luaL_checkstring(L, 3);
		std::shared_ptr<notify_cb_t> cb = wrap_lua_func_no_userref(L, 4, kDatarefCallbackSig);

		if (strlen(name) == 0)
			return luaL_argerror(L, 1, "dataref name must not be an empty string.");

		int my_writeable;
		if (strcmp(writable, "yes") == 0)
			my_writeable = 1;
		else if (strcmp(writable, "no") == 0)
			my_writeable = 0;
		else
			return luaL_argerror(L, 3, "writable must be 'yes' or 'no'");

		xlua_dref_type my_type = xlua_none;
		int my_dim = 1;
		const char* c = typestr;
		if (strcmp(c, "string") == 0)
			my_type = xlua_string;
		else if (strcmp(c, "number") == 0)
			my_type = xlua_number;
		else if (strncmp(c, "array[", 6) == 0)
		{
			while (*c && *c != '[') ++c;
			if (*c == '[')
			{
				++c;
				my_dim = atoi(c);
				my_type = xlua_array;
			}
		}
		else
			return luaL_argerror(L, 2, "Type must be number, string, or array[n]");

		xlua_dref* r = xlua_create_dref(L,
										name,
										my_type,
										my_dim,
										my_writeable,
										(my_writeable && cb) ? xlua_dataref_notify_helper : nullptr,
										cb);
		assert(r);

		xlua_pushuserdata(L, r);
		return 1;

	}

	// dref -> "array[4]"
	static int XLuaGetDataRefType(lua_State* L)
	{
		xlua_dref_type dt = xlua_none;

		xlua_dref* d = xlua_checkuserdata<xlua_dref*>(L, 1, "expected dataref");
		if (d != nullptr)
		{
			dt = xlua_dref_get_type(d);
		}

		switch (dt) {
			case xlua_none:
				lua_pushstring(L, "none");
				break;
			case xlua_number:
				lua_pushstring(L, "number");
				break;
			case xlua_array:
			{
				char buf[256];
				sprintf(buf, "array[%d]", xlua_dref_get_dim(d));
				lua_pushstring(L, buf);
			}
			break;
			case xlua_string:
				lua_pushstring(L, "string");
				break;
		}
		return 1;
	}

	// XPLMGetNumber dref -> value
	static int XLuaGetNumber(lua_State* L)
	{
		xlua_dref* d = xlua_checkuserdata<xlua_dref*>(L, 1, "expected dataref");

		lua_pushnumber(L, xlua_dref_get_number(d));
		return 1;
	}

	// XPLMSetNumber dref value
	static int XLuaSetNumber(lua_State* L)
	{
		xlua_dref* d = xlua_checkuserdata<xlua_dref*>(L, 1, "expected dataref");
		double v = luaL_checknumber(L, 2);

		xlua_dref_set_number(d, v);
		return 0;
	}

	// XPLMGetArray dref idx -> value
	static int XLuaGetArray(lua_State* L)
	{
		xlua_dref* d = xlua_checkuserdata<xlua_dref*>(L, 1, "expected dataref");
		int idx = static_cast<int>(luaL_checknumber(L, 2));

		lua_pushnumber(L, xlua_dref_get_array(d, idx));
		return 1;
	}

	// XPLMSetArray dref idx value
	static int XLuaSetArray(lua_State* L)
	{
		xlua_dref* d = xlua_checkuserdata<xlua_dref*>(L, 1, "expected dataref");
		int idx = static_cast<int>(luaL_checknumber(L, 2));
		double v = luaL_checknumber(L, 3);

		xlua_dref_set_array(d, idx, v);
		return 0;
	}

	// XLuaSetArrayFromArray dref value_array
	static int XLuaSetArrayFromArray(lua_State* L)
	{
		xlua_dref* d = xlua_checkuserdata<xlua_dref*>(L, 1, "expected dataref");
		luaL_checktype(L, 2, LUA_TTABLE);

		lua_pushvalue(L, 2);
		lua_pushnil(L);

		std::vector<double> tableVals;
		while (lua_next(L, -2))
		{
			tableVals.emplace_back(lua_tonumber(L, -1));
			lua_pop(L, 1);
		}
		lua_pop(L, 1);

		xlua_dref_set_array(d, tableVals);
		return 0;
	}

	// XPLMGetString dref -> value
	static int XLuaGetString(lua_State* L)
	{
		xlua_dref* d = xlua_checkuserdata<xlua_dref*>(L, 1, "expected dataref");

		lua_pushstring(L, xlua_dref_get_string(d).c_str());
		return 1;
	}

	// XPLMSetString dref value
	static int XLuaSetString(lua_State* L)
	{
		xlua_dref* d = xlua_checkuserdata<xlua_dref*>(L, 1, "expected dataref");
		const char* s = luaL_checkstring(L, 2);
		xlua_dref_set_string(d, string(s));
		return 0;
	}

	//----------------------------------------------------------------
	// COMMANDS
	//----------------------------------------------------------------

	// XPLMFindCommand name
	static int XLuaFindCommand(lua_State* L)
	{
		const char* name = luaL_checkstring(L, 1);

		xlua_cmd* r = xlua_find_cmd(name);
		if (r == nullptr)
		{
			lua_pushnil(L);
		}
		else
		{
			xlua_pushuserdata(L, r);
		}

		return 1;
	}

	// XPLMCreateCommand name desc
	static int XLuaCreateCommand(lua_State* L)
	{
		const char* name = luaL_checkstring(L, 1);
		const char* desc = luaL_checkstring(L, 2);

		xlua_cmd* r = xlua_create_cmd(L, name, desc);
		if (r == nullptr)
		{
			lua_pushnil(L);
		}
		else
		{
			xlua_pushuserdata(L, r);
		}

		return 1;
	}

	static int cmd_filter_cb_helper(xlua_cmd* cmd, int phase, float elapsed, std::shared_ptr<notify_cb_t> ref)
	{
		int res = 1;

		lua_State* L = setup_lua_callback(ref.get(), kFilterCallbackSig);
		if (L)
		{
			int e = lua_pcall(L, 0, 1, module::debug_proc_from_interp(L));
			if (e != 0)
			{
				l_my_print(L);
			}
			else
			{
				res = lua_toboolean(L, -1);
			}

			lua_pop(L, 1);
		}

		return res;
	}

	static int cmd_cb_helper(xlua_cmd* cmd, int phase, float elapsed, std::shared_ptr<notify_cb_t> ref)
	{
		lua_State* L = setup_lua_callback(ref.get(), kCommandCallbackSig);
		if (L)
		{
			fmt_pcall_stdvars(L, module::debug_proc_from_interp(L), false, "if", phase, elapsed);
		}

		return 1;
	}

	// XPLMFilterCommand handler
	static int XLuaFilterCommand(lua_State* L)
	{
		xlua_cmd* cmd = xlua_checkuserdata<xlua_cmd*>(L, 1, "expected command");

		std::shared_ptr<notify_cb_t> cb_filter = std::make_shared<notify_cb_t>(L, 0);
		if (wrap_next_lua_func(cb_filter, 2, false, kFilterCallbackSig))
		{
			xlua_cmd_install_filter(L, cmd, cmd_filter_cb_helper, cb_filter);
		}

		return 0;
	}

	// XPLMReplaceCommand cmd handler
	static int XLuaReplaceCommand(lua_State* L)
	{
		xlua_cmd* d = xlua_checkuserdata<xlua_cmd*>(L, 1, "expected command");

		std::shared_ptr<notify_cb_t> cb_command = std::make_shared<notify_cb_t>(L, 0);
		if (wrap_next_lua_func(cb_command, 2, false, kCommandCallbackSig))
		{
			xlua_cmd_install_handler(L, d, cmd_cb_helper, cb_command);
		}

		return 0;
	}

	// XPLMWrapCommand cmd handler1 handler2
	static int XLuaWrapCommand(lua_State* L)
	{
		xlua_cmd* d = xlua_checkuserdata<xlua_cmd*>(L, 1, "expected command");

		std::shared_ptr<notify_cb_t> cb_pre = std::make_shared<notify_cb_t>(L, 0);
		if (wrap_next_lua_func(cb_pre, 2, false, kCommandCallbackSig))
		{
			xlua_cmd_install_pre_wrapper(L, d, cmd_cb_helper, cb_pre);
		}

		std::shared_ptr<notify_cb_t> cb_post = std::make_shared<notify_cb_t>(L, 0);
		if (wrap_next_lua_func(cb_post, 3, false, kCommandCallbackSig))
		{
			xlua_cmd_install_post_wrapper(L, d, cmd_cb_helper, cb_post);
		}

		if (cb_pre->callbacks.empty() && cb_post->callbacks.empty())
		{
			luaL_error(L, "XLuaWrapCommand on %s had neither pre nor post functions specified.",
					   d->m_name.c_str());
		}

		return 0;
	}

	// XPLMCommandStart cmd
	static int XLuaCommandStart(lua_State* L)
	{
		xlua_cmd* d = xlua_checkuserdata<xlua_cmd*>(L, 1, "expected command");
		xlua_cmd_start(d);
		return 0;
	}

	// XPLMCommandStop cmd
	static int XLuaCommandStop(lua_State* L)
	{
		xlua_cmd* d = xlua_checkuserdata<xlua_cmd*>(L, 1, "expected command");
		xlua_cmd_stop(d);
		return 0;
	}

	// XPLMCommandOnce cmd
	static int XLuaCommandOnce(lua_State* L)
	{
		xlua_cmd* d = xlua_checkuserdata<xlua_cmd*>(L, 1, "expected command");
		xlua_cmd_once(d);
		return 0;
	}

	std::map<std::pair<lua_State const*, std::string>, xlua_dref*> cachedDrefs;

	#define NS_READ_STATS 1
	static int namespace_read_native(lua_State* L)
	{
		// The namespace is a table containing 'functions', 'values', 'raw_table_keys' etc.
		// That table has a custom metatable with overrides for __index, __newindex etc.
		luaL_checktype(L, 1, LUA_TTABLE);

		int test = lua_gettop(L);

	#if NS_READ_STATS
		static size_t c_values = 0, c_funcs = 0, c_cache_reads = 0, c_cache_writes = 0;
		static std::map<std::string, size_t> c_val_reads;
	#endif
		char const* wanted_key = lua_tostring(L, 2);

		lua_pushstring(L, "values");
		lua_rawget(L, 1);					// Pops 'values', pushes the result.

		lua_pushvalue(L, 2);				// Re-push the index, i.e. put at -1
		lua_gettable(L, -2);
		lua_remove(L, -2);					// Dump the 'values' table from the stack
		if (lua_type(L, -1) != LUA_TNIL)
		{
	#if NS_READ_STATS
			++c_values;
			if (wanted_key != nullptr)
			{
				c_val_reads[wanted_key]++;
			}
			else
			{
				c_val_reads["<None>"]++;
			}
	#endif
			return 1;						// Topmost item is the value we need.
		}
		lua_pop(L, 1);						// Pop the 'nil'
		test = lua_gettop(L);

		if (wanted_key != nullptr)
		{
			auto cache = cachedDrefs.find({ L, wanted_key });
			if (cache != cachedDrefs.end())
			{
				xlua_dref_type dt = xlua_dref_get_type(cache->second);
				if (dt == xlua_dref_type::xlua_number)
				{
					lua_pushnumber(L, xlua_dref_get_number(cache->second));
				}
				else
				{
					lua_pushstring(L, xlua_dref_get_string(cache->second).c_str());
				}

	#if NS_READ_STATS
				++c_cache_reads;
	#endif
				test = lua_gettop(L);
				return 1;
			}
		}

		lua_pushstring(L, "functions");
		lua_rawget(L, 1);					// Pops 'functions', pushes the result.

		lua_pushvalue(L, 2);				// Re-push the index, i.e. put at -1
		lua_gettable(L, -2);
		lua_remove(L, -2);					// Dump the 'functions' table from the stack
		if (lua_type(L, -1) != LUA_TNIL)
		{
			// If should have a '__get' method - this is a lua stub referencing the C call i.e. XLuaGetNumber() .
			lua_pushstring(L, "__get");
			lua_rawget(L, -2);				// Pops '__get', pushes the result, which should be a function.

			/////
			lua_pushstring(L, "dref");		// Test to see if there's a dref value. If so, we can shortcut the whole process next time.
			lua_rawget(L, -3);
			if (lua_type(L, -1) == LUA_TUSERDATA)
			{
				xlua_dref** actual_dref = static_cast<xlua_dref**>(lua_touserdata(L, -1));
				xlua_dref_type dt = xlua_dref_get_type(*actual_dref);
				if (dt == xlua_dref_type::xlua_number || dt == xlua_dref_type::xlua_string)
				{
					cachedDrefs.emplace(std::pair<lua_State const*, std::string>{ L, wanted_key }, *actual_dref);
	#if NS_READ_STATS
					++c_cache_writes;
	#endif
				}
			}
			lua_pop(L, 1);
			test = lua_gettop(L);
			/////

			lua_pushvalue(L, -2);			// Push the table again as a parameter.
			lua_call(L, 1, 1);

	#if NS_READ_STATS
			++c_funcs;
	#endif

			test = lua_gettop(L);
			return 1;						// Topmost item is the value we need.
		}
		lua_pop(L, 1);						// Pop the 'nil'

		lua_pushstring(L, "parent");
		lua_rawget(L, 1);					// Pops 'parent', pushes the result.
		if (lua_type(L, -1) != LUA_TNIL)
		{
			lua_pushvalue(L, 2);				// Re-push the index, i.e. put at -1
			lua_gettable(L, -2);
		}
		else
		{
			lua_pushnil(L);
		}

		lua_remove(L, -2);					// Dump the 'parent' table from the stack
		test = lua_gettop(L);

		return 1;
	}

#define XLUA1_FUNC_LIST \
	FUNC_V1(XLuaGetCode) \
	FUNC_V1(XLuaFindDataRef) \
	FUNC_V1(XLuaCreateDataRef) \
	FUNC_V1(XLuaGetDataRefType) \
	FUNC_V1(XLuaGetNumber) \
	FUNC_V1(XLuaSetNumber) \
	FUNC_V1(XLuaGetArray) \
	FUNC_V1(XLuaSetArray) \
	FUNC_V1(XLuaSetArrayFromArray) \
	FUNC_V1(XLuaGetString) \
	FUNC_V1(XLuaSetString) \
	FUNC_V1(XLuaFindCommand) \
	FUNC_V1(XLuaCreateCommand) \
	FUNC_V1(XLuaReplaceCommand) \
	FUNC_V1(XLuaWrapCommand) \
	FUNC_V1(XLuaFilterCommand) \
	FUNC_V1(XLuaCommandStart) \
	FUNC_V1(XLuaCommandStop) \
	FUNC_V1(XLuaCommandOnce) \
	FUNC_V1(namespace_read_native)

}	// End of XLua1_Compat namespace

// The XLua timer bindings (XLuaCreateTimer / XLuaRunTimer / XLuaFindTimer /
// XLuaIsTimerScheduled / XLuaGetTimerRemaining) and XLuaReloadOnFlightChange
// moved to xptimers.cpp so the host's glua library can link them too. They
// are declared lua-only in XPLMProcessing.xml and registered for XLua 2.x and
// the direct loader via add_xplm_to_interp; add_xlua_funcs_to_interp below
// hand-registers them for XLua 1.x scripts (which don't run add_xplm_to_interp).

std::string get_log_prefix(char l)
{
	char prefix[256];
	int hrs, min;
	float sec, real_time = XPLMGetDataf(drSimRealTime);
	hrs = static_cast<int>(real_time / 3600.0f);
	min = static_cast<int>(real_time / 60.0f) - (int)(hrs * 60.0f);
	sec = real_time - (hrs * 3600.0f) - (min * 60.0f);
	sprintf(prefix, "%d:%02d:%06.3f %c/LUA: ", (int)hrs, (int)min, sec, l);

	return std::string(prefix);
}

static int l_my_print(lua_State *L)
{
	int nargs = lua_gettop(L);
	module *me = module::module_from_interp(L);

	std::string prefix = get_log_prefix();

	// Unwieldy... but on the other hand, lua debug statements could in theory come from anywhere, from
	// several different instances of xlua at the same time so the full path probably is needed.
	XPLMDebugString((prefix + me->get_log_path() + "\n").c_str());

	std::string output;
	char num_buf[128];

	for (int i = 1; i <= nargs; i++)
	{
		switch (lua_type(L, i))
		{
			case LUA_TNIL:
				output += "(nil)";
				break;

			case LUA_TBOOLEAN:
				output += lua_toboolean(L, i) ? "true" : "false";
				break;

			case LUA_TNUMBER:
				lua_number2str(num_buf, lua_tonumber(L, i));
				output += num_buf;
				break;

			case LUA_TSTRING:
				output += lua_tostring(L, i);
				break;

			case LUA_TTABLE:
				// At least let people know that tables need to be split down for print() .
				output += "(table)";
				break;

			default:
				output += "(???)";
		}

		output += " ";
	}

	// Keep the console output too.
	puts(output.c_str());

	output += "\n";
	XPLMDebugString((prefix + output).c_str());

	return 0;
}

static const struct luaL_Reg printlib[] = {
	{ "print", l_my_print },
	{ NULL, NULL } /* end of array */
};

static int dofile(lua_State* L)
{
	// A shim to restore XLua V1's behaviour where dofile() is always relative to the script, not the process CWD.
	module* mod = ::module::module_from_interp(L);
	if (mod != nullptr)
	{
		const char* file = luaL_checkstring(L, 1);
#if MOBILE
		// Mobile asset paths are invisible to fopen (iOS's CWD is not the bundle
		// root, Android assets live in the APK), so load through the sim's xmap
		// file layer. The path join is lexical only — std::filesystem file-system
		// queries don't work on mobile assets. Unlike the desktop branch below,
		// a missing or broken file raises (stock-dofile semantics): silently
		// skipped scripts are miserable to debug on mobile.
		std::string full_path = (mod->get_script_path() / file).generic_string();
		xmap_class chunk(full_path);
		if (!chunk.exists())
			return luaL_error(L, "dofile: cannot open %s", full_path.c_str());
		if (luaL_loadbuffer(L, reinterpret_cast<char const*>(chunk.begin()), chunk.size(), ("@" + full_path).c_str()) != 0)
			lua_error(L);
		lua_call(L, 0, 0);
#else
		// A store-managed plugin reads through the module's store-verified/decrypted path
		// (load_module_relative_path) rather than luaL_dofile, which would open the file directly and
		// bypass the store integrity check. A non-store plugin keeps the plain luaL_dofile below.
		if (XPLMIsStoreManagedPlugin())
		{
			int const load_result = mod->load_module_relative_path(L, file);   // loads onto L; raises if not found
			if (load_result != 0)
				return lua_error(L);
			if (lua_pcall(L, 0, 0, 0) != 0)
				return lua_error(L);
		}
		else
		{
			std::filesystem::path fullPath(mod->get_script_path());
			fullPath = std::filesystem::absolute(fullPath / file);
			luaL_dofile(L, fullPath.generic_string().c_str());
		}
#endif
	}

	return 0;
}

void	add_xlua_funcs_to_interp(lua_State * L, int compat_version)
{
	#define FUNC(x) lua_register(L,#x,x);
	#define FUNC_V1(x) lua_register(L,#x,XLua1::x);

	if (compat_version == 1)
	{
		// XLua 1.x scripts never run add_xplm_to_interp (module.cpp only calls it
		// for compat >= 2), so the timer + reload bindings — registered there for
		// XLua 2.x and the direct loader via XPLMProcessing.xml — must be
		// hand-registered here. init.lua's run_timer/run_after_time sugar calls
		// straight into these.
		FUNC(XLuaCreateTimer);
		FUNC(XLuaRunTimer);
		FUNC(XLuaFindTimer);
		FUNC(XLuaIsTimerScheduled);
		FUNC(XLuaGetTimerRemaining);
		FUNC(XLuaReloadOnFlightChange);

		XLUA1_FUNC_LIST;
	}
	else
	{
		// Reinstate script-relative dofile() operation, same as V1.
		FUNC(dofile);
	}

	// For logging
	drSimRealTime = XPLMFindDataRef("sim/network/misc/network_time_sec");

	// Register the custom print handler
	lua_getglobal(L, "_G");
	luaL_register(L, NULL, printlib);
	lua_pop(L, 1);
}

