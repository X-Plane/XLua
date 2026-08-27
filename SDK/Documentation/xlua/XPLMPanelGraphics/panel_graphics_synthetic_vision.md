<h1>Panel Graphics Synthetic Vision</h1>

These routines let you draw the simulator's Synthetic Vision Technology (SVT)
terrain rendering into your avionics panel. SVT provides a 3-D perspective view
of terrain, runways, obstacles, and optional overlays such as flight path hoops,
traffic, and airport signs. The view is always centered on the user aircraft and
uses the selected AHRS source for attitude.

Create an SVT display with XPLMCreateSVTDisplay and draw it with
XPLMSVTDisplayDrawIn. Each display instance manages its own terrain tile loading
and GPU state, so you can have multiple independent SVT views (e.g. pilot and
copilot PFDs at different scales). Which visual layers are drawn is chosen per
draw call, not per display.

SVT rendering works on any aircraft, regardless of whether the stock cockpit has
a G1000 or other SVT-capable avionics installed.

---

<div class="sym-block sym-enum" data-name="XPLMSVTFeatures" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSVTFeatures { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

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

**Used by:**

- [XPLMSVTDisplayDrawIn](#xplmsvtdisplaydrawin)

</div>

---

<div class="sym-block sym-struct" data-name="XPLMCreateSVT_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCreateSVT_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

Parameters for creating an SVT display. Set structSize to the size of your
struct so that future SDK versions can add fields without breaking existing
plugins.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local My_CreateSVT_t = {
    structSize       = 0,       -- int
    pilotIndex       = 0,       -- int
    pixelsPerDegree  = 0.0,     -- float
}</code></pre>
</div>

<div class="field-table" markdown="1">

| Field | Type | Description |
|:--|:--|:--|
| structSize | int | Set to sizeof(XPLMCreateSVT_t). |
| pilotIndex | int | 0 for pilot-side AHRS, 1 for copilot-side AHRS. |
| pixelsPerDegree | float | Vertical scale of the 3-d view, in pixels per degree at the center of the display.  Must be greater than zero; the G1000 PFD uses 14. |

</div>

</div>

---

<div class="sym-block sym-typedef" data-name="XPLMSVTDisplayRef" data-type="typedef" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSVTDisplayRef { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

</div>

An opaque handle to an SVT display instance. Create one with
XPLMCreateSVTDisplay and destroy it with XPLMDestroySVTDisplay.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local my_sVTDisplayRef = nil  -- XPLMSVTDisplayRef</code></pre>
</div>


**Used by:**

- [XPLMDestroySVTDisplay](#xplmdestroysvtdisplay)
- [XPLMSVTDisplayDrawIn](#xplmsvtdisplaydrawin)
</div>

---

<div class="sym-block sym-function" data-name="XPLMCreateSVTDisplay" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCreateSVTDisplay { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function creates a new SVT display instance. The display begins loading
terrain tiles for the current aircraft position immediately. You can draw it
as soon as tiles are available; before that, the draw call is a no-op.

The pixelsPerDegree scale and the rectangle you pass to XPLMSVTDisplayDrawIn
together determine the field of view: the rectangle is simply the scale applied
to the view's angular extent. So drawing into a bigger rectangle at the same
scale shows _more_ of the world at the same magnification rather than zooming
in, and to zoom you change the scale, not the rectangle. Pick the same scale
your pitch ladder uses and the 3-d horizon will line up with your artificial
horizon.

Which visual layers are rendered is a property of the draw call, not of the
display - see XPLMSVTDisplayDrawIn.

The returned handle must be destroyed with XPLMDestroySVTDisplay when no
longer needed. Handles are automatically destroyed when the owning plugin is
unloaded.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPLMSVTDisplayRef -> assign to local/var
local my_sVTDisplayRef = XPLMCreateSVTDisplay(
    params     -- see XPLMCreateSVT_t
)</code></pre>
</div>


**See associated types:**

- [XPLMCreateSVT_t](#xplmcreatesvt_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMDestroySVTDisplay" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDestroySVTDisplay { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function destroys an SVT display and frees all associated resources.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMDestroySVTDisplay(
    svt     -- XPLMSVTDisplayRef
)</code></pre>
</div>


**See associated types:**

- [XPLMSVTDisplayRef](#xplmsvtdisplayref)
</div>

---

<div class="sym-block sym-struct" data-name="XPLMSVTCustomData_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSVTCustomData_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local My_SVTCustomData_t = {
    pitchDeg         = 0.0,     -- float
    rollDeg          = 0.0,     -- float
    headingMagDeg    = 0.0,     -- float
    magVarDeg        = 0.0,     -- float
    indicatedAltFt   = 0.0,     -- float
    baroSettingInHg  = 0.0,     -- float
    hsiSource        = 0,       -- int
    hdefDots         = 0.0,     -- float
    vdefDots         = 0.0,     -- float
}</code></pre>
</div>

<div class="field-table" markdown="1">

| Field | Type | Description |
|:--|:--|:--|
| pitchDeg | float | pitch override (degrees). |
| rollDeg | float | roll/bank override (degrees). |
| headingMagDeg | float | magnetic heading override (degrees). |
| magVarDeg | float | magnetic variation override (degrees). |
| indicatedAltFt | float | indicated altitude override (feet). |
| baroSettingInHg | float | altimeter setting override ( inHg). |
| hsiSource | int | HSI source override. |
| hdefDots | float | horizontal CDI deviation override (float). |
| vdefDots | float | vertical GS deviation override (float). |

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMSVTDisplayDrawIn" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSVTDisplayDrawIn { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSVTDisplayDrawIn(
    svt,              -- XPLMSVTDisplayRef
    features,         -- XPLMSVTFeatures
    left,             -- int
    top,              -- int
    right,            -- int
    bottom,           -- int
    dataOverrides     -- see XPLMSVTCustomData_t
)</code></pre>
</div>


**See associated types:**

- [XPLMSVTCustomData_t](#xplmsvtcustomdata_t)
- [XPLMSVTDisplayRef](#xplmsvtdisplayref)
- [XPLMSVTFeatures](#xplmsvtfeatures)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>