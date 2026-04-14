//	Copyright 2016, Laminar Research
//	This source code is licensed under the MIT open source license.
//	See LICENSE.txt for the full terms of the license.


#define VERSION "1.3.7r3"

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <algorithm>
#include <fstream>
#include <vector>

#ifndef XPLM200
#define XPLM200
#endif

#ifndef XPLM210
#define XPLM210
#endif

#include <XPLMPlugin.h>
#include <XPLMDataAccess.h>
#include <XPLMUtilities.h>
#include <XPLMProcessing.h>
#include <XPLMMenus.h>
#include <XPLMPlanes.h>
#if IBM
#include <sys/stat.h>
#else
#include <sys/stat.h>
#endif

#include "module.h"
#include "xpfuncs.h"
#include "xpdatarefs.h"
#include "xpcommands.h"
#include "xptimers.h"

using std::vector;

/*

	TODO: get good errors on compile error.
	TODO: pipe output somewhere useful.






 */

extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}

static vector<module *>g_modules;
static XPLMFlightLoopID	g_pre_loop = NULL;
static XPLMFlightLoopID	g_post_loop = NULL;
static bool				g_is_acf_inited = false;
static vector<string>    g_loaded_module_names;
XPLMDataRef				g_replay_active = NULL;
XPLMDataRef				g_sim_period = NULL;
XPLMCommandRef			reset_cmd = nullptr;
XPLMMenuID				PluginMenu = 0;

static string plugin_base_path;
static time_t g_scripts_dir_mtime = 0;
static time_t g_init_script_mtime = 0;
static time_t g_max_script_mtime = 0;
static bool   g_has_script_signature = false;
static bool   g_jit_runtime_enabled = false;

enum ResetStateFlags {
	kResetStateSkipAirportLoadedCallback = 1 << 0,
	kResetStateForceReload = 1 << 1
};

#if IBM
#define XLUA_STAT_STRUCT struct _stat
#define XLUA_STAT _stat
#else
#define XLUA_STAT_STRUCT struct stat
#define XLUA_STAT stat
#endif

static bool file_exists(const string& path)
{
	FILE* f = fopen(path.c_str(), "rb");
	if (f == nullptr)
		return false;
	fclose(f);
	return true;
}

static bool get_mod_time(const string& path, time_t& mod_time)
{
	XLUA_STAT_STRUCT info = {};
	if (XLUA_STAT(path.c_str(), &info) != 0)
		return false;
	mod_time = info.st_mtime;
	return true;
}

static bool compute_script_signature(time_t& scripts_dir_mtime,
									 time_t& init_mtime,
									 time_t& max_script_mtime)
{
	time_t dir_mtime = 0;
	time_t init_time = 0;
	time_t max_time = 0;

	string scripts_dir_path(plugin_base_path);
	scripts_dir_path += "scripts";
	if (!get_mod_time(scripts_dir_path, dir_mtime))
		return false;

	string init_script_path(plugin_base_path);
	init_script_path += "init.lua";
	if (!get_mod_time(init_script_path, init_time))
		return false;

	for (const string& module_name : g_loaded_module_names)
	{
		string script_path(scripts_dir_path);
		script_path += "/";
		script_path += module_name;
		script_path += "/";
		script_path += module_name;
		script_path += ".lua";

		time_t script_time = 0;
		if (!get_mod_time(script_path, script_time))
			return false;
		if (script_time > max_time)
			max_time = script_time;
	}

	scripts_dir_mtime = dir_mtime;
	init_mtime = init_time;
	max_script_mtime = max_time;
	return true;
}

static void apply_jit_setting_to_state(lua_State* L, bool enable)
{
	if (L == nullptr)
		return;

	if (luaL_dostring(L,
			enable ?
			"local ok, jitmod = pcall(require, 'jit'); if ok and jitmod then jitmod.on(); jitmod.flush(true); end" :
			"local ok, jitmod = pcall(require, 'jit'); if ok and jitmod then jitmod.off(); end"))
	{
		// swallow errors silently; JIT optional
		lua_pop(L, 1);
	}
}

void xlua_apply_jit_setting(bool enable)
{
	g_jit_runtime_enabled = enable;
	for (vector<module*>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)
	{
		apply_jit_setting_to_state((*m)->interp(), enable);
	}
}

static bool read_manifest(const string& manifest_path,
						  const string& scripts_dir_path,
						  vector<string>& module_names)
{
	time_t scripts_mtime = 0;
	time_t manifest_mtime = 0;
	if (!get_mod_time(scripts_dir_path, scripts_mtime))
		return false;
	if (!get_mod_time(manifest_path, manifest_mtime))
		return false;
	if (manifest_mtime < scripts_mtime)
		return false;

	std::ifstream input(manifest_path.c_str());
	if (!input.is_open())
		return false;

	string line;
	while (std::getline(input, line))
	{
		if (!line.empty() && line.back() == '\r')
			line.pop_back();

		if (line.empty() || line[0] == '#')
			continue;

		string script_path(scripts_dir_path);
		script_path += "/";
		script_path += line;
		script_path += "/";
		script_path += line;
		script_path += ".lua";

		if (!file_exists(script_path))
		{
			module_names.clear();
			return false;
		}

		module_names.emplace_back(line);
	}

	return !module_names.empty();
}

static void write_manifest(const string& manifest_path, const vector<string>& module_names)
{
	FILE* manifest = fopen(manifest_path.c_str(), "w");
	if (manifest == nullptr)
		return;

	fputs("# XLua module manifest v1\n", manifest);
	for (const string& name : module_names)
	{
		fputs(name.c_str(), manifest);
		fputc('\n', manifest);
	}
	fclose(manifest);
}

struct lua_alloc_request_t {
			void *	ud;
			void *	ptr;
			size_t	osize;
			size_t	nsize;
};

enum eMenuItems : int
{
	MI_ResetState,
};

bool g_bReloadOnFlightChange = false;

PLUGIN_API void XPluginReceiveMessage(XPLMPluginID inFromWho, int inMessage, void* inParam);

#define		ALLOC_OPEN		0x00A110C1
#define		ALLOC_REALLOC	0x00A110C2
#define		ALLOC_CLOSE		0x00A110C3
#define		ALLOC_LOCK		0x00A110C4
#define		ALLOC_UNLOCK	0x00A110C5

static void lua_lock()
{
	XPLMSendMessageToPlugin(XPLM_PLUGIN_XPLANE, ALLOC_LOCK, NULL);
}
static void lua_unlock()
{
	XPLMSendMessageToPlugin(XPLM_PLUGIN_XPLANE, ALLOC_UNLOCK, NULL);
}

static void *lj_alloc_create(void)
{
	struct lua_alloc_request_t r = { 0 };
	XPLMSendMessageToPlugin(XPLM_PLUGIN_XPLANE, ALLOC_OPEN,&r);
	return r.ud;	
}

static void  lj_alloc_destroy(void *msp)
{
	struct lua_alloc_request_t r = { 0 };
	r.ud = msp;
	XPLMSendMessageToPlugin(XPLM_PLUGIN_XPLANE, ALLOC_CLOSE,&r);
}

static void *lj_alloc_f(void *msp, void *ptr, size_t osize, size_t nsize)
{
	struct lua_alloc_request_t r = { 0 };
	r.ud = msp;
	r.ptr = ptr;
	r.osize = osize;
	r.nsize = nsize;
	XPLMSendMessageToPlugin(XPLM_PLUGIN_XPLANE, ALLOC_REALLOC,&r);
	return r.ptr;
}

static float xlua_pre_timer_master_cb(
                                   float                inElapsedSinceLastCall,    
                                   float                inElapsedTimeSinceLastFlightLoop,    
                                   int                  inCounter,    
                                   void *               inRefcon)
{
	xlua_do_timers_for_time(xlua_get_simulated_time());
	
	if(XPLMGetDatai(g_replay_active) == 0)
	if(XPLMGetDataf(g_sim_period) > 0.0f)	
	for(vector<module *>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)	
	{
		if((*m)->has_pre_physics())
			(*m)->pre_physics();
	}
	return -1;
}

static float xlua_post_timer_master_cb(
                                   float                inElapsedSinceLastCall,    
                                   float                inElapsedTimeSinceLastFlightLoop,    
                                   int                  inCounter,    
                                   void *               inRefcon)
{
	if(XPLMGetDatai(g_replay_active) == 0)
	{
		if(XPLMGetDataf(g_sim_period) > 0.0f)
		for(vector<module *>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)		
		{
			if((*m)->has_post_physics())
				(*m)->post_physics();
		}
	}
	else
	for(vector<module *>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)		
	{
		if((*m)->has_post_replay())
			(*m)->post_replay();
	}
	return -1;
}

void InitScripts(void)
{
	assert(g_modules.empty() && !plugin_base_path.empty());

	string init_script_path(plugin_base_path);
	init_script_path += "init.lua";
	string scripts_dir_path(plugin_base_path);

	scripts_dir_path += "scripts";

	vector<string> module_names;
	const string manifest_path = scripts_dir_path + "/.xlua_manifest";
	bool manifest_loaded = read_manifest(manifest_path, scripts_dir_path, module_names);

	if (!manifest_loaded)
	{
		constexpr int kBatchSize = 16;
		int offset = 0;
		int mf = 0;
		int fcount = 0;
		do
		{
			char fname_buf[4096];
			char* name_ptrs[kBatchSize] = { nullptr };
			XPLMGetDirectoryContents(
				scripts_dir_path.c_str(),
				offset,
				fname_buf,
				sizeof(fname_buf),
				name_ptrs,
				kBatchSize,
				&mf,
				&fcount);
			if (fcount == 0)
				break;

			for (int i = 0; i < fcount; ++i)
			{
				const char* entry = name_ptrs[i];
				if (entry == nullptr)
					continue;

				if (strcmp(entry, ".DS_Store") != 0)
				{
					module_names.emplace_back(entry);
				}
			}

			offset += fcount;
		} while (offset < mf);

		std::sort(module_names.begin(), module_names.end());
		if (!module_names.empty())
			write_manifest(manifest_path, module_names);
	}
	else
	{
		std::sort(module_names.begin(), module_names.end());
	}
	g_loaded_module_names = module_names;
	for (const string& module_name : module_names)
	{
		string mod_path(scripts_dir_path);
		mod_path += "/";
		mod_path += module_name;
		mod_path += "/";
		string script_path(mod_path);
		script_path += module_name;
		script_path += ".lua";

		if (!file_exists(script_path))
		{
			string warn("XLua: skipping module '");
			warn += module_name;
			warn += "' (missing ";
			warn += script_path;
			warn += ")\n";
			XPLMDebugString(warn.c_str());
			continue;
		}

		g_modules.push_back(new module(
			mod_path.c_str(),
			init_script_path.c_str(),
			script_path.c_str(),
			lj_alloc_f,
			NULL));
	}

	time_t dir_time = 0, init_time = 0, max_script_time = 0;
	if (compute_script_signature(dir_time, init_time, max_script_time))
	{
		g_scripts_dir_mtime = dir_time;
		g_init_script_mtime = init_time;
		g_max_script_mtime = max_script_time;
		g_has_script_signature = true;
	}
	else
	{
		g_has_script_signature = false;
	}
}

void CleanupScripts(void)
{
	if (g_is_acf_inited)
	{
		for (vector<module*>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)
			(*m)->acf_unload();
		g_is_acf_inited = false;
	}

	for (vector<module*>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)
		delete (*m);
	g_modules.clear();

	xlua_dref_cleanup();
	xlua_cmd_cleanup();
	xlua_timer_cleanup();
}

int ResetState(XPLMCommandRef inCommand, XPLMCommandPhase inPhase, void* inRefcon)
{
	// Don't allow this to be called if the aircraft isn't ready, just in case somebody puts the LUA
	// command in init.lua for example...
	if (inPhase == xplm_CommandBegin && g_is_acf_inited)
	{
		const intptr_t flags = reinterpret_cast<intptr_t>(inRefcon);
		const bool skip_airport_loaded_callback = (flags & kResetStateSkipAirportLoadedCallback) != 0;
		const bool force_reload = (inRefcon == nullptr) || ((flags & kResetStateForceReload) != 0);
		if (!force_reload && g_has_script_signature)
		{
			time_t dir_time = 0, init_time = 0, max_script_time = 0;
			if (compute_script_signature(dir_time, init_time, max_script_time))
			{
				if (dir_time == g_scripts_dir_mtime &&
					init_time == g_init_script_mtime &&
					max_script_time == g_max_script_mtime)
				{
					// No changes detected; skip reload.
					return 0;
				}
			}
		}

		// Set to false to clear state on this too. Provided the XLuaReloadOnFlightChange() call is still in the scripts,
		// it will be immediately set back to true from the XPLM_MSG_AIRPORT_LOADED code below.
		g_bReloadOnFlightChange = false;

		CleanupScripts();
		InitScripts();

		if (!skip_airport_loaded_callback)	// Recursion block - ResetState() can be called from XPluginReceiveMessage().
		{
			XPluginReceiveMessage(XPLM_PLUGIN_XPLANE, XPLM_MSG_AIRPORT_LOADED, nullptr);
		}
	}

	return 0;
}

static void MenuHandler(void* menuRef, void* itemRef)
{
	switch ((eMenuItems)(size_t)itemRef)
	{
		case MI_ResetState:
			ResetState(reset_cmd, xplm_CommandBegin, nullptr);
			break;
	}
}

PLUGIN_API int XPluginStart(
						char *		outName,
						char *		outSig,
						char *		outDesc)
{
    strcpy(outName, "XLua " VERSION);
    strcpy(outSig, "com.x-plane.xlua." VERSION);
    strcpy(outDesc, "A minimal scripting environment for aircraft authors.");

	g_replay_active = XPLMFindDataRef("sim/time/is_in_replay");
	g_sim_period = XPLMFindDataRef("sim/operation/misc/frame_rate_period");
	
	XPLMCreateFlightLoop_t pre = { 0 };
	XPLMCreateFlightLoop_t post = { 0 };
	pre.structSize = sizeof(pre);
	post.structSize = sizeof(post);
	pre.phase = xplm_FlightLoop_Phase_BeforeFlightModel;
	post.phase = xplm_FlightLoop_Phase_AfterFlightModel;
	pre.callbackFunc = xlua_pre_timer_master_cb;
	post.callbackFunc = xlua_post_timer_master_cb;

	g_pre_loop = XPLMCreateFlightLoop(&pre);
	g_post_loop = XPLMCreateFlightLoop(&post);
	XPLMScheduleFlightLoop(g_pre_loop, -1, 0);
	XPLMScheduleFlightLoop(g_post_loop, -1, 0);
	
	XPLMEnableFeature("XPLM_USE_NATIVE_PATHS", 1);
	
	// Plugin base path: pop off two dirs from the plugin name to get the base path for scripts, *not* the owning aircraft's base path.
	char pName[256], pPath[512] = { 0 }, myPath[512] = { 0 };
	XPLMGetPluginInfo(XPLMGetMyID(), nullptr, myPath, nullptr, nullptr);
	plugin_base_path = myPath;
	for (int s = 0; s < 2; ++s)
	{
		string::size_type lp = plugin_base_path.find_last_of(XPLMGetDirectorySeparator());
		if (lp != std::string::npos)
		{
			plugin_base_path.erase(lp);
		}
	}
	plugin_base_path += XPLMGetDirectorySeparator();

	// Do we want to add a "reset" menu item? Only for the user's plane.
	XPLMGetNthAircraftModel(XPLM_USER_AIRCRAFT, pName, pPath);
	char *PDest = strrchr(pPath, *XPLMGetDirectorySeparator());
	if (PDest != nullptr)
	{
		*PDest = 0;
		const size_t acPathLen = strlen(pPath);
		std::string ac_base_path(plugin_base_path);
		string::size_type lp = std::string::npos;

		do
		{
			lp = ac_base_path.find_last_of(XPLMGetDirectorySeparator());
			if (lp != std::string::npos)
			{
				ac_base_path.erase(lp);
			}

			if (ac_base_path.compare(pPath) == 0)
			{
				const char* menuName;
				lp = ac_base_path.find_last_of(XPLMGetDirectorySeparator());
				if (lp != std::string::npos)
				{
					menuName = ac_base_path.c_str() + lp + 1;
				}
				else
				{
					menuName = outName;
				}

				int item = XPLMAppendMenuItem(XPLMFindPluginsMenu(), menuName, nullptr, 0);
				PluginMenu = XPLMCreateMenu(menuName, XPLMFindPluginsMenu(), item, MenuHandler, nullptr);
				XPLMAppendMenuItem(PluginMenu, "Reload Scripts", (void*)MI_ResetState, 0);
				break;
			}
		} while (lp != std::string::npos && ac_base_path.size() >= acPathLen);
	}

	InitScripts();

	reset_cmd = XPLMCreateCommand("laminar/xlua/reload_all_scripts", "Reload scripts and state for this aircraft");
	if (reset_cmd != nullptr)
	{
		XPLMRegisterCommandHandler(reset_cmd, ResetState, 1, nullptr);
	}

	return 1;
}

PLUGIN_API void	XPluginStop(void)
{
	if (PluginMenu != nullptr)
	{
		XPLMDestroyMenu(PluginMenu);
		PluginMenu = nullptr;
	}

	CleanupScripts();
	xlua_flush_log_queue();
	
	XPLMDestroyFlightLoop(g_pre_loop);
	XPLMDestroyFlightLoop(g_post_loop);
	g_pre_loop = NULL;
	g_post_loop = NULL;	
	g_is_acf_inited = false;
}

PLUGIN_API void XPluginDisable(void)
{
}

PLUGIN_API int XPluginEnable(void)
{
	xlua_relink_all_drefs();
	return 1;
}

PLUGIN_API void XPluginReceiveMessage(
					XPLMPluginID	inFromWho,
					int				inMessage,
					void *			inParam)
{
	if(inFromWho != XPLM_PLUGIN_XPLANE)
		return;
		
	switch(inMessage) {
	case XPLM_MSG_PLANE_LOADED:
		if(inParam == 0)
			g_is_acf_inited = false;
		break;

	case XPLM_MSG_PLANE_UNLOADED:
		if(g_is_acf_inited)
		for(vector<module *>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)		
			(*m)->acf_unload();
		g_is_acf_inited = false;
		break;

	case XPLM_MSG_AIRPORT_LOADED:
		if (g_bReloadOnFlightChange && g_is_acf_inited)
		{
			ResetState(
				reset_cmd,
				xplm_CommandBegin,
				reinterpret_cast<void*>(static_cast<intptr_t>(
					kResetStateSkipAirportLoadedCallback | kResetStateForceReload)));
		}

		if (!g_is_acf_inited)
		{
			// Pick up any last stragglers from out-of-order load and then validate our datarefs!
			xlua_relink_all_drefs();
			xlua_validate_drefs();
			
			for(vector<module *>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)
				(*m)->acf_load();

			if (g_jit_runtime_enabled)
			{
				for (vector<module*>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)
					apply_jit_setting_to_state((*m)->interp(), true);
			}

			g_is_acf_inited = true;
		}

		for(vector<module *>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)
			(*m)->flight_start();

		break;

	case XPLM_MSG_PLANE_CRASHED:
		assert(g_is_acf_inited);
		for(vector<module *>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)
			(*m)->flight_crash();		
		break;
	}
}

