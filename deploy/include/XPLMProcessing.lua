---@meta XPLMProcessing

-- The functions, typedefs, enums, and defines in this file are
-- installed into the Lua VM at startup by the host's add_xplm_to_interp()
-- call. Scripts do NOT need to require('XPLMProcessing') to access them; this file
-- exists solely as type metadata for lua-language-server / EmmyLua.

--[[
   Copyright 2005-2026 Laminar Research, Sandy Barbour and Ben Supnik All
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

require("XPLMDefs")

--[[
You can register a flight loop callback to run either before or after the flight model is
integrated by X-Plane.
]]--

---@enum XPLMFlightLoopPhaseType
local XPLMFlightLoopPhaseType = {
    -- Your callback runs before X-Plane integrates the flight model.
    xplm_FlightLoop_Phase_BeforeFlightModel  = 0,
    -- Your callback runs after X-Plane integrates the flight model.
    xplm_FlightLoop_Phase_AfterFlightModel   = 1,
}
---@class _G
---@field XPLMFlightLoopPhaseType XPLMFlightLoopPhaseType

--- This is an opaque identifier for a flight loop callback. You can use this identifier to easily track and remove your callbacks, or to use the new flight loop APIs.
---@class XPLMFlightLoopID : userdata
---@field private __XPLMFlightLoopID_marker any

--- This is your flight loop callback. Each time the flight loop is iterated through, you receive this call at the end. Flight loop callbacks receive a number of input timing parameters. These input timing parameters are not particularly useful; you may need to track your own timing data (e.g. by reading datarefs). The input parameters are: - inElapsedSinceLastCall: the wall time since your last callback. - inElapsedTimeSinceLastFlightLoop: the wall time since any flight loop was dispatched. - inCounter: a monotonically increasing counter, bumped once per flight loop dispatch from the sim. - inRefcon: your own pointer constant provided when you registered yor callback. Your return value controls when you will next be called. - Return 0 to stop receiving callbacks. - Return a positive number to specify how many seconds until the next callback. (You will be called at or after this time, not before.) - Return a negative number to specify how many loops must go by until you are called. For example, -1.0 means call me the very next loop. Try to run your flight loop as infrequently as is practical, and suspend it (using return value 0) when you do not need it; lots of flight loop callbacks that do nothing lowers X-Plane's frame rate. Your callback will NOT be unregistered if you return 0; it will merely be inactive.
---@alias XPLMFlightLoop_f fun(inElapsedSinceLastCall: number, inElapsedTimeSinceLastFlightLoop: number, inCounter: integer, inRefcon: any): number

--- XPLMCreateFlightLoop_t contains the parameters to create a new flight loop callback. The structure may be expanded in future SDKs - always set structSize to the size of your structure in bytes.
---@class XPLMCreateFlightLoop_t
---@field structSize integer
---@field phase XPLMFlightLoopPhaseType
---@field callbackFunc XPLMFlightLoop_f
---@field refcon any

---@class _G
--- This routine returns the elapsed time since the sim started up in decimal seconds. This is a wall timer;
--- it keeps counting upward even if the sim is pasued.
---
--- __WARNING__: XPLMGetElapsedTime is not a very good timer!  It lacks precision in both its data type
--- and its source.  Do not attempt to use it for timing critical applications like network multiplayer.
---
---@field XPLMGetElapsedTime fun(): number

---@class _G
--- This routine returns a counter starting at zero for each sim cycle computed/video frame rendered.
---
---@field XPLMGetCycleNumber fun(): integer

---@class _G
--- This routine creates a flight loop callback and returns its ID. The flight loop callback is created
--- using the input param struct, and is inited to be unscheduled. Use XPLMScheduleFlightLoop
--- to schedule it.
---
---@field XPLMCreateFlightLoop fun(inParams: XPLMCreateFlightLoop_t): XPLMFlightLoopID

---@class _G
--- This routine destroys a flight loop callback by ID. Only call it on flight loops created with
--- the newer XPLMCreateFlightLoop API.
---
---@field XPLMDestroyFlightLoop fun(inFlightLoopID: XPLMFlightLoopID)

---@class _G
--- This routine schedules a flight loop callback for future execution. If inInterval is negative, it is run
--- in a certain number of frames based on the absolute value of the input. If the interval is positive, it is
--- a duration in seconds.
---
--- If inRelativeToNow is true, times are interpreted relative to the time this routine is called; otherwise
--- they are relative to the last call time or the time the flight loop was registered (if never called).
---
---@field XPLMScheduleFlightLoop fun(inFlightLoopID: XPLMFlightLoopID, inInterval: number, inRelativeToNow: boolean)

