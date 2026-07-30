---@meta XPLMDefs

-- The functions, typedefs, enums, and defines in this file are
-- installed into the Lua VM at startup by the host's add_xplm_to_interp()
-- call. Scripts do NOT need to require('XPLMDefs') to access them; this file
-- exists solely as type metadata for lua-language-server / EmmyLua.

--[[
   Copyright 2005-2026 Laminar Research, Sandy Barbour and Ben Supnik All
   rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
]]--

-----------------------------------------------------------------------------
-- XPLMDefs
-----------------------------------------------------------------------------

--[[
   This file is contains the cross-platform and basic definitions for the
   X-Plane SDK.
   
   The preprocessor macros APL, LIN and IBM must be defined to specify the
   compilation target; define APL to 1 to compile on Mac, IBM to 1 to compile
   on Windows and LIN to 1 to compile on Linux. Only one compilation target
   may be used at a time. You must specify these macro definitions before
   including XPLMDefs.h or any other XPLM headers.  You can do this using the
   -D command line option or a preprocessor header.
]]--


--- Each plug-in is identified by a unique integer ID. This ID can be used to disable or enable a plug-in, or discover what plug-in is 'running' at the time. A plug-in ID is unique within the currently running instance of X-Plane unless plug-ins are reloaded. Plug-ins may receive a different unique ID each time they are loaded. This includes the unloading and reloading of plugins that are part of the user's aircraft. For persistent identification of plug-ins, use XPLMFindPluginBySignature in XPLMUtiltiies.h . -1 indicates no plug-in.
---@alias XPLMPluginID integer

--[[
These bitfields define modifier keys in a platform independent way.
When a key is pressed, a series of messages are sent to your plugin.  The down
flag is set in the first of these messages, and the up flag in the last.  While
the key is held down, messages are sent with neither flag set to indicate that the key
is being held down as a repeated character.

The control flag is mapped to the control flag on Macintosh and PC.  Generally
X-Plane uses the control key and not the command key on Macintosh, providing
a consistent interface across platforms that does not necessarily match the Macintosh
user interface guidelines.  There is not yet a way for plugins to access the Macintosh
control keys without using #ifdefed code.

The down and up flags describe the phase of a key *event* and are only meaningful when
these flags arrive with a keystroke.  When you poll the live modifier state with
XPLMGetModifierKeys(), only the modifier bits (shift, option/alt, command/control, caps lock)
are ever set --- the down/up flags are never returned by that call.
]]--

---@enum XPLMKeyFlags
local XPLMKeyFlags = {
    -- The shift key is down
    xplm_ShiftFlag                           = 1,
    -- The option or alt key is down
    xplm_OptionAltFlag                       = 2,
    -- The control key is down
    xplm_ControlFlag                         = 4,
    -- The key is being pressed down
    xplm_DownFlag                            = 8,
    -- The key is being released
    xplm_UpFlag                              = 16,
    -- The caps lock key is engaged.  Only reported by XPLMGetModifierKeys();
    -- never set on a key event.
    xplm_CapsLockFlag                        = 32,
}
---@class _G
---@field XPLMKeyFlags XPLMKeyFlags

--[[
XPLMCursorStatus describes how you would like X-Plane to manage the cursor.  See XPLMHandleCursor_f for more info.]]--

---@enum XPLMCursorStatus
local XPLMCursorStatus = {
    -- X-Plane manages the cursor normally, plugin does not affect the cusrsor.
    xplm_CursorDefault                       = 0,
    -- X-Plane hides the cursor.
    xplm_CursorHidden                        = 1,
    -- X-Plane shows the cursor as the default arrow.
    xplm_CursorArrow                         = 2,
    -- X-Plane shows the cursor but lets you select an OS cursor.
    xplm_CursorCustom                        = 3,
    -- X-Plane shows a small bi-directional knob-rotating cursor.
    xplm_CursorRotateSmall                   = 4,
    -- X-Plane shows a small counter-clockwise knob-rotating cursor.
    xplm_CursorRotateSmallLeft               = 5,
    -- X-Plane shows a small clockwise knob-rotating cursor.
    xplm_CursorRotateSmallRight              = 6,
    -- X-Plane shows a medium bi-directional knob-rotating cursor.
    xplm_CursorRotateMedium                  = 7,
    -- X-Plane shows a medium counter-clockwise knob-rotating cursor.
    xplm_CursorRotateMediumLeft              = 8,
    -- X-Plane shows a medium clockwise knob-rotating cursor.
    xplm_CursorRotateMediumRight             = 9,
    -- X-Plane shows a large bi-directional knob-rotating cursor.
    xplm_CursorRotateLarge                   = 10,
    -- X-Plane shows a large counter-clockwise knob-rotating cursor.
    xplm_CursorRotateLargeLeft               = 11,
    -- X-Plane shows a large clockwise knob-rotating cursor.
    xplm_CursorRotateLargeRight              = 12,
    -- X-Plane shows an up-and-down arrows cursor.
    xplm_CursorUpDown                        = 13,
    -- X-Plane shows a down arrow cursor.
    xplm_CursorDown                          = 14,
    -- X-Plane shows an up arrow cursor.
    xplm_CursorUp                            = 15,
    -- X-Plane shows a left-right arrow cursor.
    xplm_CursorLeftRight                     = 16,
    -- X-Plane shows a left arrow cursor.
    xplm_CursorLeft                          = 17,
    -- X-Plane shows a right arrow cursor.
    xplm_CursorRight                         = 18,
    -- X-Plane shows a button-pushing cursor.
    xplm_CursorButton                        = 19,
    -- X-Plane shows a handle-grabbing cursor.
    xplm_CursorHandle                        = 20,
    -- X-Plane shows a four-arrows cursor.
    xplm_CursorFourArrows                    = 21,
    -- X-Plane shows a cursor to drag a horizontal splitter bar.
    xplm_CursorSplitterH                     = 22,
    -- X-Plane shows a cursor to drag a vertical splitter bar.
    xplm_CursorSplitterV                     = 23,
    -- X-Plane shows an I-Beam cursor for text editing.
    xplm_CursorText                          = 24,
}
---@class _G
---@field XPLMCursorStatus XPLMCursorStatus

--[[
				When the mouse is clicked, your mouse click routine is called repeatedly.  It is first called with the
				mouse down message.  It is then called zero or more times with the mouse-drag message, and finally it
				is called once with the mouse up message.  All of these messages will be directed to the same window;
				you are guaranteed to not receive a drag or mouse-up event without first receiving the corresponding mouse-down.
]]--

---@enum XPLMMouseStatus
local XPLMMouseStatus = {
    xplm_MouseDown                           = 1,
    xplm_MouseDrag                           = 2,
    xplm_MouseUp                             = 3,
}
---@class _G
---@field XPLMMouseStatus XPLMMouseStatus

---@class _G
--- No plugin.
---@field XPLM_NO_PLUGIN_ID integer

---@class _G
--- X-Plane itself
---@field XPLM_PLUGIN_XPLANE integer

---@class _G
--- 				The current XPLM revision is 4.4.0 (440).
---
---@field kXPLM_Version integer

--- A container for a fixed-size string buffer of 150 characters.
---@class XPLMFixedString150_t
---@field buffer string[]

---@class _G
---@field XPLM_KEY_RETURN integer

---@class _G
---@field XPLM_KEY_ESCAPE integer

---@class _G
---@field XPLM_KEY_TAB integer

---@class _G
---@field XPLM_KEY_DELETE integer

---@class _G
---@field XPLM_KEY_LEFT integer

---@class _G
---@field XPLM_KEY_RIGHT integer

---@class _G
---@field XPLM_KEY_UP integer

---@class _G
---@field XPLM_KEY_DOWN integer

---@class _G
---@field XPLM_KEY_0 integer

---@class _G
---@field XPLM_KEY_1 integer

---@class _G
---@field XPLM_KEY_2 integer

---@class _G
---@field XPLM_KEY_3 integer

---@class _G
---@field XPLM_KEY_4 integer

---@class _G
---@field XPLM_KEY_5 integer

---@class _G
---@field XPLM_KEY_6 integer

---@class _G
---@field XPLM_KEY_7 integer

---@class _G
---@field XPLM_KEY_8 integer

---@class _G
---@field XPLM_KEY_9 integer

---@class _G
---@field XPLM_KEY_DECIMAL integer

---@class _G
---@field XPLM_VK_BACK integer

---@class _G
---@field XPLM_VK_TAB integer

---@class _G
---@field XPLM_VK_CLEAR integer

---@class _G
---@field XPLM_VK_RETURN integer

---@class _G
---@field XPLM_VK_ESCAPE integer

---@class _G
---@field XPLM_VK_SPACE integer

---@class _G
---@field XPLM_VK_PRIOR integer

---@class _G
---@field XPLM_VK_NEXT integer

---@class _G
---@field XPLM_VK_END integer

---@class _G
---@field XPLM_VK_HOME integer

---@class _G
---@field XPLM_VK_LEFT integer

---@class _G
---@field XPLM_VK_UP integer

---@class _G
---@field XPLM_VK_RIGHT integer

---@class _G
---@field XPLM_VK_DOWN integer

---@class _G
---@field XPLM_VK_SELECT integer

---@class _G
---@field XPLM_VK_PRINT integer

---@class _G
---@field XPLM_VK_EXECUTE integer

---@class _G
---@field XPLM_VK_SNAPSHOT integer

---@class _G
---@field XPLM_VK_INSERT integer

---@class _G
---@field XPLM_VK_DELETE integer

---@class _G
---@field XPLM_VK_HELP integer

---@class _G
--- XPLM_VK_0 thru XPLM_VK_9 are the same as ASCII '0' thru '9' (0x30 - 0x39)
---
---@field XPLM_VK_0 integer

---@class _G
---@field XPLM_VK_1 integer

---@class _G
---@field XPLM_VK_2 integer

---@class _G
---@field XPLM_VK_3 integer

---@class _G
---@field XPLM_VK_4 integer

---@class _G
---@field XPLM_VK_5 integer

---@class _G
---@field XPLM_VK_6 integer

---@class _G
---@field XPLM_VK_7 integer

---@class _G
---@field XPLM_VK_8 integer

---@class _G
---@field XPLM_VK_9 integer

---@class _G
--- XPLM_VK_A thru XPLM_VK_Z are the same as ASCII 'A' thru 'Z' (0x41 - 0x5A)
---
---@field XPLM_VK_A integer

---@class _G
---@field XPLM_VK_B integer

---@class _G
---@field XPLM_VK_C integer

---@class _G
---@field XPLM_VK_D integer

---@class _G
---@field XPLM_VK_E integer

---@class _G
---@field XPLM_VK_F integer

---@class _G
---@field XPLM_VK_G integer

---@class _G
---@field XPLM_VK_H integer

---@class _G
---@field XPLM_VK_I integer

---@class _G
---@field XPLM_VK_J integer

---@class _G
---@field XPLM_VK_K integer

---@class _G
---@field XPLM_VK_L integer

---@class _G
---@field XPLM_VK_M integer

---@class _G
---@field XPLM_VK_N integer

---@class _G
---@field XPLM_VK_O integer

---@class _G
---@field XPLM_VK_P integer

---@class _G
---@field XPLM_VK_Q integer

---@class _G
---@field XPLM_VK_R integer

---@class _G
---@field XPLM_VK_S integer

---@class _G
---@field XPLM_VK_T integer

---@class _G
---@field XPLM_VK_U integer

---@class _G
---@field XPLM_VK_V integer

---@class _G
---@field XPLM_VK_W integer

---@class _G
---@field XPLM_VK_X integer

---@class _G
---@field XPLM_VK_Y integer

---@class _G
---@field XPLM_VK_Z integer

---@class _G
---@field XPLM_VK_NUMPAD0 integer

---@class _G
---@field XPLM_VK_NUMPAD1 integer

---@class _G
---@field XPLM_VK_NUMPAD2 integer

---@class _G
---@field XPLM_VK_NUMPAD3 integer

---@class _G
---@field XPLM_VK_NUMPAD4 integer

---@class _G
---@field XPLM_VK_NUMPAD5 integer

---@class _G
---@field XPLM_VK_NUMPAD6 integer

---@class _G
---@field XPLM_VK_NUMPAD7 integer

---@class _G
---@field XPLM_VK_NUMPAD8 integer

---@class _G
---@field XPLM_VK_NUMPAD9 integer

---@class _G
---@field XPLM_VK_MULTIPLY integer

---@class _G
---@field XPLM_VK_ADD integer

---@class _G
---@field XPLM_VK_SEPARATOR integer

---@class _G
---@field XPLM_VK_SUBTRACT integer

---@class _G
---@field XPLM_VK_DECIMAL integer

---@class _G
---@field XPLM_VK_DIVIDE integer

---@class _G
---@field XPLM_VK_F1 integer

---@class _G
---@field XPLM_VK_F2 integer

---@class _G
---@field XPLM_VK_F3 integer

---@class _G
---@field XPLM_VK_F4 integer

---@class _G
---@field XPLM_VK_F5 integer

---@class _G
---@field XPLM_VK_F6 integer

---@class _G
---@field XPLM_VK_F7 integer

---@class _G
---@field XPLM_VK_F8 integer

---@class _G
---@field XPLM_VK_F9 integer

---@class _G
---@field XPLM_VK_F10 integer

---@class _G
---@field XPLM_VK_F11 integer

---@class _G
---@field XPLM_VK_F12 integer

---@class _G
---@field XPLM_VK_F13 integer

---@class _G
---@field XPLM_VK_F14 integer

---@class _G
---@field XPLM_VK_F15 integer

---@class _G
---@field XPLM_VK_F16 integer

---@class _G
---@field XPLM_VK_F17 integer

---@class _G
---@field XPLM_VK_F18 integer

---@class _G
---@field XPLM_VK_F19 integer

---@class _G
---@field XPLM_VK_F20 integer

---@class _G
---@field XPLM_VK_F21 integer

---@class _G
---@field XPLM_VK_F22 integer

---@class _G
---@field XPLM_VK_F23 integer

---@class _G
---@field XPLM_VK_F24 integer

---@class _G
--- The following definitions are extended and are not based on the Microsoft key set.
---@field XPLM_VK_EQUAL integer

---@class _G
---@field XPLM_VK_MINUS integer

---@class _G
---@field XPLM_VK_RBRACE integer

---@class _G
---@field XPLM_VK_LBRACE integer

---@class _G
---@field XPLM_VK_QUOTE integer

---@class _G
---@field XPLM_VK_SEMICOLON integer

---@class _G
---@field XPLM_VK_BACKSLASH integer

---@class _G
---@field XPLM_VK_COMMA integer

---@class _G
---@field XPLM_VK_SLASH integer

---@class _G
---@field XPLM_VK_PERIOD integer

---@class _G
---@field XPLM_VK_BACKQUOTE integer

---@class _G
---@field XPLM_VK_ENTER integer

---@class _G
---@field XPLM_VK_NUMPAD_ENT integer

---@class _G
---@field XPLM_VK_NUMPAD_EQ integer

