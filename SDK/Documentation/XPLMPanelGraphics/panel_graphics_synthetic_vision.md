<h1>Panel Graphics Synthetic Vision</h1>

These routines let you draw the simulator's Synthetic Vision Technology (SVT)
terrain rendering into your avionics panel. SVT provides a 3-D perspective view
of terrain, runways, obstacles, and optional overlays such as flight path hoops,
traffic, and airport signs. The view is always centered on the user aircraft and
uses the selected AHRS source for attitude.

Create an SVT display with XPLMCreateSVTDisplay and draw it with
XPLMSVTDisplayDrawIn. Each display instance manages its own terrain tile loading
and GPU state, so you can have multiple independent SVT views (e.g. pilot and
copilot PFDs with different feature flags).

SVT rendering works on any aircraft, regardless of whether the stock cockpit has
a G1000 or other SVT-capable avionics installed.

---

<div class="sym-block sym-enum" data-name="XPLMSVTFeatures" data-type="enum" markdown="1">

## XPLMSVTFeatures { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

Bit flags that control which visual layers an SVT display renders. Combine
flags with bitwise OR to enable multiple layers.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_SVT_Terrain | 1 | 3-D terrain mesh with elevation coloring. |
| xplm_SVT_Runways | 2 | Runway outlines, centerline stripes, and numbers. |
| xplm_SVT_Obstacles | 4 | Obstacle markers (towers, masts, etc.). |
| xplm_SVT_FlightPath | 8 | Flight path guidance hoops along the active route. |
| xplm_SVT_Traffic | 16 | TCAS traffic symbols. |
| xplm_SVT_AirportSigns | 32 | Airport identification signs near airports. |
| xplm_SVT_ILSHoops | 64 | ILS approach guidance hoops. |
| xplm_SVT_HorizonHeading | 128 | Horizon line and heading reference. |
| xplm_SVT_All | 255 | All visual layers enabled. |

</div>

</div>

---

<div class="sym-block sym-struct" data-name="XPLMCreateSVT_t" data-type="struct" markdown="1">

## XPLMCreateSVT_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

Parameters for creating an SVT display. Set structSize to the size of your
struct so that future SDK versions can add fields without breaking existing
plugins.

```cpp
typedef struct {
     int                       structSize;
     XPLMSVTFeatures           features;
     int                       pilotIndex;
} XPLMCreateSVT_t;
```

</div>

---

<div class="sym-block sym-typedef" data-name="XPLMSVTDisplayRef" data-type="typedef" markdown="1">

## XPLMSVTDisplayRef { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

An opaque handle to an SVT display instance. Create one with
XPLMCreateSVTDisplay and destroy it with XPLMDestroySVTDisplay.

```cpp
typedef void * XPLMSVTDisplayRef;
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMCreateSVTDisplay" data-type="function" markdown="1">

## XPLMCreateSVTDisplay { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function creates a new SVT display instance. The display begins loading
terrain tiles for the current aircraft position immediately. You can draw it
as soon as tiles are available; before that, the draw call is a no-op.

The returned handle must be destroyed with XPLMDestroySVTDisplay when no
longer needed. Handles are automatically destroyed when the owning plugin is
unloaded.

```cpp
XPLM_API XPLMSVTDisplayRefXPLMCreateSVTDisplay(
                         XPLMCreateSVT_t *    params
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMDestroySVTDisplay" data-type="function" markdown="1">

## XPLMDestroySVTDisplay { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function destroys an SVT display and frees all associated resources.

```cpp
XPLM_API void       XPLMDestroySVTDisplay(
                         XPLMSVTDisplayRef    svt
                    );
```

</div>

---

<div class="sym-block sym-struct" data-name="XPLMSVTCustomData_t" data-type="struct" markdown="1">

## XPLMSVTCustomData_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

```cpp
typedef struct {
     float                     pitchDeg;
     float                     rollDeg;
     float                     headingMagDeg;
     float                     magVarDeg;
     float                     indicatedAltFt;
     float                     baroSettingInHg;
     int                       hsiSource;
     float                     hdefDots;
     float                     vdefDots;
} XPLMSVTCustomData_t;
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMSVTDisplayDrawIn" data-type="function" markdown="1">

## XPLMSVTDisplayDrawIn { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function renders the SVT display directly into the active panel surface
within the specified rectangular region. SVT sets up its own 3-D perspective
projection to fit the rectangle, so no transform stack manipulation is
needed.

The features parameter controls which visual layers are rendered for this
draw call. Pass a bitwise OR of XPLMSVTFeatures flags.

This function must be called from within an avionics drawing callback. If
terrain tiles have not finished loading yet, this function does nothing.

- svt: the SVT display handle.
- features: bitwise OR of XPLMSVTFeatures flags to enable for this draw call.
- left, top, right, bottom: the bounding rectangle in panel coordinates.
- dataOverrides. Pass nullptr for default sim state.

```cpp
XPLM_API void       XPLMSVTDisplayDrawIn(
                         XPLMSVTDisplayRef    svt,
                         XPLMSVTFeatures      features,
                         int                  left,
                         int                  top,
                         int                  right,
                         int                  bottom,
                         XPLMSVTCustomData_t* dataOverrides    /* Can be NULL */
                    );
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>