---@meta XPLMWeather

-- The functions, typedefs, enums, and defines in this file are
-- installed into the Lua VM at startup by the host's add_xplm_to_interp()
-- call. Scripts do NOT need to require('XPLMWeather') to access them; this file
-- exists solely as type metadata for lua-language-server / EmmyLua.

--[[
   Copyright 2005-2026 Laminar Research, Sandy Barbour and Ben Supnik All
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

require("XPLMDefs")

---@class XPLMWeatherInfoWinds_t
---@field alt_msl number
---@field speed number
---@field direction number
---@field gust_speed number
---@field shear number
---@field turbulence number

---@class XPLMWeatherInfoClouds_t
---@field cloud_type number
---@field coverage number
---@field alt_top number
---@field alt_base number

---@class _G
--- The number of wind layers that are expected in the latest version of XPLMWeatherInfo_t .
---
---@field XPLM_NUM_WIND_LAYERS integer

---@class _G
--- The number of cloud layers that are expected in the latest version of XPLMWeatherInfo_t .
---
---@field XPLM_NUM_CLOUD_LAYERS integer

---@class _G
--- The number of temperature layers that are expected in the latest version of XPLMWeatherInfo_t .
---
---@field XPLM_NUM_TEMPERATURE_LAYERS integer

---@class _G
--- Use this value to designate a wind layer as undefined when setting.
---
---@field XPLM_WIND_UNDEFINED_LAYER integer

---@class _G
--- Use this value to designate a temperature-related layer as undefined when setting.
---
---@field XPLM_TEMP_UNDEFINED_LAYER integer

---@class _G
--- Default radius of weather data points set using XPLMSetWeatherAtLocation and XPLMSetWeatherAtAirport.
---
---@field XPLM_DEFAULT_WXR_RADIUS_NM integer

---@class _G
--- Default vertical limit of effect of weather data points set using XPLMSetWeatherAtLocation and XPLMSetWeatherAtAirport.
---
---@field XPLM_DEFAULT_WXR_LIMIT_MSL_FT integer

--- Basic weather conditions at a specific point. To specify exactly what data you intend to send or receive, it is required to set the structSize appropriately. Version 2 data starts at "temp_layers".
---@class XPLMWeatherInfo_t
---@field structSize integer
---@field temperature_alt number
---@field dewpoint_alt number
---@field pressure_alt number
---@field precip_rate_alt number
---@field wind_dir_alt number
---@field wind_spd_alt number
---@field turbulence_alt number
---@field wave_height number
---@field wave_length number
---@field wave_dir integer
---@field wave_speed number
---@field visibility number
---@field precip_rate number
---@field thermal_climb number
---@field pressure_sl number
---@field wind_layers XPLMWeatherInfoWinds_t[]
---@field cloud_layers XPLMWeatherInfoClouds_t[]
---@field temp_layers number[]
---@field dewp_layers number[]
---@field troposphere_alt number
---@field troposphere_temp number
---@field age number
---@field radius_nm number
---@field max_altitude_msl_ft number
---@field snow_coverage_pct number

---@class _G
--- Get the last-downloaded METAR report for an airport by ICAO code. Note that the actual weather at that airport may have evolved
--- significantly since the last downloaded METAR. outMETAR must point to a char buffer of at least 150 characters.
--- THIS CALL DOES NOT RETURN THE CURRENT WEATHER AT THE AIRPORT, and returns an empty string if the system is not in real-weather mode.
---
--- This call is not intended to be used per-frame. It should be called only during the pre-flight loop callback.
---
---@field XPLMGetMETARForAirport fun(airport_id: string): { outMETAR: XPLMFixedString150_t }

---@class _G
--- Get the current weather conditions at a given location. Note that this does not work world-wide, only within the
--- surrounding region. Return true if detailed weather (i.e. an airport-specific METAR) was found, false if not. In both cases, the structure
--- will contain the best data available.
---
--- IMPORTANT: When you read the weather at a given point you are reading the OUTPUT from the internal weather simulation, the exact details of
--- which are undocumented. Never expect to read the exact numbers you may have set, even at the same coordinates.
---
--- This call is not intended to be used per-frame. It should be called only during the pre-flight loop callback.
---
---@field XPLMGetWeatherAtLocation fun(latitude: number, longitude: number, altitude_m: number): boolean, { out_info: XPLMWeatherInfo_t }

---@class _G
--- Inform the simulator that you are starting a batch update of weather information. If you are providing multiple weather updates,
--- using this call may improve performance by telling the simulator not to update weather until you are done.
---
--- This call is not intended to be used per-frame.  It should be called only during the pre-flight loop callback.
--- You must call XPLMEndWeatherUpdate before you return from the callback; XPLMBeginWeatherUpdate in one
--- callback and XPLMEndWeatherUpdate in a later callback, even within the same frame, is not permitted.
---
---@field XPLMBeginWeatherUpdate fun()

---@class _G
--- Inform the simulator that you are ending a batch update of weather information. If you have called XPLMBeginWeatherUpdate, you MUST
--- call XPLMEndWeatherUpdate before exiting your callback otherwise any accumulated weather data will be discarded.
---
--- When using incremental mode, any changes made are applied to your existing data. This makes it possible to only update a fraction of
--- your weather data at any one time. When not using incremental mode, ALL reports previously passed by your plugin are erased before
--- applying new data.
---
--- When using any of these 'weather set' APIs, the normal mode of operation is that you are setting the weather in the near future. Currently
--- this is somewhere between one and two minutes but do not rely on this remaining the same.
---
--- Setting future weather ensures that there is no sudden jump in weather conditions when you make a change mid-cycle. In some situations, notably
--- for an initial setup, you may want to ensure that the weather is changed instantly. To do this, set 'updateImmediately' as true.
---
--- isIncremental     : If true, append or modify existing records created by your plugin. If false, clear any existing records.
--- updateImmediately : If true, immediately reset and recalculate the weather. If false, your new data will be used when the weather next recalculates.
---
--- This call is not intended to be used per-frame. It should be called only during the pre-flight loop callback.
---
---@field XPLMEndWeatherUpdate fun(isIncremental: boolean, updateImmediately: boolean)

---@class _G
--- Set the current weather conditions at a given location on the ground and above it.. Please see the notes on individual fields in
--- XPLMSetWeatherAtAirport, and notes on timing in XPLMEndWeatherUpdate.
---
--- The ground altitude passed into this function call does not set the area of
--- influence of this weather vertically; the weather takes effect from 0 MSL
--- ground up to the passed-in max_altitude_msl_ft.  The ground altitude passed in is the elevation of the
--- reporting station to calibrate QNH.
---
--- IMPORTANT: As with all calls to set weather, you are setting one aspect to be used in a much wider atmospheric simulation. Never
--- expect to get the same numbers back from a read, even at the same locations, since the XPLMGetWeather... calls all read
--- the simulated state, not any particular input. This applies equally to static and real-weather modes.
---
--- This call is not intended to be used per-frame. It should be called only during the pre-flight loop callback.
---
---@field XPLMSetWeatherAtLocation fun(latitude: number, longitude: number, ground_altitude_msl: number, in_info: XPLMWeatherInfo_t)

---@class _G
--- Erase weather conditions set by your plugin at a given location. You must give exactly the same coordinates that you used to create a weather record at this point.
--- It does NOT mean 'create clear weather at this location'.
---
--- This call is not intended to be used per-frame. It should be called only during the pre-flight loop callback.
---
---@field XPLMEraseWeatherAtLocation fun(latitude: number, longitude: number)

---@class _G
--- Set the current weather conditions at a given airport. Unlike XPLMSetWeatherAtLocation, this call will replace any existing
--- weather records for that airport from other sources (i.e. downloaded METARs) instead of being used as just another weather sample.
---
--- Some notes on individual fields:
---   - pressure_alt should be QNH as reported by a station at the specified airport, or 0 if you are passing sealevel pressure in 'pressure_sl' instead.
---   - pressure_sl is ignored if pressure_alt is given.
---   - wind_dir_alt, wind_spd_alt, turbulence_alt, wave_speed, wave_length are derived from other data and are UNUSED when setting weather.
---   - Temperatures can be given EITHER as a single temperature at the ground altitude (temperature_alt) OR, if the struct is V2 or higher, as an array of temperatures aloft (temp_layers).
---     If you pass a value for temperature_alt higher than -273.15 (absolute zero), that will be used with the altitude value to calculate an offset from ISA temperature at all altitudes.
---     Any layer in temp_layers for which you set the temperature higher than -273.15 (absolute zero) will use that temperature and all others will use the existing value for the location,
---     or the calculated values from temperature_alt if you also passed that. It is advised to use a lower value than exactly -273.15 to avoid floating-point precision errors.
--- 	These calculated temperatures during a read are also affected by the troposphere altitude and temperature, and the vertical radius of effect.
--- 	If you set both temperature_alt (V1 single value) and temp_layers (V2 per-layer value) then the more detailed V2 data, if valid, will override the values calculated from the older,
--- 	ground-level only temperature value.
---   - The same rules apply to dewpoint temperatures; either a single value at ground level in 'dewpoint_alt', or per-layer values in 'dewp_layers'.
---   - The troposphere altitude and temperature will be derived from existing data if you pass 0 or lower for troposphere_alt. Both altitude and temperature may be clamped to internally-defined ranges.
---   - When setting both temperature and dewpoint from a single value (temperature_alt/dewpoint_alt), the rest of the atmosphere will be
---     graded to fit between the given values and the troposphere.
---
--- IMPORTANT: As with all calls to set weather, you are setting one aspect to be used in a much wider atmospheric simulation. Never
--- expect to get the same numbers back from a read, even at the same locations, since the XPLMGetWeather... calls all read
--- the simulated state, not any particular input. This applies equally to static and real-weather modes.
---
--- This call is not intended to be used per-frame. It should be called only during the pre-flight loop callback.
---
---@field XPLMSetWeatherAtAirport fun(airport_id: string, in_info: XPLMWeatherInfo_t)

---@class _G
--- Erase the current weather conditions set by your plugin at a given airport, allowing records from other sources to be used.
--- It does NOT mean 'create clear weather at this airport'.
---
--- This call is not intended to be used per-frame. It should be called only during the pre-flight loop callback.
---
---@field XPLMEraseWeatherAtAirport fun(airport_id: string)

