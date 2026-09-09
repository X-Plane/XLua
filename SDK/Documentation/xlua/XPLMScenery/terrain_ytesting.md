<h1>Terrain Y-Testing</h1>

The Y-testing API allows you to locate the physical scenery mesh. This would be used to place dynamic
graphics on top of the ground in a plausible way or do physics interactions.

The Y-test API works via probe objects, which are allocated by your plugin and used to query terrain.
Probe objects exist both to capture which algorithm you have requested (see probe types) and also
to cache query information.

Performance Guidelines
----------------------

It is generally faster to use the same probe for nearby points and different probes for different points.
Try not to allocate more than "hundreds" of probes at most. Share probes if you need more.
Generally, probing operations are expensive, and should be avoided via caching when possible.

Y testing returns a location on the terrain, a normal vector, and a velocity vector. The normal vector
tells you the slope of the terrain at that point. The velocity vector tells you if that terrain is moving
(and is in meters/second). For example, if your Y test hits the aircraft carrier deck, this tells you the
velocity of that point on the deck.

Note: the Y-testing API is limited to probing the loaded scenery area, which is approximately 300x300 km in
X-Plane 9. Probes outside this area will return the height of a 0 MSL sphere.

---

<div class="sym-block sym-enum" data-name="XPLMProbeType" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMProbeType { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

XPLMProbeType defines the type of terrain probe - each probe has a different algorithm. (Only one
type of probe is provided right now, but future APIs will expose more flexible or powerful or useful
probes.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_ProbeY | 0 | The Y probe gives you the location of the tallest physical scenery along the Y axis going through the queried point. |

</div>

**Used by:**

- [XPLMCreateProbe](#xplmcreateprobe)

</div>

---

<div class="sym-block sym-enum" data-name="XPLMProbeResult" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMProbeResult { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

Probe results - possible results from a probe query.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_ProbeHitTerrain | 0 | The probe hit terrain and returned valid values. |
| xplm_ProbeError | 1 | An error in the API call.  Either the probe struct size is bad, the probe is invalid, or the type is mismatched for the specific query call. |
| xplm_ProbeMissed | 2 | The probe call succeeded but there is no terrain under this point (perhaps it is off the side of the planet?) |

</div>

</div>

---

<div class="sym-block sym-typedef" data-name="XPLMProbeRef" data-type="typedef" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMProbeRef { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

</div>

An XPLMProbeRef is an opaque handle to a probe, used for querying the terrain.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local my_probeRef = nil  -- XPLMProbeRef</code></pre>
</div>


**Used by:**

- [XPLMDestroyProbe](#xplmdestroyprobe)
- [XPLMProbeTerrainXYZ](#xplmprobeterrainxyz)
</div>

---

<div class="sym-block sym-struct" data-name="XPLMProbeInfo_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMProbeInfo_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

XPLMProbeInfo_t contains the results of a probe call. Make sure to set structSize to the size of the
struct before using it.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local My_ProbeInfo_t = {
    structSize  = 0,       -- int
    locationX   = 0.0,     -- float
    locationY   = 0.0,     -- float
    locationZ   = 0.0,     -- float
    normalX     = 0.0,     -- float
    normalY     = 0.0,     -- float
    normalZ     = 0.0,     -- float
    velocityX   = 0.0,     -- float
    velocityY   = 0.0,     -- float
    velocityZ   = 0.0,     -- float
    is_wet      = false,   -- boolean
}</code></pre>
</div>

<div class="field-table" markdown="1">

| Field | Type | Description |
|:--|:--|:--|
| structSize | int | Size of structure in bytes - always set this before calling the XPLM. |
| locationX | float | Resulting X location of the terrain point we hit, in local OpenGL coordinates. |
| locationY | float | Resulting Y location of the terrain point we hit, in local OpenGL coordinates. |
| locationZ | float | Resulting Z location of the terrain point we hit, in local OpenGL coordinates. |
| normalX | float | X component of the normal vector to the terrain we found. |
| normalY | float | Y component of the normal vector to the terrain we found. |
| normalZ | float | Z component of the normal vector to the terrain we found. |
| velocityX | float | X component of the velocity vector of the terrain we found. |
| velocityY | float | Y component of the velocity vector of the terrain we found. |
| velocityZ | float | Z component of the velocity vector of the terrain we found. |
| is_wet | boolean | Tells if the surface we hit is water (otherwise it is land). |

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMCreateProbe" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCreateProbe { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Creates a new probe object of a given type and returns.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPLMProbeRef -> assign to local/var
local my_probeRef = XPLMCreateProbe(
    inProbeType     -- XPLMProbeType
)</code></pre>
</div>


**See associated types:**

- [XPLMProbeType](#xplmprobetype)
</div>

---

<div class="sym-block sym-function" data-name="XPLMDestroyProbe" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDestroyProbe { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Deallocates an existing probe object.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMDestroyProbe(
    inProbe     -- XPLMProbeRef
)</code></pre>
</div>


**See associated types:**

- [XPLMProbeRef](#xplmproberef)
</div>

---

<div class="sym-block sym-function" data-name="XPLMProbeTerrainXYZ" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMProbeTerrainXYZ { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Probes the terrain. Pass in the XYZ coordinate of the probe point, a probe object, and an
XPLMProbeInfo_t struct that
has its structSize member set properly. Other fields are filled in if we hit terrain, and a probe result
is returned.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPLMProbeResult -> assign to local/var
local my_probeResult = XPLMProbeTerrainXYZ(
    inProbe,    -- XPLMProbeRef
    inX,        -- float
    inY,        -- float
    inZ,        -- float
    outInfo     -- see XPLMProbeInfo_t
)</code></pre>
</div>


**See associated types:**

- [XPLMProbeInfo_t](#xplmprobeinfo_t)
- [XPLMProbeRef](#xplmproberef)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>