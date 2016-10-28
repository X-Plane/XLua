//	Copyright 2016, Laminar Research
//	This source code is licensed under the MIT open source license.
//	See LICENSE.txt for the full terms of the license.

#define VERSION "1.0.0b1"

#include <stdio.h>
#include <string.h>
#include <assert.h>
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

#include "module.h"
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

#if !MOBILE
static void *			g_alloc = NULL;
#endif
static vector<module *>g_modules;
static XPLMFlightLoopID	g_pre_loop = NULL;
static XPLMFlightLoopID	g_post_loop = NULL;
static int				g_is_acf_inited = 0;
XPLMDataRef				g_replay_mode = NULL;
XPLMDataRef				g_sim_period = NULL;

struct lua_alloc_request_t {
			void *	ud;
			void *	ptr;
			size_t	osize;
			size_t	nsize;
};

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
	xlua_do_timers_for_time(XPLMGetElapsedTime());
	
	if(XPLMGetDatai(g_replay_mode) == 0)
	if(XPLMGetDataf(g_sim_period) > 0.0f)	
	for(vector<module *>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)	
		(*m)->pre_physics();
	return -1;
}

static float xlua_post_timer_master_cb(
                                   float                inElapsedSinceLastCall,    
                                   float                inElapsedTimeSinceLastFlightLoop,    
                                   int                  inCounter,    
                                   void *               inRefcon)
{
	if(XPLMGetDatai(g_replay_mode) == 0)
	{
		if(XPLMGetDataf(g_sim_period) > 0.0f)
		for(vector<module *>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)		
			(*m)->post_physics();
	}
	else
	for(vector<module *>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)		
		(*m)->post_replay();
	return -1;
}


PLUGIN_API int XPluginStart(
						char *		outName,
						char *		outSig,
						char *		outDesc)
{

    strcpy(outName, "XLua " VERSION);
    strcpy(outSig, "com.x-plane.xlua." VERSION);
    strcpy(outDesc, "A minimal scripting environment for aircraft authors.");

	g_replay_mode = XPLMFindDataRef("sim/operation/prefs/replay_mode");
	g_sim_period = XPLMFindDataRef("sim/operation/misc/frame_rate_period");

#if !MOBILE
	g_alloc = lj_alloc_create();
	if (g_alloc == NULL)
	{
		XPLMDebugString("Unable to get allocator from X-Plane.");
		printf("No allocator\n");
		return 0;
	}
#endif
	
	XPLMCreateFlightLoop_t pre = { 0 };
	XPLMCreateFlightLoop_t post = { 0 };
	pre.structSize = sizeof(pre);
	post.structSize = sizeof(post);
	pre.phase = xplm_FlightLoop_Phase_BeforeFlightModel;
	post.phase = xplm_FlightLoop_Phase_BeforeFlightModel;
	pre.callbackFunc = xlua_pre_timer_master_cb;
	post.callbackFunc = xlua_post_timer_master_cb;

	g_pre_loop = XPLMCreateFlightLoop(&pre);
	g_post_loop = XPLMCreateFlightLoop(&post);
	XPLMScheduleFlightLoop(g_pre_loop, -1, 0);
	XPLMScheduleFlightLoop(g_post_loop, -1, 0);
	
	XPLMEnableFeature("XPLM_USE_NATIVE_PATHS", 1);
	
	char path_to_me_c[2048];
	XPLMGetPluginInfo(XPLMGetMyID(), NULL, path_to_me_c, NULL, NULL);
	
	// Plugin base path: pop off two dirs from the plugin name to get the base path.
	string plugin_base_path(path_to_me_c);
	string::size_type lp = plugin_base_path.find_last_of("/\\");
	plugin_base_path.erase(lp);
	lp = plugin_base_path.find_last_of("/\\");
	plugin_base_path.erase(lp+1);
	
	string init_script_path(plugin_base_path);
	init_script_path += "init.lua";
	string scripts_dir_path(plugin_base_path);
	
	scripts_dir_path += "scripts";

	int offset = 0;
	int mf, fcount;
	while(1)
	{
		char fname_buf[2048];
		char * fptr;
		int result = XPLMGetDirectoryContents(
								scripts_dir_path.c_str(),
								offset,
								fname_buf,
								sizeof(fname_buf),
								&fptr,
								1,
								&mf,
								&fcount);
		if(fcount == 0)
			break;
		
		if(strcmp(fptr, ".DS_Store") != 0)
		{		
			string mod_path(scripts_dir_path);
			mod_path += "/";
			mod_path += fptr;
			mod_path += "/";
			string script_path(mod_path);
			script_path += fptr;
			script_path += ".lua";

#if !MOBILE
			g_modules.push_back(new module(
							mod_path.c_str(),
							init_script_path.c_str(),
							script_path.c_str(),
							lj_alloc_f,
							g_alloc));
#else
			g_modules.push_back(new module(
				mod_path.c_str(),
				init_script_path.c_str(),
				script_path.c_str(),
				lj_alloc_f,
				NULL));
#endif
		}
			
		++offset;
		if(offset == mf)
			break;
	}


	return 1;
}

PLUGIN_API void	XPluginStop(void)
{
	if(g_is_acf_inited)
	{
		for(vector<module *>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)
			(*m)->acf_unload();
		g_is_acf_inited = 0;
	}

	for(vector<module *>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)
		delete (*m);
	g_modules.clear();

#if !MOBILE
	if(g_alloc)
	{
		lj_alloc_destroy(g_alloc);
		g_alloc = NULL;
	}
#endif
	
	xlua_dref_cleanup();
	xlua_cmd_cleanup();
	xlua_timer_cleanup();
	
	XPLMDestroyFlightLoop(g_pre_loop);
	XPLMDestroyFlightLoop(g_post_loop);
	g_pre_loop = NULL;
	g_post_loop = NULL;	
	g_is_acf_inited = 0;
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
			g_is_acf_inited = 0;
		break;
	case XPLM_MSG_PLANE_UNLOADED:
		if(g_is_acf_inited)
		for(vector<module *>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)		
			(*m)->acf_unload();
		g_is_acf_inited = 0;
		break;
	case XPLM_MSG_AIRPORT_LOADED:
		if(!g_is_acf_inited)
		{
			for(vector<module *>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)
				(*m)->acf_load();
			g_is_acf_inited = 1;							
		}
		for(vector<module *>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)
			(*m)->flight_init();
		break;
	case XPLM_MSG_PLANE_CRASHED:
		assert(g_is_acf_inited);
		for(vector<module *>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)
			(*m)->flight_crash();		
		break;
	}
}

