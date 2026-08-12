<h1>Weather Access</h1>

---

<div class="sym-block sym-struct" data-name="XPLMWeatherInfoWinds_t" data-type="struct" markdown="1">

## XPLMWeatherInfoWinds_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

```cpp
typedef struct {
     float                     alt_msl;
     float                     speed;
     float                     direction;
     float                     gust_speed;
     float                     shear;
     float                     turbulence;
} XPLMWeatherInfoWinds_t;
```

</div>

---

<div class="sym-block sym-struct" data-name="XPLMWeatherInfoClouds_t" data-type="struct" markdown="1">

## XPLMWeatherInfoClouds_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

```cpp
typedef struct {
     float                     cloud_type;
     float                     coverage;
     float                     alt_top;
     float                     alt_base;
} XPLMWeatherInfoClouds_t;
```

</div>

---

<div class="sym-block sym-define" data-name="XPLM_NUM_WIND_LAYERS" data-type="define" markdown="1">

## XPLM_NUM_WIND_LAYERS { .symbol-title }

<span class="sym-badge badge-define">define</span>

The number of wind layers that are expected in the latest version of XPLMWeatherInfo_t .

`#define XPLM_NUM_WIND_LAYERS 13`

</div>

---

<div class="sym-block sym-define" data-name="XPLM_NUM_CLOUD_LAYERS" data-type="define" markdown="1">

## XPLM_NUM_CLOUD_LAYERS { .symbol-title }

<span class="sym-badge badge-define">define</span>

The number of cloud layers that are expected in the latest version of XPLMWeatherInfo_t .

`#define XPLM_NUM_CLOUD_LAYERS 3`

</div>

---

<div class="sym-block sym-define" data-name="XPLM_NUM_TEMPERATURE_LAYERS" data-type="define" markdown="1">

## XPLM_NUM_TEMPERATURE_LAYERS { .symbol-title }

<span class="sym-badge badge-define">define</span> <span class="sym-badge badge-version">XPLM420</span>

The number of temperature layers that are expected in the latest version of XPLMWeatherInfo_t .

`#define XPLM_NUM_TEMPERATURE_LAYERS 13`

</div>

---

<div class="sym-block sym-define" data-name="XPLM_WIND_UNDEFINED_LAYER" data-type="define" markdown="1">

## XPLM_WIND_UNDEFINED_LAYER { .symbol-title }

<span class="sym-badge badge-define">define</span> <span class="sym-badge badge-version">XPLM420</span>

Use this value to designate a wind layer as undefined when setting.

`#define XPLM_WIND_UNDEFINED_LAYER -1`

</div>

---

<div class="sym-block sym-define" data-name="XPLM_TEMP_UNDEFINED_LAYER" data-type="define" markdown="1">

## XPLM_TEMP_UNDEFINED_LAYER { .symbol-title }

<span class="sym-badge badge-define">define</span> <span class="sym-badge badge-version">XPLM440</span>

Use this value to designate a temperature-related layer as undefined when setting.

`#define XPLM_TEMP_UNDEFINED_LAYER -274`

</div>

---

<div class="sym-block sym-define" data-name="XPLM_DEFAULT_WXR_RADIUS_NM" data-type="define" markdown="1">

## XPLM_DEFAULT_WXR_RADIUS_NM { .symbol-title }

<span class="sym-badge badge-define">define</span> <span class="sym-badge badge-version">XPLM420</span>

Default radius of weather data points set using XPLMSetWeatherAtLocation and XPLMSetWeatherAtAirport.

`#define XPLM_DEFAULT_WXR_RADIUS_NM 30`

</div>

---

<div class="sym-block sym-define" data-name="XPLM_DEFAULT_WXR_LIMIT_MSL_FT" data-type="define" markdown="1">

## XPLM_DEFAULT_WXR_LIMIT_MSL_FT { .symbol-title }

<span class="sym-badge badge-define">define</span> <span class="sym-badge badge-version">XPLM420</span>

Default vertical limit of effect of weather data points set using XPLMSetWeatherAtLocation and XPLMSetWeatherAtAirport.

`#define XPLM_DEFAULT_WXR_LIMIT_MSL_FT 10000`

</div>

---

<div class="sym-block sym-struct" data-name="XPLMWeatherInfo_t" data-type="struct" markdown="1">

## XPLMWeatherInfo_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

Basic weather conditions at a specific point. To specify exactly what data you intend to send or receive, it
is required to set the structSize appropriately.

Version 2 data starts at "temp_layers".

```cpp
typedef struct {
     int                       structSize;
     float                     temperature_alt;
     float                     dewpoint_alt;
     float                     pressure_alt;
     float                     precip_rate_alt;
     float                     wind_dir_alt;
     float                     wind_spd_alt;
     float                     turbulence_alt;
     float                     wave_height;
     float                     wave_length;
     int                       wave_dir;
     float                     wave_speed;
     float                     visibility;
     float                     precip_rate;
     float                     thermal_climb;
     float                     pressure_sl;
     XPLMWeatherInfoWinds_t[XPLM_NUM_WIND_LAYERS] wind_layers;
     XPLMWeatherInfoClouds_t[XPLM_NUM_CLOUD_LAYERS] cloud_layers;
     float[XPLM_NUM_TEMPERATURE_LAYERS] temp_layers;
     float[XPLM_NUM_TEMPERATURE_LAYERS] dewp_layers;
     float                     troposphere_alt;
     float                     troposphere_temp;
     float                     age;
     float                     radius_nm;
     float                     max_altitude_msl_ft;
     float                     snow_coverage_pct;
} XPLMWeatherInfo_t;
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetMETARForAirport" data-type="function" markdown="1">

## XPLMGetMETARForAirport { .symbol-title }

<span class="sym-badge badge-fn">function</span>

Get the last-downloaded METAR report for an airport by ICAO code. Note that the actual weather at that airport may have evolved
significantly since the last downloaded METAR. outMETAR must point to a char buffer of at least 150 characters.
THIS CALL DOES NOT RETURN THE CURRENT WEATHER AT THE AIRPORT, and returns an empty string if the system is not in real-weather mode.

This call is not intended to be used per-frame. It should be called only during the pre-flight loop callback.

```cpp
XPLM_API void       XPLMGetMETARForAirport(
                         const char *         airport_id,
                         XPLMFixedString150_t * outMETAR
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetWeatherAtLocation" data-type="function" markdown="1">

## XPLMGetWeatherAtLocation { .symbol-title }

<span class="sym-badge badge-fn">function</span>

Get the current weather conditions at a given location. Note that this does not work world-wide, only within the
surrounding region. Return true if detailed weather (i.e. an airport-specific METAR) was found, false if not. In both cases, the structure
will contain the best data available.

IMPORTANT: When you read the weather at a given point you are reading the OUTPUT from the internal weather simulation, the exact details of
which are undocumented. Never expect to read the exact numbers you may have set, even at the same coordinates.

This call is not intended to be used per-frame. It should be called only during the pre-flight loop callback.

```cpp
XPLM_API int        XPLMGetWeatherAtLocation(
                         double               latitude,
                         double               longitude,
                         double               altitude_m,
                         XPLMWeatherInfo_t *  out_info
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMBeginWeatherUpdate" data-type="function" markdown="1">

## XPLMBeginWeatherUpdate { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM420</span>

Inform the simulator that you are starting a batch update of weather information. If you are providing multiple weather updates,
using this call may improve performance by telling the simulator not to update weather until you are done.

This call is not intended to be used per-frame.  It should be called only during the pre-flight loop callback.
You must call XPLMEndWeatherUpdate before you return from the callback; XPLMBeginWeatherUpdate in one
callback and XPLMEndWeatherUpdate in a later callback, even within the same frame, is not permitted.

```cpp
XPLM_API void       XPLMBeginWeatherUpdate(void);
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMEndWeatherUpdate" data-type="function" markdown="1">

## XPLMEndWeatherUpdate { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM420</span>

Inform the simulator that you are ending a batch update of weather information. If you have called XPLMBeginWeatherUpdate, you MUST
call XPLMEndWeatherUpdate before exiting your callback otherwise any accumulated weather data will be discarded.

When using incremental mode, any changes made are applied to your existing data. This makes it possible to only update a fraction of
your weather data at any one time. When not using incremental mode, ALL reports previously passed by your plugin are erased before
applying new data.

When using any of these 'weather set' APIs, the normal mode of operation is that you are setting the weather in the near future. Currently
this is somewhere between one and two minutes but do not rely on this remaining the same.

Setting future weather ensures that there is no sudden jump in weather conditions when you make a change mid-cycle. In some situations, notably
for an initial setup, you may want to ensure that the weather is changed instantly. To do this, set 'updateImmediately' as true.

isIncremental     : If true, append or modify existing records created by your plugin. If false, clear any existing records.
updateImmediately : If true, immediately reset and recalculate the weather. If false, your new data will be used when the weather next recalculates.

This call is not intended to be used per-frame. It should be called only during the pre-flight loop callback.

```cpp
XPLM_API void       XPLMEndWeatherUpdate(
                         int                  isIncremental,
                         int                  updateImmediately
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMSetWeatherAtLocation" data-type="function" markdown="1">

## XPLMSetWeatherAtLocation { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM420</span>

Set the current weather conditions at a given location on the ground and above it.. Please see the notes on individual fields in
XPLMSetWeatherAtAirport, and notes on timing in XPLMEndWeatherUpdate.

The ground altitude passed into this function call does not set the area of
influence of this weather vertically; the weather takes effect from 0 MSL
ground up to the passed-in max_altitude_msl_ft.  The ground altitude passed in is the elevation of the
reporting station to calibrate QNH.

IMPORTANT: As with all calls to set weather, you are setting one aspect to be used in a much wider atmospheric simulation. Never
expect to get the same numbers back from a read, even at the same locations, since the XPLMGetWeather... calls all read
the simulated state, not any particular input. This applies equally to static and real-weather modes.

This call is not intended to be used per-frame. It should be called only during the pre-flight loop callback.

```cpp
XPLM_API void       XPLMSetWeatherAtLocation(
                         double               latitude,
                         double               longitude,
                         double               ground_altitude_msl,
                         XPLMWeatherInfo_t *  in_info
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMEraseWeatherAtLocation" data-type="function" markdown="1">

## XPLMEraseWeatherAtLocation { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM420</span>

Erase weather conditions set by your plugin at a given location. You must give exactly the same coordinates that you used to create a weather record at this point.
It does NOT mean 'create clear weather at this location'.

This call is not intended to be used per-frame. It should be called only during the pre-flight loop callback.

```cpp
XPLM_API void       XPLMEraseWeatherAtLocation(
                         double               latitude,
                         double               longitude
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMSetWeatherAtAirport" data-type="function" markdown="1">

## XPLMSetWeatherAtAirport { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM420</span>

Set the current weather conditions at a given airport. Unlike XPLMSetWeatherAtLocation, this call will replace any existing
weather records for that airport from other sources (i.e. downloaded METARs) instead of being used as just another weather sample.

Some notes on individual fields:
  - pressure_alt should be QNH as reported by a station at the specified airport, or 0 if you are passing sealevel pressure in 'pressure_sl' instead.
  - pressure_sl is ignored if pressure_alt is given.
  - wind_dir_alt, wind_spd_alt, turbulence_alt, wave_speed, wave_length are derived from other data and are UNUSED when setting weather.
  - Temperatures can be given EITHER as a single temperature at the ground altitude (temperature_alt) OR, if the struct is V2 or higher, as an array of temperatures aloft (temp_layers).
    If you pass a value for temperature_alt higher than -273.15 (absolute zero), that will be used with the altitude value to calculate an offset from ISA temperature at all altitudes.
    Any layer in temp_layers for which you set the temperature higher than -273.15 (absolute zero) will use that temperature and all others will use the existing value for the location,
    or the calculated values from temperature_alt if you also passed that. It is advised to use a lower value than exactly -273.15 to avoid floating-point precision errors.
	These calculated temperatures during a read are also affected by the troposphere altitude and temperature, and the vertical radius of effect.
	If you set both temperature_alt (V1 single value) and temp_layers (V2 per-layer value) then the more detailed V2 data, if valid, will override the values calculated from the older,
	ground-level only temperature value.
  - The same rules apply to dewpoint temperatures; either a single value at ground level in 'dewpoint_alt', or per-layer values in 'dewp_layers'.
  - The troposphere altitude and temperature will be derived from existing data if you pass 0 or lower for troposphere_alt. Both altitude and temperature may be clamped to internally-defined ranges.
  - When setting both temperature and dewpoint from a single value (temperature_alt/dewpoint_alt), the rest of the atmosphere will be
    graded to fit between the given values and the troposphere.

IMPORTANT: As with all calls to set weather, you are setting one aspect to be used in a much wider atmospheric simulation. Never
expect to get the same numbers back from a read, even at the same locations, since the XPLMGetWeather... calls all read
the simulated state, not any particular input. This applies equally to static and real-weather modes.

This call is not intended to be used per-frame. It should be called only during the pre-flight loop callback.

```cpp
XPLM_API void       XPLMSetWeatherAtAirport(
                         const char *         airport_id,
                         XPLMWeatherInfo_t *  in_info
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMEraseWeatherAtAirport" data-type="function" markdown="1">

## XPLMEraseWeatherAtAirport { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM420</span>

Erase the current weather conditions set by your plugin at a given airport, allowing records from other sources to be used.
It does NOT mean 'create clear weather at this airport'.

This call is not intended to be used per-frame. It should be called only during the pre-flight loop callback.

```cpp
XPLM_API void       XPLMEraseWeatherAtAirport(
                         const char *         airport_id
                    );
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>