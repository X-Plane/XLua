-- Use require('XPLMCamera') to access these functions.

--[[
   Copyright 2005-2022 Laminar Research, Sandy Barbour and Ben Supnik All
   rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
]]--

-----------------------------------------------------------------------------
-- XPLMCamera
-----------------------------------------------------------------------------

--[[
   The XPLMCamera APIs allow plug-ins to control the camera angle in X-Plane.
   This has a number of applications, including but not limited to:
   
   - Creating new views (including dynamic/user-controllable views) for the
     user.
   - Creating applications that use X-Plane as a renderer of scenery,
     aircrafts, or both.
   
   The camera is controlled via six parameters: a location in OpenGL
   coordinates and pitch, roll and yaw, similar to an airplane's position.
   OpenGL coordinate info is described in detail in the XPLMGraphics
   documentation; generally you should use the XPLMGraphics routines to
   convert from world to local coordinates. The camera's orientation starts
   facing level with the ground directly up the negative-Z axis (approximately
   north) with the horizon horizontal. It is then rotated clockwise for yaw,
   pitched up for positive pitch, and rolled clockwise around the vector it is
   looking along for roll.
   
   You control the camera either either until the user selects a new view or
   permanently (the latter being similar to how UDP camera control works). You
   control the camera by registering a callback per frame from which you
   calculate the new camera positions. This guarantees smooth camera motion.
   
   Use the XPLMDataAccess APIs to get information like the position of the
   aircraft, etc. for complex camera positioning.
   
   Note: if your goal is to move the virtual pilot in the cockpit, this API is
   not needed; simply update the datarefs for the pilot's head position.
   
   For custom exterior cameras, set the camera's mode to an external view
   first to get correct sound and 2-d panel behavior.
]]--

#include "XPLMDefs.h"
require("XPLMDefs")

--[[
This enumeration states how long you want to retain control of the camera.
You can retain it indefinitely or until the user selects a new view.
]]--

XPLMCameraControlDuration = {
    -- Control the camera until the user picks a new view.
    xplm_ControlCameraUntilViewChanges       = 1,
    -- Control the camera until your plugin is disabled or another plugin forcibly
    -- takes control.
    xplm_ControlCameraForever                = 2,
}

--[[
   XLuaControlCamera
   
   This function repositions the camera on the next drawing cycle. You must
   pass a non-null control function. Specify in inHowLong how long you'd like
   control (indefinitely or until a new view mode is set by the user).
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inHowLong                              (XPLMCameraControlDuration)
     inControlFunc                          (XPLMCameraControl_f)
     inRefcon                               (Any reference value)

]]--

--[[
   XLuaDontControlCamera
   
   This function stops you from controlling the camera. If you have a camera
   control function, it will not be called with an inIsLosingControl flag.
   X-Plane will control the camera on the next cycle.
   
   For maximum compatibility you should not use this routine unless you are in
   posession of the camera.
]]--
--[[
    Returns   : Nothing.

    Parameters:
      None.
]]--

--[[
   XLuaIsCameraBeingControlled
   
   This routine returns true if the camera is being controlled, false if it is
   not. If it is and you pass in a pointer to a camera control duration, the
   current control duration will be returned.
]]--
--[[
    Returns   : boolean, Table {
          ["outCameraControlDuration"]      (integer)
    }

    Parameters:
      None.
]]--

--[[
   XLuaReadCameraPosition
   
   This function reads the current camera position.
]]--
--[[
    Returns   : Table {
          ["outCameraPosition"]             (XPLMCameraPosition_t)
    }

    Parameters:
      None.
]]--

