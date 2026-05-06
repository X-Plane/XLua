#ifndef _Glue_XPLMDisplay_h_
#define _Glue_XPLMDisplay_h_

/*
 * Copyright 2005-2026 Laminar Research, Sandy Barbour and Ben Supnik All
 * rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
 *
 */

/***************************************************************************
 * XPLMDisplay
 ***************************************************************************/
/*
 * This API provides the basic hooks to draw in X-Plane and create user
 * interface. All X-Plane drawing is done in OpenGL. The X-Plane plug-in
 * manager takes care of properly setting up the OpenGL context and matrices. 
 * You do not decide when in your code's execution to draw; X-Plane tells you
 * (via callbacks) when it is ready to have your plugin draw.
 * 
 * X-Plane's drawing strategy is straightforward: every "frame" the screen is
 * rendered by drawing the 3-D scene (dome, ground, objects, airplanes, etc.)
 * and then drawing the cockpit on top of it.  Alpha blending is used to
 * overlay the cockpit over the world (and the gauges over the panel, etc.).
 * X-Plane user interface elements (including windows like the map, the main
 * menu, etc.) are then drawn on top of the cockpit.
 * 
 * There are two ways you can draw: directly and in a window.
 * 
 * Direct drawing (deprecated!---more on that below) involves drawing to the
 * screen before or after X-Plane finishes a phase of drawing.  When you draw
 * directly, you can specify whether X-Plane is to complete this phase or not.
 * This allows you to do three things: draw before X-Plane does (under it),
 * draw after X-Plane does (over it), or draw instead of X-Plane.
 * 
 * To draw directly, you register a callback and specify which phase you want
 * to intercept.  The plug-in manager will call you over and over to draw that
 * phase.
 * 
 * Direct drawing allows you to override scenery, panels, or anything.  Note
 * that you cannot assume that you are the only plug-in drawing at this phase.
 * 
 * Direct drawing is deprecated; at some point in the X-Plane 11 run, it will
 * likely become unsupported entirely as X-Plane transitions from OpenGL to
 * modern graphics API backends (e.g., Vulkan, Metal, etc.). In the long term,
 * plugins should use the XPLMInstance API for drawing 3-D objects---this will
 * be much more efficient than general 3-D OpenGL drawing, and it will
 * actually be supported by the new graphics backends. We do not yet know what
 * the post-transition API for generic 3-D drawing will look like (if it
 * exists at all).
 * 
 * In contrast to direct drawing, window drawing provides a higher level
 * functionality. With window drawing, you create a 2-D window that takes up a
 * portion of the screen. Window drawing is always two dimensional.  Window
 * drawing is depth controlled; you can specify that you want your window to
 * be brought on top, and other plug-ins may put their window on top of you. 
 * Window drawing also allows you to sign up for key presses and receive mouse
 * clicks.
 * 
 * Drawing into the screen of an avionics device, like a GPS or a Primary
 * Flight Display, is a way  to extend or replace X-Plane's avionics. Most
 * screens can be displayed both in a 3d cockpit or 
 * 2d panel, and also in separate popup windows. By installing drawing
 *  callbacks for a certain avionics  device, you can change or extend the
 *  appearance of that device regardless whether it's installed  in a 3d
 *  cockpit or used in a separate display for home cockpits because you leave
 *  the window managing to X-Plane.
 * 
 * There are three ways to get keystrokes:
 * 
 * 1. If you create a window, the window can take keyboard focus.  It will
 *    then receive all keystrokes.  If no window has focus, X-Plane receives
 *    keystrokes.  Use this to implement typing in dialog boxes, etc.  Only
 *    one window may have focus at a time; your window will be notified if it
 *    loses focus.
 * 2. If you need low level access to the keystroke stream, install a key
 *    sniffer.  Key sniffers can be installed above everything or right in
 *    front of the sim.
 * 3. If you would like to associate key strokes with commands/functions in
 *    your plug-in, you should simply register a command (via
 *    XPLMCreateCommand()) and allow users to bind whatever key they choose to
 *    that command. Another (now deprecated) method of doing so is to use a
 *    hot key---a key-specific callback.  Hotkeys are sent based on virtual
 *    key strokes, so any key may be distinctly mapped with any modifiers. 
 *    Hot keys can be remapped by other plug-ins.  As a plug-in, you don't
 *    have to worry about what your hot key ends up mapped to; other plug-ins
 *    may provide a UI for remapping keystrokes.  So hotkeys allow a user to
 *    resolve conflicts and customize keystrokes.
 *
 */


#include "XPLMDefs.h"
#include "XPLMDisplay.h"

#include "XPLMCallbackWrapper.h"
#if defined(XPLM_DEFINE_HOST_GLOBALS)
#include "XPDLLUtils.h"
#endif

#if defined(XPLM_DEFINE_CLIENT_WRAP_HOOKS)
#include "XPLMHookWrapper.h"
#endif

#ifdef __cplusplus
extern "C" {
#endif


using xplmCreateWindow_f = XPLMWindowID (*)(int inLeft, int inTop, int inRight, int inBottom, int inIsVisible, XPLMDrawWindow_f inDrawCallback, XPLMHandleKey_f inKeyCallback, XPLMHandleMouseClick_f inMouseCallback, void* inRefcon);
#if defined(XPLM_DEFINE_HOST_GLOBALS)
    xplmCreateWindow_f xplmCreateWindow = nullptr;
#else
    extern xplmCreateWindow_f xplmCreateWindow;
#endif


using xplmDestroyWindow_f = void (*)(XPLMWindowID inWindowID);
#if defined(XPLM_DEFINE_HOST_GLOBALS)
    xplmDestroyWindow_f xplmDestroyWindow = nullptr;
#else
    extern xplmDestroyWindow_f xplmDestroyWindow;
#endif


using xplmWindowSetURL_f = void (*)(XPLMWindowID inWindowID, const char * inURL);
#if defined(XPLM_DEFINE_HOST_GLOBALS)
    xplmWindowSetURL_f xplmWindowSetURL = nullptr;
#else
    extern xplmWindowSetURL_f xplmWindowSetURL;
#endif


using xplmWindowRefresh_f = void (*)(XPLMWindowID inWindowID, int inIgnoreCache);
#if defined(XPLM_DEFINE_HOST_GLOBALS)
    xplmWindowRefresh_f xplmWindowRefresh = nullptr;
#else
    extern xplmWindowRefresh_f xplmWindowRefresh;
#endif


using xplmWindowInjectScript_f = void (*)(XPLMWindowID inWindowID, const char * inScript);
#if defined(XPLM_DEFINE_HOST_GLOBALS)
    xplmWindowInjectScript_f xplmWindowInjectScript = nullptr;
#else
    extern xplmWindowInjectScript_f xplmWindowInjectScript;
#endif


using xplmReturnString_f = const char * (*)(const char * inString);
#if defined(XPLM_DEFINE_HOST_GLOBALS)
    xplmReturnString_f xplmReturnString = nullptr;
#else
    extern xplmReturnString_f xplmReturnString;
#endif


using xplmWindowAddBrowserFunction_f = void (*)(XPLMWindowID inWindowID, const char * inName, XPLMBrowserCallback_f inFunction, void* inRefcon);
#if defined(XPLM_DEFINE_HOST_GLOBALS)
    xplmWindowAddBrowserFunction_f xplmWindowAddBrowserFunction = nullptr;
#else
    extern xplmWindowAddBrowserFunction_f xplmWindowAddBrowserFunction;
#endif


using xplmGetScreenSize_f = void (*)(int * outWidth, int * outHeight);
#if defined(XPLM_DEFINE_HOST_GLOBALS)
    xplmGetScreenSize_f xplmGetScreenSize = nullptr;
#else
    extern xplmGetScreenSize_f xplmGetScreenSize;
#endif


using xplmGetMouseLocation_f = void (*)(int * outX, int * outY);
#if defined(XPLM_DEFINE_HOST_GLOBALS)
    xplmGetMouseLocation_f xplmGetMouseLocation = nullptr;
#else
    extern xplmGetMouseLocation_f xplmGetMouseLocation;
#endif


using xplmGetWindowGeometry_f = void (*)(XPLMWindowID inWindowID, int * outLeft, int * outTop, int * outRight, int * outBottom);
#if defined(XPLM_DEFINE_HOST_GLOBALS)
    xplmGetWindowGeometry_f xplmGetWindowGeometry = nullptr;
#else
    extern xplmGetWindowGeometry_f xplmGetWindowGeometry;
#endif


using xplmSetWindowGeometry_f = void (*)(XPLMWindowID inWindowID, int inLeft, int inTop, int inRight, int inBottom);
#if defined(XPLM_DEFINE_HOST_GLOBALS)
    xplmSetWindowGeometry_f xplmSetWindowGeometry = nullptr;
#else
    extern xplmSetWindowGeometry_f xplmSetWindowGeometry;
#endif


using xplmGetWindowIsVisible_f = int (*)(XPLMWindowID inWindowID);
#if defined(XPLM_DEFINE_HOST_GLOBALS)
    xplmGetWindowIsVisible_f xplmGetWindowIsVisible = nullptr;
#else
    extern xplmGetWindowIsVisible_f xplmGetWindowIsVisible;
#endif


using xplmSetWindowIsVisible_f = void (*)(XPLMWindowID inWindowID, int inIsVisible);
#if defined(XPLM_DEFINE_HOST_GLOBALS)
    xplmSetWindowIsVisible_f xplmSetWindowIsVisible = nullptr;
#else
    extern xplmSetWindowIsVisible_f xplmSetWindowIsVisible;
#endif


using xplmGetWindowRefCon_f = void* (*)(XPLMWindowID inWindowID);
#if defined(XPLM_DEFINE_HOST_GLOBALS)
    xplmGetWindowRefCon_f xplmGetWindowRefCon = nullptr;
#else
    extern xplmGetWindowRefCon_f xplmGetWindowRefCon;
#endif


using xplmSetWindowRefCon_f = void (*)(XPLMWindowID inWindowID, void* inRefcon);
#if defined(XPLM_DEFINE_HOST_GLOBALS)
    xplmSetWindowRefCon_f xplmSetWindowRefCon = nullptr;
#else
    extern xplmSetWindowRefCon_f xplmSetWindowRefCon;
#endif


using xplmTakeKeyboardFocus_f = void (*)(XPLMWindowID inWindow);
#if defined(XPLM_DEFINE_HOST_GLOBALS)
    xplmTakeKeyboardFocus_f xplmTakeKeyboardFocus = nullptr;
#else
    extern xplmTakeKeyboardFocus_f xplmTakeKeyboardFocus;
#endif


using xplmHasKeyboardFocus_f = int (*)(XPLMWindowID inWindow);
#if defined(XPLM_DEFINE_HOST_GLOBALS)
    xplmHasKeyboardFocus_f xplmHasKeyboardFocus = nullptr;
#else
    extern xplmHasKeyboardFocus_f xplmHasKeyboardFocus;
#endif


using xplmBringWindowToFront_f = void (*)(XPLMWindowID inWindow);
#if defined(XPLM_DEFINE_HOST_GLOBALS)
    xplmBringWindowToFront_f xplmBringWindowToFront = nullptr;
#else
    extern xplmBringWindowToFront_f xplmBringWindowToFront;
#endif


using xplmIsWindowInFront_f = int (*)(XPLMWindowID inWindow);
#if defined(XPLM_DEFINE_HOST_GLOBALS)
    xplmIsWindowInFront_f xplmIsWindowInFront = nullptr;
#else
    extern xplmIsWindowInFront_f xplmIsWindowInFront;
#endif

#ifdef __cplusplus
} // extern "C"
#endif
#if defined(XPLM_DEFINE_HOST_GLOBALS)

class XPLMDisplay_glue_helper : public glue_helper_base {
public: 

virtual void init_glue(XPDLLRef dll) override
{


	xplmCreateWindow = SIM_TO_XPLM_FUNC(xplmCreateWindow_f, XPFindSymbolInDLL(dll, "XPLMCreateWindow"));

	xplmDestroyWindow = SIM_TO_XPLM_FUNC(xplmDestroyWindow_f, XPFindSymbolInDLL(dll, "XPLMDestroyWindow"));

	xplmWindowSetURL = SIM_TO_XPLM_FUNC(xplmWindowSetURL_f, XPFindSymbolInDLL(dll, "XPLMWindowSetURL"));

	xplmWindowRefresh = SIM_TO_XPLM_FUNC(xplmWindowRefresh_f, XPFindSymbolInDLL(dll, "XPLMWindowRefresh"));

	xplmWindowInjectScript = SIM_TO_XPLM_FUNC(xplmWindowInjectScript_f, XPFindSymbolInDLL(dll, "XPLMWindowInjectScript"));

	xplmReturnString = SIM_TO_XPLM_FUNC(xplmReturnString_f, XPFindSymbolInDLL(dll, "XPLMReturnString"));

	xplmWindowAddBrowserFunction = SIM_TO_XPLM_FUNC(xplmWindowAddBrowserFunction_f, XPFindSymbolInDLL(dll, "XPLMWindowAddBrowserFunction"));

	xplmGetScreenSize = SIM_TO_XPLM_FUNC(xplmGetScreenSize_f, XPFindSymbolInDLL(dll, "XPLMGetScreenSize"));

	xplmGetMouseLocation = SIM_TO_XPLM_FUNC(xplmGetMouseLocation_f, XPFindSymbolInDLL(dll, "XPLMGetMouseLocation"));

	xplmGetWindowGeometry = SIM_TO_XPLM_FUNC(xplmGetWindowGeometry_f, XPFindSymbolInDLL(dll, "XPLMGetWindowGeometry"));

	xplmSetWindowGeometry = SIM_TO_XPLM_FUNC(xplmSetWindowGeometry_f, XPFindSymbolInDLL(dll, "XPLMSetWindowGeometry"));

	xplmGetWindowIsVisible = SIM_TO_XPLM_FUNC(xplmGetWindowIsVisible_f, XPFindSymbolInDLL(dll, "XPLMGetWindowIsVisible"));

	xplmSetWindowIsVisible = SIM_TO_XPLM_FUNC(xplmSetWindowIsVisible_f, XPFindSymbolInDLL(dll, "XPLMSetWindowIsVisible"));

	xplmGetWindowRefCon = SIM_TO_XPLM_FUNC(xplmGetWindowRefCon_f, XPFindSymbolInDLL(dll, "XPLMGetWindowRefCon"));

	xplmSetWindowRefCon = SIM_TO_XPLM_FUNC(xplmSetWindowRefCon_f, XPFindSymbolInDLL(dll, "XPLMSetWindowRefCon"));

	xplmTakeKeyboardFocus = SIM_TO_XPLM_FUNC(xplmTakeKeyboardFocus_f, XPFindSymbolInDLL(dll, "XPLMTakeKeyboardFocus"));

	xplmHasKeyboardFocus = SIM_TO_XPLM_FUNC(xplmHasKeyboardFocus_f, XPFindSymbolInDLL(dll, "XPLMHasKeyboardFocus"));

	xplmBringWindowToFront = SIM_TO_XPLM_FUNC(xplmBringWindowToFront_f, XPFindSymbolInDLL(dll, "XPLMBringWindowToFront"));

	xplmIsWindowInFront = SIM_TO_XPLM_FUNC(xplmIsWindowInFront_f, XPFindSymbolInDLL(dll, "XPLMIsWindowInFront"));
}

virtual  void shutdown_glue() override
{


	xplmCreateWindow = nullptr;

	xplmDestroyWindow = nullptr;

	xplmWindowSetURL = nullptr;

	xplmWindowRefresh = nullptr;

	xplmWindowInjectScript = nullptr;

	xplmReturnString = nullptr;

	xplmWindowAddBrowserFunction = nullptr;

	xplmGetScreenSize = nullptr;

	xplmGetMouseLocation = nullptr;

	xplmGetWindowGeometry = nullptr;

	xplmSetWindowGeometry = nullptr;

	xplmGetWindowIsVisible = nullptr;

	xplmSetWindowIsVisible = nullptr;

	xplmGetWindowRefCon = nullptr;

	xplmSetWindowRefCon = nullptr;

	xplmTakeKeyboardFocus = nullptr;

	xplmHasKeyboardFocus = nullptr;

	xplmBringWindowToFront = nullptr;

	xplmIsWindowInFront = nullptr;
}

}; /* XPLMDisplay_glue_helper */

static XPLMDisplay_glue_helper s_XPLMDisplay_glue_helper;

#endif


/***************************************************************************
 * Host API
 ***************************************************************************/


#define XPLMDisplayHostApiVersion 0

/*
 * XPCreateAvionics
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void*      XPCreateAvionics(
                         const XPLMCreateAvionics_t* callback);

/*
 * XPDestroyAvionics
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPDestroyAvionics(
                         void*                handle);

/*
 * XPIsAvionicsBound
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 int        XPIsAvionicsBound(
                         int                  id,
                         void*                handle);

/*
 * XPSetAvionicsBrightness
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPSetAvionicsBrightness(
                         int                  id,
                         void*                handle,
                         float                brt);

/*
 * XPGetAvionicsBrightness
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 float      XPGetAvionicsBrightness(
                         int                  id,
                         void*                handle);

/*
 * XPGetAvionicsBusVoltsRatio
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 float      XPGetAvionicsBusVoltsRatio(
                         int                  id,
                         void*                handle);

/*
 * XPSetAvionicsPopupVisible
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPSetAvionicsPopupVisible(
                         int                  id,
                         void*                handle,
                         int                  visible);

/*
 * XPIsAvionicsPopupVisible
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 int        XPIsAvionicsPopupVisible(
                         int                  id,
                         void*                handle);

/*
 * XPPopOutAvionics
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPPopOutAvionics(
                         int                  id,
                         void*                handle);

/*
 * XPIsAvionicsPoppedOut
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 int        XPIsAvionicsPoppedOut(
                         int                  id,
                         void*                handle);

/*
 * XPAvionicsNeedsDrawing
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPAvionicsNeedsDrawing(
                         int                  id,
                         void*                handle);

/*
 * XPIsMouseOverAvionics
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 int        XPIsMouseOverAvionics(
                         int                  id,
                         void*                handle,
                         int*                 x,
                         int*                 y);

/*
 * XPTakeAvionicsKeyboardFocus
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPTakeAvionicsKeyboardFocus(
                         int                  id,
                         void*                handle);

/*
 * XPHasAvionicsKeyboardFocus
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 int        XPHasAvionicsKeyboardFocus(
                         int                  id,
                         void*                handle);

/*
 * XPGetAvionicsWindowBounds
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPGetAvionicsWindowBounds(
                         int                  id,
                         void*                handle,
                         int                  outBounds[4]);

/*
 * XPSetAvionicsWindowBounds
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPSetAvionicsWindowBounds(
                         int                  id,
                         void*                handle,
                         int                  inBounds[4]);

/*
 * XPGetAvionicsWindowBoundsOS
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPGetAvionicsWindowBoundsOS(
                         int                  id,
                         void*                handle,
                         int                  outBounds[4]);

/*
 * XPSetAvionicsWindowBoundsOS
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPSetAvionicsWindowBoundsOS(
                         int                  id,
                         void*                handle,
                         int                  inBounds[4]);

/*
 * XPGetScreenSize
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPGetScreenSize(
                         int*                 outWidth,
                         int*                 outHeight);

/*
 * XPGetScreenBoundsGlobal
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPGetScreenBoundsGlobal(
                         int*                 outLeft,
                         int*                 outTop,
                         int*                 outRight,
                         int*                 outBottom);

/*
 * XPGetAllMonitorBoundsGlobal
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPGetAllMonitorBoundsGlobal(
                         XPLMReceiveMonitorBoundsGlobal_f inMonitorBoundsCallback,
                         void*                refcon);

/*
 * XPGetAllMonitorBoundsOS
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPGetAllMonitorBoundsOS(
                         XPLMReceiveMonitorBoundsOS_f inMonitorBoundsCallback,
                         void*                refcon);

/*
 * XPGetMouseLocation
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPGetMouseLocation(
                         int*                 outX,
                         int*                 outY,
                         int                  inMenuBarOK);

/*
 * XPGetMouseLocationGlobal
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPGetMouseLocationGlobal(
                         int*                 outX,
                         int*                 outY,
                         int                  inMenuBarOK);

/*
 * XPSetPluginMouseFocus
 * 
 * Params are mutually exclusive. If both parameters are false, it means SDK
 * focus is on *no* window.
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPSetPluginMouseFocus(
                         int                  want_focus_hack_for_old_style_windows,
                         void*                ptr_to_modern_window_if_focus_is_on_modern_window_or_null);

/*
 * XPCreateGuiPluginWindow
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPCreateGuiPluginWindow(
                         void*                window,
                         XPLMWindowDecoration decoration,
                         int                  layer,
                         int                  initially_visible,
                         int                  is_gui_backed);

/*
 * XPDestroyGuiPluginWindow
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPDestroyGuiPluginWindow(
                         void*                window);

/*
 * XPGuiPluginWindowIsVisible
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 int        XPGuiPluginWindowIsVisible(
                         void*                window);

/*
 * XPHideGuiPluginWindow
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPHideGuiPluginWindow(
                         void*                window);

/*
 * XPShowGuiPluginWindow
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPShowGuiPluginWindow(
                         void*                window);

/*
 * XPGetGuiPluginWindowBounds
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPGetGuiPluginWindowBounds(
                         void*                window,
                         int                  out_bounds[4]);

/*
 * XPSetGuiPluginWindowBounds
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 int        XPSetGuiPluginWindowBounds(
                         void*                window,
                         int                  in_bounds[4]);

/*
 * XPGetPopoutWindowOSBounds
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPGetPopoutWindowOSBounds(
                         void*                window,
                         int                  out_bounds[4]);

/*
 * XPSetPopoutWindowOSBounds
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 int        XPSetPopoutWindowOSBounds(
                         void*                window,
                         int                  in_os_bounds[4]);

/*
 * XPGuiWindowIsPoppedOut
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 int        XPGuiWindowIsPoppedOut(
                         void*                window);

/*
 * XPGuiWindowIsInVr
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 int        XPGuiWindowIsInVr(
                         void*                window);

/*
 * XPBringGuiWindowToFront
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPBringGuiWindowToFront(
                         void*                window);

/*
 * XPGuiWindowIsInFront
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 int        XPGuiWindowIsInFront(
                         void*                window);

/*
 * XPSetWindowPositioningMode
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPSetWindowPositioningMode(
                         void*                window,
                         int                  inPositioningMode,
                         int                  inMonitorIndex);

/*
 * XPSetWindowResizingLimits
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPSetWindowResizingLimits(
                         void*                window,
                         int                  inMinWidthBoxels,
                         int                  inMinHeightBoxels,
                         int                  inMaxWidthBoxels,
                         int                  inMaxHeightBoxels);

/*
 * XPSetWindowGravity
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPSetWindowGravity(
                         void*                window,
                         float                inLeftGravity,
                         float                inTopGravity,
                         float                inRightGravity,
                         float                inBottomGravity);

/*
 * XPSetWindowTitle
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPSetWindowTitle(
                         void*                window,
                         char const*          title);

/*
 * XPGetWindowVrSize
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPGetWindowVrSize(
                         XPLMWindowID         window,
                         int*                 out_width,
                         int*                 out_height);

/*
 * XPSetWindowVrSize
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPSetWindowVrSize(
                         XPLMWindowID         window,
                         int                  width,
                         int                  height);

/*
 * XPDisplayModalAlert
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPDisplayModalAlert(
                         const char*          m1,
                         const char*          m2,
                         const char*          m3,
                         const char*          m4);

/*
 * XPDisplayDismissableAlert
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPDisplayDismissableAlert(
                         const char*          plugin_path,
                         const char*          dialog_id,
                         const char*          m1,
                         const char*          m2,
                         const char*          m3,
                         const char*          m4);

/*
 * XPDisplayInitString
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPDisplayInitString(
                         const char*          msg);

/*
 * XPWindowSetURL
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPWindowSetURL(
                         void*                window,
                         const char *         url);

/*
 * XPWindowRefresh
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPWindowRefresh(
                         void*                window,
                         int                  ignoreCache);

/*
 * XPWindowInjectScript
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPWindowInjectScript(
                         void*                window,
                         const char *         script);

/*
 * XPAddBrowserFunction
 *
 */
/* NOT thread-safe. Use ONLY from the main thread, in callbacks.                 */
 void       XPAddBrowserFunction(
                         void *               window,
                         const char *         name,
                         void *               closure);
struct XPLMDisplay_hooks
{
    XPLMDisplay_hooks();


    void* (*XPCreateAvionics_f)(const XPLMCreateAvionics_t* callback);

    void (*XPDestroyAvionics_f)(void* handle);

    int (*XPIsAvionicsBound_f)(int id, void* handle);

    void (*XPSetAvionicsBrightness_f)(int id, void* handle, float brt);

    float (*XPGetAvionicsBrightness_f)(int id, void* handle);

    float (*XPGetAvionicsBusVoltsRatio_f)(int id, void* handle);

    void (*XPSetAvionicsPopupVisible_f)(int id, void* handle, int visible);

    int (*XPIsAvionicsPopupVisible_f)(int id, void* handle);

    void (*XPPopOutAvionics_f)(int id, void* handle);

    int (*XPIsAvionicsPoppedOut_f)(int id, void* handle);

    void (*XPAvionicsNeedsDrawing_f)(int id, void* handle);

    int (*XPIsMouseOverAvionics_f)(int id, void* handle, int* x, int* y);

    void (*XPTakeAvionicsKeyboardFocus_f)(int id, void* handle);

    int (*XPHasAvionicsKeyboardFocus_f)(int id, void* handle);

    void (*XPGetAvionicsWindowBounds_f)(int id, void* handle, int outBounds[4]);

    void (*XPSetAvionicsWindowBounds_f)(int id, void* handle, int inBounds[4]);

    void (*XPGetAvionicsWindowBoundsOS_f)(int id, void* handle, int outBounds[4]);

    void (*XPSetAvionicsWindowBoundsOS_f)(int id, void* handle, int inBounds[4]);

    void (*XPGetScreenSize_f)(int* outWidth, int* outHeight);

    void (*XPGetScreenBoundsGlobal_f)(int* outLeft, int* outTop, int* outRight, int* outBottom);

    void (*XPGetAllMonitorBoundsGlobal_f)(XPLMReceiveMonitorBoundsGlobal_f inMonitorBoundsCallback, void* refcon);

    void (*XPGetAllMonitorBoundsOS_f)(XPLMReceiveMonitorBoundsOS_f inMonitorBoundsCallback, void* refcon);

    void (*XPGetMouseLocation_f)(int* outX, int* outY, int inMenuBarOK);

    void (*XPGetMouseLocationGlobal_f)(int* outX, int* outY, int inMenuBarOK);

    void (*XPSetPluginMouseFocus_f)(int want_focus_hack_for_old_style_windows, void* ptr_to_modern_window_if_focus_is_on_modern_window_or_null);

    void (*XPCreateGuiPluginWindow_f)(void* window, XPLMWindowDecoration decoration, int layer, int initially_visible, int is_gui_backed);

    void (*XPDestroyGuiPluginWindow_f)(void* window);

    int (*XPGuiPluginWindowIsVisible_f)(void* window);

    void (*XPHideGuiPluginWindow_f)(void* window);

    void (*XPShowGuiPluginWindow_f)(void* window);

    void (*XPGetGuiPluginWindowBounds_f)(void* window, int out_bounds[4]);

    int (*XPSetGuiPluginWindowBounds_f)(void* window, int in_bounds[4]);

    void (*XPGetPopoutWindowOSBounds_f)(void* window, int out_bounds[4]);

    int (*XPSetPopoutWindowOSBounds_f)(void* window, int in_os_bounds[4]);

    int (*XPGuiWindowIsPoppedOut_f)(void* window);

    int (*XPGuiWindowIsInVr_f)(void* window);

    void (*XPBringGuiWindowToFront_f)(void* window);

    int (*XPGuiWindowIsInFront_f)(void* window);

    void (*XPSetWindowPositioningMode_f)(void* window, int inPositioningMode, int inMonitorIndex);

    void (*XPSetWindowResizingLimits_f)(void* window, int inMinWidthBoxels, int inMinHeightBoxels, int inMaxWidthBoxels, int inMaxHeightBoxels);

    void (*XPSetWindowGravity_f)(void* window, float inLeftGravity, float inTopGravity, float inRightGravity, float inBottomGravity);

    void (*XPSetWindowTitle_f)(void* window, char const* title);

    void (*XPGetWindowVrSize_f)(XPLMWindowID window, int* out_width, int* out_height);

    void (*XPSetWindowVrSize_f)(XPLMWindowID window, int width, int height);

    void (*XPDisplayModalAlert_f)(const char* m1, const char* m2, const char* m3, const char* m4);

    void (*XPDisplayDismissableAlert_f)(const char* plugin_path, const char* dialog_id, const char* m1, const char* m2, const char* m3, const char* m4);

    void (*XPDisplayInitString_f)(const char* msg);

    void (*XPWindowSetURL_f)(void* window, const char * url);

    void (*XPWindowRefresh_f)(void* window, int ignoreCache);

    void (*XPWindowInjectScript_f)(void* window, const char * script);

    void (*XPAddBrowserFunction_f)(void * window, const char * name, void * closure);
};

#if defined(XPLM_DEFINE_HOST_HOOK_WIRE)
inline XPLMDisplay_hooks::XPLMDisplay_hooks()
{


    this->XPCreateAvionics_f = XPLM_TO_SIM_FUNC(XPCreateAvionics);

    this->XPDestroyAvionics_f = XPLM_TO_SIM_FUNC(XPDestroyAvionics);

    this->XPIsAvionicsBound_f = XPLM_TO_SIM_FUNC(XPIsAvionicsBound);

    this->XPSetAvionicsBrightness_f = XPLM_TO_SIM_FUNC(XPSetAvionicsBrightness);

    this->XPGetAvionicsBrightness_f = XPLM_TO_SIM_FUNC(XPGetAvionicsBrightness);

    this->XPGetAvionicsBusVoltsRatio_f = XPLM_TO_SIM_FUNC(XPGetAvionicsBusVoltsRatio);

    this->XPSetAvionicsPopupVisible_f = XPLM_TO_SIM_FUNC(XPSetAvionicsPopupVisible);

    this->XPIsAvionicsPopupVisible_f = XPLM_TO_SIM_FUNC(XPIsAvionicsPopupVisible);

    this->XPPopOutAvionics_f = XPLM_TO_SIM_FUNC(XPPopOutAvionics);

    this->XPIsAvionicsPoppedOut_f = XPLM_TO_SIM_FUNC(XPIsAvionicsPoppedOut);

    this->XPAvionicsNeedsDrawing_f = XPLM_TO_SIM_FUNC(XPAvionicsNeedsDrawing);

    this->XPIsMouseOverAvionics_f = XPLM_TO_SIM_FUNC(XPIsMouseOverAvionics);

    this->XPTakeAvionicsKeyboardFocus_f = XPLM_TO_SIM_FUNC(XPTakeAvionicsKeyboardFocus);

    this->XPHasAvionicsKeyboardFocus_f = XPLM_TO_SIM_FUNC(XPHasAvionicsKeyboardFocus);

    this->XPGetAvionicsWindowBounds_f = XPLM_TO_SIM_FUNC(XPGetAvionicsWindowBounds);

    this->XPSetAvionicsWindowBounds_f = XPLM_TO_SIM_FUNC(XPSetAvionicsWindowBounds);

    this->XPGetAvionicsWindowBoundsOS_f = XPLM_TO_SIM_FUNC(XPGetAvionicsWindowBoundsOS);

    this->XPSetAvionicsWindowBoundsOS_f = XPLM_TO_SIM_FUNC(XPSetAvionicsWindowBoundsOS);

    this->XPGetScreenSize_f = XPLM_TO_SIM_FUNC(XPGetScreenSize);

    this->XPGetScreenBoundsGlobal_f = XPLM_TO_SIM_FUNC(XPGetScreenBoundsGlobal);

    this->XPGetAllMonitorBoundsGlobal_f = XPLM_TO_SIM_FUNC(XPGetAllMonitorBoundsGlobal);

    this->XPGetAllMonitorBoundsOS_f = XPLM_TO_SIM_FUNC(XPGetAllMonitorBoundsOS);

    this->XPGetMouseLocation_f = XPLM_TO_SIM_FUNC(XPGetMouseLocation);

    this->XPGetMouseLocationGlobal_f = XPLM_TO_SIM_FUNC(XPGetMouseLocationGlobal);

    this->XPSetPluginMouseFocus_f = XPLM_TO_SIM_FUNC(XPSetPluginMouseFocus);

    this->XPCreateGuiPluginWindow_f = XPLM_TO_SIM_FUNC(XPCreateGuiPluginWindow);

    this->XPDestroyGuiPluginWindow_f = XPLM_TO_SIM_FUNC(XPDestroyGuiPluginWindow);

    this->XPGuiPluginWindowIsVisible_f = XPLM_TO_SIM_FUNC(XPGuiPluginWindowIsVisible);

    this->XPHideGuiPluginWindow_f = XPLM_TO_SIM_FUNC(XPHideGuiPluginWindow);

    this->XPShowGuiPluginWindow_f = XPLM_TO_SIM_FUNC(XPShowGuiPluginWindow);

    this->XPGetGuiPluginWindowBounds_f = XPLM_TO_SIM_FUNC(XPGetGuiPluginWindowBounds);

    this->XPSetGuiPluginWindowBounds_f = XPLM_TO_SIM_FUNC(XPSetGuiPluginWindowBounds);

    this->XPGetPopoutWindowOSBounds_f = XPLM_TO_SIM_FUNC(XPGetPopoutWindowOSBounds);

    this->XPSetPopoutWindowOSBounds_f = XPLM_TO_SIM_FUNC(XPSetPopoutWindowOSBounds);

    this->XPGuiWindowIsPoppedOut_f = XPLM_TO_SIM_FUNC(XPGuiWindowIsPoppedOut);

    this->XPGuiWindowIsInVr_f = XPLM_TO_SIM_FUNC(XPGuiWindowIsInVr);

    this->XPBringGuiWindowToFront_f = XPLM_TO_SIM_FUNC(XPBringGuiWindowToFront);

    this->XPGuiWindowIsInFront_f = XPLM_TO_SIM_FUNC(XPGuiWindowIsInFront);

    this->XPSetWindowPositioningMode_f = XPLM_TO_SIM_FUNC(XPSetWindowPositioningMode);

    this->XPSetWindowResizingLimits_f = XPLM_TO_SIM_FUNC(XPSetWindowResizingLimits);

    this->XPSetWindowGravity_f = XPLM_TO_SIM_FUNC(XPSetWindowGravity);

    this->XPSetWindowTitle_f = XPLM_TO_SIM_FUNC(XPSetWindowTitle);

    this->XPGetWindowVrSize_f = XPLM_TO_SIM_FUNC(XPGetWindowVrSize);

    this->XPSetWindowVrSize_f = XPLM_TO_SIM_FUNC(XPSetWindowVrSize);

    this->XPDisplayModalAlert_f = XPLM_TO_SIM_FUNC(XPDisplayModalAlert);

    this->XPDisplayDismissableAlert_f = XPLM_TO_SIM_FUNC(XPDisplayDismissableAlert);

    this->XPDisplayInitString_f = XPLM_TO_SIM_FUNC(XPDisplayInitString);

    this->XPWindowSetURL_f = XPLM_TO_SIM_FUNC(XPWindowSetURL);

    this->XPWindowRefresh_f = XPLM_TO_SIM_FUNC(XPWindowRefresh);

    this->XPWindowInjectScript_f = XPLM_TO_SIM_FUNC(XPWindowInjectScript);

    this->XPAddBrowserFunction_f = XPLM_TO_SIM_FUNC(XPAddBrowserFunction);
}
#endif
#if defined(XPLM_DEFINE_CLIENT_WRAP_HOOKS)
inline void wrap_XPLMDisplay_hooks(XPLMDisplay_hooks& hooks)
{


    auto orig_XPCreateAvionics_f = hooks.XPCreateAvionics_f;
    hooks.XPCreateAvionics_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPCreateAvionics_f)>::Install(orig_XPCreateAvionics_f);


    auto orig_XPDestroyAvionics_f = hooks.XPDestroyAvionics_f;
    hooks.XPDestroyAvionics_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPDestroyAvionics_f)>::Install(orig_XPDestroyAvionics_f);


    auto orig_XPIsAvionicsBound_f = hooks.XPIsAvionicsBound_f;
    hooks.XPIsAvionicsBound_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPIsAvionicsBound_f)>::Install(orig_XPIsAvionicsBound_f);


    auto orig_XPSetAvionicsBrightness_f = hooks.XPSetAvionicsBrightness_f;
    hooks.XPSetAvionicsBrightness_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPSetAvionicsBrightness_f)>::Install(orig_XPSetAvionicsBrightness_f);


    auto orig_XPGetAvionicsBrightness_f = hooks.XPGetAvionicsBrightness_f;
    hooks.XPGetAvionicsBrightness_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPGetAvionicsBrightness_f)>::Install(orig_XPGetAvionicsBrightness_f);


    auto orig_XPGetAvionicsBusVoltsRatio_f = hooks.XPGetAvionicsBusVoltsRatio_f;
    hooks.XPGetAvionicsBusVoltsRatio_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPGetAvionicsBusVoltsRatio_f)>::Install(orig_XPGetAvionicsBusVoltsRatio_f);


    auto orig_XPSetAvionicsPopupVisible_f = hooks.XPSetAvionicsPopupVisible_f;
    hooks.XPSetAvionicsPopupVisible_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPSetAvionicsPopupVisible_f)>::Install(orig_XPSetAvionicsPopupVisible_f);


    auto orig_XPIsAvionicsPopupVisible_f = hooks.XPIsAvionicsPopupVisible_f;
    hooks.XPIsAvionicsPopupVisible_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPIsAvionicsPopupVisible_f)>::Install(orig_XPIsAvionicsPopupVisible_f);


    auto orig_XPPopOutAvionics_f = hooks.XPPopOutAvionics_f;
    hooks.XPPopOutAvionics_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPPopOutAvionics_f)>::Install(orig_XPPopOutAvionics_f);


    auto orig_XPIsAvionicsPoppedOut_f = hooks.XPIsAvionicsPoppedOut_f;
    hooks.XPIsAvionicsPoppedOut_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPIsAvionicsPoppedOut_f)>::Install(orig_XPIsAvionicsPoppedOut_f);


    auto orig_XPAvionicsNeedsDrawing_f = hooks.XPAvionicsNeedsDrawing_f;
    hooks.XPAvionicsNeedsDrawing_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPAvionicsNeedsDrawing_f)>::Install(orig_XPAvionicsNeedsDrawing_f);


    auto orig_XPIsMouseOverAvionics_f = hooks.XPIsMouseOverAvionics_f;
    hooks.XPIsMouseOverAvionics_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPIsMouseOverAvionics_f)>::Install(orig_XPIsMouseOverAvionics_f);


    auto orig_XPTakeAvionicsKeyboardFocus_f = hooks.XPTakeAvionicsKeyboardFocus_f;
    hooks.XPTakeAvionicsKeyboardFocus_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPTakeAvionicsKeyboardFocus_f)>::Install(orig_XPTakeAvionicsKeyboardFocus_f);


    auto orig_XPHasAvionicsKeyboardFocus_f = hooks.XPHasAvionicsKeyboardFocus_f;
    hooks.XPHasAvionicsKeyboardFocus_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPHasAvionicsKeyboardFocus_f)>::Install(orig_XPHasAvionicsKeyboardFocus_f);


    auto orig_XPGetAvionicsWindowBounds_f = hooks.XPGetAvionicsWindowBounds_f;
    hooks.XPGetAvionicsWindowBounds_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPGetAvionicsWindowBounds_f)>::Install(orig_XPGetAvionicsWindowBounds_f);


    auto orig_XPSetAvionicsWindowBounds_f = hooks.XPSetAvionicsWindowBounds_f;
    hooks.XPSetAvionicsWindowBounds_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPSetAvionicsWindowBounds_f)>::Install(orig_XPSetAvionicsWindowBounds_f);


    auto orig_XPGetAvionicsWindowBoundsOS_f = hooks.XPGetAvionicsWindowBoundsOS_f;
    hooks.XPGetAvionicsWindowBoundsOS_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPGetAvionicsWindowBoundsOS_f)>::Install(orig_XPGetAvionicsWindowBoundsOS_f);


    auto orig_XPSetAvionicsWindowBoundsOS_f = hooks.XPSetAvionicsWindowBoundsOS_f;
    hooks.XPSetAvionicsWindowBoundsOS_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPSetAvionicsWindowBoundsOS_f)>::Install(orig_XPSetAvionicsWindowBoundsOS_f);


    auto orig_XPGetScreenSize_f = hooks.XPGetScreenSize_f;
    hooks.XPGetScreenSize_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPGetScreenSize_f)>::Install(orig_XPGetScreenSize_f);


    auto orig_XPGetScreenBoundsGlobal_f = hooks.XPGetScreenBoundsGlobal_f;
    hooks.XPGetScreenBoundsGlobal_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPGetScreenBoundsGlobal_f)>::Install(orig_XPGetScreenBoundsGlobal_f);


    auto orig_XPGetAllMonitorBoundsGlobal_f = hooks.XPGetAllMonitorBoundsGlobal_f;
    hooks.XPGetAllMonitorBoundsGlobal_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPGetAllMonitorBoundsGlobal_f)>::Install(orig_XPGetAllMonitorBoundsGlobal_f);


    auto orig_XPGetAllMonitorBoundsOS_f = hooks.XPGetAllMonitorBoundsOS_f;
    hooks.XPGetAllMonitorBoundsOS_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPGetAllMonitorBoundsOS_f)>::Install(orig_XPGetAllMonitorBoundsOS_f);


    auto orig_XPGetMouseLocation_f = hooks.XPGetMouseLocation_f;
    hooks.XPGetMouseLocation_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPGetMouseLocation_f)>::Install(orig_XPGetMouseLocation_f);


    auto orig_XPGetMouseLocationGlobal_f = hooks.XPGetMouseLocationGlobal_f;
    hooks.XPGetMouseLocationGlobal_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPGetMouseLocationGlobal_f)>::Install(orig_XPGetMouseLocationGlobal_f);


    auto orig_XPSetPluginMouseFocus_f = hooks.XPSetPluginMouseFocus_f;
    hooks.XPSetPluginMouseFocus_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPSetPluginMouseFocus_f)>::Install(orig_XPSetPluginMouseFocus_f);


    auto orig_XPCreateGuiPluginWindow_f = hooks.XPCreateGuiPluginWindow_f;
    hooks.XPCreateGuiPluginWindow_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPCreateGuiPluginWindow_f)>::Install(orig_XPCreateGuiPluginWindow_f);


    auto orig_XPDestroyGuiPluginWindow_f = hooks.XPDestroyGuiPluginWindow_f;
    hooks.XPDestroyGuiPluginWindow_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPDestroyGuiPluginWindow_f)>::Install(orig_XPDestroyGuiPluginWindow_f);


    auto orig_XPGuiPluginWindowIsVisible_f = hooks.XPGuiPluginWindowIsVisible_f;
    hooks.XPGuiPluginWindowIsVisible_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPGuiPluginWindowIsVisible_f)>::Install(orig_XPGuiPluginWindowIsVisible_f);


    auto orig_XPHideGuiPluginWindow_f = hooks.XPHideGuiPluginWindow_f;
    hooks.XPHideGuiPluginWindow_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPHideGuiPluginWindow_f)>::Install(orig_XPHideGuiPluginWindow_f);


    auto orig_XPShowGuiPluginWindow_f = hooks.XPShowGuiPluginWindow_f;
    hooks.XPShowGuiPluginWindow_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPShowGuiPluginWindow_f)>::Install(orig_XPShowGuiPluginWindow_f);


    auto orig_XPGetGuiPluginWindowBounds_f = hooks.XPGetGuiPluginWindowBounds_f;
    hooks.XPGetGuiPluginWindowBounds_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPGetGuiPluginWindowBounds_f)>::Install(orig_XPGetGuiPluginWindowBounds_f);


    auto orig_XPSetGuiPluginWindowBounds_f = hooks.XPSetGuiPluginWindowBounds_f;
    hooks.XPSetGuiPluginWindowBounds_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPSetGuiPluginWindowBounds_f)>::Install(orig_XPSetGuiPluginWindowBounds_f);


    auto orig_XPGetPopoutWindowOSBounds_f = hooks.XPGetPopoutWindowOSBounds_f;
    hooks.XPGetPopoutWindowOSBounds_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPGetPopoutWindowOSBounds_f)>::Install(orig_XPGetPopoutWindowOSBounds_f);


    auto orig_XPSetPopoutWindowOSBounds_f = hooks.XPSetPopoutWindowOSBounds_f;
    hooks.XPSetPopoutWindowOSBounds_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPSetPopoutWindowOSBounds_f)>::Install(orig_XPSetPopoutWindowOSBounds_f);


    auto orig_XPGuiWindowIsPoppedOut_f = hooks.XPGuiWindowIsPoppedOut_f;
    hooks.XPGuiWindowIsPoppedOut_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPGuiWindowIsPoppedOut_f)>::Install(orig_XPGuiWindowIsPoppedOut_f);


    auto orig_XPGuiWindowIsInVr_f = hooks.XPGuiWindowIsInVr_f;
    hooks.XPGuiWindowIsInVr_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPGuiWindowIsInVr_f)>::Install(orig_XPGuiWindowIsInVr_f);


    auto orig_XPBringGuiWindowToFront_f = hooks.XPBringGuiWindowToFront_f;
    hooks.XPBringGuiWindowToFront_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPBringGuiWindowToFront_f)>::Install(orig_XPBringGuiWindowToFront_f);


    auto orig_XPGuiWindowIsInFront_f = hooks.XPGuiWindowIsInFront_f;
    hooks.XPGuiWindowIsInFront_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPGuiWindowIsInFront_f)>::Install(orig_XPGuiWindowIsInFront_f);


    auto orig_XPSetWindowPositioningMode_f = hooks.XPSetWindowPositioningMode_f;
    hooks.XPSetWindowPositioningMode_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPSetWindowPositioningMode_f)>::Install(orig_XPSetWindowPositioningMode_f);


    auto orig_XPSetWindowResizingLimits_f = hooks.XPSetWindowResizingLimits_f;
    hooks.XPSetWindowResizingLimits_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPSetWindowResizingLimits_f)>::Install(orig_XPSetWindowResizingLimits_f);


    auto orig_XPSetWindowGravity_f = hooks.XPSetWindowGravity_f;
    hooks.XPSetWindowGravity_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPSetWindowGravity_f)>::Install(orig_XPSetWindowGravity_f);


    auto orig_XPSetWindowTitle_f = hooks.XPSetWindowTitle_f;
    hooks.XPSetWindowTitle_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPSetWindowTitle_f)>::Install(orig_XPSetWindowTitle_f);


    auto orig_XPGetWindowVrSize_f = hooks.XPGetWindowVrSize_f;
    hooks.XPGetWindowVrSize_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPGetWindowVrSize_f)>::Install(orig_XPGetWindowVrSize_f);


    auto orig_XPSetWindowVrSize_f = hooks.XPSetWindowVrSize_f;
    hooks.XPSetWindowVrSize_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPSetWindowVrSize_f)>::Install(orig_XPSetWindowVrSize_f);


    auto orig_XPDisplayModalAlert_f = hooks.XPDisplayModalAlert_f;
    hooks.XPDisplayModalAlert_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPDisplayModalAlert_f)>::Install(orig_XPDisplayModalAlert_f);


    auto orig_XPDisplayDismissableAlert_f = hooks.XPDisplayDismissableAlert_f;
    hooks.XPDisplayDismissableAlert_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPDisplayDismissableAlert_f)>::Install(orig_XPDisplayDismissableAlert_f);


    auto orig_XPDisplayInitString_f = hooks.XPDisplayInitString_f;
    hooks.XPDisplayInitString_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPDisplayInitString_f)>::Install(orig_XPDisplayInitString_f);


    auto orig_XPWindowSetURL_f = hooks.XPWindowSetURL_f;
    hooks.XPWindowSetURL_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPWindowSetURL_f)>::Install(orig_XPWindowSetURL_f);


    auto orig_XPWindowRefresh_f = hooks.XPWindowRefresh_f;
    hooks.XPWindowRefresh_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPWindowRefresh_f)>::Install(orig_XPWindowRefresh_f);


    auto orig_XPWindowInjectScript_f = hooks.XPWindowInjectScript_f;
    hooks.XPWindowInjectScript_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPWindowInjectScript_f)>::Install(orig_XPWindowInjectScript_f);


    auto orig_XPAddBrowserFunction_f = hooks.XPAddBrowserFunction_f;
    hooks.XPAddBrowserFunction_f = RuntimeWrap<std::integral_constant<int, __COUNTER__>, decltype(hooks.XPAddBrowserFunction_f)>::Install(orig_XPAddBrowserFunction_f);

}
#endif


#endif
