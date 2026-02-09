-- Use require('XPLMDefs') to access these functions.

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
]]--

XPLMKeyFlags = {
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
}

--[[
XPLMCursorStatus describes how you would like X-Plane to manage the cursor.  See XPLMHandleCursor_f for more info.]]--

XPLMCursorStatus = {
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

--[[
				When the mouse is clicked, your mouse click routine is called repeatedly.  It is first called with the
				mouse down message.  It is then called zero or more times with the mouse-drag message, and finally it
				is called once with the mouse up message.  All of these messages will be directed to the same window;
				you are guaranteed to not receive a drag or mouse-up event without first receiving the corresponding mouse-down.
]]--

XPLMMouseStatus = {
    xplm_MouseDown                           = 1,
    xplm_MouseDrag                           = 2,
    xplm_MouseUp                             = 3,
}

