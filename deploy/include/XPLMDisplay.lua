---@meta XPLMDisplay

-- The functions, typedefs, enums, and defines in this file are
-- installed into the Lua VM at startup by the host's add_xplm_to_interp()
-- call. Scripts do NOT need to require('XPLMDisplay') to access them; this file
-- exists solely as type metadata for lua-language-server / EmmyLua.

--[[
   Copyright 2005-2026 Laminar Research, Sandy Barbour and Ben Supnik All
   rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
]]--

-----------------------------------------------------------------------------
-- XPLMDisplay
-----------------------------------------------------------------------------

--[[
   This API provides the basic hooks to draw in X-Plane and create user
   interface. All X-Plane drawing is done in OpenGL. The X-Plane plug-in
   manager takes care of properly setting up the OpenGL context and matrices. 
   You do not decide when in your code's execution to draw; X-Plane tells you
   (via callbacks) when it is ready to have your plugin draw.
   
   X-Plane's drawing strategy is straightforward: every "frame" the screen is
   rendered by drawing the 3-D scene (dome, ground, objects, airplanes, etc.)
   and then drawing the cockpit on top of it.  Alpha blending is used to
   overlay the cockpit over the world (and the gauges over the panel, etc.).
   X-Plane user interface elements (including windows like the map, the main
   menu, etc.) are then drawn on top of the cockpit.
   
   There are two ways you can draw: directly and in a window.
   
   Direct drawing (deprecated!---more on that below) involves drawing to the
   screen before or after X-Plane finishes a phase of drawing.  When you draw
   directly, you can specify whether X-Plane is to complete this phase or not.
   This allows you to do three things: draw before X-Plane does (under it),
   draw after X-Plane does (over it), or draw instead of X-Plane.
   
   To draw directly, you register a callback and specify which phase you want
   to intercept.  The plug-in manager will call you over and over to draw that
   phase.
   
   Direct drawing allows you to override scenery, panels, or anything.  Note
   that you cannot assume that you are the only plug-in drawing at this phase.
   
   Direct drawing is deprecated; at some point in the X-Plane 11 run, it will
   likely become unsupported entirely as X-Plane transitions from OpenGL to
   modern graphics API backends (e.g., Vulkan, Metal, etc.). In the long term,
   plugins should use the XPLMInstance API for drawing 3-D objects---this will
   be much more efficient than general 3-D OpenGL drawing, and it will
   actually be supported by the new graphics backends. We do not yet know what
   the post-transition API for generic 3-D drawing will look like (if it
   exists at all).
   
   In contrast to direct drawing, window drawing provides a higher level
   functionality. With window drawing, you create a 2-D window that takes up a
   portion of the screen. Window drawing is always two dimensional.  Window
   drawing is depth controlled; you can specify that you want your window to
   be brought on top, and other plug-ins may put their window on top of you. 
   Window drawing also allows you to sign up for key presses and receive mouse
   clicks.
   
   Drawing into the screen of an avionics device, like a GPS or a Primary
   Flight Display, is a way  to extend or replace X-Plane's avionics. Most
   screens can be displayed both in a 3d cockpit or 
   2d panel, and also in separate popup windows. By installing drawing
    callbacks for a certain avionics  device, you can change or extend the
    appearance of that device regardless whether it's installed  in a 3d
    cockpit or used in a separate display for home cockpits because you leave
    the window managing to X-Plane.
   
   There are three ways to get keystrokes:
   
   1. If you create a window, the window can take keyboard focus.  It will
      then receive all keystrokes.  If no window has focus, X-Plane receives
      keystrokes.  Use this to implement typing in dialog boxes, etc.  Only
      one window may have focus at a time; your window will be notified if it
      loses focus.
   2. If you need low level access to the keystroke stream, install a key
      sniffer.  Key sniffers can be installed above everything or right in
      front of the sim.
   3. If you would like to associate key strokes with commands/functions in
      your plug-in, you should simply register a command (via
      XPLMCreateCommand()) and allow users to bind whatever key they choose to
      that command. Another (now deprecated) method of doing so is to use a
      hot key---a key-specific callback.  Hotkeys are sent based on virtual
      key strokes, so any key may be distinctly mapped with any modifiers. 
      Hot keys can be remapped by other plug-ins.  As a plug-in, you don't
      have to worry about what your hot key ends up mapped to; other plug-ins
      may provide a UI for remapping keystrokes.  So hotkeys allow a user to
      resolve conflicts and customize keystrokes.
]]--

require("XPLMDefs")
require("XPLMUtilities")
require("XPLMScenery")

--[[
XPLMWindowContentType describes how the content for a window (or an avionics device's screen) is provided.
]]--

---@enum XPLMWindowContentType
local XPLMWindowContentType = {
    -- The window is drawn by calling back your plugin, which will draw using
    -- panel graphics APIs. You provide mouse and keyboard hooks for interaction.
    xplm_WindowContentTypePanelGraphics      = 1,
    -- The window content is specified using a web page.
    xplm_WindowContentTypeBrowser            = 2,
}
---@class _G
---@field XPLMWindowContentType XPLMWindowContentType

--[[
This constant indicates the device we want to override or enhance. We can get a callback before or after each item.
]]--

---@enum XPLMDeviceID
local XPLMDeviceID = {
    -- GNS430, pilot side.
    xplm_device_GNS430_1                     = 0,
    -- GNS430, copilot side.
    xplm_device_GNS430_2                     = 1,
    -- GNS530, pilot side.
    xplm_device_GNS530_1                     = 2,
    -- GNS530, copilot side.
    xplm_device_GNS530_2                     = 3,
    -- generic airliner CDU, pilot side.
    xplm_device_CDU739_1                     = 4,
    -- generic airliner CDU, copilot side.
    xplm_device_CDU739_2                     = 5,
    -- G1000 Primary Flight Display, pilot side.
    xplm_device_G1000_PFD_1                  = 6,
    -- G1000 Multifunction Display.
    xplm_device_G1000_MFD                    = 7,
    -- G1000 Primary Flight Display, copilot side.
    xplm_device_G1000_PFD_2                  = 8,
    -- Primus CDU, pilot side.
    xplm_device_CDU815_1                     = 9,
    -- Primus CDU, copilot side.
    xplm_device_CDU815_2                     = 10,
    -- Primus Primary Flight Display, pilot side.
    xplm_device_Primus_PFD_1                 = 11,
    -- Primus Primary Flight Display, copilot side.
    xplm_device_Primus_PFD_2                 = 12,
    -- Primus Multifunction Display, pilot side.
    xplm_device_Primus_MFD_1                 = 13,
    -- Primus Multifunction Display, copilot side.
    xplm_device_Primus_MFD_2                 = 14,
    -- Primus Multifunction Display, central.
    xplm_device_Primus_MFD_3                 = 15,
    -- Primus Radio Management Unit, pilot side.
    xplm_device_Primus_RMU_1                 = 16,
    -- Primus Radio Management Unit, copilot side.
    xplm_device_Primus_RMU_2                 = 17,
    -- Airbus MCDU, pilot side.
    xplm_device_MCDU_1                       = 18,
    -- Airbus MCDU, copilot side.
    xplm_device_MCDU_2                       = 19,
    -- Airbus MCDU 3.
    xplm_device_MCDU_3                       = 24,
}
---@class _G
---@field XPLMDeviceID XPLMDeviceID

--- This is the prototype for drawing callbacks for customized built-in device. You are passed in the device you are enhancing/replacing, and (if this is used for a built-in device that you are customizing) whether it is before or after X-Plane drawing. If you are before X-Plane, return true to let X-Plane draw or false to suppress X-Plane drawing. If you are called after X-Plane, the return value is ignored. Refcon is a unique value that you specify when registering the callback, allowing you to slip a pointer to your own data to the callback. Upon entry the OpenGL context will be correctly set up for you and OpenGL will be in panel coordinates for 2d drawing. The OpenGL state (texturing, etc.) will be unknown.
---@alias XPLMAvionicsCallback_f fun(inDeviceID: XPLMDeviceID, inIsBefore: boolean, inRefcon: any): boolean

--- Mouse click callback for clicks into your screen or (2D-popup) bezel, useful if the device you are making simulates a touch-screen the user can click in the 3d cockpit, or if your pop-up's bezel has buttons that the user can click. Return true to consume the event, or false to let X-Plane process it (for stock avionics devices).
---@alias XPLMAvionicsMouse_f fun(x: integer, y: integer, inMouse: XPLMMouseStatus, inRefcon: any): boolean

--- Mouse wheel callback for scroll actions into your screen or (2D-popup) bezel, useful if your bezel has knobs that can be turned using the mouse wheel, or if you want to simulate pinch-to-zoom on a touchscreen. Return true to consume the event, or false to let X-Plane process it (for stock avionics devices). The number of "clicks" indicates how far the wheel was turned since the last callback. The wheel is 0 for the vertical axis or 1 for the horizontal axis (for OS/mouse combinations that support this).
---@alias XPLMAvionicsMouseWheel_f fun(x: integer, y: integer, wheel: integer, clicks: integer, inRefcon: any): boolean

--- Cursor callback that decides which cursor to show when the mouse is over your screen or (2D-popup) bezel. Return xplm_CursorDefault to let X-Plane use which cursor to show, or other values to force the cursor to a particular one (see XPLMCursorStatus).
---@alias XPLMAvionicsCursor_f fun(x: integer, y: integer, inRefcon: any): XPLMCursorStatus

--- Key callback called when your device is popped up and you've requested to capture the keyboard. Return true to consume the event, or false to let X-Plane process it (for stock avionics devices).
---@alias XPLMAvionicsKeyboard_f fun(inKey: string, inFlags: XPLMKeyFlags, inVirtualKey: string, inRefcon: any, losingFocus: boolean): boolean

--- This is an opaque identifier for an avionics display that you enhance or replace. When you register your callbacks (via XPLMRegisterAvionicsCallbacksEx()) or create a new device (via XPLMCreateAvionicsDevice()), you will specify drawing and mouse callbacks, and get back such a handle.
---@class XPLMAvionicsID : userdata
---@field private __XPLMAvionicsID_marker any

--- The XPLMCustomizeAvionics_t structure defines all of the parameters used to replace or enhance built-in simulator avionics devices using XPLMRegisterAvionicsCallbacksEx(). The structure will be expanded in future SDK APIs to include more features. Always set the structSize member to the size of your struct in bytes!
---@class XPLMCustomizeAvionics_t
---@field structSize integer Used to inform XPLMRegisterAvionicsCallbacksEx() of the SDK version you compiled against; should always be set to sizeof(XPLMCustomizeAvionics_t)
---@field deviceId XPLMDeviceID The built-in avionics device to which you want your drawing applied.
---@field drawCallbackBefore XPLMAvionicsCallback_f The draw callback to be called before X-Plane draws.
---@field drawCallbackAfter XPLMAvionicsCallback_f The draw callback to be called after X-Plane has drawn.
---@field bezelClickCallback XPLMAvionicsMouse_f The mouse click callback that is called when the user clicks onto the device's bezel.
---@field bezelRightClickCallback XPLMAvionicsMouse_f The mouse click callback that is called when the user clicks onto the device's bezel.
---@field bezelScrollCallback XPLMAvionicsMouseWheel_f The callback that is called when the users uses the scroll wheel over the device's bezel.
---@field bezelCursorCallback XPLMAvionicsCursor_f The callback that lets you determine what cursor should be shown when the mouse is over the device's bezel.
---@field screenTouchCallback XPLMAvionicsMouse_f The mouse click callback that is called when the user clicks onto the device's screen.
---@field screenRightTouchCallback XPLMAvionicsMouse_f The right mouse click callback that is called when the user clicks onto the device's screen.
---@field screenScrollCallback XPLMAvionicsMouseWheel_f The callback that is called when the users uses the scroll wheel over the device's screen.
---@field screenCursorCallback XPLMAvionicsCursor_f The callback that lets you determine what cursor should be shown when the mouse is over the device's screen.
---@field keyboardCallback XPLMAvionicsKeyboard_f The key callback that is called when the user types in the device's popup.
---@field refcon any A reference which will be passed into each of your draw callbacks. Use this to pass information to yourself as needed.
---@field contentType XPLMWindowContentType How this device's screen is drawn: xplm_WindowContentTypeOpenGL (the legacy OpenGL bridge) or xplm_WindowContentTypePanelGraphics (native panel-graphics rendering). xplm_WindowContentTypeBrowser is not valid for avionics.

---@class _G
--- This routine registers your callbacks for a built-in device. This returns a
--- handle. If the returned handle is NULL, there was a problem interpreting your
--- input, most likely the struct size was wrong for your SDK version.
--- If the returned handle is not NULL, your callbacks will be called according to schedule
--- as long as your plugin is not deactivated, or unloaded, or you call XPLMUnregisterAvionicsCallbacks().
---
--- Note that you cannot register new callbacks for a device that is not a built-in
--- one (for example a device that you have created, or a device another plugin
--- has created).
---
---@field XPLMRegisterAvionicsCallbacksEx fun(inParams: XPLMCustomizeAvionics_t): XPLMAvionicsID

---@class _G
--- This routine registers no callbacks for a built-in cockpit device, but returns a handle which allows
--- you to interact with it using the Avionics Device API. Use this if you do not wish to intercept drawing,
--- clicks and touchscreen calls to a device, but want to interact with its popup programmatically.
--- This is equivalent to calling XPLMRegisterAvionicsCallbackEx() with NULL for all callbacks.
---
---@field XPLMGetAvionicsHandle fun(inDeviceID: XPLMDeviceID): XPLMAvionicsID

---@class _G
--- This routine unregisters your callbacks for a built-in device. You should only call this
--- for handles you acquired from XPLMRegisterAvionicsCallbacksEx(). They will no longer be called.
---
---@field XPLMUnregisterAvionicsCallbacks fun(inAvionicsId: XPLMAvionicsID)

--- This is the prototype for drawing callbacks for custom devices' screens. Refcon is a unique value that you specify when creating the device, allowing you to slip a pointer to your own data to the callback. Upon entry the OpenGL context will be correctly set up for you and OpenGL will be in panel coordinates for 2d drawing. The OpenGL state (texturing, etc.) will be unknown. X-Plane does not clear your screen for you between calls - this means you can re-use portions to save drawing, but otherwise you must call glClear() to erase the screen's contents.
---@alias XPLMAvionicsScreenCallback_f fun(inRefcon: any)

--- This is the prototype for drawing callbacks for custom devices' bezel. You are passed in the red, green, and blue values you can optinally use for tinting your bezel accoring to ambiant light. Refcon is a unique value that you specify when creating the device, allowing you to slip a pointer to your own data to the callback. Upon entry the OpenGL context will be correctly set up for you and OpenGL will be in panel coordinates for 2d drawing. The OpenGL state (texturing, etc.) will be unknown.
---@alias XPLMAvionicsBezelCallback_f fun(inAmbiantR: number, inAmbiantG: number, inAmbiantB: number, inRefcon: any)

--- This is the prototype for screen brightness callbacks for custom devices. If you provide a callback, you can return the ratio of the screen's maximum brightness that the simulator should use when displaying the screen in the 3D cockpit. inRheoValue is the current ratio value (between 0 and 1) of the instrument brightness rheostat to which the device is bound. inAmbientBrightness is the value (between 0 and 1) that the callback should return for the screen to be at a usable brightness based on ambient light (if your device has a photo cell and automatically adjusts its brightness, you can return this and your screen will be at the optimal brightness to be readable, but not blind the pilot). inBusVoltsRatio is the ratio of the nominal voltage currently present on the bus to which the device is bound, or -1 if the device is not bound to the current aircraft. Refcon is a unique value that you specify when creating the device, allowing you to slip a pointer to your own data to the callback.
---@alias XPLMAvionicsBrightness_f fun(inRheoValue: number, inAmbiantBrightness: number, inBusVoltsRatio: number, inRefcon: any): number

--- Called for a browser-content-type avionics device when its main frame finishes loading a page. This is NOT a guarantee that the load succeeded: a page that renders an HTTP error response (e.g. a server's 404 page) also "finishes" here. A navigation that fails before the page renders fires XPLMAvionicsBrowserLoadError_f instead. If your page needs to know its own HTTP status, have it report that from JavaScript via a browser function. Set this via browserLoadFinishedFunc in XPLMCreateAvionics_t.
---@alias XPLMAvionicsBrowserLoadFinished_f fun(inAvionics: XPLMAvionicsID, inURL: string, inRefcon: any)

--- Called for a browser-content-type avionics device when a navigation fails at the network level (bad URL, host unreachable, TLS failure, file not found). inError describes the failure. This may be followed by XPLMAvionicsBrowserLoadFinished_f for a substitute error page, so treat a load error as the authoritative signal that the navigation to inURL failed. Set this via browserLoadErrorFunc in XPLMCreateAvionics_t.
---@alias XPLMAvionicsBrowserLoadError_f fun(inAvionics: XPLMAvionicsID, inURL: string, inError: string, inRefcon: any)

--- The XPLMCreateAvionics_t structure defines all of the parameters used to generate your own glass cockpit device by using XPLMCreateAvionicsEx(). The structure will be expanded in future SDK APIs to include more features. Always set the structSize member to the size of your struct in bytes!
---@class XPLMCreateAvionics_t
---@field structSize integer Used to inform XPLMCreateAvionicsEx() of the SDK version you compiled against; should always be set to sizeof(XPLMCreateAvionics_t)
---@field screenWidth integer Width of the device's screen in pixels.
---@field screenHeight integer Height of the device's screen in pixels.
---@field bezelWidth integer Width of the bezel around your device's screen for 2D pop-ups.
---@field bezelHeight integer Height of the bezel around your device's screen for 2D pop-ups.
---@field screenOffsetX integer The screen's lateral offset into the bezel for 2D pop-ups.
---@field screenOffsetY integer The screen's vertical offset into the bezel for 2D pop-ups.
---@field drawOnDemand boolean If set to true (1), X-Plane won't call your plugin to re-render the device's screen every frame. Instead, you should tell X-Plane you want to refresh your screen with XPLMAvionicsNeedsDrawing(), and X-Plane will call you before rendering the next simulator frame.
---@field bezelDrawCallback XPLMAvionicsBezelCallback_f The draw callback you will use to draw the 2D-popup bezel. This is called only when the popup window is visible, and X-Plane is about to draw the bezel in it.
---@field drawCallback XPLMAvionicsScreenCallback_f The draw callback you will be using to draw into the device's screen framebuffer.
---@field bezelClickCallback XPLMAvionicsMouse_f The mouse click callback that is called when the user clicks onto your bezel.
---@field bezelRightClickCallback XPLMAvionicsMouse_f The mouse click callback that is called when the user clicks onto your bezel.
---@field bezelScrollCallback XPLMAvionicsMouseWheel_f The callback that is called when the users uses the scroll wheel over your avionics' bezel.
---@field bezelCursorCallback XPLMAvionicsCursor_f The callback that lets you determine what cursor should be shown when the mouse is over your device's bezel.
---@field screenTouchCallback XPLMAvionicsMouse_f The mouse click callback that is called when the user clicks onto your screen.
---@field screenRightTouchCallback XPLMAvionicsMouse_f The right mouse click callback that is called when the user clicks onto your screen.
---@field screenScrollCallback XPLMAvionicsMouseWheel_f The callback that is called when the users uses the scroll wheel over your avionics' screen.
---@field screenCursorCallback XPLMAvionicsCursor_f The callback that lets you determine what cursor should be shown when the mouse is over your device's screen.
---@field keyboardCallback XPLMAvionicsKeyboard_f The key callback that is called when the user types in your popup.
---@field brightnessCallback XPLMAvionicsBrightness_f The callback that is called to determine the absolute brightness of the device's screen. Set to NULL to use X-Plane's default behaviour.
---@field deviceID string A null-terminated string of maximum 64 characters to uniquely identify your cockpit device. This must be unique (you cannot re-use an ID that X-Plane or another plugin provides), and it must not contain spaces. This is the string the OBJ file must reference when marking polygons with ATTR_cockpit_device. The string is copied when you call XPLMCreateAvionicsEx, so you don't need to hold this string in memory after the call.
---@field deviceName string A null-terminated string to give a user-readable name to your device, which can be presented in UI dialogs.
---@field refcon any A reference which will be passed into your draw and mouse callbacks. Use this to pass information to yourself as needed.
---@field contentType XPLMWindowContentType How this device's screen is drawn: xplm_WindowContentTypeOpenGL (the legacy OpenGL bridge), xplm_WindowContentTypePanelGraphics (native panel-graphics rendering), or xplm_WindowContentTypeBrowser (a CEF web view). For a browser device the single web page covers the whole bezel including the screen; X-Plane copies the screen sub-rectangle into the device's framebuffer, so your drawCallback/bezelDrawCallback are not used. Drive the page with XPLMAvionicsSetURL() and friends. Browser content is only valid for devices you create here, not when customising a built-in device.
---@field windowWithChrome integer If set to true (1), X-Plane will draw the chrome with the close and pop-out buttons outside of your bezel, rather than having the buttons steal pixels from your bezel.
---@field browserLoadFinishedFunc XPLMAvionicsBrowserLoadFinished_f For browser content (xplm_WindowContentTypeBrowser): called when a page's main frame finishes loading. Not a success guarantee --a rendered HTTP error page finishes too. Set to NULL if you don't need it.
---@field browserLoadErrorFunc XPLMAvionicsBrowserLoadError_f For browser content (xplm_WindowContentTypeBrowser): called when a navigation fails at the network level, with a description of the failure. Set to NULL if you don't need it.

---@class _G
--- Creates a new cockpit device to be used in the 3D cockpit. You can call this at any time: if an aircraft referencing your device is loaded before your plugin, the simulator will make sure to retroactively map your display into it.
---
---             When you are done with the device, and at least before your plugin is unloaded, you should destroy the device using XPLMDestroyAvionics().
---
---@field XPLMCreateAvionicsEx fun(inParams: XPLMCreateAvionics_t): XPLMAvionicsID

---@class _G
--- Destroys the cockpit device and deallocates its screen's memory. You should only ever call this for devices that you created using XPLMCreateAvionicsEx(), not X-Plane' built-ine devices you have customised.
---
---@field XPLMDestroyAvionics fun(inHandle: XPLMAvionicsID)

---@class _G
--- Loads a URL into a browser-content-type avionics device (one created via
--- XPLMCreateAvionicsEx() with contentType xplm_WindowContentTypeBrowser). Safe
--- to call before the underlying webview has finished initialising; the load is
--- queued and applied as soon as the browser is ready, so you may call this
--- immediately after XPLMCreateAvionicsEx(). Subsequent calls replace the
--- pending or current page. Has no effect on non-browser devices.
---
---@field XPLMAvionicsSetURL fun(inAvionicsID: XPLMAvionicsID, inURL: string)

---@class _G
--- Reloads the current URL in a browser-content-type avionics device. Pass true
--- for inIgnoreCache to bypass the HTTP cache (the equivalent of a shift-reload).
--- Has no effect on non-browser devices.
---
---@field XPLMAvionicsRefresh fun(inAvionicsID: XPLMAvionicsID, inIgnoreCache: integer)

---@class _G
--- Executes a JavaScript snippet in the main frame of a browser-content-type
--- avionics device. The script has access to the same xplane.* namespace exposed
--- to the page. If injected before the page has finished loading, it may run
--- against an empty document. Has no effect on non-browser devices.
---
---@field XPLMAvionicsInjectScript fun(inAvionicsID: XPLMAvionicsID, inScript: string)

--- Handler invoked when the page in a browser-content-type avionics device calls xplane.<name>(arg). You receive the device, the argument serialised as a JSON string, and your refcon; return a JSON string (or NULL) that the JS Promise resolves to.
---@alias XPLMAvionicsBrowserCallback_f fun(inAvionicsID: XPLMAvionicsID, inJSON: string, inRefcon: any): string

---@class _G
--- Registers a callback that the page running in a browser-content-type avionics
--- device can invoke as xplane.<inName>(arg). The JS call returns a Promise
--- that resolves to the value your XPLMAvionicsBrowserCallback_f returns (parsed
--- as JSON). Registering the same name again replaces the previous callback. Each
--- device has its own independent xplane.* namespace. Has no effect on non-browser
--- devices.
---
---@field XPLMAvionicsAddBrowserFunction fun(inAvionicsID: XPLMAvionicsID, inName: string, inFunction: XPLMAvionicsBrowserCallback_f, inRefcon: any)

---@class _G
--- Glues a cockpit device you created with XPLMCreateAvionicsEx() onto a 3D object you loaded with XPLMLoadObject(), so that the device's screen is drawn on that object - typically one you draw in the world using the instancing API (XPLMCreateInstance()).
---
--- The device is matched to the object's screen by ID: the object must declare an `ATTR_cockpit_device` with the same device ID string you passed to XPLMCreateAvionicsEx(). The binding is a property of the object itself, so every instance you draw from that object shows the same device. You may only bind devices you created yourself, not X-Plane's built-in devices.
---
--- Brightness on the object follows your device's own brightness callback, independent of any aircraft electrical system.
---
--- Returns 1 if the object had a matching device screen and the binding succeeded, or 0 otherwise.
---
---@field XPLMSetObjectAvionics fun(inObject: XPLMObjectRef, inAvionics: XPLMAvionicsID): integer

---@class _G
--- Removes a binding previously made with XPLMSetObjectAvionics(), restoring the object's device screen to black and detaching its click handler. Bindings are also cleared automatically when you destroy the device with XPLMDestroyAvionics().
---
---@field XPLMClearObjectAvionics fun(inObject: XPLMObjectRef, inAvionics: XPLMAvionicsID)

---@class _G
--- Returns true (1) if the cockpit device with the given handle is used by the current aircraft.
---
---@field XPLMIsAvionicsBound fun(inHandle: XPLMAvionicsID): boolean

---@class _G
--- Sets the brightness setting's value, between 0 and 1, for the screen of the cockpit device with the given handle.
---
--- If the device is bound to the current aircraft, this is a shortcut to setting the brightness rheostat value using the `sim/cockpit2/switches/instrument_brightness_ratio[]` dataref; this sets the slot in the `instrument_brightness_ratio` array to which the device is bound.
---
--- If the device is not currently bound, the device keeps track of its own screen brightness rheostat, allowing you to control the brightness even though it isn't connected to the `instrument_brightness_ratio` dataref.
---
---@field XPLMSetAvionicsBrightnessRheo fun(inHandle: XPLMAvionicsID, brightness: number)

---@class _G
--- Returns the brightness setting value, between 0 and 1, for the screen of the cockpit device with the given handle.
---
--- 		If the device is bound to the current aircraft, this is a shortcut to getting the brightness rheostat value from the `sim/cockpit2/switches/instrument_brightness_ratio[]` dataref; this gets the slot in the `instrument_brightness_ratio` array to which the device is bound.
---
--- 		If the device is not currently bound, this returns the device's own brightness rheostat value.
---
---@field XPLMGetAvionicsBrightnessRheo fun(inHandle: XPLMAvionicsID): number

---@class _G
--- Returns the ratio of the nominal voltage (1.0 means full nominal voltage) of the electrical bus to which the given avionics device is bound, or -1 if the device is not bound to the current aircraft.
---
---@field XPLMGetAvionicsBusVoltsRatio fun(inHandle: XPLMAvionicsID): number

---@class _G
--- Returns true (1) if the mouse is currently over the screen of cockpit device with the given handle. If they are not NULL, the optional x and y arguments are filled with the co-ordinates of the mouse cursor in device co-ordinates.
---
---@field XPLMIsCursorOverAvionics fun(inHandle: XPLMAvionicsID): boolean, { outX: userdata, outY: userdata }

---@class _G
--- Tells X-Plane that your device's screen needs to be re-drawn. If your device is marked for on-demand drawing, X-Plane will call your screen drawing callback before drawing the next simulator frame. If your device is already drawn every frame, this has no effect.
---
---@field XPLMAvionicsNeedsDrawing fun(inHandle: XPLMAvionicsID)

---@class _G
--- Shows or hides the popup window for a cockpit device.
---
--- Visibility is independent of where the popup is drawn (in the X-Plane window, popped out as an
--- OS window, or mapped to a VR floating window): the popup always remains in whichever target
--- mode you most recently selected, and toggling visibility just shows or hides it there.
---
---@field XPLMSetAvionicsPopupVisible fun(inHandle: XPLMAvionicsID, inVisible: boolean)

---@class _G
--- Returns true (1) if the popup window for a cockpit device is visible.
---
---@field XPLMIsAvionicsPopupVisible fun(inHandle: XPLMAvionicsID): boolean

---@class _G
--- Pops out the window for a cockpit device, making it a first-class window in the
--- operating system, separate from the X-Plane window.
---
--- Popping out and being mapped to VR are mutually exclusive: if the device is currently mapped
--- to VR (XPLMIsAvionicsMappedToVR() is true), calling this routine clears its VR mapping before
--- popping out.
---
---@field XPLMPopOutAvionics fun(inHandle: XPLMAvionicsID)

---@class _G
--- Returns true (1) if the popup window for a cockpit device is popped out as a
--- first-class OS window.
---
--- This is true if and only if you have most recently asked the popup to be popped out (via
--- XPLMPopOutAvionics()) and it has not since been mapped to VR (via XPLMSetAvionicsMappedToVR()).
---
---@field XPLMIsAvionicsPoppedOut fun(inHandle: XPLMAvionicsID): boolean

---@class _G
--- Maps a custom cockpit device's popup window to a VR floating window in the
--- headset, or returns it from VR back to the X-Plane window. Pass 1 to map to VR, 0 to unmap.
---
--- The VR window shows the device's bezel and screen at their intrinsic size, as supplied via
--- XPLMCreateAvionicsEx(). Avionics in VR are not user-resizable.
---
--- Mapping to VR and being popped out as an OS window are mutually exclusive: calling this with
--- inMapped=1 on a popped-out device clears its pop-out state, and calling XPLMPopOutAvionics()
--- on a VR-mapped device clears its VR mapping. This mirrors the relationship between
--- xplm_WindowPopOut and xplm_WindowVR for XPLMWindow.
---
--- VR mapping is independent of popup visibility (XPLMSetAvionicsPopupVisible). Mapping a hidden
--- popup to VR leaves it hidden until you make it visible.
---
--- Has no effect (and logs a warning) if VR is not currently running on the headset, or if the
--- device was not created via XPLMCreateAvionicsEx() (built-in avionics cannot be VR-mapped).
---
---@field XPLMSetAvionicsMappedToVR fun(inHandle: XPLMAvionicsID, inMapped: boolean)

---@class _G
--- Returns true (1) if the popup window for a cockpit device is currently mapped
--- to a VR floating window.
---
--- This is true if and only if you have most recently asked the device to be mapped to VR (via
--- XPLMSetAvionicsMappedToVR()) and it has not since been unmapped, popped out, or had VR shut
--- down beneath it.
---
---@field XPLMIsAvionicsMappedToVR fun(inHandle: XPLMAvionicsID): boolean

---@class _G
--- This routine gives keyboard focus to the popup window of a custom cockpit device, if it is visible.
---
---@field XPLMTakeAvionicsKeyboardFocus fun(inHandle: XPLMAvionicsID)

---@class _G
--- Returns true (1) if the popup window for a cockpit device has keyboard focus.
---
---@field XPLMHasAvionicsKeyboardFocus fun(inHandle: XPLMAvionicsID): boolean

---@class _G
--- Returns the bounds of a cockpit device's popup window in the X-Plane coordinate system.
---
---@field XPLMGetAvionicsGeometry fun(inHandle: XPLMAvionicsID): { outLeft: userdata, outTop: userdata, outRight: userdata, outBottom: userdata }

---@class _G
--- Sets the size and position of a cockpit device's popup window in the X-Plane coordinate system.
---
---@field XPLMSetAvionicsGeometry fun(inHandle: XPLMAvionicsID, inLeft: integer, inTop: integer, inRight: integer, inBottom: integer)

---@class _G
--- Returns the bounds of a cockpit device's popped-out window.
---
---@field XPLMGetAvionicsGeometryOS fun(inHandle: XPLMAvionicsID): { outLeft: userdata, outTop: userdata, outRight: userdata, outBottom: userdata }

---@class _G
--- Sets the size and position of a cockpit device's popped-out window.
---
---@field XPLMSetAvionicsGeometryOS fun(inHandle: XPLMAvionicsID, inLeft: integer, inTop: integer, inRight: integer, inBottom: integer)

--- This is an opaque identifier for a window. You use it to control your window. When you create a window (via either XPLMCreateWindow() or XPLMCreateWindowEx()), you will specify callbacks to handle drawing, mouse interaction, etc.
---@class XPLMWindowID : userdata
---@field private __XPLMWindowID_marker any

--- A callback to handle 2-D drawing of your window. You are passed in your window and its refcon. Draw the window. You can use other XPLM functions from this header to find the current dimensions of your window, etc. When this callback is called, the OpenGL context will be set properly for 2-D window drawing. **Note**: Because you are drawing your window over a background, you can make a translucent window easily by simply not filling in your entire window's bounds.
---@alias XPLMDrawWindow_f fun(inWindowID: XPLMWindowID, inRefcon: any)

--- This function is called when a key is pressed or keyboard focus is taken away from your window. If losingFocus is 1, you are losing the keyboard focus, otherwise a key was pressed and inKey contains its character. The window ID passed in will be your window for key presses, or the other window taking focus when losing focus. Note that in the modern plugin system, often focus is taken by the window manager itself; for this resaon, the window ID may be zero when losing focus, and you should not write code that depends onit. The refcon passed in will be the one from registration, for both key presses and losing focus. Warning: this API declares virtual keys as a signed character; however the VKEY #define macros in XPLMDefs.h define the vkeys using unsigned values (that is 0x80 instead of -0x80). So you may need to cast the incoming vkey to an unsigned char to get correct comparisons in C.
---@alias XPLMHandleKey_f fun(inWindowID: XPLMWindowID, inKey: string, inFlags: XPLMKeyFlags, inVirtualKey: string, inRefcon: any, losingFocus: boolean)

--- You receive this call for one of three events: - when the user clicks the mouse button down - (optionally) when the user drags the mouse after a down-click, but before the up-click - when the user releases the down-clicked mouse button. You receive the x and y of the click, your window, and a refcon. Return 1 to consume the click, or 0 to pass it through. WARNING: passing clicks through windows (as of this writing) causes mouse tracking problems in X-Plane; do not use this feature! The units for x and y values match the units used in your window. Thus, for "modern" windows (those created via XPLMCreateWindowEx() and compiled against the XPLM300 library), the units are boxels, while legacy windows will get pixels. Legacy windows have their origin in the lower left of the main X-Plane window, while modern windows have their origin in the lower left of the global desktop space. In both cases, x increases as you move right, and y increases as you move up.
---@alias XPLMHandleMouseClick_f fun(inWindowID: XPLMWindowID, x: integer, y: integer, inMouse: XPLMMouseStatus, inRefcon: any): integer

--- The SDK calls your cursor status callback when the mouse is over your plugin window. Return a cursor status code to indicate how you would like X-Plane to manage the cursor. If you return xplm_CursorDefault, the SDK will try lower-Z-order plugin windows, then let the sim manage the cursor. Note: you should never show or hide the cursor yourself---these APIs are typically reference-counted and thus cannot safely and predictably be used by the SDK. Instead return one of xplm_CursorHidden to hide the cursor or xplm_CursorArrow/xplm_CursorCustom to show the cursor. If you want to implement a custom cursor by drawing a cursor in OpenGL, use xplm_CursorHidden to hide the OS cursor and draw the cursor using a 2-d drawing callback (after xplm_Phase_Window is probably a good choice, but see deprecation warnings on the drawing APIs!). If you want to use a custom OS-based cursor, use xplm_CursorCustom to ask X-Plane to show the cursor but not affect its image. You can then use an OS specific call like SetThemeCursor (Mac) or SetCursor/LoadCursor (Windows). The units for x and y values match the units used in your window. Thus, for "modern" windows (those created via XPLMCreateWindowEx() and compiled against the XPLM300 library), the units are boxels, while legacy windows will get pixels. Legacy windows have their origin in the lower left of the main X-Plane window, while modern windows have their origin in the lower left of the global desktop space. In both cases, x increases as you move right, and y increases as you move up.
---@alias XPLMHandleCursor_f fun(inWindowID: XPLMWindowID, x: integer, y: integer, inRefcon: any): XPLMCursorStatus

--- The SDK calls your mouse wheel callback when one of the mouse wheels is scrolled within your window. Return true to consume the mouse wheel movement or false to pass them on to a lower window. (If your window appears opaque to the user, you should consume mouse wheel scrolling even if it does nothing.) The number of "clicks" indicates how far the wheel was turned since the last callback. The wheel is 0 for the vertical axis or 1 for the horizontal axis (for OS/mouse combinations that support this). The units for x and y values match the units used in your window. Thus, for "modern" windows (those created via XPLMCreateWindowEx() and compiled against the XPLM300 library), the units are boxels, while legacy windows will get pixels. Legacy windows have their origin in the lower left of the main X-Plane window, while modern windows have their origin in the lower left of the global desktop space. In both cases, x increases as you move right, and y increases as you move up.
---@alias XPLMHandleMouseWheel_f fun(inWindowID: XPLMWindowID, x: integer, y: integer, wheel: integer, clicks: integer, inRefcon: any): boolean

--- Called for a browser-content-type window when its main frame finishes loading a page. NOT a success guarantee --a rendered HTTP error page (e.g. a 404) also finishes here. A navigation that fails before the page renders fires XPLMBrowserLoadError_f instead. Set this via browserLoadFinishedFunc in XPLMCreateWindow_t.
---@alias XPLMBrowserLoadFinished_f fun(inWindow: XPLMWindowID, inURL: string, inRefcon: any)

--- Called for a browser-content-type window when a navigation fails at the network level (bad URL, host unreachable, TLS failure, file not found). inError describes the failure. May be followed by XPLMBrowserLoadFinished_f for a substitute error page, so treat this as the authoritative signal that the navigation to inURL failed. Set this via browserLoadErrorFunc in XPLMCreateWindow_t.
---@alias XPLMBrowserLoadError_f fun(inWindow: XPLMWindowID, inURL: string, inError: string, inRefcon: any)

--[[
XPLMWindowLayer describes where in the ordering of windows X-Plane should place a particular window.
Windows in higher layers cover windows in lower layers. So, a given window might be at the top of its particular layer,
but it might still be obscured by a window in a higher layer. (This happens frequently when floating windows, like
X-Plane's map, are covered by a modal alert.)

Your window's layer can only be specified when you create the window (in the XPLMCreateWindow_t you pass to XPLMCreateWindowEx()).
For this reason, layering only applies to windows created with new X-Plane 11 GUI features.
(Windows created using the older XPLMCreateWindow(), or windows compiled against a pre-XPLM300 version of the SDK will
simply be placed in the flight overlay window layer.)
]]--

---@enum XPLMWindowLayer
local XPLMWindowLayer = {
    -- The lowest layer, used for HUD-like displays while flying.
    xplm_WindowLayerFlightOverlay            = 0,
    -- Windows that "float" over the sim, like the X-Plane 11 map does. If you are
    -- not sure which layer to create your window in, choose floating.
    xplm_WindowLayerFloatingWindows          = 1,
    -- An interruptive modal that covers the sim with a transparent black overlay
    -- to draw the user's focus to the alert
    xplm_WindowLayerModal                    = 2,
    -- "Growl"-style notifications that are visible in a corner of the screen,
    -- even over modals
    xplm_WindowLayerGrowlNotifications       = 3,
}
---@class _G
---@field XPLMWindowLayer XPLMWindowLayer

--[[
XPLMWindowDecoration describes how "modern" windows will be displayed. This impacts both how X-Plane draws your window as well as certain mouse handlers.

Your window's decoration can only be specified when you create the window (in the XPLMCreateWindow_t you pass to XPLMCreateWindowEx()).
]]--

---@enum XPLMWindowDecoration
local XPLMWindowDecoration = {
    -- X-Plane will draw no decoration for your window, and apply no automatic
    -- click handlers. The window will not stop click from passing through its
    -- bounds. This is suitable for "windows" which request, say, the full screen
    -- bounds, then only draw in a small portion of the available area.
    xplm_WindowDecorationNone                = 0,
    -- The default decoration for "native" windows, like the map. Provides a solid
    -- background, as well as click handlers for resizing and dragging the window.
    xplm_WindowDecorationRoundRectangle      = 1,
    -- X-Plane will draw no decoration for your window, nor will it provide resize
    -- handlers for your window edges, but it will stop clicks from passing
    -- through your windows bounds.
    xplm_WindowDecorationSelfDecorated       = 2,
    -- Like self-decorated, but with resizing; X-Plane will draw no decoration for
    -- your window, but it will stop clicks from passing through your windows
    -- bounds, and provide automatic mouse handlers for resizing.
    xplm_WindowDecorationSelfDecoratedResizable = 3,
}
---@class _G
---@field XPLMWindowDecoration XPLMWindowDecoration

--- The XPMCreateWindow_t structure defines all of the parameters used to create a modern window using XPLMCreateWindowEx(). The structure will be expanded in future SDK APIs to include more features. Always set the structSize member to the size of your struct in bytes! All windows created by this function in the XPLM300 version of the API are created with the new X-Plane 11 GUI features. This means your plugin will get to "know" about the existence of X-Plane windows other than the main window. All drawing and mouse callbacks for your window will occur in "boxels," giving your windows automatic support for high-DPI scaling in X-Plane. In addition, your windows can opt-in to decoration with the X-Plane 11 window styling, and you can use the XPLMSetWindowPositioningMode() API to make your window "popped out" into a first-class operating system window. Note that this requires dealing with your window's bounds in "global desktop" positioning units, rather than the traditional panel coordinate system. In global desktop coordinates, the main X-Plane window may not have its origin at coordinate (0, 0), and your own window may have negative coordinates. Assuming you don't implicitly assume (0, 0) as your origin, the only API change you should need is to start using XPLMGetMouseLocationGlobal() rather than XPLMGetMouseLocation(), and XPLMGetScreenBoundsGlobal() instead of XPLMGetScreenSize(). If you ask to be decorated as a floating window, you'll get the blue window control bar and blue backing that you see in X-Plane 11's normal "floating" windows (like the map).
---@class XPLMCreateWindow_t
---@field structSize integer Used to inform XPLMCreateWindowEx() of the SDK version you compiled against; should always be set to sizeof(XPLMCreateWindow_t)
---@field left integer Left bound, in global desktop boxels
---@field top integer Top bound, in global desktop boxels
---@field right integer Right bound, in global desktop boxels
---@field bottom integer Bottom bound, in global desktop boxels
---@field visible boolean
---@field drawWindowFunc XPLMDrawWindow_f A callback to draw your window's contents. Required for OpenGL and panel-graphics content; may be NULL only for browser content, which draws itself.
---@field handleMouseClickFunc XPLMHandleMouseClick_f A callback to handle the user left-clicking within your window (or NULL to ignore left clicks)
---@field handleKeyFunc XPLMHandleKey_f A callback to handle keyboard input (or NULL to ignore keyboard input)
---@field handleCursorFunc XPLMHandleCursor_f A callback to determine the cursor shape over your window (or NULL for the default cursor)
---@field handleMouseWheelFunc XPLMHandleMouseWheel_f A callback to handle scroll-wheel events (or NULL to ignore them)
---@field refcon any A reference which will be passed into each of your window callbacks. Use this to pass information to yourself as needed.
---@field decorateAsFloatingWindow XPLMWindowDecoration Specifies the type of X-Plane 11-style "wrapper" you want around your window, if any
---@field layer XPLMWindowLayer
---@field handleRightClickFunc XPLMHandleMouseClick_f A callback to handle the user right-clicking within your window (or NULL to ignore right clicks)
---@field windowContentType XPLMWindowContentType The source of content for this Window (OpenGL, Panel Graphics, CEF, etc.)
---@field browserLoadFinishedFunc XPLMBrowserLoadFinished_f For browser content: called when the main frame finishes loading (not a success guarantee --error pages finish too). NULL if unused.
---@field browserLoadErrorFunc XPLMBrowserLoadError_f For browser content: called when a navigation fails at the network level. NULL if unused.

---@class _G
--- This routine creates a new "modern" window. You pass in an XPLMCreateWindow_t structure with all
--- of the fields set in.  You must set the structSize of the structure to the size of the
--- actual structure you used.  Also, you must provide functions for every callback---you may
--- not leave them null!  (If you do not support the cursor or mouse wheel, use functions that
--- return the default values.)
---
--- NOTE: For an imgui-drawn window, Lua scripts should use XLuaCreateImguiWindow()
--- instead; it opens and closes the imgui frame for you and wires the input handlers.
---
---@field XPLMCreateWindowEx fun(inParams: XPLMCreateWindow_t): XPLMWindowID

---@class _G
--- This routine destroys a window.  The window's callbacks are not called after this call.
--- Keyboard focus is removed from the window before destroying it.
---
--- NOTE: A window created with XLuaCreateImguiWindow() must be destroyed with
--- XLuaDestroyImguiWindow(), not this function, so its captured Lua callbacks are released.
---
---@field XPLMDestroyWindow fun(inWindowID: XPLMWindowID)

---@class _G
--- Lua only. Creates a modern panel-graphics window pre-wired for imgui drawing
--- and input, and returns its XPLMWindowID (or nil on failure).
---
--- Pass a single config table. Recognised fields (all optional):
---   left, top, right, bottom    Window geometry in boxels (defaults 100/500/600/100).
---   visible                     Boolean; whether the window starts visible (default true).
---   decorateAsFloatingWindow    An XPLMWindowDecoration value (default xplm_WindowDecorationRoundRectangle).
---   layer                       An XPLMWindowLayer value (default xplm_WindowLayerFloatingWindows).
---   drawWindowFunc              function(windowID, width, height) -- called each frame inside an
---                               imgui frame that is opened and closed for you; the body is pure
---                               imgui widget calls (no NewFrame/Render boilerplate).
---
--- The imgui input handlers (mouse, keyboard, cursor, wheel) are installed
--- automatically; any input callbacks in the table are ignored by design.
--- Destroy the window with XLuaDestroyImguiWindow().
---
---@field XLuaCreateImguiWindow fun(params: table): XPLMWindowID

---@class _G
--- Lua only. Destroys a window created with XLuaCreateImguiWindow() and releases
--- its captured Lua callbacks. Do not use on windows created any other way.
---
---@field XLuaDestroyImguiWindow fun(inWindowID: XPLMWindowID)

---@class _G
--- Loads a URL into a browser-content-type window. Safe to call before the
--- underlying webview has finished initialising; the load is queued and
--- applied as soon as the browser is ready, so plugins may call this
--- immediately after `XPLMCreateWindowEx`. Subsequent calls replace the
--- pending or current page.
---
---@field XPLMWindowSetURL fun(inWindowID: XPLMWindowID, inURL: string)

---@class _G
--- Reloads the current URL in a browser-content-type window. Pass true for
--- `inIgnoreCache` to bypass the HTTP cache (the equivalent of a
--- shift-reload).
---
---@field XPLMWindowRefresh fun(inWindowID: XPLMWindowID, inIgnoreCache: boolean)

---@class _G
--- Executes a JavaScript snippet in the browser window's main frame. The
--- script is run once; it has access to the same `xplane.*` namespace
--- exposed to the page itself (so it can call functions registered via
--- `XPLMWindowAddBrowserFunction`). If injected before the page has
--- finished loading, the script may run against an empty document.
---
---@field XPLMWindowInjectScript fun(inWindowID: XPLMWindowID, inScript: string)

---@alias XPLMBrowserCallback_f fun(inWindowID: XPLMWindowID, inJSON: string, inRefcon: any): string

---@class _G
--- Registers a callback that the page running in this browser window can
--- invoke as `xplane.<inName>(arg)`. The JS call returns a Promise that
--- resolves to the value your `XPLMBrowserCallback_f` returns (parsed as
--- JSON -- see that callback's desc for the contract).
---
--- Multiple registrations against the same name on the same window
--- overwrite each other. Each window has its own independent `xplane.*`
--- namespace; functions registered on window A are not callable from
--- window B.
---
---@field XPLMWindowAddBrowserFunction fun(inWindowID: XPLMWindowID, inName: string, inFunction: XPLMBrowserCallback_f, inRefcon: any)

---@class _G
--- This routine returns the size of the main X-Plane OpenGL window in pixels.
--- This number can be used to get a rough idea of the amount
--- of detail the user will be able to see when drawing in 3-d.
---
---@field XPLMGetScreenSize fun(): { outWidth: userdata, outHeight: userdata }

---@class _G
--- This routine returns the bounds of the "global" X-Plane desktop, in boxels.
--- Unlike the non-global version XPLMGetScreenSize(), this is multi-monitor aware.
--- There are three primary consequences of multimonitor awareness.
---
--- First, if the user is running X-Plane in full-screen on two or more monitors (typically configured using
--- one full-screen window per monitor), the global desktop will be sized to include all X-Plane windows.
---
--- Second, the origin of the screen coordinates is not guaranteed to be (0, 0). Suppose the user has two displays
--- side-by-side, both running at 1080p. Suppose further that they've configured their OS to make the left display
--- their "primary" monitor, and that X-Plane is running in full-screen on their right monitor only. In this case,
--- the global desktop bounds would be the rectangle from (1920, 0) to (3840, 1080). If the user later asked X-Plane
--- to draw on their primary monitor as well, the bounds would change to (0, 0) to (3840, 1080).
---
--- Finally, if the usable area of the virtual desktop is not a perfect rectangle (for instance,
--- because the monitors have different resolutions or because one monitor is configured in the operating system
--- to be above and to the right of the other), the global desktop will include any wasted space. Thus, if you
--- have two 1080p monitors, and monitor 2 is configured to have its bottom left touch monitor 1's upper right,
--- your global desktop area would be the rectangle from (0, 0) to (3840, 2160).
---
--- Note that popped-out windows (windows drawn in their own operating system windows, rather than "floating" within X-Plane)
--- are not included in these bounds.
---
---@field XPLMGetScreenBoundsGlobal fun(): { outLeft: userdata, outTop: userdata, outRight: userdata, outBottom: userdata }

--- This function is informed of the global bounds (in boxels) of a particular monitor within the X-Plane global desktop space. Note that X-Plane must be running in full screen on a monitor in order for that monitor to be passed to you in this callback.
---@alias XPLMReceiveMonitorBoundsGlobal_f fun(inMonitorIndex: integer, inLeftBx: integer, inTopBx: integer, inRightBx: integer, inBottomBx: integer, inRefcon: any)

---@class _G
--- This routine immediately and synchronously calls you back with the bounds (in boxels) of each full-screen X-Plane window
--- within the X-Plane global desktop space, one callback per window.
--- Note that if a monitor is *not* covered by an X-Plane window, you cannot get its bounds this way. Likewise,
--- monitors with only an X-Plane window (not in full-screen mode) will not be included.
---
--- If X-Plane is running in full-screen and your monitors are of the same size and configured contiguously in the OS,
--- then the combined global bounds of all full-screen monitors
--- will match the total global desktop bounds, as returned by XPLMGetScreenBoundsGlobal(). (Of course,
--- if X-Plane is running in windowed mode, this will not be the case. Likewise, if you have differently sized monitors,
--- the global desktop space will include wasted space.)
---
--- Note that this function's monitor indices match those provided by XPLMGetAllMonitorBoundsOS(), but the coordinates are different
--- (since the X-Plane global desktop may not match the operating system's global desktop, and one X-Plane boxel may be larger than
--- one pixel due to 150% or 200% scaling).
---
---@field XPLMGetAllMonitorBoundsGlobal fun(inMonitorBoundsCallback: XPLMReceiveMonitorBoundsGlobal_f, inRefcon: any)

--- This function is informed of the global bounds (in pixels) of a particular monitor within the operating system's global desktop space. Note that a monitor index being passed to you here does not indicate that X-Plane is running in full screen on this monitor, or even that any X-Plane windows exist on this monitor.
---@alias XPLMReceiveMonitorBoundsOS_f fun(inMonitorIndex: integer, inLeftPx: integer, inTopPx: integer, inRightPx: integer, inBottomPx: integer, inRefcon: any)

---@class _G
--- This routine immediately and synchronously calls you back with the bounds (in pixels) of each monitor within the operating system's
--- global desktop space, one callback per monitor. Note that unlike XPLMGetAllMonitorBoundsGlobal(), this may include monitors that have no X-Plane window on them.
---
--- Note that this function's monitor indices match those provided by XPLMGetAllMonitorBoundsGlobal(), but the coordinates are different
--- (since the X-Plane global desktop may not match the operating system's global desktop, and one X-Plane boxel may be larger than one pixel).
---
---@field XPLMGetAllMonitorBoundsOS fun(inMonitorBoundsCallback: XPLMReceiveMonitorBoundsOS_f, inRefcon: any)

---@class _G
--- Returns the current mouse location in global desktop boxels. Unlike
--- XPLMGetMouseLocation(), the bottom left of the main X-Plane window is not guaranteed to be
--- (0, 0)---instead, the origin is the lower left of the entire global desktop space.
--- In addition, this routine gives the real mouse location when the mouse goes
--- to X-Plane windows other than the primary display. Thus, it can be used with both
--- pop-out windows and secondary monitors.
---
--- This is the mouse location function to use with modern windows (i.e., those created by XPLMCreateWindowEx()).
---
--- Pass NULL to not receive info about either parameter.
---
---@field XPLMGetMouseLocationGlobal fun(): { outX: userdata, outY: userdata }

---@class _G
--- Returns the modifier keys that are being held down *right now*, as a bitfield of XPLMKeyFlags.
--- Unlike the modifier flags delivered with a key event, this reflects the live keyboard state at the
--- moment of the call, so it can be used to make mouse clicks modifier-sensitive (e.g. shift-click) or
--- to react to a modifier changing during drawing (e.g. show alignment guides while shift is held).
---
--- Only the modifier bits are ever set: xplm_ShiftFlag, xplm_OptionAltFlag, xplm_ControlFlag and
--- xplm_CapsLockFlag.  The xplm_DownFlag and xplm_UpFlag bits (which describe a key event's phase) are
--- never returned. As elsewhere in the SDK, the Command key on macOS is folded into xplm_ControlFlag
--- rather than reported separately.
---
---@field XPLMGetModifierKeys fun(): XPLMKeyFlags

---@class _G
--- This routine returns the position and size of a window. The units and coordinate system vary depending
--- on the type of window you have.
---
--- If this is a legacy window (one compiled against a pre-XPLM300 version of the SDK,
--- or an XPLM300 window that was not created using XPLMCreateWindowEx()), the units are pixels relative
--- to the main X-Plane display.
---
--- If, on the other hand, this is a new X-Plane 11-style window (compiled against the XPLM300 SDK and
--- created using XPLMCreateWindowEx()), the units are global desktop boxels.
---
--- Pass NULL to not receive any paramter.
---
---@field XPLMGetWindowGeometry fun(inWindowID: XPLMWindowID): { outLeft: userdata, outTop: userdata, outRight: userdata, outBottom: userdata }

---@class _G
--- This routine allows you to set the position and size of a window.
---
--- The units and coordinate system match those of XPLMGetWindowGeometry(). That is, modern windows use
--- global desktop boxel coordinates, while legacy windows use pixels relative to the main X-Plane display.
---
--- Note that this only applies to "floating" windows (that is, windows that are drawn within the X-Plane simulation windows,
--- rather than being "popped out" into their own first-class operating system windows). To set the position
--- of windows whose positioning mode is xplm_WindowPopOut, you'll need to instead use XPLMSetWindowGeometryOS().
---
---@field XPLMSetWindowGeometry fun(inWindowID: XPLMWindowID, inLeft: integer, inTop: integer, inRight: integer, inBottom: integer)

---@class _G
--- This routine returns the position and size of a "popped out" window (i.e., a window whose positioning
--- mode is xplm_WindowPopOut), in operating system pixels.  Pass NULL to not receive any parameter.
---
---@field XPLMGetWindowGeometryOS fun(inWindowID: XPLMWindowID): { outLeft: userdata, outTop: userdata, outRight: userdata, outBottom: userdata }

---@class _G
--- This routine allows you to set the position and size, in operating system pixel coordinates, of a popped out window
--- (that is, a window whose positioning mode is xplm_WindowPopOut, which exists outside the X-Plane simulation window,
--- in its own first-class operating system window).
---
--- Note that you are responsible for ensuring both that your window is popped out (using XPLMWindowIsPoppedOut()) and
--- that a monitor really exists at the OS coordinates you provide (using XPLMGetAllMonitorBoundsOS()).
---
---@field XPLMSetWindowGeometryOS fun(inWindowID: XPLMWindowID, inLeft: integer, inTop: integer, inRight: integer, inBottom: integer)

---@class _G
--- Returns the width and height, in boxels, of a window in VR.
--- Note that you are responsible for ensuring your window is in VR (using XPLMWindowIsInVR()).
---
---@field XPLMGetWindowGeometryVR fun(inWindowID: XPLMWindowID): { outWidthBoxels: userdata, outHeightBoxels: userdata }

---@class _G
--- This routine allows you to set the size, in boxels, of a window in VR
--- (that is, a window whose positioning mode is xplm_WindowVR).
---
--- Note that you are responsible for ensuring your window is in VR (using XPLMWindowIsInVR()).
---
---@field XPLMSetWindowGeometryVR fun(inWindowID: XPLMWindowID, widthBoxels: integer, heightBoxels: integer)

---@class _G
--- Returns true (1) if the specified window is visible.
---@field XPLMGetWindowIsVisible fun(inWindowID: XPLMWindowID): boolean

---@class _G
--- This routine shows or hides a window.
---@field XPLMSetWindowIsVisible fun(inWindowID: XPLMWindowID, inIsVisible: boolean)

---@class _G
--- True if this window has been popped out (making it a first-class window in the operating system), which
--- in turn is true if and only if you have set the window's positioning mode to xplm_WindowPopOut.
---
--- Only applies to modern windows. (Windows created using the deprecated XPLMCreateWindow(),
--- or windows compiled against a pre-XPLM300 version of the SDK cannot be popped out.)
---
---@field XPLMWindowIsPoppedOut fun(inWindowID: XPLMWindowID): boolean

---@class _G
--- True if this window has been moved to the virtual reality (VR) headset, which
--- in turn is true if and only if you have set the window's positioning mode to xplm_WindowVR.
---
--- Only applies to modern windows. (Windows created using the deprecated XPLMCreateWindow(),
--- or windows compiled against a pre-XPLM301 version of the SDK cannot be moved to VR.)
---
---@field XPLMWindowIsInVR fun(inWindowID: XPLMWindowID): boolean

---@class _G
--- A window's "gravity" controls how the window shifts as the whole X-Plane window resizes.
--- A gravity of 1 means the window maintains its positioning relative to the right or top edges,
--- 0 the left/bottom, and 0.5 keeps it centered.
---
--- Default gravity is (0, 1, 0, 1), meaning your window will maintain its position relative to the top left
--- and will not change size as its containing window grows.
---
--- If you wanted, say, a window that sticks to the top of the screen (with a constant height),
--- but which grows to take the full width of the window, you would pass (0, 1, 1, 1). Because your left
--- and right edges would maintain their positioning relative to their respective edges of the screen,
--- the whole width of your window would change with the X-Plane window.
---
--- Only applies to modern windows. (Windows created using the deprecated XPLMCreateWindow(),
--- or windows compiled against a pre-XPLM300 version of the SDK will simply get the default gravity.)
---
---@field XPLMSetWindowGravity fun(inWindowID: XPLMWindowID, inLeftGravity: number, inTopGravity: number, inRightGravity: number, inBottomGravity: number)

---@class _G
--- Sets the minimum and maximum size of the client rectangle of the given window. (That is, it does not include
--- any window styling that you might have asked X-Plane to apply on your behalf.)
--- All resizing operations are constrained to these sizes.
---
--- Only applies to modern windows. (Windows created using the deprecated XPLMCreateWindow(),
--- or windows compiled against a pre-XPLM300 version of the SDK will have no minimum or maximum size.)
---
---@field XPLMSetWindowResizingLimits fun(inWindowID: XPLMWindowID, inMinWidthBoxels: integer, inMinHeightBoxels: integer, inMaxWidthBoxels: integer, inMaxHeightBoxels: integer)

--[[
XPLMWindowPositionMode describes how X-Plane will position your window on the user's screen. X-Plane will maintain
this positioning mode even as the user resizes their window or adds/removes full-screen monitors.

Positioning mode can only be set for "modern" windows (that is, windows created using XPLMCreateWindowEx()
and compiled against the XPLM300 SDK). Windows created using the deprecated XPLMCreateWindow(), or windows compiled against a
pre-XPLM300 version of the SDK will simply get the "free" positioning mode.
]]--

---@enum XPLMWindowPositioningMode
local XPLMWindowPositioningMode = {
    -- The default positioning mode. Set the window geometry and its future
    -- position will be determined by its window gravity, resizing limits, and
    -- user interactions.
    xplm_WindowPositionFree                  = 0,
    -- Keep the window centered on the monitor you specify
    xplm_WindowCenterOnMonitor               = 1,
    -- Keep the window full screen on the monitor you specify
    xplm_WindowFullScreenOnMonitor           = 2,
    -- Like gui_window_full_screen_on_monitor, but stretches over *all* monitors
    -- and popout windows. This is an obscure one... unless you have a very good
    -- reason to need it, you probably don't!
    xplm_WindowFullScreenOnAllMonitors       = 3,
    -- A first-class window in the operating system, completely separate from the
    -- X-Plane window(s)
    xplm_WindowPopOut                        = 4,
    -- A floating window visible on the VR headset
    xplm_WindowVR                            = 5,
}
---@class _G
---@field XPLMWindowPositioningMode XPLMWindowPositioningMode

---@class _G
--- Sets the policy for how X-Plane will position your window.
---
--- Some positioning modes apply to a particular monitor. For those modes, you can pass a negative monitor index
--- to position the window on the main X-Plane monitor (the screen with the X-Plane menu bar at the top). Or,
--- if you have a specific monitor you want to position your window on, you can pass a real monitor index as received
--- from, e.g., XPLMGetAllMonitorBoundsOS().
---
--- Only applies to modern windows. (Windows created using the deprecated XPLMCreateWindow(),
--- or windows compiled against a pre-XPLM300 version of the SDK will always use xplm_WindowPositionFree.)
---
---@field XPLMSetWindowPositioningMode fun(inWindowID: XPLMWindowID, inPositioningMode: XPLMWindowPositioningMode, inMonitorIndex: integer)

---@class _G
--- Sets the name for a window. This only applies to windows that opted-in to styling
--- as an X-Plane 11 floating window (i.e., with styling mode xplm_WindowDecorationRoundRectangle)
--- when they were created using XPLMCreateWindowEx().
---
---@field XPLMSetWindowTitle fun(inWindowID: XPLMWindowID, inWindowTitle: string)

---@class _G
--- Returns a window's reference constant, the unique value you can use for your own purposes.
---@field XPLMGetWindowRefCon fun(inWindowID: XPLMWindowID): any

---@class _G
--- Sets a window's reference constant.  Use this to pass data to yourself in the callbacks.
---@field XPLMSetWindowRefCon fun(inWindowID: XPLMWindowID, inRefcon: any)

---@class _G
--- This routine gives a specific window keyboard focus.  Keystrokes will be sent to
--- that window.  Pass a window ID of 0 to remove keyboard focus from any plugin-created windows
--- and instead pass keyboard strokes directly to X-Plane.
---
---@field XPLMTakeKeyboardFocus fun(inWindow: XPLMWindowID)

---@class _G
--- Returns true (1) if the indicated window has keyboard focus.
--- Pass a window ID of 0 to see if no plugin window has focus, and all keystrokes
--- will go directly to X-Plane.
---
---@field XPLMHasKeyboardFocus fun(inWindow: XPLMWindowID): boolean

---@class _G
--- This routine brings the window to the front of the Z-order for its layer.  Windows are brought to the
--- front automatically when they are created. Beyond that, you should make sure you are front before
--- handling mouse clicks.
---
--- Note that this only brings your window to the front of its layer (XPLMWindowLayer).
--- Thus, if you have a window in the floating window layer (xplm_WindowLayerFloatingWindows),
--- but there is a modal window (in layer xplm_WindowLayerModal) above you, you would still
--- not be the true frontmost window after calling this. (After all, the window layers are
--- strictly ordered, and no window in a lower layer can ever be above any window in a higher one.)
---
---@field XPLMBringWindowToFront fun(inWindow: XPLMWindowID)

---@class _G
--- This routine returns true if the window you passed in is the frontmost visible window in its layer (XPLMWindowLayer).
---
--- Thus, if you have a window at the front of the floating window layer (xplm_WindowLayerFloatingWindows),
--- this will return true even if there is a modal window (in layer xplm_WindowLayerModal) above you.
--- (Not to worry, though: in such a case, X-Plane will not pass clicks or keyboard input down to your
--- layer until the window above stops "eating" the input.)
---
--- Note that legacy windows are always placed in layer xplm_WindowLayerFlightOverlay, while modern-style windows
--- default to xplm_WindowLayerFloatingWindows. This means it's perfectly consistent to have two different
--- plugin-created windows (one legacy, one modern) *both* be in the front (of their different layers!) at the same time.
---
---@field XPLMIsWindowInFront fun(inWindow: XPLMWindowID): boolean

---@class imgui
--- imgui.InputText(label, current_text, [max_len=256], [flags=0]) returns changed, new_text
---@field InputText fun(label: string, current_text: string, max_len: integer, flags: integer): boolean

---@class imgui
--- imgui.InputTextWithHint(label, hint, current_text, [max_len=256], [flags=0]) returns changed, new_text
---@field InputTextWithHint fun(label: string, hint: string, current_text: string, max_len: integer, flags: integer): boolean

---@class imgui
--- imgui.InputTextMultiline(label, current_text, [max_len=4096], [width=0], [height=0], [flags=0]) returns changed, new_text
---@field InputTextMultiline fun(label: string, current_text: string, max_len: integer, width: number, height: number, flags: integer): boolean

