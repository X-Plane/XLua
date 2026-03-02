-- Use require('XPLMDisplay') to access these functions.

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

--[[
This constant indicates the device we want to override or enhance. We can get a callback before or after each item.
]]--

XPLMDeviceID = {
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

--[[
   XLuaRegisterAvionicsCallbacksEx
   
   This routine registers your callbacks for a built-in device. This returns a
   handle. If the returned handle is NULL, there was a problem interpreting
   your input, most likely the struct size was wrong for your SDK version. If
   the returned handle is not NULL, your callbacks will be called according to
   schedule as long as your plugin is not deactivated, or unloaded, or you
   call XPLMUnregisterAvionicsCallbacks().
   
   Note that you cannot register new callbacks for a device that is not a
   built-in one (for example a device that you have created, or a device
   another plugin has created).
]]--
--[[
    Returns   : userdata<XPLMAvionicsID>

    Parameters:
     inParams                               (XPLMCustomizeAvionics_t)

]]--

--[[
   XLuaGetAvionicsHandle
   
   This routine registers no callbacks for a built-in cockpit device, but
   returns a handle which allows you to interact with it using the Avionics
   Device API. Use this if you do not wish to intercept drawing, clicks and
   touchscreen calls to a device, but want to interact with its popup
   programmatically. This is equivalent to calling
   XPLMRegisterAvionicsCallbackEx() with NULL for all callbacks.
]]--
--[[
    Returns   : userdata<XPLMAvionicsID>

    Parameters:
     inDeviceID                             (XPLMDeviceID)

]]--

--[[
   XLuaUnregisterAvionicsCallbacks
   
   This routine unregisters your callbacks for a built-in device. You should
   only call this for handles you acquired from
   XPLMRegisterAvionicsCallbacksEx(). They will no longer be called.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inAvionicsId                           (XPLMAvionicsID)

]]--

--[[
   XLuaCreateAvionicsEx
   
   Creates a new cockpit device to be used in the 3D cockpit. You can call
   this at any time: if an aircraft referencing your device is loaded before
   your plugin, the simulator will make sure to retroactively map your display
   into it.
   
               When you are done with the device, and at least before your
               plugin is unloaded, you should destroy the device using
               XPLMDestroyAvionics().
]]--
--[[
    Returns   : userdata<XPLMAvionicsID>

    Parameters:
     inParams                               (XPLMCreateAvionics_t)

]]--

--[[
   XLuaDestroyAvionics
   
   Destroys the cockpit device and deallocates its screen's memory. You should
   only ever call this for devices that you created using
   XPLMCreateAvionicsEx(), not X-Plane' built-ine devices you have customised.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inHandle                               (XPLMAvionicsID)

]]--

--[[
   XLuaIsAvionicsBound
   
   Returns true (1) if the cockpit device with the given handle is used by the
   current aircraft.
]]--
--[[
    Returns   : boolean

    Parameters:
     inHandle                               (XPLMAvionicsID)

]]--

--[[
   XLuaSetAvionicsBrightnessRheo
   
   Sets the brightness setting's value, between 0 and 1, for the screen of the
   cockpit device with the given handle.
   
   If the device is bound to the current aircraft, this is a shortcut to
   setting the brightness rheostat value using the
   `sim/cockpit2/switches/instrument_brightness_ratio[]` dataref; this sets
   the slot in the `instrument_brightness_ratio` array to which the device is
   bound.
   
   If the device is not currently bound, the device keeps track of its own
   screen brightness rheostat, allowing you to control the brightness even
   though it isn't connected to the `instrument_brightness_ratio` dataref.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inHandle                               (XPLMAvionicsID)
     brightness                             (number)

]]--

--[[
   XLuaGetAvionicsBrightnessRheo
   
   Returns the brightness setting value, between 0 and 1, for the screen of
   the cockpit device with the given handle.
   
           If the device is bound to the current aircraft, this is a shortcut
           to getting the brightness rheostat value from the
           `sim/cockpit2/switches/instrument_brightness_ratio[]` dataref; this
           gets the slot in the `instrument_brightness_ratio` array to which
           the device is bound.
   
           If the device is not currently bound, this returns the device's own
           brightness rheostat value.
]]--
--[[
    Returns   : number

    Parameters:
     inHandle                               (XPLMAvionicsID)

]]--

--[[
   XLuaGetAvionicsBusVoltsRatio
   
   Returns the ratio of the nominal voltage (1.0 means full nominal voltage)
   of the electrical bus to which the given avionics device is bound, or -1 if
   the device is not bound to the current aircraft.
]]--
--[[
    Returns   : number

    Parameters:
     inHandle                               (XPLMAvionicsID)

]]--

--[[
   XLuaIsCursorOverAvionics
   
   Returns true (1) if the mouse is currently over the screen of cockpit
   device with the given handle. If they are not NULL, the optional x and y
   arguments are filled with the co-ordinates of the mouse cursor in device
   co-ordinates.
]]--
--[[
    Returns   : boolean, Table {
          ["outX"]                          (integer),
          ["outY"]                          (integer)
    }

    Parameters:
     inHandle                               (XPLMAvionicsID)

]]--

--[[
   XLuaAvionicsNeedsDrawing
   
   Tells X-Plane that your device's screen needs to be re-drawn. If your
   device is marked for on-demand drawing, X-Plane will call your screen
   drawing callback before drawing the next simulator frame. If your device is
   already drawn every frame, this has no effect.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inHandle                               (XPLMAvionicsID)

]]--

--[[
   XLuaSetAvionicsPopupVisible
   
   Shows or hides the popup window for a cockpit device.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inHandle                               (XPLMAvionicsID)
     inVisible                              (boolean)

]]--

--[[
   XLuaIsAvionicsPopupVisible
   
   Returns true (1) if the popup window for a cockpit device is visible.
]]--
--[[
    Returns   : boolean

    Parameters:
     inHandle                               (XPLMAvionicsID)

]]--

--[[
   XLuaPopOutAvionics
   
   Pops out the window for a cockpit device.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inHandle                               (XPLMAvionicsID)

]]--

--[[
   XLuaIsAvionicsPoppedOut
   
   Returns true (1) if the popup window for a cockpit device is popped out.
]]--
--[[
    Returns   : boolean

    Parameters:
     inHandle                               (XPLMAvionicsID)

]]--

--[[
   XLuaTakeAvionicsKeyboardFocus
   
   This routine gives keyboard focus to the popup window of a custom cockpit
   device, if it is visible.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inHandle                               (XPLMAvionicsID)

]]--

--[[
   XLuaHasAvionicsKeyboardFocus
   
   Returns true (1) if the popup window for a cockpit device has keyboard
   focus.
]]--
--[[
    Returns   : boolean

    Parameters:
     inHandle                               (XPLMAvionicsID)

]]--

--[[
   XLuaGetAvionicsGeometry
   
   Returns the bounds of a cockpit device's popup window in the X-Plane
   coordinate system.
]]--
--[[
    Returns   : Table {
          ["outLeft"]                       (integer),
          ["outTop"]                        (integer),
          ["outRight"]                      (integer),
          ["outBottom"]                     (integer)
    }

    Parameters:
     inHandle                               (XPLMAvionicsID)

]]--

--[[
   XLuaSetAvionicsGeometry
   
   Sets the size and position of a cockpit device's popup window in the
   X-Plane coordinate system.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inHandle                               (XPLMAvionicsID)
     inLeft                                 (integer)
     inTop                                  (integer)
     inRight                                (integer)
     inBottom                               (integer)

]]--

--[[
   XLuaGetAvionicsGeometryOS
   
   Returns the bounds of a cockpit device's popped-out window.
]]--
--[[
    Returns   : Table {
          ["outLeft"]                       (integer),
          ["outTop"]                        (integer),
          ["outRight"]                      (integer),
          ["outBottom"]                     (integer)
    }

    Parameters:
     inHandle                               (XPLMAvionicsID)

]]--

--[[
   XLuaSetAvionicsGeometryOS
   
   Sets the size and position of a cockpit device's popped-out window.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inHandle                               (XPLMAvionicsID)
     inLeft                                 (integer)
     inTop                                  (integer)
     inRight                                (integer)
     inBottom                               (integer)

]]--

--[[
   XLuaRegisterHotKey
   
   This routine registers a hot key.  You specify your preferred key stroke
   virtual key/flag combination, a description of what your callback does (so
   other plug-ins can describe the plug-in to the user for remapping) and a
   callback function and opaque pointer to pass in).  A new hot key ID is
   returned.  During execution, the actual key associated with your hot key
   may change, but you are insulated from this.
]]--
--[[
    Returns   : userdata<XPLMHotKeyID>

    Parameters:
     inVirtualKey                           (string)
     inFlags                                (XPLMKeyFlags)
     inDescription                          (string)
     inCallback                             (XPLMHotKey_f)
     inRefcon                               (Any reference value)

]]--

--[[
   XLuaUnregisterHotKey
   
   Unregisters a hot key.  You can only unregister your own hot keys.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inHotKey                               (XPLMHotKeyID)

]]--

--[[
   XLuaCountHotKeys
   
   Returns the number of current hot keys.
]]--
--[[
    Returns   : integer

    Parameters:
      None.
]]--

--[[
   XLuaGetNthHotKey
   
   Returns a hot key by index, for iteration on all hot keys.
]]--
--[[
    Returns   : userdata<XPLMHotKeyID>

    Parameters:
     inIndex                                (integer)

]]--

--[[
   XLuaGetHotKeyInfo
   
   Returns information about the hot key.  Return NULL for any parameter you
   don't want info about.  The description should be at least 512 chars long.
]]--
--[[
    Returns   : Table {
          ["outVirtualKey"]                 (array[1] of string),
          ["outFlags"]                      (integer),
          ["outDescription"]                (array[512] of string),
          ["outPlugin"]                     (XPLMPluginID)
    }

    Parameters:
     inHotKey                               (XPLMHotKeyID)

]]--

--[[
   XLuaSetHotKeyCombination
   
   Remaps a hot key's keystrokes.  You may remap another plugin's keystrokes.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inHotKey                               (XPLMHotKeyID)
     inVirtualKey                           (string)
     inFlags                                (XPLMKeyFlags)

]]--

