-- Use require('XPLMWeather') to access these functions.

--[[
   Copyright 2005-2022 Laminar Research, Sandy Barbour and Ben Supnik All
   rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
]]--

-----------------------------------------------------------------------------
-- XPLMWeather
-----------------------------------------------------------------------------

--[[
   This provides access to the X-Plane 12 enhanced weather system.
   
   ALL FUNCTIONS RELATING TO UPDATING THE WEATHER ARE CURRENTLY EXPERIMENTAL,
   FOR EVALUATION.
   
   The API will be kept stable if at all possible during the evaluation
   period. The details of how the data is processed will change over time as
   the weather engine changes, even after the API is stabilised.
]]--

#include "XPLMDefs.h"
require("XPLMDefs")

--[[
   XLuaGetMETARForAirport
   
   Get the last-downloaded METAR report for an airport by ICAO code. Note that
   the actual weather at that airport may have evolved significantly since the
   last downloaded METAR. outMETAR must point to a char buffer of at least 150
   characters. THIS CALL DOES NOT RETURN THE CURRENT WEATHER AT THE AIRPORT,
   and returns an empty string if the system is not in real-weather mode.
   
   This call is not intended to be used per-frame. It should be called only
   during the pre-flight loop callback.
]]--
-- Returns   :  Table { ["outMETAR"] }
-- Parameters:
--   airport_id (string)

--[[
   XLuaGetWeatherAtLocation
   
   Get the current weather conditions at a given location. Note that this does
   not work world-wide, only within the surrounding region. Return true if
   detailed weather (i.e. an airport-specific METAR) was found, false if not.
   In both cases, the structure will contain the best data available.
   
   This call is not intended to be used per-frame. It should be called only
   during the pre-flight loop callback.
]]--
-- Returns   : boolean,  Table { ["out_info"] }
-- Parameters:
--   latitude (number)
--   longitude (number)
--   altitude_m (number)

--[[
   XLuaBeginWeatherUpdate
   
   Inform the simulator that you are starting a batch update of weather
   information. If you are providing multiple weather updates, using this call
   may improve performance by telling the simulator not to update weather
   until you are done.
   
   This call is not intended to be used per-frame.  It should be called only
   during the pre-flight loop callback. You must call XPLMEndWeatherUpdate
   before you return from the callback; XPLMBeginWeatherUpdate in one callback
   and XPLMEndWeatherUpdate in a later callback, even within the same frame,
   is not permitted.
]]--
-- Returns   : Nothing.
-- Parameters:
--   None.

--[[
   XLuaEndWeatherUpdate
   
   Inform the simulator that you are ending a batch update of weather
   information. If you have called XPLMBeginWeatherUpdate, you MUST call
   XPLMEndWeatherUpdate before exiting your callback otherwise any accumulated
   weather data will be discarded.
   
   When using incremental mode, any changes made are applied to your existing
   data. This makes it possible to only update a fraction of your weather data
   at any one time. When not using incremental mode, ALL reports previously
   passed by your plugin are erased before applying new data.
   
   When using any of these 'weather set' APIs, the normal mode of operation is
   that you are setting the weather in the near future. Currently this is
   somewhere between one and two minutes but do not rely on this remaining the
   same.
   
   Setting future weather ensures that there is no sudden jump in weather
   conditions when you make a change mid-cycle. In some situations, notably
   for an initial setup, you may want to ensure that the weather is changed
   instantly. To do this, set 'updateImmediately' as true.
   
   This call is not intended to be used per-frame. It should be called only
   during the pre-flight loop callback.
]]--
-- Returns   : Nothing.
-- Parameters:
--   isIncremental (boolean)
--   updateImmediately (boolean)

--[[
   XLuaSetWeatherAtLocation
   
   Set the current weather conditions at a given location. Please see the
   notes on individual fields in XPLMSetWeatherAtAirport, and notes on timing
   in XPLMEndWeatherUpdate.
   
   This call is not intended to be used per-frame. It should be called only
   during the pre-flight loop callback.
]]--
-- Returns   : Nothing.
-- Parameters:
--   latitude (number)
--   longitude (number)
--   altitude_m (number)
--   in_info (XPLMWeatherInfo_t)

--[[
   XLuaEraseWeatherAtLocation
   
   Erase weather conditions set by your plugin at a given location. You must
   give exactly the same coordinates that you used to create a weather record
   at this point. It does NOT mean 'create clear weather at this location'.
   
   This call is not intended to be used per-frame. It should be called only
   during the pre-flight loop callback.
]]--
-- Returns   : Nothing.
-- Parameters:
--   latitude (number)
--   longitude (number)

--[[
   XLuaSetWeatherAtAirport
   
   Set the current weather conditions at a given airport. Unlike
   XPLMSetWeatherAtLocation, this call will replace any existing weather
   records for that airport from other sources (i.e. downloaded METARs)
   instead of being used as just another weather sample.
   
   Some notes on individual fields:
     - pressure_alt should be QNH as reported by a station at the ground
       altitude given, or 0 if you are passing sealevel pressure in
       'pressure_sl' instead.
     - pressure_sl is ignored if pressure_alt is given.
     - wind_dir_alt, wind_spd_alt, turbulence_alt, wave_speed, wave_length are
       derived from other data and are UNUSED when setting weather.
     - Temperatures can be given either as a single temperature at the ground
       altitude (temperature_alt) OR, if the struct is V2 or higher, as an
       array of temperatures aloft (temp_layers). If you pass a value for
       temperature_alt higher than -273.15 (absolute zero), that will be used
       with the altitude value to calculate an offset from ISA temperature at
       all altitudes. Any layer in temp_layers for which you set the
       temperature higher than -273.15 (absolute zero) will use that
       temperature and all others will use the existing value for the
       location, or the calculated values from temperature_alt if you also
       passed that. It is advised to use a lower value than exactly -273.15 to
       avoid floating-point precision errors. These calculated temperatures
       during a read are also affected by the troposphere altitude and
       temperature, and the vertical radius of effect. Do not expect to get
       the exact values you set.
     - The same rules apply to dewpoint temperatures; either a single value at
       ground level in 'dewpoint_alt', or per-layer values in 'dewp_layers'.
     - The troposphere altitude and temperature will be derived from existing
       data if you pass 0 or lower for troposphere_alt. Both altitude and
       temperature may be clamped to internally-defined ranges.
     - When setting both temperature and dewpoint from a single value
       (temperature_alt/dewpoint_alt), the rest of the atmosphere will be
       graded to fit between the given values and the troposphere.
   
   This call is not intended to be used per-frame. It should be called only
   during the pre-flight loop callback.
]]--
-- Returns   : Nothing.
-- Parameters:
--   airport_id (string)
--   in_info (XPLMWeatherInfo_t)

--[[
   XLuaEraseWeatherAtAirport
   
   Erase the current weather conditions set by your plugin at a given airport,
   allowing records from other sources to be used. It does NOT mean 'create
   clear weather at this airport'.
   
   This call is not intended to be used per-frame. It should be called only
   during the pre-flight loop callback.
]]--
-- Returns   : Nothing.
-- Parameters:
--   airport_id (string)

