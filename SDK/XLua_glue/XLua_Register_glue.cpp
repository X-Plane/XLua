extern "C"
{
	#include <lua.h>
	#include <lauxlib.h>


	// Headers with typedefs etc.
	#include "XPLMCamera.h"
	#include "XPLMDataAccess.h"
	#include "XPLMDefs.h"
	#include "XPLMDisplay.h"
	#include "XPLMGraphics.h"
	#include "XPLMInstance.h"
	#include "XPLMMap.h"
	#include "XPLMMenus.h"
	#include "XPLMNavigation.h"
	#include "XPLMPlanes.h"
	#include "XPLMProcessing.h"
	#include "XPLMScenery.h"
	#include "XPLMUtilities.h"
	#include "XPLMWeather.h"

	int MakeXPLMCameraPosition_t(lua_State* L);
	int MakeXPLMCreateAvionics_t(lua_State* L);
	int MakeXPLMCreateFlightLoop_t(lua_State* L);
	int MakeXPLMCreateMapLayer_t(lua_State* L);
	int MakeXPLMCustomizeAvionics_t(lua_State* L);
	int MakeXPLMDataRefInfo_t(lua_State* L);
	int MakeXPLMDrawInfoDouble_t(lua_State* L);
	int MakeXPLMDrawInfo_t(lua_State* L);
	int MakeXPLMFixedString150_t(lua_State* L);
	int MakeXPLMPlaneDrawState_t(lua_State* L);
	int MakeXPLMProbeInfo_t(lua_State* L);
	int MakeXPLMWeatherInfoClouds_t(lua_State* L);
	int MakeXPLMWeatherInfoWinds_t(lua_State* L);
	int MakeXPLMWeatherInfo_t(lua_State* L);

	// Typedefs
	void RegType_XPLMAvionicsID(lua_State* L);
	XPLMAvionicsID* Make_XPLMAvionicsID(lua_State* L, XPLMAvionicsID const& init);
	void RegType_XPLMCommandRef(lua_State* L);
	XPLMCommandRef* Make_XPLMCommandRef(lua_State* L, XPLMCommandRef const& init);
	void RegType_XPLMDataRef(lua_State* L);
	XPLMDataRef* Make_XPLMDataRef(lua_State* L, XPLMDataRef const& init);
	void RegType_XPLMFlightLoopID(lua_State* L);
	XPLMFlightLoopID* Make_XPLMFlightLoopID(lua_State* L, XPLMFlightLoopID const& init);
	void RegType_XPLMHotKeyID(lua_State* L);
	XPLMHotKeyID* Make_XPLMHotKeyID(lua_State* L, XPLMHotKeyID const& init);
	void RegType_XPLMInstanceRef(lua_State* L);
	XPLMInstanceRef* Make_XPLMInstanceRef(lua_State* L, XPLMInstanceRef const& init);
	void RegType_XPLMMapLayerID(lua_State* L);
	XPLMMapLayerID* Make_XPLMMapLayerID(lua_State* L, XPLMMapLayerID const& init);
	void RegType_XPLMMapProjectionID(lua_State* L);
	XPLMMapProjectionID* Make_XPLMMapProjectionID(lua_State* L, XPLMMapProjectionID const& init);
	void RegType_XPLMMenuID(lua_State* L);
	XPLMMenuID* Make_XPLMMenuID(lua_State* L, XPLMMenuID const& init);
	void RegType_XPLMNavRef(lua_State* L);
	XPLMNavRef* Make_XPLMNavRef(lua_State* L, XPLMNavRef const& init);
	void RegType_XPLMObjectRef(lua_State* L);
	XPLMObjectRef* Make_XPLMObjectRef(lua_State* L, XPLMObjectRef const& init);
	void RegType_XPLMPluginID(lua_State* L);
	XPLMPluginID* Make_XPLMPluginID(lua_State* L, XPLMPluginID const& init);
	void RegType_XPLMProbeRef(lua_State* L);
	XPLMProbeRef* Make_XPLMProbeRef(lua_State* L, XPLMProbeRef const& init);
}		// extern "C"


void add_xplm_to_interp(lua_State* L)
{
	lua_register(L, "XPLMCameraPosition_t", MakeXPLMCameraPosition_t);
	lua_register(L, "XPLMCreateAvionics_t", MakeXPLMCreateAvionics_t);
	lua_register(L, "XPLMCreateFlightLoop_t", MakeXPLMCreateFlightLoop_t);
	lua_register(L, "XPLMCreateMapLayer_t", MakeXPLMCreateMapLayer_t);
	lua_register(L, "XPLMCustomizeAvionics_t", MakeXPLMCustomizeAvionics_t);
	lua_register(L, "XPLMDataRefInfo_t", MakeXPLMDataRefInfo_t);
	lua_register(L, "XPLMDrawInfoDouble_t", MakeXPLMDrawInfoDouble_t);
	lua_register(L, "XPLMDrawInfo_t", MakeXPLMDrawInfo_t);
	lua_register(L, "XPLMFixedString150_t", MakeXPLMFixedString150_t);
	lua_register(L, "XPLMPlaneDrawState_t", MakeXPLMPlaneDrawState_t);
	lua_register(L, "XPLMProbeInfo_t", MakeXPLMProbeInfo_t);
	lua_register(L, "XPLMWeatherInfoClouds_t", MakeXPLMWeatherInfoClouds_t);
	lua_register(L, "XPLMWeatherInfoWinds_t", MakeXPLMWeatherInfoWinds_t);
	lua_register(L, "XPLMWeatherInfo_t", MakeXPLMWeatherInfo_t);

	// Userdata types
	RegType_XPLMAvionicsID(L);
	RegType_XPLMCommandRef(L);
	RegType_XPLMDataRef(L);
	RegType_XPLMFlightLoopID(L);
	RegType_XPLMHotKeyID(L);
	RegType_XPLMInstanceRef(L);
	RegType_XPLMMapLayerID(L);
	RegType_XPLMMapProjectionID(L);
	RegType_XPLMMenuID(L);
	RegType_XPLMNavRef(L);
	RegType_XPLMObjectRef(L);
	RegType_XPLMPluginID(L);
	RegType_XPLMProbeRef(L);
}
