<h1>X-Plane Coordinates</h1>

These routines allow you to use OpenGL with X-Plane.

---

<div class="sym-block sym-function" data-name="XPLMWorldToLocal" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMWorldToLocal { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine translates coordinates from latitude, longitude, and altitude to local
scene coordinates. Latitude and longitude are in decimal degrees, and altitude is
in meters MSL (mean sea level).  The XYZ coordinates are in meters in the local
OpenGL coordinate system.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMWorldToLocal(
    inLatitude,     -- float
    inLongitude,    -- float
    inAltitude      -- float
)
-- outs = { outX, outY, outZ }</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMLocalToWorld" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMLocalToWorld { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine translates a local coordinate triplet back into latitude, longitude,
and altitude.  Latitude and longitude are in decimal degrees, and altitude is
in meters MSL (mean sea level).  The XYZ coordinates are in meters in the local
OpenGL coordinate system.

NOTE: world coordinates are less precise than local coordinates; you should
try to avoid round tripping from local to world and back.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMLocalToWorld(
    inX,    -- float
    inY,    -- float
    inZ     -- float
)
-- outs = { outLatitude, outLongitude, outAltitude }</code></pre>
</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>