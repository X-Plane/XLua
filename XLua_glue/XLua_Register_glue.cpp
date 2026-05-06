void xlua_register_event(int EventID, char const* EventParamtype);

extern "C"
{
	#include <lua.h>
	#include <lauxlib.h>


	// Headers with typedefs etc.
	#include "XPLMDefs.h"
	#include "XPLMDisplay.h"

	int XLuaAvionicsNeedsDrawing(lua_State* L);
	int XLuaBringWindowToFront(lua_State* L);
	int XLuaCountHotKeys(lua_State* L);
	int XLuaCreateAvionicsEx(lua_State* L);
	int MakeXPLMCreateAvionics_t(lua_State* L);
	int XLuaCreateWindow(lua_State* L);
	int XLuaCreateWindowEx(lua_State* L);
	int MakeXPLMCreateWindow_t(lua_State* L);
	int MakeXPLMCustomizeAvionics_t(lua_State* L);
	int XLuaDestroyAvionics(lua_State* L);
	int XLuaDestroyWindow(lua_State* L);
	int XLuaGetAllMonitorBoundsGlobal(lua_State* L);
	int XLuaGetAllMonitorBoundsOS(lua_State* L);
	int XLuaGetAvionicsBrightnessRheo(lua_State* L);
	int XLuaGetAvionicsBusVoltsRatio(lua_State* L);
	int XLuaGetAvionicsGeometry(lua_State* L);
	int XLuaGetAvionicsGeometryOS(lua_State* L);
	int XLuaGetAvionicsHandle(lua_State* L);
	int XLuaGetHotKeyInfo(lua_State* L);
	int XLuaGetMouseLocation(lua_State* L);
	int XLuaGetMouseLocationGlobal(lua_State* L);
	int XLuaGetNthHotKey(lua_State* L);
	int XLuaGetScreenBoundsGlobal(lua_State* L);
	int XLuaGetScreenSize(lua_State* L);
	int XLuaGetWindowGeometry(lua_State* L);
	int XLuaGetWindowGeometryOS(lua_State* L);
	int XLuaGetWindowGeometryVR(lua_State* L);
	int XLuaGetWindowIsVisible(lua_State* L);
	int XLuaGetWindowRefCon(lua_State* L);
	int XLuaHasAvionicsKeyboardFocus(lua_State* L);
	int XLuaHasKeyboardFocus(lua_State* L);
	int XLuaIsAvionicsBound(lua_State* L);
	int XLuaIsAvionicsPoppedOut(lua_State* L);
	int XLuaIsAvionicsPopupVisible(lua_State* L);
	int XLuaIsCursorOverAvionics(lua_State* L);
	int XLuaIsWindowInFront(lua_State* L);
	int XLuaPopOutAvionics(lua_State* L);
	int XLuaRegisterAvionicsCallbacksEx(lua_State* L);
	int XLuaRegisterHotKey(lua_State* L);
	int XLuaReturnString(lua_State* L);
	int XLuaSetAvionicsBrightnessRheo(lua_State* L);
	int XLuaSetAvionicsGeometry(lua_State* L);
	int XLuaSetAvionicsGeometryOS(lua_State* L);
	int XLuaSetAvionicsPopupVisible(lua_State* L);
	int XLuaSetHotKeyCombination(lua_State* L);
	int XLuaSetWindowGeometry(lua_State* L);
	int XLuaSetWindowGeometryOS(lua_State* L);
	int XLuaSetWindowGeometryVR(lua_State* L);
	int XLuaSetWindowGravity(lua_State* L);
	int XLuaSetWindowIsVisible(lua_State* L);
	int XLuaSetWindowPositioningMode(lua_State* L);
	int XLuaSetWindowRefCon(lua_State* L);
	int XLuaSetWindowResizingLimits(lua_State* L);
	int XLuaSetWindowTitle(lua_State* L);
	int XLuaTakeAvionicsKeyboardFocus(lua_State* L);
	int XLuaTakeKeyboardFocus(lua_State* L);
	int XLuaUnregisterAvionicsCallbacks(lua_State* L);
	int XLuaUnregisterHotKey(lua_State* L);
	int XLuaWindowAddBrowserFunction(lua_State* L);
	int XLuaWindowInjectScript(lua_State* L);
	int XLuaWindowIsInVR(lua_State* L);
	int XLuaWindowIsPoppedOut(lua_State* L);
	int XLuaWindowRefresh(lua_State* L);
	int XLuaWindowSetURL(lua_State* L);

	// Typedefs
	void RegType_XPLMAvionicsID(lua_State* L);
	XPLMAvionicsID* Make_XPLMAvionicsID(lua_State* L, XPLMAvionicsID const& init);
	void RegType_XPLMHotKeyID(lua_State* L);
	XPLMHotKeyID* Make_XPLMHotKeyID(lua_State* L, XPLMHotKeyID const& init);
	void RegType_XPLMPluginID(lua_State* L);
	XPLMPluginID* Make_XPLMPluginID(lua_State* L, XPLMPluginID const& init);
	void RegType_XPLMWindowID(lua_State* L);
	XPLMWindowID* Make_XPLMWindowID(lua_State* L, XPLMWindowID const& init);
}		// extern "C"


void add_xplm_to_interp(lua_State* L)
{
	lua_register(L, "XPLMAvionicsNeedsDrawing", XLuaAvionicsNeedsDrawing);
	lua_register(L, "XPLMBringWindowToFront", XLuaBringWindowToFront);
	lua_register(L, "XPLMCountHotKeys", XLuaCountHotKeys);
	lua_register(L, "XPLMCreateAvionicsEx", XLuaCreateAvionicsEx);
	lua_register(L, "XPLMCreateAvionics_t", MakeXPLMCreateAvionics_t);
	lua_register(L, "XPLMCreateWindow", XLuaCreateWindow);
	lua_register(L, "XPLMCreateWindowEx", XLuaCreateWindowEx);
	lua_register(L, "XPLMCreateWindow_t", MakeXPLMCreateWindow_t);
	lua_register(L, "XPLMCustomizeAvionics_t", MakeXPLMCustomizeAvionics_t);
	lua_register(L, "XPLMDestroyAvionics", XLuaDestroyAvionics);
	lua_register(L, "XPLMDestroyWindow", XLuaDestroyWindow);
	lua_register(L, "XPLMGetAllMonitorBoundsGlobal", XLuaGetAllMonitorBoundsGlobal);
	lua_register(L, "XPLMGetAllMonitorBoundsOS", XLuaGetAllMonitorBoundsOS);
	lua_register(L, "XPLMGetAvionicsBrightnessRheo", XLuaGetAvionicsBrightnessRheo);
	lua_register(L, "XPLMGetAvionicsBusVoltsRatio", XLuaGetAvionicsBusVoltsRatio);
	lua_register(L, "XPLMGetAvionicsGeometry", XLuaGetAvionicsGeometry);
	lua_register(L, "XPLMGetAvionicsGeometryOS", XLuaGetAvionicsGeometryOS);
	lua_register(L, "XPLMGetAvionicsHandle", XLuaGetAvionicsHandle);
	lua_register(L, "XPLMGetHotKeyInfo", XLuaGetHotKeyInfo);
	lua_register(L, "XPLMGetMouseLocation", XLuaGetMouseLocation);
	lua_register(L, "XPLMGetMouseLocationGlobal", XLuaGetMouseLocationGlobal);
	lua_register(L, "XPLMGetNthHotKey", XLuaGetNthHotKey);
	lua_register(L, "XPLMGetScreenBoundsGlobal", XLuaGetScreenBoundsGlobal);
	lua_register(L, "XPLMGetScreenSize", XLuaGetScreenSize);
	lua_register(L, "XPLMGetWindowGeometry", XLuaGetWindowGeometry);
	lua_register(L, "XPLMGetWindowGeometryOS", XLuaGetWindowGeometryOS);
	lua_register(L, "XPLMGetWindowGeometryVR", XLuaGetWindowGeometryVR);
	lua_register(L, "XPLMGetWindowIsVisible", XLuaGetWindowIsVisible);
	lua_register(L, "XPLMGetWindowRefCon", XLuaGetWindowRefCon);
	lua_register(L, "XPLMHasAvionicsKeyboardFocus", XLuaHasAvionicsKeyboardFocus);
	lua_register(L, "XPLMHasKeyboardFocus", XLuaHasKeyboardFocus);
	lua_register(L, "XPLMIsAvionicsBound", XLuaIsAvionicsBound);
	lua_register(L, "XPLMIsAvionicsPoppedOut", XLuaIsAvionicsPoppedOut);
	lua_register(L, "XPLMIsAvionicsPopupVisible", XLuaIsAvionicsPopupVisible);
	lua_register(L, "XPLMIsCursorOverAvionics", XLuaIsCursorOverAvionics);
	lua_register(L, "XPLMIsWindowInFront", XLuaIsWindowInFront);
	lua_register(L, "XPLMPopOutAvionics", XLuaPopOutAvionics);
	lua_register(L, "XPLMRegisterAvionicsCallbacksEx", XLuaRegisterAvionicsCallbacksEx);
	lua_register(L, "XPLMRegisterHotKey", XLuaRegisterHotKey);
	lua_register(L, "XPLMReturnString", XLuaReturnString);
	lua_register(L, "XPLMSetAvionicsBrightnessRheo", XLuaSetAvionicsBrightnessRheo);
	lua_register(L, "XPLMSetAvionicsGeometry", XLuaSetAvionicsGeometry);
	lua_register(L, "XPLMSetAvionicsGeometryOS", XLuaSetAvionicsGeometryOS);
	lua_register(L, "XPLMSetAvionicsPopupVisible", XLuaSetAvionicsPopupVisible);
	lua_register(L, "XPLMSetHotKeyCombination", XLuaSetHotKeyCombination);
	lua_register(L, "XPLMSetWindowGeometry", XLuaSetWindowGeometry);
	lua_register(L, "XPLMSetWindowGeometryOS", XLuaSetWindowGeometryOS);
	lua_register(L, "XPLMSetWindowGeometryVR", XLuaSetWindowGeometryVR);
	lua_register(L, "XPLMSetWindowGravity", XLuaSetWindowGravity);
	lua_register(L, "XPLMSetWindowIsVisible", XLuaSetWindowIsVisible);
	lua_register(L, "XPLMSetWindowPositioningMode", XLuaSetWindowPositioningMode);
	lua_register(L, "XPLMSetWindowRefCon", XLuaSetWindowRefCon);
	lua_register(L, "XPLMSetWindowResizingLimits", XLuaSetWindowResizingLimits);
	lua_register(L, "XPLMSetWindowTitle", XLuaSetWindowTitle);
	lua_register(L, "XPLMTakeAvionicsKeyboardFocus", XLuaTakeAvionicsKeyboardFocus);
	lua_register(L, "XPLMTakeKeyboardFocus", XLuaTakeKeyboardFocus);
	lua_register(L, "XPLMUnregisterAvionicsCallbacks", XLuaUnregisterAvionicsCallbacks);
	lua_register(L, "XPLMUnregisterHotKey", XLuaUnregisterHotKey);
	lua_register(L, "XPLMWindowAddBrowserFunction", XLuaWindowAddBrowserFunction);
	lua_register(L, "XPLMWindowInjectScript", XLuaWindowInjectScript);
	lua_register(L, "XPLMWindowIsInVR", XLuaWindowIsInVR);
	lua_register(L, "XPLMWindowIsPoppedOut", XLuaWindowIsPoppedOut);
	lua_register(L, "XPLMWindowRefresh", XLuaWindowRefresh);
	lua_register(L, "XPLMWindowSetURL", XLuaWindowSetURL);

	// Userdata types
	RegType_XPLMAvionicsID(L);
	RegType_XPLMHotKeyID(L);
	RegType_XPLMPluginID(L);
	RegType_XPLMWindowID(L);

	// Event types
}
