//	Copyright 2016, Laminar Research
//	This source code is licensed under the MIT open source license.
//	See LICENSE.txt for the full terms of the license.


#define VERSION "1.5.1r1"

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <vector>
#include <memory>
#include <algorithm>
#include <array>
#include <filesystem>

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

#include "module.h"
#include "xpdatarefs.h"
#include "xpcommands.h"
#include "xptimers.h"
#include "xpfuncs.h"

#if !MOBILE
#include "ImGUIIntegration.h"
#endif

using std::vector;

extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}

std::map<int, char const*> gXPMessageParamTypes;

static vector<module *>g_modules;
static XPLMFlightLoopID	g_pre_loop = NULL;
static XPLMFlightLoopID	g_post_loop = NULL;
static bool				g_is_acf_inited = false;
XPLMDataRef				g_replay_active = NULL;
XPLMDataRef				g_sim_period = NULL;
XPLMCommandRef			reset_cmd = nullptr;
XPLMMenuID				PluginMenu = 0;					// Our sub-menu
int						PluginMenuItem = 0;				// Our sub-menu's item number on the Plugins menu
bool					g_bIsAircraftPlugin = true;
int						JITMenuItem = 0;

static string plugin_base_path;

struct lua_alloc_request_t {
			void *	ud;
			void *	ptr;
			size_t	osize;
			size_t	nsize;
};

enum eMenuItems : int
{
	MI_ResetState,
#if !MOBILE
	MI_ShowProfiler,
	MI_ToggleJIT
#endif
};

bool g_bReloadOnFlightChange = false;

#if !MOBILE
std::shared_ptr<flwnd::ImGUIWindow> profilerWnd;
#endif

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
		(*m)->pre_physics();
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
			(*m)->post_physics();
	}
	else
	for(vector<module *>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)		
		(*m)->post_replay();
#if !MOBILE
	if (profilerWnd)
	{
		if (!profilerWnd->isVisible())
		{
			profilerWnd->reportClose();
			profilerWnd.reset();
		}
	}
	if (!g_modules.empty())
	{
		bool is_enabled = g_modules.front()->get_jit_mode();
		XPLMCheckMenuItem(PluginMenu, JITMenuItem, is_enabled ? xplm_Menu_Checked : xplm_Menu_Unchecked);
	}
#endif
	return -1;
}

void InitScripts(void)
{
	assert(g_modules.empty() && !plugin_base_path.empty());

	string init_script_path(plugin_base_path);
	init_script_path += "init.lua";
	string scripts_dir_path(plugin_base_path);

	scripts_dir_path += "scripts";

	int offset = 0;
	int mf, fcount;
	while (1)
	{
		char fname_buf[2048];
		char* fptr;
		XPLMGetDirectoryContents(
			scripts_dir_path.c_str(),
			offset,
			fname_buf,
			sizeof(fname_buf),
			&fptr,
			1,
			&mf,
			&fcount);
		if (fcount == 0)
			break;

		if (strcmp(fptr, ".DS_Store") != 0)
		{
			string mod_path(scripts_dir_path);
			mod_path += "/";
			mod_path += fptr;
			mod_path += "/";
			string script_path(mod_path);
			script_path += fptr;
			script_path += ".lua";

			g_modules.push_back(new module(
				mod_path.c_str(),
				init_script_path.c_str(),
				script_path.c_str(),
				lj_alloc_f,
				NULL));
		}

		++offset;
		if (offset == mf)
			break;
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

	// Get rid of drefs/cmds/timers first, they may well hold references to the Lua interpreter.
	xlua_dref_cleanup();
	xlua_cmd_cleanup();
	xlua_timer_cleanup();
	xlua_callback_cleanup();

	for (vector<module*>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)
		delete (*m);
	g_modules.clear();
}

int ResetState(XPLMCommandRef inCommand, XPLMCommandPhase inPhase, void* inRefcon)
{
	// Don't allow this to be called if the aircraft isn't ready, just in case somebody puts the LUA
	// command in init.lua for example...
	if (inPhase == xplm_CommandBegin && g_is_acf_inited)
	{
		// Set to false to clear state on this too. Provided the XLuaReloadOnFlightChange() call is still in the scripts,
		// it will be immediately set back to true from the XPLM_MSG_AIRPORT_LOADED code below.
		g_bReloadOnFlightChange = false;

		CleanupScripts();
		InitScripts();

		if (!(intptr_t)inRefcon)	// Recursion block - ResetState() can be called from XPluginReceiveMessage().
		{
			XPluginReceiveMessage(XPLM_PLUGIN_XPLANE, XPLM_MSG_AIRPORT_LOADED, nullptr);
		}
	}

	return 0;
}
#if !MOBILE
void ShowProfiler(void)
{
	using namespace flwnd;

	if (!profilerWnd)
	{
		profilerWnd = std::make_shared<ImGUIWindow>(800, 300, xplm_WindowDecorationRoundRectangle);

		profilerWnd->setTitle("XLua Profiler");
		profilerWnd->setBuildCallback([](ImGUIWindow& wnd) -> void
									  {
										  static int module_selected_idx = 0, profiler_mode = 0, last_profiler_mode = 0;
										  static bool profiler_running = false, last_profiler_running = false, show_as_percent = true;
										  static module* last_selected_module = nullptr;

										  module* selected_module = nullptr;
										  if (module_selected_idx >= 0 && module_selected_idx < g_modules.size())
										  {
											  selected_module = g_modules.at(module_selected_idx);

											  if (profiler_running != last_profiler_running)
											  {
												  if (selected_module != nullptr)
												  {
													  if (profiler_running)
													  {
														  selected_module->start_profile();
													  }
													  else
													  {
														  selected_module->stop_profile();
													  }
												  }

												  last_profiler_running = profiler_running;
											  }
										  }

										  if (selected_module != last_selected_module)
										  {
											  if (profiler_running)
											  {
												  if (last_selected_module != nullptr && std::find(g_modules.begin(), g_modules.end(), last_selected_module) != g_modules.end())
												  {
													  last_selected_module->stop_profile();
												  }

												  selected_module->start_profile();
											  }

											  last_selected_module = selected_module;
										  }

										  if (ImGui::BeginCombo("##modules", (selected_module == nullptr ? "" : selected_module->get_log_path().c_str()), 
																ImGuiComboFlags_::ImGuiComboFlags_None))
										  {
											  for (size_t i=0; i < g_modules.size(); ++i)
											  {
												  if (ImGui::Selectable(g_modules[i]->get_log_path().c_str(), g_modules[i] == selected_module))
												  {
													  // Was selected?
													  module_selected_idx = static_cast<int>(i);
												  }
											  }

											  ImGui::EndCombo();
										  }

										  if (ImGui::BeginCombo("Mode", profiler_mode == 0 ? "Function" : "Line", ImGuiComboFlags_::ImGuiComboFlags_WidthFitPreview))
										  {
											  static const std::array<std::pair<char const*, int>, 2> kModes{ 
												  std::pair<char const*, int>{ "Function", 0 }, 
												  std::pair<char const*, int>{ "Line", 1 }
											  };

											  for (auto const& [t, i] : kModes)
											  {
												  if (ImGui::Selectable(t, profiler_mode == 0))
												  {
													  // Need to clear all results.
													  for (auto& mod : g_modules)
													  {
														  mod->clear_profile();
													  }

													  profiler_mode = i;

													  if (selected_module != nullptr)
													  {
														  selected_module->m_profile_line_level = (profiler_mode == 1);
													  }
												  }
											  }

											  ImGui::EndCombo();
										  }

										  ImGui::SameLine(0, 20);
										  ImGui::Checkbox("Show as %", &show_as_percent);

										  ImGui::Checkbox("Run Profiler", &profiler_running);

										  ImGui::SameLine(0, 20);
										  ImGui::BeginDisabled(selected_module == nullptr || selected_module->m_profile.empty());
										  if (selected_module != nullptr && ImGui::Button("Dump to Log"))
										  {
											  selected_module->dump_profile();
										  }
										  ImGui::SameLine();
										  if (selected_module != nullptr && ImGui::Button("Clear"))
										  {
											  selected_module->clear_profile();
										  }
										  ImGui::EndDisabled();

										  if (ImGui::BeginTable("Results", 3, ImGuiTableFlags_::ImGuiTableFlags_Borders | ImGuiTableFlags_::ImGuiTableFlags_Resizable | ImGuiTableFlags_::ImGuiTableFlags_Sortable))
										  {
											  ImGui::TableSetupColumn("Call Site");
											  ImGui::TableSetupColumn("Inclusive");
											  ImGui::TableSetupColumn("Self");
											  ImGui::TableHeadersRow();

											  if (selected_module != nullptr)
											  {
												  typedef decltype(module::m_profile)::const_iterator prof_type;

												  std::vector<prof_type> profile_iterators_vec;
												  profile_iterators_vec.reserve(selected_module->m_profile.size());
												  size_t total_self = 0;
												  for (prof_type i = selected_module->m_profile.cbegin(); i != selected_module->m_profile.cend(); ++i)
												  {
													  profile_iterators_vec.emplace_back(i);
													  total_self += i->second.self;
												  }

												  // Sort our data if sort specs have been changed!
												  if (ImGuiTableSortSpecs* sort_specs = ImGui::TableGetSortSpecs())
												  {
													  // Sadly our data is potentially changing per-frame so the sort also needs to be per-frame.
													  //if (sort_specs->SpecsDirty)
													  //{
														 // MyItem::SortWithSortSpecs(sort_specs, items.Data, items.Size);
														 // sort_specs->SpecsDirty = false;
													  //}

													  std::sort(profile_iterators_vec.begin(), profile_iterators_vec.end(),
																		[sort_specs](prof_type const& lhs, prof_type const& rhs) -> bool
																		{
																			for (int n = 0; n < sort_specs->SpecsCount; n++)
																			{
																				ImGuiTableColumnSortSpecs const* sort_spec = &sort_specs->Specs[n];

																				int delta = 0;
																				if (sort_spec->ColumnIndex == 0)
																					delta = lhs->first.compare(rhs->first);
																				else if (sort_spec->ColumnIndex == 1)
																					delta = (lhs->second.cumulative - rhs->second.cumulative);
																				else
																					delta = (lhs->second.self - rhs->second.self);

																				if (delta > 0)
																					return (sort_spec->SortDirection == ImGuiSortDirection_Ascending);
																				if (delta < 0)
																					return (sort_spec->SortDirection != ImGuiSortDirection_Ascending);
																			}

																			return lhs->first.compare(rhs->first) < 0;
																		});
												  }

												  for (auto const &it : profile_iterators_vec)
												  {
													  const auto& [site, count] = *it;
													  ImGui::TableNextRow();

													  ImGui::TableNextColumn();
													  ImGui::Text("%s", site.c_str());

													  if (show_as_percent)
													  {
														  ImGui::TableNextColumn();
														  ImGui::Text("%0.3f%%", 100 * static_cast<float>(count.cumulative) / total_self);

														  ImGui::TableNextColumn();
														  ImGui::Text("%0.3f%%", 100 * static_cast<float>(count.self) / total_self);
													  }
													  else
													  {
														  ImGui::TableNextColumn();
														  ImGui::Text("%zu", count.cumulative);

														  ImGui::TableNextColumn();
														  ImGui::Text("%zu", count.self);
													  }
												  }
											  }

											  ImGui::EndTable();
										  }
									  });

		profilerWnd->setCloseCallback([](FloatingWindow& wnd) -> void
									  {
										  wnd.setVisible(false);
									  });
	}
	else
	{
		profilerWnd->setVisible(true);
	}
}
#endif
static void MenuHandler(void* menuRef, void* itemRef)
{
	switch ((eMenuItems)(size_t)itemRef)
	{
		case MI_ResetState:
			ResetState(reset_cmd, xplm_CommandBegin, nullptr);
			break;
#if !MOBILE
		case MI_ShowProfiler:
			ShowProfiler();
			break;

		case MI_ToggleJIT:
		{
			if (!g_modules.empty())
			{
				XPLMMenuCheck curState;
				XPLMCheckMenuItemState(PluginMenu, JITMenuItem, &curState);

				for (auto const& m : g_modules)
				{
					m->set_jit_mode(curState != xplm_Menu_Checked);
				}
			}
			break;
		}
#endif
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
	
	XPLMEnableFeature("XPLM_USE_NATIVE_PATHS", 1);
	
	// Plugin base path: pop off two dirs from the plugin name to get the base path for scripts, *not* the owning aircraft's base path.
	char pPath[512] = { 0 }, myPath[512] = { 0 };
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

	char sysPath[512];
	XPLMGetSystemPath(sysPath);
	auto relpath = std::filesystem::relative(std::filesystem::path(myPath), std::filesystem::path(sysPath) / "Aircraft");
	g_bIsAircraftPlugin = !relpath.string().starts_with("..");

	if (g_bIsAircraftPlugin)
	{
		strcpy(outSig, "com.x-plane.xlua-sys." VERSION);
	}

	return 1;
}

PLUGIN_API void	XPluginStop(void)
{
}

PLUGIN_API void XPluginDisable(void)
{
	if (PluginMenu != nullptr)
	{
		XPLMRemoveMenuItem(XPLMFindPluginsMenu(), PluginMenuItem);
		XPLMDestroyMenu(PluginMenu);
		PluginMenu = nullptr;
	}

	CleanupScripts();

	XPLMDestroyFlightLoop(g_pre_loop);
	XPLMDestroyFlightLoop(g_post_loop);
	g_pre_loop = nullptr;
	g_post_loop = nullptr;
	g_is_acf_inited = false;
}

PLUGIN_API int XPluginEnable(void)
{
	XPLMCreateFlightLoop_t pre =
	{
		.structSize = sizeof(XPLMCreateFlightLoop_t),
		.phase = xplm_FlightLoop_Phase_BeforeFlightModel,
		.callbackFunc = xlua_pre_timer_master_cb
	};
	g_pre_loop = XPLMCreateFlightLoop(&pre);
	XPLMScheduleFlightLoop(g_pre_loop, -1, 0);

	XPLMCreateFlightLoop_t post =
	{
		.structSize = sizeof(XPLMCreateFlightLoop_t),
		.phase = xplm_FlightLoop_Phase_AfterFlightModel,
		.callbackFunc = xlua_post_timer_master_cb
	};
	g_post_loop = XPLMCreateFlightLoop(&post);
	XPLMScheduleFlightLoop(g_post_loop, -1, 0);

	char const* menuName = nullptr;
	std::string ac_base_path(plugin_base_path);

	if (g_bIsAircraftPlugin)
	{
		// Do we want to add a "reset" menu item? Only for the user's plane.
		char pName[256], sysPath[512];

		XPLMGetSystemPath(sysPath);
		XPLMGetNthAircraftModel(XPLM_USER_AIRCRAFT, pName, sysPath);
		char* PDest = strrchr(sysPath, *XPLMGetDirectorySeparator());
		if (PDest != nullptr)
		{
			*PDest = 0;
			const size_t acPathLen = strlen(sysPath);
			string::size_type lp = std::string::npos;

			do
			{
				lp = ac_base_path.find_last_of(XPLMGetDirectorySeparator());
				if (lp != std::string::npos)
				{
					ac_base_path.erase(lp);
				}

				if (ac_base_path.compare(sysPath) == 0)
				{
					lp = ac_base_path.find_last_of(XPLMGetDirectorySeparator());
					if (lp != std::string::npos)
					{
						menuName = ac_base_path.c_str() + lp + 1;
					}
					else
					{
						menuName = "XLua " VERSION;
					}

					break;
				}
			} while (lp != std::string::npos && ac_base_path.size() >= acPathLen);
		}

		reset_cmd = XPLMCreateCommand("laminar/xlua/reload_all_scripts", "Reload scripts and state for this aircraft");
		if (reset_cmd != nullptr)
		{
			XPLMRegisterCommandHandler(reset_cmd, ResetState, 1, nullptr);
		}
	}
	else
	{
		menuName = "System XLua";
	}

	if (menuName != nullptr)
	{
		PluginMenuItem = XPLMAppendMenuItem(XPLMFindPluginsMenu(), menuName, nullptr, 0);
		PluginMenu = XPLMCreateMenu(menuName, XPLMFindPluginsMenu(), PluginMenuItem, MenuHandler, nullptr);
		XPLMAppendMenuItem(PluginMenu, "Reload Scripts", (void*)MI_ResetState, 0);
#if !MOBILE
		XPLMAppendMenuItem(PluginMenu, "Show Profiler", (void*)MI_ShowProfiler, 1);
		JITMenuItem = XPLMAppendMenuItem(PluginMenu, "Toggle JIT", (void*)MI_ToggleJIT, 2);
#endif
	}

	InitScripts();

	xlua_relink_all_drefs();
	return 1;
}

PLUGIN_API void XPluginReceiveMessage(
					XPLMPluginID	inFromWho,
					int				inMessage,
					void *			inParam)
{
	if (inFromWho == XPLM_PLUGIN_XPLANE)
	{
		switch (inMessage)
		{
			case XPLM_MSG_PLANE_LOADED:
				if (inParam == 0)
					g_is_acf_inited = false;
				break;

			case XPLM_MSG_PLANE_UNLOADED:
				if (g_is_acf_inited)
					for (vector<module*>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)
						(*m)->acf_unload();

				g_is_acf_inited = false;
				break;

			case XPLM_MSG_AIRPORT_LOADED:
				if (g_bReloadOnFlightChange && g_is_acf_inited)
				{
					ResetState(reset_cmd, xplm_CommandBegin, (void*)(intptr_t)1);
				}

				if (!g_is_acf_inited)
				{
					// Pick up any last stragglers from out-of-order load and then validate our datarefs!
					xlua_relink_all_drefs();
					xlua_validate_drefs();

					for (vector<module*>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)
						(*m)->acf_load();

					g_is_acf_inited = true;
				}

				for (vector<module*>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)
					(*m)->flight_start();

				break;

			case XPLM_MSG_PLANE_CRASHED:
				assert(g_is_acf_inited);
				for (vector<module*>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)
					(*m)->flight_crash();
				break;
		}
	}

	// Either way, send the full details through so that Lua can now deal with arbitrary messages.
	for (vector<module*>::iterator m = g_modules.begin(); m != g_modules.end(); ++m)
	{
		(*m)->forward_notification(inFromWho, inMessage, inParam);
	}
}

void xlua_register_event(int EventID, char const* EventParamtype)
{
	gXPMessageParamTypes[EventID] = EventParamtype;
}
