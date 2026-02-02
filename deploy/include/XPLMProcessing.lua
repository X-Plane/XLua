-- Use require('XPLMProcessing') to access these functions.

--[[
   Copyright 2005-2022 Laminar Research, Sandy Barbour and Ben Supnik All
   rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
]]--

-----------------------------------------------------------------------------
-- XPLMProcessing
-----------------------------------------------------------------------------

--[[
   This API allows you to get regular callbacks during the flight loop, the
   part of X-Plane where the plane's position calculates the physics of
   flight, etc. Use these APIs to accomplish periodic tasks like logging data
   and performing I/O.
   
   You can receive a callback either just before or just after the per-frame
   physics calculations happen - you can use post-flightmodel callbacks to
   "patch" the flight model after it has run.
   
   If the user has set the number of flight model iterations per frame greater
   than one your plugin will _not_ see this; these integrations run on the
   sub-section of the flight model where iterations improve responsiveness
   (e.g. physical integration, not simple systems tracking) and are thus
   opaque to plugins.
   
   Flight loop scheduling, when scheduled by time, is scheduled by a "first
   callback after the deadline" schedule, e.g. your callbacks will always be
   slightly late to ensure that we don't run faster than your deadline.
   
   WARNING: Do NOT use the post-flightmodel callback for initialization,
   resource creation, etc. The only recommended use of post-FM callbacks is to
   "patch" the computed values of the flightmodel using dataref read-writes,
   and to compute custom system values by reading the flightmodel. APIs that
   create resources or initialize the sim may issue warnings, crash rhe sim,
   or have unexpected results.
   
   WARNING: Do NOT use these callbacks to draw! You cannot draw during flight
   loop callbacks. Use the drawing callbacks (see XPLMDisplay for more info)
   for graphics or the XPLMInstance functions for aircraft or models. (One
   exception: you can use a post-flight loop callback to update your own
   off-screen FBOs.)
]]--

#include "XPLMDefs.h"
require("XPLMDefs")

--[[
You can register a flight loop callback to run either before or after the flight model is
integrated by X-Plane.
]]--

XPLMFlightLoopPhaseType = {
    -- Your callback runs before X-Plane integrates the flight model.
    xplm_FlightLoop_Phase_BeforeFlightModel  = 0,
    -- Your callback runs after X-Plane integrates the flight model.
    xplm_FlightLoop_Phase_AfterFlightModel   = 1,
}

--[[
   XLuaGetElapsedTime
   
   This routine returns the elapsed time since the sim started up in decimal
   seconds. This is a wall timer; it keeps counting upward even if the sim is
   pasued.
   
   __WARNING__: XPLMGetElapsedTime is not a very good timer!  It lacks
   precision in both its data type and its source.  Do not attempt to use it
   for timing critical applications like network multiplayer.
]]--
--[[
    Returns   : number

    Parameters:
      None.
]]--

--[[
   XLuaGetCycleNumber
   
   This routine returns a counter starting at zero for each sim cycle
   computed/video frame rendered.
]]--
--[[
    Returns   : integer

    Parameters:
      None.
]]--

--[[
   XLuaCreateFlightLoop
   
   This routine creates a flight loop callback and returns its ID. The flight
   loop callback is created using the input param struct, and is inited to be
   unscheduled. Use XPLMScheduleFlightLoop to schedule it.
]]--
--[[
    Returns   : userdata<XPLMFlightLoopID>

    Parameters:
     inParams                               (XPLMCreateFlightLoop_t)

]]--

--[[
   XLuaDestroyFlightLoop
   
   This routine destroys a flight loop callback by ID. Only call it on flight
   loops created with the newer XPLMCreateFlightLoop API.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inFlightLoopID                         (XPLMFlightLoopID)

]]--

--[[
   XLuaScheduleFlightLoop
   
   This routine schedules a flight loop callback for future execution. If
   inInterval is negative, it is run in a certain number of frames based on
   the absolute value of the input. If the interval is positive, it is a
   duration in seconds.
   
   If inRelativeToNow is true, times are interpreted relative to the time this
   routine is called; otherwise they are relative to the last call time or the
   time the flight loop was registered (if never called).
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inFlightLoopID                         (XPLMFlightLoopID)
     inInterval                             (number)
     inRelativeToNow                        (boolean)

]]--

