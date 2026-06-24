---@meta XPLMDataAccess

-- The functions, typedefs, enums, and defines in this file are
-- installed into the Lua VM at startup by the host's add_xplm_to_interp()
-- call. Scripts do NOT need to require('XPLMDataAccess') to access them; this file
-- exists solely as type metadata for lua-language-server / EmmyLua.

--[[
   Copyright 2005-2026 Laminar Research, Sandy Barbour and Ben Supnik All
   rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
]]--

-----------------------------------------------------------------------------
-- XPLMDataAccess
-----------------------------------------------------------------------------

--[[
   The data access API gives you a generic, flexible, high performance way to
   read and write data to and from X-Plane and other plug-ins. For example,
   this API allows you to read and set the nav radios, get the plane location,
   determine the current effective graphics frame rate, etc.
   
   The data access APIs are the way that you read and write data from the sim
   as well as other plugins.
   
   The API works using opaque data references. A data reference is a source of
   data; you do not know where it comes from, but once you have it you can
   read the data quickly and possibly write it.
   
   Dataref Lookup
   --------------
   
   Data references are identified by verbose, permanent string names; by
   convention these names use path separators to form a hierarchy of datarefs,
   e.g. (sim/cockpit/radios/nav1_freq_hz). The actual opaque numeric value of
   the data reference, as returned by the XPLM API, is implementation defined
   and changes each time X-Plane is launched; therefore you need to look up
   the dataref by path every time your plugin runs.
   
   The task of looking up a data reference is relatively expensive; look up
   your data references once based on the verbose path strings, and save the
   opaque data reference value for the duration of your plugin's operation.
   Reading and writing data references is relatively fast (the cost is
   equivalent to two function calls through function pointers).
   
   X-Plane publishes many thousands of datarefs; a complete list may be found
   in the reference section of the SDK online documentation (from the SDK home
   page, choose Documentation) and the Resources/plugins/DataRefs.txt file.
   
   Dataref Types
   -------------
   
   A note on typing: you must know the correct data type to read and write.
   APIs are provided for reading and writing data in a number of ways. You can
   also double check the data type for a dataref. Automatic type conversion is
   not done for you.
   
   Dataref types are a set, e.g. a dataref can be more than one type.  When
   this happens, you can choose which API you want to use to read.  For
   example, it is not uncommon for a dataref to be available both as float and
   double.  This means you can use either XPLMGetDatad or XPLMGetDataf to read
   it.
   
   Creating New Datarefs
   ---------------------
   
   X-Plane provides datarefs that come with the sim, but plugins can also
   create their own datarefs.  A plugin creates a dataref by registering
   function callbacks to read and write the dataref.  The XPLM will call your
   plugin each time some other plugin (or X-Plane) tries to read or write the
   dataref.  You must provide a read (and optional write) callback for each
   data type you support.
   
   A note for plugins sharing data with other plugins: the load order of
   plugins is not guaranteed. To make sure that every plugin publishing data
   has published their data references before other plugins try to subscribe,
   publish your data references in your start routine but resolve others'
   datarefs the first time your 'enable' routine is called, or the first time
   they are needed in code.
   
   When a plugin that created a dataref is unloaded, it becomes "orphaned". 
   The dataref handle continues to be usable, but the dataref is not writable,
   and reading it will always return 0 (or 0 items for arrays).  If the plugin
   is reloaded and re-registers the dataref, the handle becomes un-orphaned
   and works again.
   
   Introspection: Finding All Datarefs
   -----------------------------------
   
   In the XPLM400 API, it is possible for a plugin to iterate the entire set
   of datarefs. This functionality is meant only for "tool" add-ons, like
   dataref browsers; normally all add-ons  should find the dataref they want
   by name.
   
   Because datarefs are never destroyed during a run of the simulator (they
   are orphaned when their providing plugin goes away until a new one
   re-registers the dataref), the set of  datarefs for a given run of X-Plane
   can be enumerated by index. A plugin that wants to find all new datarefs
   can use XPLMCountDataRefs to find the number of datarefs and iterate only 
   the ones with higher index numbers than the last iteration.
   
   Plugins can also receive notifications when datarefs are registered; see
   the XPLMPlugin feature-enable API for more details.    
]]--

require("XPLMDefs")

--- A dataref is an opaque handle to data provided by the simulator or another plugin. It uniquely identifies one variable (or array of variables) over the lifetime of your plugin. You never hard code these values; you always get them from XPLMFindDataRef.
---@class XPLMDataRef : userdata
---@field private __XPLMDataRef_marker any

--[[
This is an enumeration that defines the type of the data behind a data reference.
This allows you to sanity check that the data type matches what you expect.
But for the most part, you will know the type of data you are expecting from
the online documentation.

Data types each take a bit field; it is legal to have a single dataref be more
than one type of data.  Whe this happens, you can pick any matching get/set API.
]]--

---@enum XPLMDataTypeID
local XPLMDataTypeID = {
    -- Data of a type the current XPLM doesn't do.
    xplmType_Unknown                         = 0,
    -- A single 4-byte integer, native endian.
    xplmType_Int                             = 1,
    -- A single 4-byte float, native endian.
    xplmType_Float                           = 2,
    -- A single 8-byte double, native endian.
    xplmType_Double                          = 4,
    -- An array of 4-byte floats, native endian.
    xplmType_FloatArray                      = 8,
    -- An array of 4-byte integers, native endian.
    xplmType_IntArray                        = 16,
    -- A variable block of data.
    xplmType_Data                            = 32,
}
---@class _G
---@field XPLMDataTypeID XPLMDataTypeID

--- The XPLMDataRefInfo_t structure contains all of the information about a single data ref. The structure can be expanded in future SDK APIs to include more features. Always set the structSize member to the size of your struct in bytes!
---@class XPLMDataRefInfo_t
---@field structSize integer Used to inform XPLMGetDatarefInfo() of the SDK version you compiled against; should always be set to sizeof(XPLMDataRefInfo_t)
---@field name string The full name/path of the data ref
---@field type XPLMDataTypeID
---@field writable boolean TRUE if the data ref permits writing to it. FALSE if it's read-only.
---@field owner XPLMPluginID The handle to the plugin that registered this dataref.

---@class _G
--- Returns the total number of datarefs that have been registered in X-Plane.
---
---@field XPLMCountDataRefs fun(): integer

---@class _G
--- Given an offset and count, this function will return an array of XPLMDataRefs in that range.
--- The offset/count idiom is useful for things like pagination.
---
---@field XPLMGetDataRefsByIndex fun(offset: integer, count: integer): { outDataRefs: XPLMDataRef[] }

---@class _G
--- Give a data ref, this routine returns a populated struct containing the available information about the dataref.
---
---@field XPLMGetDataRefInfo fun(inDataRef: XPLMDataRef): { outInfo: XPLMDataRefInfo_t }

---@class _G
--- Given a C-style string that names the dataref, this routine looks up
--- the actual opaque XPLMDataRef that you use to read and write the data.
--- The string names for datarefs are published on the X-Plane SDK web site.
---
--- This function returns NULL if the dataref cannot be found.
---
--- NOTE: this function is relatively expensive; save the XPLMDataRef this
--- function returns for future use. Do not look up your dataref by string
--- every time you need to read or write it.
---
---@field XPLMFindDataRef fun(inDataRefName: string): XPLMDataRef

---@class _G
--- Given a dataref, this routine returns true if you can successfully set
--- the data, false otherwise. Some datarefs are read-only.
---
--- NOTE: even if a dataref is marked writable, it may not act writable.  This can happen for
--- datarefs that X-Plane writes to on every frame of simulation.  In some cases, the dataref
--- is writable but you have to set a separate "override" dataref to 1 to stop X-Plane from
--- writing it.
---
---@field XPLMCanWriteDataRef fun(inDataRef: XPLMDataRef): boolean

---@class _G
--- This function returns true if the passed in handle is a valid dataref that is not orphaned.
---
--- Note: there is normally no need to call this function; datarefs returned by XPLMFindDataRef
--- remain valid (but possibly orphaned) unless there is a complete plugin reload (in which case
--- your plugin is reloaded anyway). Orphaned datarefs can be safely read and return 0. Therefore
--- you never need to call XPLMIsDataRefGood to 'check' the safety of a dataref. (XPLMIsDataRefGood
--- performs some slow checking of the handle validity, so it has a performance cost.)
---
---@field XPLMIsDataRefGood fun(inDataRef: XPLMDataRef): boolean

---@class _G
--- This routine returns the types of the dataref for accessor use. If a dataref
--- is available in multiple data types, the bit-wise OR of these types will be returned.
---
---@field XPLMGetDataRefTypes fun(inDataRef: XPLMDataRef): XPLMDataTypeID

---@class _G
--- Read an integer dataref and return its value.
--- The return value is the dataref value or 0 if the dataref is NULL or the plugin is disabled.
---
---@field XPLMGetDatai fun(inDataRef: XPLMDataRef): integer

---@class _G
--- Write a new value to an integer dataref.
--- This routine is a no-op if the plugin publishing the dataref is disabled, the dataref is NULL, or the dataref is not writable.
---
---@field XPLMSetDatai fun(inDataRef: XPLMDataRef, inValue: integer)

---@class _G
--- Read a single precision floating point dataref and return its value.
--- The return value is the dataref value or 0.0 if the dataref is NULL or the plugin is disabled.
---
---@field XPLMGetDataf fun(inDataRef: XPLMDataRef): number

---@class _G
--- Write a new value to a single precision floating point dataref.
--- This routine is a no-op if the plugin publishing the dataref is disabled, the dataref is NULL, or the
--- dataref is not writable.
---
---@field XPLMSetDataf fun(inDataRef: XPLMDataRef, inValue: number)

---@class _G
--- Read a double precision floating point dataref and return its value.
--- The return value is the dataref value or 0.0 if the dataref is NULL or the plugin is disabled.
---
---@field XPLMGetDatad fun(inDataRef: XPLMDataRef): number

---@class _G
--- Write a new value to a double precision floating point dataref.
--- This routine is a no-op if the plugin publishing the dataref is disabled, the dataref is NULL, or the
--- dataref is not writable.
---
---@field XPLMSetDatad fun(inDataRef: XPLMDataRef, inValue: number)

---@class _G
--- Read a part of an integer array dataref. If you pass NULL for outValues, the routine will return the
--- size of the array, ignoring inOffset and inMax.
---
--- If outValues is not NULL, then up to inMax values are copied from the dataref into outValues, starting
--- at inOffset in the dataref. If inMax + inOffset is larger than the size of the dataref, less than inMax
--- values will be copied. The number of values copied is returned.
---
--- Note: the semantics of array datarefs are entirely implemented by the plugin (or X-Plane) that provides
--- the dataref, not the SDK itself; the above description is how these datarefs are intended to work, but a
--- rogue plugin may have different behavior.
---
---@field XPLMGetDatavi fun(inDataRef: XPLMDataRef, inOffset: integer, inMax: integer): integer, { outValues: integer[] }

---@class _G
--- Write part or all of an integer array dataref. The values passed by inValues are written into the
--- dataref starting at inOffset. Up to inCount values are written; however if the values would write past
--- the end of the dataref array, then fewer values are written.
---
--- Note: the semantics of array datarefs are entirely implemented by the plugin (or X-Plane) that provides
--- the dataref, not the SDK itself; the above description is how these datarefs are intended to work, but a
--- rogue plugin may have different behavior.
---
---@field XPLMSetDatavi fun(inDataRef: XPLMDataRef, inValues: integer[], inoffset: integer, inCount: integer)

---@class _G
--- Read a part of a single precision floating point array dataref. If you pass NULL for outValues, the
--- routine will return the size of the array, ignoring inOffset and inMax.
---
--- If outValues is not NULL, then up to inMax values are copied from the dataref into outValues, starting
--- at inOffset in the dataref.
--- If inMax + inOffset is larger than the size of the dataref, less than inMax values will be copied. The
--- number of values copied is returned.
---
--- Note: the semantics of array datarefs are entirely implemented by the plugin (or X-Plane) that provides
--- the dataref, not the SDK
--- itself; the above description is how these datarefs are intended to work, but a rogue plugin may have
--- different behavior.
---
---@field XPLMGetDatavf fun(inDataRef: XPLMDataRef, inOffset: integer, inMax: integer): integer, { outValues: number[] }

---@class _G
--- Write part or all of a single precision floating point array dataref. The values passed by inValues are
--- written into the dataref starting at
--- inOffset. Up to inCount values are written; however if the values would write past the end of the
--- dataref array, then fewer values are written.
---
--- Note: the semantics of array datarefs are entirely implemented by the plugin (or X-Plane) that provides
--- the dataref, not the SDK
--- itself; the above description is how these datarefs are intended to work, but a rogue plugin may have
--- different behavior.
---
---@field XPLMSetDatavf fun(inDataRef: XPLMDataRef, inValues: number[], inoffset: integer, inCount: integer)

---@class _G
--- Read a part of a byte array dataref. If you pass NULL for outValues, the routine will return the size of
--- the array, ignoring inOffset and inMax.
---
--- If outValues is not NULL, then up to inMax values are copied from the dataref into outValues, starting
--- at inOffset in the dataref.
--- If inMax + inOffset is larger than the size of the dataref, less than inMax values will be copied. The
--- number of values copied is returned.
---
--- Note: the semantics of array datarefs are entirely implemented by the plugin (or X-Plane) that provides
--- the dataref, not the SDK
--- itself; the above description is how these datarefs are intended to work, but a rogue plugin may have
--- different behavior.
---
---@field XPLMGetDatab fun(inDataRef: XPLMDataRef, inOffset: integer, inMaxBytes: integer): integer, { outValue: integer[] }

---@class _G
--- Write part or all of a byte array dataref. The values passed by inValues are written into the dataref
--- starting at
--- inOffset. Up to inCount values are written; however if the values would write "off the end" of the
--- dataref array, then fewer values are written.
---
--- Note: the semantics of array datarefs are entirely implemented by the plugin (or X-Plane) that provides
--- the dataref, not the SDK
--- itself; the above description is how these datarefs are intended to work, but a rogue plugin may have
--- different behavior.
---
---@field XPLMSetDatab fun(inDataRef: XPLMDataRef, inValue: integer[], inOffset: integer, inLength: integer)

--- Data provider function pointers. These define the function pointers you provide to get or set data. Note that you are passed a generic pointer for each one. This is the same pointer you pass in your register routine; you can use it to locate plugin variables, etc. The semantics of your callbacks are the same as the dataref accessors above - basically routines like XPLMGetDatai are just pass-throughs from a caller to your plugin. Be particularly mindful in implementing array dataref read-write accessors; you are responsible for avoiding overruns, supporting offset read/writes, and handling a read with a NULL buffer.
---@alias XPLMGetDatai_f fun(inRefcon: any): integer

---@alias XPLMSetDatai_f fun(inRefcon: any, inValue: integer)

---@alias XPLMGetDataf_f fun(inRefcon: any): number

---@alias XPLMSetDataf_f fun(inRefcon: any, inValue: number)

---@alias XPLMGetDatad_f fun(inRefcon: any): number

---@alias XPLMSetDatad_f fun(inRefcon: any, inValue: number)

---@alias XPLMGetDatavi_f fun(inRefcon: any, outValues: integer[], inOffset: integer, inMax: integer): integer

---@alias XPLMSetDatavi_f fun(inRefcon: any, inValues: integer[], inOffset: integer, inCount: integer)

---@alias XPLMGetDatavf_f fun(inRefcon: any, outValues: number[], inOffset: integer, inMax: integer): integer

---@alias XPLMSetDatavf_f fun(inRefcon: any, inValues: number[], inOffset: integer, inCount: integer)

---@alias XPLMGetDatab_f fun(inRefcon: any, outValue: integer[], inOffset: integer, inMaxLength: integer): integer

---@alias XPLMSetDatab_f fun(inRefcon: any, inValue: integer[], inOffset: integer, inLength: integer)

---@class _G
--- This routine creates a new item of data that can be read and written. Pass in
--- the data's full name for searching, the type(s) of the data for accessing, and whether
--- the data can be written to. For each data type you support, pass in a read accessor
--- function and a write accessor function if necessary. Pass NULL for data types you
--- do not support or write accessors if you are read-only.
---
--- You are returned a dataref for the new item of data created. You can use this
--- dataref to unregister your data later or read or write from it.
---
---@field XPLMRegisterDataAccessor fun(inDataName: string, inDataType: XPLMDataTypeID, inIsWritable: boolean, inReadInt: XPLMGetDatai_f, inWriteInt: XPLMSetDatai_f, inReadFloat: XPLMGetDataf_f, inWriteFloat: XPLMSetDataf_f, inReadDouble: XPLMGetDatad_f, inWriteDouble: XPLMSetDatad_f, inReadIntArray: XPLMGetDatavi_f, inWriteIntArray: XPLMSetDatavi_f, inReadFloatArray: XPLMGetDatavf_f, inWriteFloatArray: XPLMSetDatavf_f, inReadData: XPLMGetDatab_f, inWriteData: XPLMSetDatab_f, inReadRefcon: any, inWriteRefcon: any): XPLMDataRef

---@class _G
--- Use this routine to unregister any data accessors you may have registered.
--- You unregister a dataref by the XPLMDataRef you get back from registration.
--- Once you unregister a dataref, your function pointer will not be called anymore.
---
---@field XPLMUnregisterDataAccessor fun(inDataRef: XPLMDataRef)

