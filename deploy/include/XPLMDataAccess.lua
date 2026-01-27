-- Use require('XPLMDataAccess') to access these functions.

--[[
   Copyright 2005-2022 Laminar Research, Sandy Barbour and Ben Supnik All
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

#include "XPLMDefs.h"
require("XPLMDefs")

--[[
This is an enumeration that defines the type of the data behind a data reference.
This allows you to sanity check that the data type matches what you expect.
But for the most part, you will know the type of data you are expecting from
the online documentation.

Data types each take a bit field; it is legal to have a single dataref be more
than one type of data.  Whe this happens, you can pick any matching get/set API.
]]--

XPLMDataTypeID = {
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

--[[
   XLuaCountDataRefs
   
   Returns the total number of datarefs that have been registered in X-Plane.
]]--
-- Returns   : integer
-- Parameters:
--   None.

--[[
   XLuaGetDataRefsByIndex
   
   Given an offset and count, this function will return an array of
   XPLMDataRefs in that range.  The offset/count idiom is useful for things
   like pagination.
]]--
-- Returns   :  Table { ["outDataRefs"] }
-- Parameters:
--   offset (integer)
--   count (integer)

--[[
   XLuaGetDataRefInfo
   
   Give a data ref, this routine returns a populated struct containing the
   available information about the dataref.
]]--
-- Returns   :  Table { ["outInfo"] }
-- Parameters:
--   inDataRef (XPLMDataRef)

--[[
   XLuaFindDataRef
   
   Given a C-style string that names the dataref, this routine looks up the
   actual opaque XPLMDataRef that you use to read and write the data. The
   string names for datarefs are published on the X-Plane SDK web site.
   
   This function returns NULL if the dataref cannot be found.
   
   NOTE: this function is relatively expensive; save the XPLMDataRef this
   function returns for future use. Do not look up your dataref by string
   every time you need to read or write it.
]]--
-- Returns   : userdata<XPLMDataRef>
-- Parameters:
--   inDataRefName (string)

--[[
   XLuaCanWriteDataRef
   
   Given a dataref, this routine returns true if you can successfully set the
   data, false otherwise. Some datarefs are read-only.
   
   NOTE: even if a dataref is marked writable, it may not act writable.  This
   can happen for datarefs that X-Plane writes to on every frame of
   simulation.  In some cases, the dataref is writable but you have to set a
   separate "override" dataref to 1 to stop X-Plane from writing it.
]]--
-- Returns   : boolean
-- Parameters:
--   inDataRef (XPLMDataRef)

--[[
   XLuaIsDataRefGood
   
   This function returns true if the passed in handle is a valid dataref that
   is not orphaned.
   
   Note: there is normally no need to call this function; datarefs returned by
   XPLMFindDataRef remain valid (but possibly orphaned) unless there is a
   complete plugin reload (in which case your plugin is reloaded anyway).
   Orphaned datarefs can be safely read and return 0. Therefore you never need
   to call XPLMIsDataRefGood to 'check' the safety of a dataref.
   (XPLMIsDataRefGood performs some slow checking of the handle validity, so
   it has a performance cost.)
]]--
-- Returns   : boolean
-- Parameters:
--   inDataRef (XPLMDataRef)

--[[
   XLuaGetDataRefTypes
   
   This routine returns the types of the dataref for accessor use. If a
   dataref is available in multiple data types, the bit-wise OR of these types
   will be returned.
]]--
-- Returns   : integer
-- Parameters:
--   inDataRef (XPLMDataRef)

--[[
   XLuaGetDatai
   
   Read an integer dataref and return its value. The return value is the
   dataref value or 0 if the dataref is NULL or the plugin is disabled.
]]--
-- Returns   : integer
-- Parameters:
--   inDataRef (XPLMDataRef)

--[[
   XLuaSetDatai
   
   Write a new value to an integer dataref. This routine is a no-op if the
   plugin publishing the dataref is disabled, the dataref is NULL, or the
   dataref is not writable.
]]--
-- Returns   : Nothing.
-- Parameters:
--   inDataRef (XPLMDataRef)
--   inValue (integer)

--[[
   XLuaGetDataf
   
   Read a single precision floating point dataref and return its value. The
   return value is the dataref value or 0.0 if the dataref is NULL or the
   plugin is disabled.
]]--
-- Returns   : number
-- Parameters:
--   inDataRef (XPLMDataRef)

--[[
   XLuaSetDataf
   
   Write a new value to a single precision floating point dataref. This
   routine is a no-op if the plugin publishing the dataref is disabled, the
   dataref is NULL, or the dataref is not writable.
]]--
-- Returns   : Nothing.
-- Parameters:
--   inDataRef (XPLMDataRef)
--   inValue (number)

--[[
   XLuaGetDatad
   
   Read a double precision floating point dataref and return its value. The
   return value is the dataref value or 0.0 if the dataref is NULL or the
   plugin is disabled.
]]--
-- Returns   : number
-- Parameters:
--   inDataRef (XPLMDataRef)

--[[
   XLuaSetDatad
   
   Write a new value to a double precision floating point dataref. This
   routine is a no-op if the plugin publishing the dataref is disabled, the
   dataref is NULL, or the dataref is not writable.
]]--
-- Returns   : Nothing.
-- Parameters:
--   inDataRef (XPLMDataRef)
--   inValue (number)

--[[
   XLuaGetDatavi
   
   Read a part of an integer array dataref. If you pass NULL for outValues,
   the routine will return the size of the array, ignoring inOffset and inMax.
   
   If outValues is not NULL, then up to inMax values are copied from the
   dataref into outValues, starting at inOffset in the dataref. If inMax +
   inOffset is larger than the size of the dataref, less than inMax values
   will be copied. The number of values copied is returned.
   
   Note: the semantics of array datarefs are entirely implemented by the
   plugin (or X-Plane) that provides the dataref, not the SDK itself; the
   above description is how these datarefs are intended to work, but a rogue
   plugin may have different behavior.
]]--
-- Returns   : integer,  Table { ["outValues"] }
-- Parameters:
--   inDataRef (XPLMDataRef)
--   inOffset (integer)
--   inMax (integer)

--[[
   XLuaSetDatavi
   
   Write part or all of an integer array dataref. The values passed by
   inValues are written into the dataref starting at inOffset. Up to inCount
   values are written; however if the values would write past the end of the
   dataref array, then fewer values are written.
   
   Note: the semantics of array datarefs are entirely implemented by the
   plugin (or X-Plane) that provides the dataref, not the SDK itself; the
   above description is how these datarefs are intended to work, but a rogue
   plugin may have different behavior.
]]--
-- Returns   : Nothing.
-- Parameters:
--   inDataRef (XPLMDataRef)
--   inValues (array<integer|int>[])
--   inoffset (integer)
--   inCount (integer)

--[[
   XLuaGetDatavf
   
   Read a part of a single precision floating point array dataref. If you pass
   NULL for outValues, the routine will return the size of the array, ignoring
   inOffset and inMax.
   
   If outValues is not NULL, then up to inMax values are copied from the
   dataref into outValues, starting at inOffset in the dataref. If inMax +
   inOffset is larger than the size of the dataref, less than inMax values
   will be copied. The number of values copied is returned.
   
   Note: the semantics of array datarefs are entirely implemented by the
   plugin (or X-Plane) that provides the dataref, not the SDK itself; the
   above description is how these datarefs are intended to work, but a rogue
   plugin may have different behavior.
]]--
-- Returns   : integer,  Table { ["outValues"] }
-- Parameters:
--   inDataRef (XPLMDataRef)
--   inOffset (integer)
--   inMax (integer)

--[[
   XLuaSetDatavf
   
   Write part or all of a single precision floating point array dataref. The
   values passed by inValues are written into the dataref starting at
   inOffset. Up to inCount values are written; however if the values would
   write past the end of the dataref array, then fewer values are written.
   
   Note: the semantics of array datarefs are entirely implemented by the
   plugin (or X-Plane) that provides the dataref, not the SDK itself; the
   above description is how these datarefs are intended to work, but a rogue
   plugin may have different behavior.
]]--
-- Returns   : Nothing.
-- Parameters:
--   inDataRef (XPLMDataRef)
--   inValues (array<number|float>[])
--   inoffset (integer)
--   inCount (integer)

--[[
   XLuaGetDatab
   
   Read a part of a byte array dataref. If you pass NULL for outValues, the
   routine will return the size of the array, ignoring inOffset and inMax.
   
   If outValues is not NULL, then up to inMax values are copied from the
   dataref into outValues, starting at inOffset in the dataref. If inMax +
   inOffset is larger than the size of the dataref, less than inMax values
   will be copied. The number of values copied is returned.
   
   Note: the semantics of array datarefs are entirely implemented by the
   plugin (or X-Plane) that provides the dataref, not the SDK itself; the
   above description is how these datarefs are intended to work, but a rogue
   plugin may have different behavior.
]]--
-- Returns   : integer,  Table { ["outValue"] }
-- Parameters:
--   inDataRef (XPLMDataRef)
--   inOffset (integer)
--   inMaxBytes (integer)

--[[
   XLuaSetDatab
   
   Write part or all of a byte array dataref. The values passed by inValues
   are written into the dataref starting at inOffset. Up to inCount values are
   written; however if the values would write "off the end" of the dataref
   array, then fewer values are written.
   
   Note: the semantics of array datarefs are entirely implemented by the
   plugin (or X-Plane) that provides the dataref, not the SDK itself; the
   above description is how these datarefs are intended to work, but a rogue
   plugin may have different behavior.
]]--
-- Returns   : Nothing.
-- Parameters:
--   inDataRef (XPLMDataRef)
--   inValue (array<byte|byte>[])
--   inOffset (integer)
--   inLength (integer)

--[[
   XLuaRegisterDataAccessor
   
   This routine creates a new item of data that can be read and written. Pass
   in the data's full name for searching, the type(s) of the data for
   accessing, and whether the data can be written to. For each data type you
   support, pass in a read accessor function and a write accessor function if
   necessary. Pass NULL for data types you do not support or write accessors
   if you are read-only.
   
   You are returned a dataref for the new item of data created. You can use
   this dataref to unregister your data later or read or write from it.
]]--
-- Returns   : userdata<XPLMDataRef>
-- Parameters:
--   inDataName (string)
--   inDataType (integer)
--   inIsWritable (boolean)
--   inReadInt (XPLMGetDatai_f)
--   inWriteInt (XPLMSetDatai_f)
--   inReadFloat (XPLMGetDataf_f)
--   inWriteFloat (XPLMSetDataf_f)
--   inReadDouble (XPLMGetDatad_f)
--   inWriteDouble (XPLMSetDatad_f)
--   inReadIntArray (XPLMGetDatavi_f)
--   inWriteIntArray (XPLMSetDatavi_f)
--   inReadFloatArray (XPLMGetDatavf_f)
--   inWriteFloatArray (XPLMSetDatavf_f)
--   inReadData (XPLMGetDatab_f)
--   inWriteData (XPLMSetDatab_f)
--   inReadRefcon (Any reference value)
--   inWriteRefcon (Any reference value)

--[[
   XLuaUnregisterDataAccessor
   
   Use this routine to unregister any data accessors you may have registered.
   You unregister a dataref by the XPLMDataRef you get back from registration.
   Once you unregister a dataref, your function pointer will not be called
   anymore.
]]--
-- Returns   : Nothing.
-- Parameters:
--   inDataRef (XPLMDataRef)

