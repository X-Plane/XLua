-- Use require('XPLMScenery') to access these functions.

--[[
   Copyright 2005-2022 Laminar Research, Sandy Barbour and Ben Supnik All
   rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
]]--

-----------------------------------------------------------------------------
-- XPLMScenery
-----------------------------------------------------------------------------

--[[
   This package contains APIs to interact with X-Plane's scenery system.
]]--

#include "XPLMDefs.h"
require("XPLMDefs")

--[[
XPLMProbeType defines the type of terrain probe - each probe has a different algorithm. (Only one
type of probe is provided right now, but future APIs will expose more flexible or powerful or useful
probes.
]]--

XPLMProbeType = {
    -- The Y probe gives you the location of the tallest physical scenery along
    -- the Y axis going through the queried point.
    xplm_ProbeY                              = 0,
}

--[[
Probe results - possible results from a probe query.
]]--

XPLMProbeResult = {
    -- The probe hit terrain and returned valid values.
    xplm_ProbeHitTerrain                     = 0,
    -- An error in the API call.  Either the probe struct size is bad, the probe
    -- is invalid, or the type is mismatched for the specific query call.
    xplm_ProbeError                          = 1,
    -- The probe call succeeded but there is no terrain under this point (perhaps
    -- it is off the side of the planet?)
    xplm_ProbeMissed                         = 2,
}

--[[
   XLuaCreateProbe
   
   Creates a new probe object of a given type and returns.
]]--
--[[
    Returns   : userdata<XPLMProbeRef>

    Parameters:
     inProbeType                            (XPLMProbeType)

]]--

--[[
   XLuaDestroyProbe
   
   Deallocates an existing probe object.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inProbe                                (XPLMProbeRef)

]]--

--[[
   XLuaProbeTerrainXYZ
   
   Probes the terrain. Pass in the XYZ coordinate of the probe point, a probe
   object, and an XPLMProbeInfo_t struct that has its structSize member set
   properly. Other fields are filled in if we hit terrain, and a probe result
   is returned.
]]--
--[[
    Returns   : integer

    Parameters:
     inProbe                                (XPLMProbeRef)
     inX                                    (number)
     inY                                    (number)
     inZ                                    (number)
     outInfo                                (XPLMProbeInfo_t)

]]--

--[[
   XLuaGetMagneticVariation
   
   Returns X-Plane's simulated magnetic variation (declination) at the
   indication latitude and longitude.
]]--
--[[
    Returns   : number

    Parameters:
     latitude                               (number)
     longitude                              (number)

]]--

--[[
   XLuaDegTrueToDegMagnetic
   
   Converts a heading in degrees relative to true north into a value relative
   to magnetic north at the user's current location.
]]--
--[[
    Returns   : number

    Parameters:
     headingDegreesTrue                     (number)

]]--

--[[
   XLuaDegMagneticToDegTrue
   
   Converts a heading in degrees relative to magnetic north at the user's
   current location into a value relative to true north.
]]--
--[[
    Returns   : number

    Parameters:
     headingDegreesMagnetic                 (number)

]]--

--[[
   XLuaLoadObject
   
   This routine loads an OBJ file and returns a handle to it. If X-Plane has
   already loaded the object, the handle to the existing object is returned.
   Do not assume you will get the same handle back twice, but do make sure to
   call unload once for every load to avoid "leaking" objects. The object will
   be purged from memory when no plugins and no scenery are using it.
   
   The path for the object must be relative to the X-System base folder. If
   the path is in the root of the X-System folder you may need to prepend ./
   to it; loading objects in the root of the X-System folder is STRONGLY
   discouraged - your plugin should not dump art resources in the root folder!
   
   XPLMLoadObject will return NULL if the object cannot be loaded (either
   because it is not found or the file is misformatted). This routine will
   load any object that can be used in the X-Plane scenery system.
   
   It is important that the datarefs an object uses for animation already be
   registered before you load the object. For this reason it may be necessary
   to defer object loading until the sim has fully started.
]]--
--[[
    Returns   : userdata<XPLMObjectRef>

    Parameters:
     inPath                                 (string)

]]--

--[[
   XLuaLoadObjectAsync
   
   This routine loads an object asynchronously; control is returned to you
   immediately while X-Plane loads the object. The sim will not stop flying
   while the object loads. For large objects, it may be several seconds before
   the load finishes.
   
   You provide a callback function that is called once the load has completed.
   Note that if the object cannot be loaded, you will not find out until the
   callback function is called with a NULL object handle.
   
   There is no way to cancel an asynchronous object load; you must wait for
   the load to complete and then release the object if it is no longer
   desired.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inPath                                 (string)
     inCallback                             (XPLMObjectLoaded_f)
     inRefcon                               (Any reference value)

]]--

--[[
   XLuaUnloadObject
   
   This routine marks an object as no longer being used by your plugin.
   Objects are reference counted: once no plugins are using an object, it is
   purged from memory. Make sure to call XPLMUnloadObject once for each
   successful call to XPLMLoadObject.
]]--
--[[
    Returns   : Nothing.

    Parameters:
     inObject                               (XPLMObjectRef)

]]--

--[[
   XLuaLookupObjects
   
   This routine looks up a virtual path in the library system and returns all
   matching elements. You provide a callback - one virtual path may match many
   objects in the library. XPLMLookupObjects returns the number of objects
   found.
   
   The latitude and longitude parameters specify the location the object will
   be used. The library system allows for scenery packages to only provide
   objects to certain local locations. Only objects that are allowed at the
   latitude/longitude you provide will be returned.
]]--
--[[
    Returns   : integer

    Parameters:
     inPath                                 (string)
     inLatitude                             (number)
     inLongitude                            (number)
     enumerator                             (XPLMLibraryEnumerator_f)
     ref                                    (Any reference value)

]]--

