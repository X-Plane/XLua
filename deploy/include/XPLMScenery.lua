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
---@field structSize integer
---@field locationX number
---@field locationY number
---@field locationZ number
---@field normalX number
---@field normalY number
---@field normalZ number
---@field velocityX number
---@field velocityY number
---@field velocityZ number
---@field is_wet boolean

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

--- An XPLMObjectRef is a opaque handle to an .obj file that has been loaded into memory.
---@class XPLMObjectRef : userdata
---@field private __XPLMObjectRef_marker any

--- The XPLMDrawInfo_t structure contains positioning info for one object that is to be drawn. Be sure to set structSize to the size of the structure for future expansion.
---@class XPLMDrawInfo_t
---@field structSize integer
---@field x number
---@field y number
---@field z number
---@field pitch number
---@field heading number
---@field roll number

--- The XPLMDrawInfo_t structure contains positioning info for one object that is to be drawn. Be sure to set structSize to the size of the structure for future expansion.
---@class XPLMDrawInfoDouble_t
---@field structSize integer
---@field x number
---@field y number
---@field z number
---@field pitch number
---@field heading number
---@field roll number

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

