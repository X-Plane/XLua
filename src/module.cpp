//
//  module.cpp
//  xlua
//
//  Created by Ben Supnik on 3/19/16.
//
//	Copyright 2016, Laminar Research
//	This source code is licensed under the MIT open source license.
//	See LICENSE.txt for the full terms of the license.

#include "module.h"
#include "xpfuncs.h"
#include "shared_xpfuncs.h"
#include "lua_helpers.h"

#include <XPLMUtilities.h>

#include <algorithm>
#include <regex>
#include <cassert>
#include <string>
#include <string_view>

// Registers the generated XPLM lua glue (XLua_Register_glue.cpp) — the full
// SDK surface on desktop, the mobile_compatible subset on mobile.
void add_xplm_to_interp(lua_State* L);

#if MOBILE
	#include "xmap.h"
	extern "C"
	{
		#include "../luajit/src/luajit.h"
		#include "../luajit/src/lualib.h"
	}
#else
	#include "xlua_imgui.h"
	#include "xlua2_window_helpers.h"

	extern "C"
	{
		#include "../luajit/src/luajit.h"
		#include "../luajit/src/lualib.h"
	}

	class	xmap_class {
	public:
		xmap_class(std::filesystem::path const& in_file_name);
		xmap_class(const string& in_file_name);
		~xmap_class()				{ if (m_buffer != nullptr) free(m_buffer); }
		bool exists() const			{ return m_buffer != nullptr; }
		char const* begin() const	{ return m_buffer; }
		size_t size() const			{ return m_size; }
	private:
		char *		 m_buffer;
		size_t		 m_size;
	};

	void add_xplm_to_interp(lua_State* L);
#endif

version_triplet sPluginVersion = { -1, -1, -1 };

static_assert(version_triplet{ 1,0,0 } == version_triplet{ 1,0,0 });
static_assert(version_triplet{ 1,0,0 } < version_triplet{ 1,0,1 });
static_assert(version_triplet{ 1,0,1 } > version_triplet{ 1,0,0 });

bool version_triplet::init_from_string(std::string ver_str)
{
	std::smatch v_match;
	static const std::regex reVersion(R"(^(\d+)(?:\.(\d+))?(?:\.(\d+))?)");
	if (std::regex_search(ver_str, v_match, reVersion))
	{
		for (int i = 1; i <= 3; ++i)
		{
			if (v_match[i].matched)
			{
				try
				{
					(*this)[i-1] = std::stoi(v_match[i].str());
				}
				catch (std::exception const& ex)
				{
					return false;
				}
			}
			else
			{
				(*this)[i-1] = 0;
			}
		}

		return true;
	}

	return false;
}

static const char * shorten_to_file(const char * path)
{
	const char * p = path, * t = path;
	while(*p)
	{
		if(*p == '/' || *p == '\\')
			t = p+1;
		++p;
	}
	return t;
}

static int length_of_dir(const char * p)
{
	const char * f = shorten_to_file(p);
	return f - p;
}

#define MALLOC_CHUNK_SIZE 4096

struct module_alloc_block {
	module_alloc_block *		next;
	char *					ptr;
	size_t					remaining;
	char						data[MALLOC_CHUNK_SIZE];
};

static module_alloc_block * make_alloc_block()
{
	module_alloc_block * r = (module_alloc_block *) malloc(sizeof(module_alloc_block));
	assert(r);
	r->next = NULL;
	r->ptr = r->data;
	r->remaining = MALLOC_CHUNK_SIZE;
	return r;
}

static void * alloc_from_block(module_alloc_block *& head, size_t amt)
{
	assert(amt <= MALLOC_CHUNK_SIZE);
	
	if(head != NULL && head->remaining >= amt)
	{
		void * r = head->ptr;
		head->ptr += amt;
		head->remaining -= amt;
		return r;
	}
	else
	{
		module_alloc_block * nb = make_alloc_block();
		nb->next = head;
		head = nb;
	}	

	void * r = head->ptr;
	head->ptr += amt;
	head->remaining -= amt;
	return r;
}

static void destroy_alloc_block(module_alloc_block * head)
{
	while(head)
	{
		module_alloc_block * k = head;
		head = head->next;
		free(k);
	}
}

#define CTOR_FAIL(errcode,msg) \
if(errcode != 0) { \
	XPLMDebugString((get_log_prefix('E') + "Error during " + msg + " '" + m_log_path + "'\n").c_str()); \
	if (m_interp) \
	{ \
		const char *errmsg = nullptr; \
		lua_tostring(m_interp, -1); \
		log_message(m_interp,"%s\n%s failed: %d\n",errmsg,msg,errcode); \
		lua_close(m_interp); \
		m_interp = nullptr; \
	} \
	return; }

void profile_callback(void* data, lua_State* L, int samples, int vmstate)
{
	if (vmstate != 'C')
	{
		size_t buflen = 0;
		char const* p = luaJIT_profile_dumpstack(L, "flZ;", -20, &buflen);		// A333_fws_210_deferred[string]:4379;
		if (p != nullptr)
		{
			module* me = (module*)data;
			std::string cb(p, buflen);

			char const* pch = strtok(cb.data(), ";");
			while (pch != nullptr)
			{
				auto& this_fn = me->m_profile[pch];
				this_fn.cumulative += samples;

				pch = strtok(nullptr, ";");
				if (pch == nullptr)
				{
					// Last one - this is 'self'.
					this_fn.self += samples;
				}
			}
		}
	}
}

void module::start_profile(void)
{
	log_message(m_interp, "Lua profiler started in %s\n", get_log_path().c_str());
	luaJIT_profile_start(m_interp, "li1", profile_callback, this);
}

void module::stop_profile(void)
{
	log_message(m_interp, "Lua profiler stopped in %s\n", get_log_path().c_str());
	luaJIT_profile_stop(m_interp);
}

void module::dump_profile(void) const
{
	log_message(m_interp, "========================\n");
	log_message(m_interp, "Profile for %s\n", m_log_path.c_str());
	for (auto it = m_profile.begin(); it != m_profile.end(); ++it)
	{
		log_message(m_interp, "%s : %zu\n", it->first.c_str(), it->second);
	}
	log_message(m_interp, "========================\n");
}

void module::set_jit_mode(bool enable)
{
	luaJIT_setmode(m_interp, 0, LUAJIT_MODE_ENGINE | (enable ? LUAJIT_MODE_ON : LUAJIT_MODE_OFF));
	luaJIT_setmode(m_interp, 0, LUAJIT_MODE_ENGINE | LUAJIT_MODE_FLUSH);
}

bool module::get_jit_mode(void)
{
	// There's no C equivalent to _get_ the JIT mode...
	bool is_enabled = false;
	if (m_interp != nullptr && 0 == luaL_dostring(m_interp, "return jit and jit.status() or false"))
	{
		is_enabled = lua_toboolean(m_interp, -1);
		lua_pop(m_interp, 1);
	}
	return is_enabled;
}

module::module(
	std::filesystem::path const& in_module_path,
	std::filesystem::path const& in_init_script,
	std::filesystem::path const& in_module_script,
	void* (*in_alloc_func)(void* msp, void* ptr, size_t osize, size_t nsize),
	void* in_alloc_ref) :
	m_interp(NULL),
	m_memory(NULL),
	m_path(in_module_path),
	m_debug_proc(0),
	m_enabled(true),
	m_xlua_compat({ 1, 0, 0 })
{
	m_log_path = std::filesystem::relative(in_module_script, std::filesystem::path(in_init_script).remove_filename()).generic_string();

	// Mobile devices like Android don't use a regular file system...they have a bundle of resources in-memory so
	// we need to load the Lua script from an already allocated memory buffer.
	xmap_class lmod(in_module_script);
	if (!lmod.exists())
		CTOR_FAIL(-1, "load module");

	static const std::regex reHashbang(R"(^--\[\[\s*XLua\s+((?:\d+\.?){1,3})\s*\]\])");
	std::smatch hb_match;
	std::string hb_view(reinterpret_cast<char const*>(lmod.begin()), std::min<size_t>(lmod.size(), 128));
	if (std::regex_search(hb_view, hb_match, reHashbang))
	{
		if (!m_xlua_compat.init_from_string(hb_match[1].str()))
		{
			log_message(nullptr, "Unable to parse version '%s' in '%s'\n", hb_match[1].str().c_str(), m_log_path.c_str());
			CTOR_FAIL(-1, "load module");
		}
	}

	if (m_xlua_compat > sPluginVersion)
	{
		log_message(nullptr, "Script '%s' requires XLua %d.%d.%d or higher.\n", m_log_path.c_str(),
					m_xlua_compat[0], m_xlua_compat[1], m_xlua_compat[2]);
		CTOR_FAIL(-1, "Version too low");
	}

	m_interp = luaL_newstate();
	if(m_interp == nullptr)
	{
		XPLMDebugString("Unable to set up Lua.");
		return;
	}
	xlua_install_panic_handler(m_interp);
	luaL_openlibs(m_interp);

    xlua_pushuserdata(m_interp, this);
	lua_setglobal(m_interp, "__module_ptr");

	xlua_pushinteger(m_interp, m_xlua_compat[0]);
	lua_setglobal(m_interp, "XLuaMajorVersion");

	lua_pushstring(m_interp, XLUA_VERSION);
	lua_setglobal(m_interp, "XLuaPluginVersion");

	add_xlua_funcs_to_interp(m_interp, m_xlua_compat[0]);
	if (m_xlua_compat[0] >= 2)
	{
		// XLua 2.x functions. On mobile the generated glue registers the
		// mobile_compatible subset of the SDK; imgui and browser windows are
		// desktop-only.
		add_xplm_to_interp(m_interp);
#if !MOBILE
		LoadImguiBindings(m_interp);
		register_xlua_imgui_text_inputs(m_interp);
		// XLuaCreate/DestroyImguiWindow + XLuaCreate/DestroyBrowserWindow are now
		// registered by add_xplm_to_interp() above (declared in XPLMDisplay.xml
		// with lua_impl="external"), so the old register_xlua2_window_helpers()
		// call has been removed. imgui text inputs stay hand-registered because
		// their imgui table is created by LoadImguiBindings(), after the
		// generated registration runs.
#endif
	}

	lua_getfield(m_interp, LUA_GLOBALSINDEX, "package");
	lua_getfield(m_interp, -1, "path");
	std::string cur_path = lua_tostring(m_interp, -1);
	lua_pop(m_interp, 1);
	if (!cur_path.empty() && cur_path.back() != ';')
	{
		cur_path += ";";
	}
	lua_pushstring(m_interp, (cur_path / m_path / "../../include/?.lua").generic_string().c_str());
	lua_setfield(m_interp, -2, "path");
	lua_pop(m_interp, 1); // Remove the package table from the stack

	log_message(m_interp, "Running %s\n", m_log_path.c_str());

	// Mobile devices like Android don't use a regular file system...they have a bundle of resources in-memory so
	// we need to load the Lua script from an already allocated memory buffer.
	xmap_class linit(in_init_script);
	if(!linit.exists())
		CTOR_FAIL(-1, "load init script");
	
	m_debug_proc = lua_pushtraceback(m_interp);
	
	/*
	* Where do these numbers come from?
	* 
	* In short, see lj_jit.h, all the optimization parameters. Each of those ends up with a constant like
	* 'JIT_P_<name>'. Search the luajit code for anywhere that checks any of the JIT_P_max* parameters, stick
	* a breakpoint on the following call to lj_trace_err, slowly increase the values in J->param[whatever] until the
	* breakpoint stops hitting. Would be nice if this auto-tuned TBH. They end up calling RaiseException() on Windows but
	* catching that in any pcall() here does nothing because the JIT catches it itself.
	* 
	* Actual errors to breakpoint on: LJ_TRERR_SNAPOV, LJ_TRERR_MCODEAL, LJ_TRERR_MCODEOV, LJ_TRERR_TRACEOV, LJ_TRLINK_INTERP, lj_trace_flushall
	*
	* If these limits are hit then the jit tries, fails after a while and falls back to standard lua. On every frame.
	* 
	* Current A330 requirements without allocation errors:
	*				maxmcode		maxtrace		maxirconst		maxside
	*   default		512				1000			500				100
	*   A330		7168			3072			1500			400
	* 
	*/

	// The `jit and jit.opt` guard keeps this quiet on interpreter-only builds (iOS
	// forbids JIT, so LuaJIT ships without the jit.opt module there).
	int load_result = luaL_loadstring(m_interp, "if jit and jit.opt then jit.opt.start(\"maxmcode=8192\", \"maxtrace=4096\", \"maxirconst=1500\", \"maxside=500\") end");
	CTOR_FAIL(load_result, "set jit defaults")
	int script_result = lua_pcall(m_interp, 0, 0, m_debug_proc);

	load_result = luaL_loadbuffer(m_interp, (const char*)linit.begin(), linit.size(), in_init_script.generic_string().c_str());
	CTOR_FAIL(load_result, "load init script")

	script_result = lua_pcall(m_interp, 0, 0, m_debug_proc);
	CTOR_FAIL(script_result, "run init script");

	int module_load_result = luaL_loadbuffer(m_interp, (const char*)lmod.begin(), lmod.size(), m_log_path.c_str());
	CTOR_FAIL(module_load_result,"load module");
	
	int module_run_result;
	if (m_xlua_compat[0] == 1)
	{
		lua_getfield(m_interp, LUA_GLOBALSINDEX, "run_module_in_namespace");
		lua_insert(m_interp, -2);
		module_run_result = lua_pcall(m_interp, 1, 0, m_debug_proc);
		CTOR_FAIL(module_run_result, "run module V1");
	}
	else
	{
		module_run_result = lua_pcall(m_interp, 0, 0, m_debug_proc);
		CTOR_FAIL(module_run_result, "run module V2+");

		// To completely duplicate the normal C API, add XPluginStart etc.
		if (!(_XPluginStart() && _XPluginEnable()))
		{
			shutdown_lua();
		}
	}
}

int module::load_module_relative_path(const string& path)
{
	std::filesystem::path script_path(m_path / path);
	
	xmap_class script_text(script_path);
	
	if(!script_text.exists())
	{
		return luaL_error(m_interp, "Unable to load script file: %s", path.c_str());
	}
	
	int load_result = luaL_loadbuffer(m_interp, (const char*)script_text.begin(), script_text.size(), path.c_str());
	
	return load_result;
}

int module::debug_proc_from_interp(lua_State * interp)
{
	module * me = module_from_interp(interp);
	if(me)
		return me->m_debug_proc;
	return 0;
}

::module * module::module_from_interp(lua_State * interp)
{
    lua_getglobal(interp,"__module_ptr");

    module * me = xlua_checkuserdata<module*>(interp, -1, "module* is missing");
    lua_pop(interp, 1);
    return me;
}

void *		module::module_alloc_tracked(size_t amount)
{
	return alloc_from_block(m_memory, amount);
}

void		module::acf_load()
{
	if (m_interp != nullptr && m_enabled || m_xlua_compat[0] == 1)
	{
		do_callout("aircraft_load");
	}
}

void		module::acf_unload()
{
	if (m_interp != nullptr && m_enabled || m_xlua_compat[0] == 1)
	{
		do_callout("aircraft_unload");
	}
}

void		module::flight_start()
{
	if (m_interp != nullptr && m_enabled || m_xlua_compat[0] == 1)
	{
		do_callout("flight_start");
	}
}

void		module::flight_crash()
{
	if (m_interp != nullptr && m_enabled || m_xlua_compat[0] == 1)
	{
		do_callout("flight_crash");
	}
}

void		module::pre_physics()
{
	if (m_interp != nullptr && m_enabled || m_xlua_compat[0] == 1)
	{
		do_callout("before_physics");
	}
}

void		module::post_physics()
{
	if (m_interp != nullptr && m_enabled || m_xlua_compat[0] == 1)
	{
		do_callout("after_physics");
	}
}

void		module::post_replay()
{
	if (m_interp != nullptr && m_enabled || m_xlua_compat[0] == 1)
	{
		do_callout("after_replay");
	}
}

void module::do_callout(char const* f)
{
	if (m_interp == nullptr || !m_enabled)
		return;

	if (m_xlua_compat[0] == 1)
	{
		lua_getfield(m_interp, LUA_GLOBALSINDEX, "do_callout");
		if (!lua_isfunction(m_interp, -1))
		{
			lua_pop(m_interp, 1);
		}
		else
		{
			fmt_pcall_stdvars(m_interp, m_debug_proc, false, "s", f);
		}
	}
	else
	{
		lua_getfield(m_interp, LUA_GLOBALSINDEX, f);
		if (!lua_isfunction(m_interp, -1))
		{
			lua_pop(m_interp, 1);
		}
		else
		{
			fmt_pcall_stdvars(m_interp, m_debug_proc, false, "");
		}
	}
}

extern "C"
{
	XPLMPluginID* Make_XPLMPluginID(lua_State* L, XPLMPluginID const& init);
}

void module::_XPluginReceiveMessage(XPLMPluginID inFromWho, int inMessage, void* inParam)
{
	if (m_interp == nullptr || !m_enabled || m_xlua_compat[0] < 2)
		return;

	if (m_xlua_compat[0] == 1)
	{
		lua_getfield(m_interp, LUA_GLOBALSINDEX, "receive_message");
	}
	else
	{
		lua_getfield(m_interp, LUA_GLOBALSINDEX, "XPluginReceiveMessage");
	}

	if (!lua_isfunction(m_interp, -1))
	{
		lua_pop(m_interp, 1);
	}
	else
	{
		/*
		* Try to allow messages received via XPluginReceiveMessage to be sent. The problem is that the inParam is void* and
		* messages can be defined arbitrarily by plugins, so there's no way of knowing what datatype to make available.
		*
		* One option would be to translate _known_ messages to the correct type and leave all others as either null or userdata with a pointer
		* which could at least be used as a unique ID.
		*/

		std::string ptype = "n";
		auto known_msg = gXPMessageParamTypes.find(inMessage);
		if (known_msg != gXPMessageParamTypes.end())
		{
			ptype = known_msg->second;
		}

		if (ptype.front() == '*')
		{
			inParam = *(void**)inParam;
			ptype.erase(0);
		}

		Make_XPLMPluginID(m_interp, inFromWho);
		int ref = luaL_ref(m_interp, LUA_REGISTRYINDEX);
		fmt_pcall_stdvars(m_interp, m_debug_proc, false, ("ri" + ptype).c_str(), ref, inMessage, inParam);
		luaL_unref(m_interp, LUA_REGISTRYINDEX, ref);
	}
}

void module::shutdown_lua(void)
{
	if (m_interp)
	{
		if (m_enabled)
		{
			_XPluginDisable();
		}
		_XPluginStop();

		// Ditch all the callbacks now, during shutdown and _after_ any disable/stop hooks in case the user decides
		// to do anything funny like register callbacks.
		xlua_callback_cleanup(m_interp);

		luaJIT_profile_stop(m_interp);
		lua_close(m_interp);
		m_interp = nullptr;
	}
}

module::~module()
{
	shutdown_lua();
	destroy_alloc_block(m_memory);
}

bool module::_XPluginStart(void)
{
	bool res = true;

	lua_getfield(m_interp, LUA_GLOBALSINDEX, "XPluginStart");
	if (!lua_isfunction(m_interp, -1))
	{
		lua_pop(m_interp, 1);
	}
	else
	{
		res = false;		// They've defined an XPluginStart function. Assume it fails - they now need to return true from working code to continue.

		// In our case we're not going to pass through the parameters though, they're irrelevant.
		if (0 == fmt_pcall_stdvars(m_interp, m_debug_proc, true, ""))
		{
			if (lua_isboolean(m_interp, -1))
			{
				res = lua_toboolean(m_interp, -1);
			}
			else
			{
				log_message(m_interp, "XPluginStart did not return a boolean. Disabling this script.");
			}
		}
	}

	return res;
}

void module::_XPluginStop(void)
{
	// We want XPluginStop to be called regardless of the enabled status. This only gets called immediately before
	// an unload anyway.
	m_enabled = true;

	do_callout("XPluginStop");
}

bool module::_XPluginEnable(void)
{
	if (m_interp == nullptr)
		return false;

	m_enabled = true;

	lua_getfield(m_interp, LUA_GLOBALSINDEX, "XPluginEnable");

	if (!lua_isfunction(m_interp, -1))
	{
		lua_pop(m_interp, 1);
	}
	else
	{
		// In our case we're not going to pass through the parameters though, they're irrelevant.
		m_enabled = false;		// They've defined an XPluginEnable function. Assume it fails - they now need to return true from working code to continue.

		if (0 == fmt_pcall_stdvars(m_interp, m_debug_proc, true, ""))
		{
			if (lua_isboolean(m_interp, -1))
			{
				m_enabled = lua_toboolean(m_interp, -1);
			}
			else
			{
				log_message(m_interp, "XPluginEnable did not return a boolean. Disabling this script.");
			}
		}
	}

	return m_enabled;
}

void module::_XPluginDisable(void)
{
	do_callout("XPluginDisable");
}

#if !MOBILE

#if IBM

//-----
//https://stackoverflow.com/questions/215963/how-do-you-properly-use-widechartomultibyte

// Convert a wide Unicode string to an UTF8 string
// Convert an UTF8 string to a wide Unicode String
std::wstring utf8_decode(const std::string &str)
{
	if (str.empty()) return std::wstring();
	int size_needed = MultiByteToWideChar(CP_UTF8, 0, &str[0], (int)str.size(), NULL, 0);
	std::wstring wstrTo(size_needed, 0);
	MultiByteToWideChar(CP_UTF8, 0, &str[0], (int)str.size(), &wstrTo[0], size_needed);
	return wstrTo;
}

//-----

#endif

xmap_class::xmap_class(std::filesystem::path const& in_file_name) : xmap_class(in_file_name.generic_string())
{
}

xmap_class::xmap_class(const string& in_file_name) :
	m_buffer(NULL), m_size(0)
{
#if IBM
	FILE * fi = _wfopen(utf8_decode(in_file_name).c_str(), L"rb");
#else
	FILE * fi = fopen(in_file_name.c_str(), "rb");
#endif
	if (fi)
	{
		fseek(fi,0,SEEK_END);
		m_size = ftell(fi);
		fseek(fi, 0, SEEK_SET);

		m_buffer = static_cast<char *>(malloc(m_size + 1));
		if (m_buffer != nullptr)
		{
			fread(m_buffer, 1, m_size, fi);
			m_buffer[m_size] = 0;
		}

		fclose(fi);
	}
}

#endif
