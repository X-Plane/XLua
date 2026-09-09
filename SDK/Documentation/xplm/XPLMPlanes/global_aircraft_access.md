<h1>Global Aircraft Access</h1>

These APIs let you control the AI aircraft and take over multiplayer/aI aircraft control.

---

<div class="sym-block sym-define" data-name="XPLM_USER_AIRCRAFT" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_USER_AIRCRAFT { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

The user's aircraft is always index 0.

<div class="xplm-code" markdown="1">

`#define XPLM_USER_AIRCRAFT 0`

</div>

</div>

---

<div class="sym-block sym-struct" data-name="XPLMPlaneDrawState_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMPlaneDrawState_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span> <span class="sym-badge badge-deprecated">XPLM_DEPRECATED</span>

</div>

This structure contains additional plane parameter info to be passed to draw plane.  Make sure to fill in the
size of the structure field with sizeof(XPLMDrawPlaneState_t) so that the XPLM can tell how many fields you
knew about when compiling your plugin (since more fields may be added later).

Most of these fields are ratios from 0 to 1 for control input.  X-Plane calculates what the actual controls look
like based on the .acf file for that airplane.  Note for the yoke inputs, this is what the pilot of the plane has
commanded (post artificial stability system if there were one) and affects ailerons, rudder, etc.  It is not
necessarily related to the actual position of the plane's surfaces!

<div class="xplm-code" markdown="1">

```cpp
typedef struct {
     int                       structSize;
     float                     gearPosition;
     float                     flapRatio;
     float                     spoilerRatio;
     float                     speedBrakeRatio;
     float                     slatRatio;
     float                     wingSweep;
     float                     thrust;
     float                     yokePitch;
     float                     yokeHeading;
     float                     yokeRoll;
} XPLMPlaneDrawState_t;
```

</div>

<div class="field-table" markdown="1">

| Field | Type | Description |
|:--|:--|:--|
| structSize | int | The size of the draw state struct. |
| gearPosition | float | A ratio from [0..1] describing how far the landing gear is extended. |
| flapRatio | float | Ratio of flap deployment, 0 = up, 1 = full deploy. |
| spoilerRatio | float | Ratio of spoiler deployment, 0 = none, 1 = full deploy. |
| speedBrakeRatio | float | Ratio of speed brake deployment, 0 = none, 1 = full deploy. |
| slatRatio | float | Ratio of slat deployment, 0 = none, 1 = full deploy. |
| wingSweep | float | Wing sweep ratio, 0 = forward, 1 = swept. |
| thrust | float | Thrust power, 0 = none, 1 = full fwd, -1 = full reverse. |
| yokePitch | float | Total pitch input for this plane. |
| yokeHeading | float | Total Heading input for this plane. |
| yokeRoll | float | Total Roll input for this plane. |

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMCountAircraft" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCountAircraft { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function returns the number of aircraft X-Plane is capable of having,
as well as the number of aircraft that are currently active.  These
numbers count the user's aircraft.  It can also return the plugin that
is currently controlling aircraft.  In X-Plane 7, this routine reflects
the number of aircraft the user has enabled in the rendering options window.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMCountAircraft(
                         int *                outTotalAircraft,    /* Can be NULL */
                         int *                outActiveAircraft,    /* Can be NULL */
                         XPLMPluginID *       outController    /* Can be NULL */
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetNthAircraftModel" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetNthAircraftModel { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function returns the aircraft model for the Nth aircraft.  Indices
are zero based, with zero being the user's aircraft.  The file name should
be at least 256 chars in length; the path should be at least 512 chars
in length.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMGetNthAircraftModel(
                         int                  inIndex,
                         char                 outFileName[256],    /* Can be NULL */
                         char                 outPath[512]    /* Can be NULL */
                    );
```

</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>