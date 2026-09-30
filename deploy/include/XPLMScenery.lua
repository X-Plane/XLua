---@meta XPLMScenery

-- The functions, typedefs, enums, and defines in this file are
-- installed into the Lua VM at startup by the host's add_xplm_to_interp()
-- call. Scripts do NOT need to require('XPLMScenery') to access them; this file
-- exists solely as type metadata for lua-language-server / EmmyLua.

--[[
   Copyright 2005-2026 Laminar Research, Sandy Barbour and Ben Supnik All
   rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
]]--

-----------------------------------------------------------------------------
-- XPLMScenery
-----------------------------------------------------------------------------

--[[
   This package contains APIs to interact with X-Plane's scenery system.
]]--

require("XPLMDefs")


-----------------------------------------------------------------------------
-- Terrain Y-Testing
-----------------------------------------------------------------------------

--[[
   The Y-testing API allows you to locate the physical scenery mesh. This
   would be used to place dynamic graphics on top of the ground in a plausible
   way or do physics interactions.
   
   The Y-test API works via probe objects, which are allocated by your plugin
   and used to query terrain. Probe objects exist both to capture which
   algorithm you have requested (see probe types) and also to cache query
   information.
   
   Performance Guidelines
   ----------------------
   
   It is generally faster to use the same probe for nearby points and
   different probes for different points. Try not to allocate more than
   "hundreds" of probes at most. Share probes if you need more. Generally,
   probing operations are expensive, and should be avoided via caching when
   possible.
   
   Y testing returns a location on the terrain, a normal vector, and a
   velocity vector. The normal vector tells you the slope of the terrain at
   that point. The velocity vector tells you if that terrain is moving (and is
   in meters/second). For example, if your Y test hits the aircraft carrier
   deck, this tells you the velocity of that point on the deck.
   
   Note: the Y-testing API is limited to probing the loaded scenery area,
   which is approximately 300x300 km in X-Plane 9. Probes outside this area
   will return the height of a 0 MSL sphere.
]]--

--[[
XPLMProbeType defines the type of terrain probe - each probe has a different algorithm. (Only one
type of probe is provided right now, but future APIs will expose more flexible or powerful or useful
probes.
]]--

---@enum XPLMProbeType
local XPLMProbeType = {
    -- The Y probe gives you the location of the tallest physical scenery along
    -- the Y axis going through the queried point.
    xplm_ProbeY                              = 0,
}
---@class _G
---@field XPLMProbeType XPLMProbeType

--[[
Probe results - possible results from a probe query.
]]--

---@enum XPLMProbeResult
local XPLMProbeResult = {
    -- The probe hit terrain and returned valid values.
    xplm_ProbeHitTerrain                     = 0,
    -- An error in the API call.  Either the probe struct size is bad, the probe
    -- is invalid, or the type is mismatched for the specific query call.
    xplm_ProbeError                          = 1,
    -- The probe call succeeded but there is no terrain under this point (perhaps
    -- it is off the side of the planet?)
    xplm_ProbeMissed                         = 2,
}
---@class _G
---@field XPLMProbeResult XPLMProbeResult

--- An XPLMProbeRef is an opaque handle to a probe, used for querying the terrain.
---@class XPLMProbeRef : userdata
---@field private __XPLMProbeRef_marker any

--- XPLMProbeInfo_t contains the results of a probe call. Make sure to set structSize to the size of the struct before using it.
---@class XPLMProbeInfo_t
---@field structSize integer Size of structure in bytes - always set this before calling the XPLM.
---@field locationX number Resulting X location of the terrain point we hit, in local OpenGL coordinates.
---@field locationY number Resulting Y location of the terrain point we hit, in local OpenGL coordinates.
---@field locationZ number Resulting Z location of the terrain point we hit, in local OpenGL coordinates.
---@field normalX number X component of the normal vector to the terrain we found.
---@field normalY number Y component of the normal vector to the terrain we found.
---@field normalZ number Z component of the normal vector to the terrain we found.
---@field velocityX number X component of the velocity vector of the terrain we found.
---@field velocityY number Y component of the velocity vector of the terrain we found.
---@field velocityZ number Z component of the velocity vector of the terrain we found.
---@field is_wet boolean Tells if the surface we hit is water (otherwise it is land).

---@class _G
--- Creates a new probe object of a given type and returns.
---
---@field XPLMCreateProbe fun(inProbeType: XPLMProbeType): XPLMProbeRef

---@class _G
--- Deallocates an existing probe object.
---
---@field XPLMDestroyProbe fun(inProbe: XPLMProbeRef)

---@class _G
--- Probes the terrain. Pass in the XYZ coordinate of the probe point, a probe object, and an
--- XPLMProbeInfo_t struct that
--- has its structSize member set properly. Other fields are filled in if we hit terrain, and a probe result
--- is returned.
---
---@field XPLMProbeTerrainXYZ fun(inProbe: XPLMProbeRef, inX: number, inY: number, inZ: number, outInfo: XPLMProbeInfo_t): XPLMProbeResult


-----------------------------------------------------------------------------
-- Magnetic Variation
-----------------------------------------------------------------------------

--[[
   Use the magnetic variation (more properly, the "magnetic declination") API
   to find the offset of magnetic north from true north at a given latitude
   and longitude within the simulator.
   
   In the real world, the Earth's magnetic field is irregular, such that true
   north (the direction along a meridian toward the north pole) does not
   necessarily match what a magnetic compass shows as north.
   
   Using this API ensures that you present the same offsets to users as
   X-Plane's built-in instruments.
]]--

---@class _G
--- Returns X-Plane's simulated magnetic variation (declination) at the indication latitude and longitude.
---
---@field XPLMGetMagneticVariation fun(latitude: number, longitude: number): number

---@class _G
--- Converts a heading in degrees relative to true north into a value relative to magnetic north at the user's current location.
---
---@field XPLMDegTrueToDegMagnetic fun(headingDegreesTrue: number): number

---@class _G
--- Converts a heading in degrees relative to magnetic north at the user's current location into a value relative to true north.
---
---@field XPLMDegMagneticToDegTrue fun(headingDegreesMagnetic: number): number


-----------------------------------------------------------------------------
-- Object Drawing
-----------------------------------------------------------------------------

--[[
   The object drawing routines let you load and draw X-Plane OBJ files.
   Objects are loaded by file path and managed via an opaque handle. X-Plane
   naturally reference counts objects, so it is important that you balance
   every successful call to XPLMLoadObject with a call to XPLMUnloadObject!
]]--

--- An XPLMObjectRef is a opaque handle to an .obj file that has been loaded into memory.
---@class XPLMObjectRef : userdata
---@field private __XPLMObjectRef_marker any

--- The XPLMDrawInfo_t structure contains positioning info for one object that is to be drawn. Be sure to set structSize to the size of the structure for future expansion.
---@class XPLMDrawInfo_t
---@field structSize integer Set this to the size of this structure!
---@field x number X location of the object in local coordinates.
---@field y number Y location of the object in local coordinates.
---@field z number Z location of the object in local coordinates.
---@field pitch number Pitch in degres to rotate the object, positive is up.
---@field heading number Heading in local coordinates to rotate the object, clockwise.
---@field roll number Roll to rotate the object.

--- The XPLMDrawInfo_t structure contains positioning info for one object that is to be drawn. Be sure to set structSize to the size of the structure for future expansion.
---@class XPLMDrawInfoDouble_t
---@field structSize integer Set this to the size of this structure!
---@field x number X location of the object in local coordinates.
---@field y number Y location of the object in local coordinates.
---@field z number Z location of the object in local coordinates.
---@field pitch number Pitch in degres to rotate the object, positive is up.
---@field heading number Heading in local coordinates to rotate the object, clockwise.
---@field roll number Roll to rotate the object.

--- You provide this callback when loading an object asynchronously; it will be called once the object is loaded. Your refcon is passed back. The object ref passed in is the newly loaded object (ready for use) or NULL if an error occured. It will not be called more than once per object. If your plugin is disabled, this callback will be delivered as soon as the plugin is re-enabled. If your plugin is unloaded before this callback is ever called, the SDK will release the object handle for you.
---@alias XPLMObjectLoaded_f fun(inObject: XPLMObjectRef, inRefcon: any)

---@class _G
--- This routine loads an OBJ file and returns a handle to it. If X-Plane has already loaded the object, the
--- handle to the existing object is returned. Do not assume you will get the same handle back twice, but do make
--- sure to call unload once for every load to avoid "leaking" objects. The object will be purged from memory when
--- no plugins and no scenery are using it.
---
--- The path for the object must be relative to the X-System base folder. If the path is in the root of the
--- X-System folder you may need to prepend ./ to it; loading objects in the root of the X-System folder is STRONGLY
--- discouraged - your plugin should not dump art resources in the root folder!
---
--- XPLMLoadObject will return NULL if the object cannot be loaded (either because it is not found or the
--- file is misformatted). This routine will load any object that can be used in the X-Plane scenery system.
---
--- It is important that the datarefs an object uses for animation already be registered before you load the
--- object. For this reason it may be necessary to defer object loading until the sim has fully started.
---
---@field XPLMLoadObject fun(inPath: string): XPLMObjectRef

---@class _G
--- This routine loads an object asynchronously; control is returned to you immediately while X-Plane loads
--- the object. The sim will not stop flying while the object loads. For large objects, it may be several
--- seconds before the load finishes.
---
--- You provide a callback function that is called once the load has completed. Note that if the object
--- cannot be loaded, you will not find out until the callback function is called with a NULL object handle.
---
--- There is no way to cancel an asynchronous object load; you must wait for the load to complete and then
--- release the object if it is no longer desired.
---
---@field XPLMLoadObjectAsync fun(inPath: string, inCallback: XPLMObjectLoaded_f, inRefcon: any)

---@class _G
--- This routine marks an object as no longer being used by your plugin. Objects are reference counted: once
--- no plugins are using an object, it is purged from memory. Make sure to call XPLMUnloadObject once for each
--- successful call to XPLMLoadObject.
---
---@field XPLMUnloadObject fun(inObject: XPLMObjectRef)


-----------------------------------------------------------------------------
-- Library Access
-----------------------------------------------------------------------------

--[[
   The library access routines allow you to locate scenery objects via the
   X-Plane library system. Right now library access is only provided for
   objects, allowing plugin-drawn objects to be extended using the library
   system.
]]--

--- An XPLMLibraryEnumerator_f is a callback you provide that is called once for each library element that is located. The returned paths will be relative to the X-System folder.
---@alias XPLMLibraryEnumerator_f fun(inFilePath: string, inRef: any)

---@class _G
--- This routine looks up a virtual path in the library system and returns all matching elements. You
--- provide a callback - one virtual path may match many objects in the library. XPLMLookupObjects returns
--- the number of objects found.
---
--- The latitude and longitude parameters specify the location the object will be used. The library system
--- allows for scenery packages to only provide objects to certain local locations. Only objects that are
--- allowed at the latitude/longitude you provide will be returned.
---
--- The enumerator is fully synchronous: it is called once per matching object, and all calls complete before
--- XPLMLookupObjects returns.
---
---@field XPLMLookupObjects fun(inPath: string, inLatitude: number, inLongitude: number, enumerator: XPLMLibraryEnumerator_f, ref: any): integer

