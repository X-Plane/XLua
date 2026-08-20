<h1>Weather Access</h1>

---

<div class="sym-block sym-struct" data-name="XPLMWeatherInfoWinds_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMWeatherInfoWinds_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local My_WeatherInfoWinds_t = {
    alt_msl     = 0.0,     -- float
    speed       = 0.0,     -- float
    direction   = 0.0,     -- float
    gust_speed  = 0.0,     -- float
    shear       = 0.0,     -- float
    turbulence  = 0.0,     -- float
}</code></pre>
</div>

</div>

---

<div class="sym-block sym-struct" data-name="XPLMWeatherInfoClouds_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMWeatherInfoClouds_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local My_WeatherInfoClouds_t = {
    cloud_type  = 0.0,     -- float
    coverage    = 0.0,     -- float
    alt_top     = 0.0,     -- float
    alt_base    = 0.0,     -- float
}</code></pre>
</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_NUM_WIND_LAYERS" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_NUM_WIND_LAYERS { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

The number of wind layers that are expected in the latest version of XPLMWeatherInfo_t .

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLM_NUM_WIND_LAYERS  -- 13</code></pre>
</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_NUM_CLOUD_LAYERS" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_NUM_CLOUD_LAYERS { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

The number of cloud layers that are expected in the latest version of XPLMWeatherInfo_t .

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLM_NUM_CLOUD_LAYERS  -- 3</code></pre>
</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_NUM_TEMPERATURE_LAYERS" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_NUM_TEMPERATURE_LAYERS { .symbol-title }

<span class="sym-badge badge-define">define</span> <span class="sym-badge badge-version">XPLM420</span>

</div>

The number of temperature layers that are expected in the latest version of XPLMWeatherInfo_t .

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLM_NUM_TEMPERATURE_LAYERS  -- 13</code></pre>
</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_WIND_UNDEFINED_LAYER" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_WIND_UNDEFINED_LAYER { .symbol-title }

<span class="sym-badge badge-define">define</span> <span class="sym-badge badge-version">XPLM420</span>

</div>

Use this value to designate a wind layer as undefined when setting.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLM_WIND_UNDEFINED_LAYER  -- -1</code></pre>
</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_TEMP_UNDEFINED_LAYER" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_TEMP_UNDEFINED_LAYER { .symbol-title }

<span class="sym-badge badge-define">define</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

Use this value to designate a temperature-related layer as undefined when setting.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLM_TEMP_UNDEFINED_LAYER  -- -274</code></pre>
</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_DEFAULT_WXR_RADIUS_NM" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_DEFAULT_WXR_RADIUS_NM { .symbol-title }

<span class="sym-badge badge-define">define</span> <span class="sym-badge badge-version">XPLM420</span>

</div>

Default radius of weather data points set using XPLMSetWeatherAtLocation and XPLMSetWeatherAtAirport.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLM_DEFAULT_WXR_RADIUS_NM  -- 30</code></pre>
</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_DEFAULT_WXR_LIMIT_MSL_FT" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_DEFAULT_WXR_LIMIT_MSL_FT { .symbol-title }

<span class="sym-badge badge-define">define</span> <span class="sym-badge badge-version">XPLM420</span>

</div>

Default vertical limit of effect of weather data points set using XPLMSetWeatherAtLocation and XPLMSetWeatherAtAirport.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLM_DEFAULT_WXR_LIMIT_MSL_FT  -- 10000</code></pre>
</div>

</div>

---

<div class="sym-block sym-struct" data-name="XPLMWeatherInfo_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMWeatherInfo_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

Basic weather conditions at a specific point. To specify exactly what data you intend to send or receive, it
is required to set the structSize appropriately.

Version 2 data starts at "temp_layers".

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local My_WeatherInfo_t = {
    structSize           = 0,       -- int
    temperature_alt      = 0.0,     -- float
    dewpoint_alt         = 0.0,     -- float
    pressure_alt         = 0.0,     -- float
    precip_rate_alt      = 0.0,     -- float
    wind_dir_alt         = 0.0,     -- float
    wind_spd_alt         = 0.0,     -- float
    turbulence_alt       = 0.0,     -- float
    wave_height          = 0.0,     -- float
    wave_length          = 0.0,     -- float
    wave_dir             = 0,       -- int
    wave_speed           = 0.0,     -- float
    visibility           = 0.0,     -- float
    precip_rate          = 0.0,     -- float
    thermal_climb        = 0.0,     -- float
    pressure_sl          = 0.0,     -- float
    wind_layers          = nil,     -- see XPLMWeatherInfoWinds_t
    cloud_layers         = nil,     -- see XPLMWeatherInfoClouds_t
    temp_layers          = nil,     -- float
    dewp_layers          = nil,     -- float
    troposphere_alt      = 0.0,     -- float
    troposphere_temp     = 0.0,     -- float
    age                  = 0.0,     -- float
    radius_nm            = 0.0,     -- float
    max_altitude_msl_ft  = 0.0,     -- float
    snow_coverage_pct    = 0.0,     -- float
}</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetMETARForAirport" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetMETARForAirport { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Get the last-downloaded METAR report for an airport by ICAO code. Note that the actual weather at that airport may have evolved
significantly since the last downloaded METAR. outMETAR must point to a char buffer of at least 150 characters.
THIS CALL DOES NOT RETURN THE CURRENT WEATHER AT THE AIRPORT, and returns an empty string if the system is not in real-weather mode.

This call is not intended to be used per-frame. It should be called only during the pre-flight loop callback.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMGetMETARForAirport(
    airport_id     -- string
)
-- outs = { outMETAR }</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetWeatherAtLocation" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetWeatherAtLocation { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Get the current weather conditions at a given location. Note that this does not work world-wide, only within the
surrounding region. Return true if detailed weather (i.e. an airport-specific METAR) was found, false if not. In both cases, the structure
will contain the best data available.

IMPORTANT: When you read the weather at a given point you are reading the OUTPUT from the internal weather simulation, the exact details of
which are undocumented. Never expect to read the exact numbers you may have set, even at the same coordinates.

This call is not intended to be used per-frame. It should be called only during the pre-flight loop callback.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean, plus a table of out values
local my_result, outs = XPLMGetWeatherAtLocation(
    latitude,      -- float
    longitude,     -- float
    altitude_m     -- float
)
-- outs = { out_info }</code></pre>
</div>


**See associated types:**

- [XPLMWeatherInfo_t](#xplmweatherinfo_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMBeginWeatherUpdate" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMBeginWeatherUpdate { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM420</span>

</div>

Inform the simulator that you are starting a batch update of weather information. If you are providing multiple weather updates,
using this call may improve performance by telling the simulator not to update weather until you are done.

This call is not intended to be used per-frame.  It should be called only during the pre-flight loop callback.
You must call XPLMEndWeatherUpdate before you return from the callback; XPLMBeginWeatherUpdate in one
callback and XPLMEndWeatherUpdate in a later callback, even within the same frame, is not permitted.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMBeginWeatherUpdate(
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMEndWeatherUpdate" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMEndWeatherUpdate { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM420</span>

</div>

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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMEndWeatherUpdate(
    isIncremental,        -- boolean
    updateImmediately     -- boolean
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMSetWeatherAtLocation" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetWeatherAtLocation { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM420</span>

</div>

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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetWeatherAtLocation(
    latitude,               -- float
    longitude,              -- float
    ground_altitude_msl,    -- float
    in_info                 -- see XPLMWeatherInfo_t
)</code></pre>
</div>


**See associated types:**

- [XPLMWeatherInfo_t](#xplmweatherinfo_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMEraseWeatherAtLocation" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMEraseWeatherAtLocation { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM420</span>

</div>

Erase weather conditions set by your plugin at a given location. You must give exactly the same coordinates that you used to create a weather record at this point.
It does NOT mean 'create clear weather at this location'.

This call is not intended to be used per-frame. It should be called only during the pre-flight loop callback.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMEraseWeatherAtLocation(
    latitude,     -- float
    longitude     -- float
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMSetWeatherAtAirport" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetWeatherAtAirport { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM420</span>

</div>

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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetWeatherAtAirport(
    airport_id,    -- string
    in_info        -- see XPLMWeatherInfo_t
)</code></pre>
</div>


**See associated types:**

- [XPLMWeatherInfo_t](#xplmweatherinfo_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMEraseWeatherAtAirport" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMEraseWeatherAtAirport { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM420</span>

</div>

Erase the current weather conditions set by your plugin at a given airport, allowing records from other sources to be used.
It does NOT mean 'create clear weather at this airport'.

This call is not intended to be used per-frame. It should be called only during the pre-flight loop callback.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMEraseWeatherAtAirport(
    airport_id     -- string
)</code></pre>
</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>