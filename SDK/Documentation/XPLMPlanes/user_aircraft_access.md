<h1>User Aircraft Access</h1>

These routines are used to initialize and manipulate the user's aircraft.

---

<div class="sym-block sym-enum" data-name="XPLMInitResult" data-type="enum" markdown="1">

## XPLMInitResult { .symbol-title }

<span class="sym-badge badge-enum">enum</span> <span class="sym-badge badge-version">XPLM430</span>

Result codes from initializing or updating the user's aircraft. Initialization can fail due to
unparsable/invalid data, or due to the contents of the initialization containing parameters the
sim cannot fulfill (e.g. an aircraft not on disk, a ramp start not present in an airport due to
custom scenery).

If an initialization fails, a human-readable string is sent to your plugin's error function.
This is meant for debugging purposes only and should not be parsed. Your plugin's logic should
only use the result code for flow control.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_Init_Success | 0 | The initialization succeeded. |
| xplm_Init_Invalid | 1 | The provided argument was invalid. This can be returned if the provided string is not a valid json string. This error can also be returned if one or more of the provided arguments is invalid, such as a missing required field or an unrecognized parameter such as an unknown runway name. Invalid errors imply that your calling code is generating incorrect JSON and should be fixed; use your plugin's error callback to find more detailed information about the problem with your input. |
| xplm_Init_MissingAircraft | 2 | The new flight could not be initialized because one of the aircraft requested could not be found on disk or loaded. |
| xplm_Init_MissingLivery | 3 | The new flight could not be initialized because one of the aircraft's' requested liveries could not be found on disk or loaded. |
| xplm_Init_MissingAirport | 4 | The new flight could not be initialized because the requested airport was not found in X-Plane's airport database. |
| xplm_Init_MissingRamp | 5 | The new flight could not be initialized because the requested ramp start was not found at the specified airport in X-Plane's airport database. |
| xplm_Init_MissingRunway | 6 | The new flight could not be initialized because the requested runway was not found at the specified airport in X-Plane's airport database. |

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMInitFlight" data-type="function" markdown="1">

## XPLMInitFlight { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM430</span>

Initialize a new flight, ending th user's current flight. The flight config is provided as json string.
See https://developer.x-plane.com/article/flight-initialization-api/ for the JSON format specification.

Returns a XPLMInitResult enum value specifying whether the initalization succeeeded (and if not, what
caused it to fail).

```cpp
XPLM_API XPLMInitResultXPLMInitFlight(
                         char const*          inJsonData
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMUpdateFlight" data-type="function" markdown="1">

## XPLMUpdateFlight { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM430</span>

Updates the user's 'current flight, modifying some flight parameters. The flight config is provided as
a JSON string, see https://developer.x-plane.com/article/flight-initialization-api/ for the JSON format
specification.

Returns an XPLMInitResult enum value specifying whether the update suceeeded (and if not, what caused
it to fail).

```cpp
XPLM_API XPLMInitResultXPLMUpdateFlight(
                         char const*          inJsonData
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMSetUsersAircraft" data-type="function" markdown="1">

## XPLMSetUsersAircraft { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This routine changes the user's aircraft.  Note that this will reinitialize the user
to be on the nearest airport's first runway.  Pass in a full path (hard drive and
everything including the .acf extension) to the .acf file.

Use XPLMInitFlight for complete control over initialization.

**WARNING**: this API takes a full, not relative aicraft path.

```cpp
XPLM_API void       XPLMSetUsersAircraft(
                         const char *         inAircraftPath
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMPlaceUserAtAirport" data-type="function" markdown="1">

## XPLMPlaceUserAtAirport { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This routine places the user at a given airport.  Specify the airport by its X-Plane
airport ID (e.g. 'KBOS').

Use XPLMInitFlight for complete control over initialization.

```cpp
XPLM_API void       XPLMPlaceUserAtAirport(
                         const char *         inAirportCode
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMPlaceUserAtLocation" data-type="function" markdown="1">

## XPLMPlaceUserAtLocation { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM300</span>

Places the user at a specific location after performing any necessary scenery loads.

As with in-air starts initiated from the X-Plane user interface, the aircraft will always start with
its engines running, regardless of the user's preferences (i.e., regardless of what the dataref
`sim/operation/prefs/startup_running` says).

Use XPLMInitFlight for complete control over initialization.

```cpp
XPLM_API void       XPLMPlaceUserAtLocation(
                         double               latitudeDegrees,
                         double               longitudeDegrees,
                         float                elevationMetersMSL,
                         float                headingDegreesTrue,
                         float                speedMetersPerSecond
                    );
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>