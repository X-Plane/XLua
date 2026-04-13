-- Use require('XPLMPlanes') to access these functions.

--[[
   Copyright 2005-2026 Laminar Research, Sandy Barbour and Ben Supnik All
   rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
]]--

-----------------------------------------------------------------------------
-- XPLMPlanes
-----------------------------------------------------------------------------

--[[
   The XPLMPlanes APIs allow you to control the various aircraft in X-Plane,
   both the user's and the sim's.
   
   You cannot initialize a flight from any XPLM callback. Only initialize a
   flight in response to:
    * Command handlers
    * Menu handlers
    * UI handlers (keyboard, mouse) from XPLMDisplay/widgets
    * The pre-flightmodel processing callback
   
   In particular, do not initialize a flight from:
    * The post-flightmodel processing callback
    * Dataref get/set handlers
    * Any drawing callbacks
   
   *Note*: Some older APIs for accessing aircraft require full paths and not
    paths relative to the X-Plane folder for historical reasons. You will need
    to prefix all relative paths with the  X-Plane path as accessed via
    XPLMGetSystemPath.
]]--

require("XPLMDefs")

--[[
Result codes from initializing or updating the user's aircraft. Initialization can fail due to
unparsable/invalid data, or due to the contents of the initialization containing parameters the
sim cannot fulfill (e.g. an aircraft not on disk, a ramp start not present in an airport due to
custom scenery).

If an initialization fails, a human-readable string is sent to your plugin's error function.
This is meant for debugging purposes only and should not be parsed. Your plugin's logic should
only use the result code for flow control.
]]--

XPLMInitResult = {
    -- The initialization succeeded.
    xplm_Init_Success                        = 0,
    -- The provided argument was invalid. This can be returned if the provided
    -- string is not a valid json string. This error can also be returned if one
    -- or more of the provided arguments is invalid, such as a missing  required
    -- field or an unrecognized parameter such as an unknown runway name. Invalid
    -- errors imply that your calling code is generating incorrect JSON and should
    -- be fixed; use your plugin's error callback to find more detailed
    -- information about the problem with your input.
    xplm_Init_Invalid                        = 1,
    -- The new flight could not be initialized because one of the aircraft
    -- requested could not be found on disk or loaded.
    xplm_Init_MissingAircraft                = 2,
    -- The new flight could not be initialized because one of the aircraft's'
    -- requested liveries could not be found on disk or loaded.
    xplm_Init_MissingLivery                  = 3,
    -- The new flight could not be initialized because the requested airport was
    -- not found in X-Plane's airport database.
    xplm_Init_MissingAirport                 = 4,
    -- The new flight could not be initialized because the requested ramp start
    -- was not found at the specified airport in X-Plane's airport database.
    xplm_Init_MissingRamp                    = 5,
    -- The new flight could not be initialized because the requested runway was
    -- not found at the specified airport in X-Plane's airport database.
    xplm_Init_MissingRunway                  = 6,
}

--[[
   XLuaInitFlight
   
   Initialize a new flight, ending th user's current flight. The flight config
   is provided as json string. See
   https://developer.x-plane.com/article/flight-initialization-api/ for the
   JSON format specification. 
   
   Returns a XPLMInitResult enum value specifying whether the initalization
   succeeeded (and if not, what  caused it to fail).
]]--
--[[
    Returns   : integer

    Parameters:
     inJsonData                             (string)

]]--

--[[
   XLuaUpdateFlight
   
   Updates the user's 'current flight, modifying some flight parameters. The
   flight config is provided as a JSON string, see
   https://developer.x-plane.com/article/flight-initialization-api/ for the
   JSON format  specification.
   
   Returns an XPLMInitResult enum value specifying whether the update
   suceeeded (and if not, what caused  it to fail).
]]--
--[[
    Returns   : integer

    Parameters:
     inJsonData                             (string)

]]--

--[[
   XLuaSetUsersAircraft
   
   This routine changes the user's aircraft.  Note that this will reinitialize
   the user to be on the nearest airport's first runway.  Pass in a full path
   (hard drive and everything including the .acf extension) to the .acf file.
   
   Use XPLMInitFlight for complete control over initialization.
   
   **WARNING**: this API takes a full, not relative aicraft path.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inAircraftPath                         (string)

]]--

--[[
   XLuaPlaceUserAtAirport
   
   This routine places the user at a given airport.  Specify the airport by
   its X-Plane airport ID (e.g. 'KBOS').
   
   Use XPLMInitFlight for complete control over initialization.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inAirportCode                          (string)

]]--

--[[
   XLuaPlaceUserAtLocation
   
   Places the user at a specific location after performing any necessary
   scenery loads.
   
   As with in-air starts initiated from the X-Plane user interface, the
   aircraft will always start with its engines running, regardless of the
   user's preferences (i.e., regardless of what the dataref
   `sim/operation/prefs/startup_running` says).
   
   Use XPLMInitFlight for complete control over initialization.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     latitudeDegrees                        (number)
     longitudeDegrees                       (number)
     elevationMetersMSL                     (number)
     headingDegreesTrue                     (number)
     speedMetersPerSecond                   (number)

]]--

--[[
   XLuaCountAircraft
   
   This function returns the number of aircraft X-Plane is capable of having,
   as well as the number of aircraft that are currently active.  These numbers
   count the user's aircraft.  It can also return the plugin that is currently
   controlling aircraft.  In X-Plane 7, this routine reflects the number of
   aircraft the user has enabled in the rendering options window.
]]--
--[[
    Returns   : Table {
          ["outTotalAircraft"]              (integer),
          ["outActiveAircraft"]             (integer),
          ["outController"]                 (XPLMPluginID)
    }

    Parameters:
      None.
]]--

--[[
   XLuaGetNthAircraftModel
   
   This function returns the aircraft model for the Nth aircraft.  Indices are
   zero based, with zero being the user's aircraft.  The file name should be
   at least 256 chars in length; the path should be at least 512 chars in
   length.
]]--
--[[
    Returns   : Table {
          ["outFileName"]                   (array[256] of string),
          ["outPath"]                       (array[512] of string)
    }

    Parameters:
     inIndex                                (integer)

]]--

--[[
   XLuaAcquirePlanes
   
   XPLMAcquirePlanes grants your plugin exclusive access to the aircraft.  It
   returns true if you gain access, false if you do not.
   
   inAircraft - pass in an array of pointers to strings specifying the planes
   you want loaded.  For any plane index you do not want loaded, pass a
   0-length string.  Other strings should be full paths with the .acf
   extension.  NULL terminates this array, or pass NULL if there are no planes
   you want loaded.
   
   Aircraft paths for this API are full, not relative aircraft paths.
   
   If you pass in a callback and do not receive access to the planes your
   callback will be called when the airplanes are available. If you do receive
   airplane access, your callback will not be called.
]]--
--[[
    Returns   : boolean

    Parameters:
     inAircraft                             (array<string|char const*>[])
     inCallback                             (XPLMPlanesAvailable_f)
     inRefcon                               (Any reference value)

]]--

--[[
   XLuaReleasePlanes
   
   Call this function to release access to the planes.  Note that if you are
   disabled, access to planes is released for you and you must reacquire it.
]]--
--[[
    Returns   : Nothing.

    Parameters:
      None.
]]--

--[[
   XLuaSetActiveAircraftCount
   
   This routine sets the number of active planes.  If you pass in a number
   higher than the total number of planes availables, only the total number of
   planes available is actually used.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inCount                                (integer)

]]--

--[[
   XLuaSetAircraftModel
   
   This routine loads an aircraft model.  It may only be called if you have
   exclusive access to the airplane APIs.  Pass in the path of the model with
   the .acf extension.  The index is zero based, but you may not pass in 0
   (use XPLMSetUsersAircraft to load the user's aircracft).
   
   This API takes a full aircraft path.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inIndex                                (integer)
     inAircraftPath                         (string)

]]--

--[[
   XLuaDisableAIForPlane
   
   This routine turns off X-Plane's AI for a given plane.  The plane will
   continue to draw and be a real plane in X-Plane, but will not move itself.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inPlaneIndex                           (integer)

]]--

