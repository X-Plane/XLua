<h1>Panel Graphics Primitives</h1>

These routines draw 2-D vector primitives: lines, line strips, line loops,
filled polygons, and quad strips.

Line-based primitives (Lines, LineStrip, LineLoop) have four variants:

- Base variant: uniform color, default line width.
- WithWidth variant: uniform color, caller-specified line width.
- "c" variant: per-vertex color (using XPLMVertexColor_t), default line width.
- "c" + WithWidth variant: per-vertex color and caller-specified line width.

They also have a Stipple variant that draws dashed lines with a caller-specified
dash length and line width.

Filled primitives (Polygon, Quadstrip) have no line width, so they come in only
the base and "c" variants.

---

<div class="sym-block sym-struct" data-name="XPLMVertex_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMVertex_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

A 2-D vertex with an x and y position in panel coordinates.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local My_Vertex_t = {
    x  = 0.0,     -- float
    y  = 0.0,     -- float
}</code></pre>
</div>

</div>

---

<div class="sym-block sym-struct" data-name="XPLMVertexColor_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMVertexColor_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

A 2-D vertex with an x and y position in panel coordinates and a per-vertex
color. Use this struct with the "c" drawing variants to assign a different color
to each vertex; colors are interpolated across the primitive.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local My_VertexColor_t = {
    x      = 0.0,     -- float
    y      = 0.0,     -- float
    color  = nil,     -- see uint32_t / XPLMMakeColor
}</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMMakeColor" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMakeColor { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function packs four floating-point color components into a single uint32_t
suitable for use with all panel graphics drawing routines. Each component is in
the range 0.0 to 1.0 and is clamped before packing. The returned value is in
ABGR byte order (alpha in the high byte, red in the low byte).

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns uint32_t -> assign to local/var
local my_result = XPLMMakeColor(
    red,      -- float
    green,    -- float
    blue,     -- float
    alpha     -- float
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMLines" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMLines { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws disconnected line segments. Every pair of vertices defines
one segment: the first segment runs from vertices[0] to vertices[1], the second
from vertices[2] to vertices[3], and so on.

- count: the number of vertices. Must be even.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMLines(
    color,       -- see uint32_t / XPLMMakeColor
    vertices,    -- see XPLMVertex_t
    count        -- ArraySize
)</code></pre>
</div>


**See associated types:**

- [XPLMMakeColor](#xplmmakecolor)
- [XPLMVertex_t](#xplmvertex_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMLinesWithWidth" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMLinesWithWidth { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws disconnected line segments with a caller-specified line
width. Vertex interpretation is the same as XPLMLines.

- lineWidth: the line width in pixels.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMLinesWithWidth(
    color,        -- see uint32_t / XPLMMakeColor
    lineWidth,    -- float
    vertices,     -- see XPLMVertex_t
    count         -- ArraySize
)</code></pre>
</div>


**See associated types:**

- [XPLMMakeColor](#xplmmakecolor)
- [XPLMVertex_t](#xplmvertex_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMLinesc" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMLinesc { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws disconnected line segments with per-vertex colors.
Vertex interpretation is the same as XPLMLines; colors are interpolated along
each segment.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMLinesc(
    vertices,    -- see XPLMVertexColor_t
    count        -- ArraySize
)</code></pre>
</div>


**See associated types:**

- [XPLMVertexColor_t](#xplmvertexcolor_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMLinescWithWidth" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMLinescWithWidth { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws disconnected line segments with per-vertex colors and a
caller-specified line width.

- lineWidth: the line width in pixels.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMLinescWithWidth(
    lineWidth,    -- float
    vertices,     -- see XPLMVertexColor_t
    count         -- ArraySize
)</code></pre>
</div>


**See associated types:**

- [XPLMVertexColor_t](#xplmvertexcolor_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMLinesStipple" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMLinesStipple { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws disconnected dashed line segments. Vertex interpretation
is the same as XPLMLines. The dash pattern alternates between drawn and
undrawn segments of equal length.

- dashLength: the length of each dash and gap, in pixels.
- lineWidth: the line width in pixels.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMLinesStipple(
    color,         -- see uint32_t / XPLMMakeColor
    pts,           -- see XPLMVertex_t
    count,         -- ArraySize
    dashLength,    -- float
    lineWidth      -- float
)</code></pre>
</div>


**See associated types:**

- [XPLMMakeColor](#xplmmakecolor)
- [XPLMVertex_t](#xplmvertex_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMLineStrip" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMLineStrip { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws a connected line strip. Vertices are connected in order:
a segment from vertices[0] to vertices[1], then from vertices[1] to
vertices[2], and so on. The last vertex is not connected back to the first.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMLineStrip(
    color,    -- see uint32_t / XPLMMakeColor
    pts,      -- see XPLMVertex_t
    count     -- ArraySize
)</code></pre>
</div>


**See associated types:**

- [XPLMMakeColor](#xplmmakecolor)
- [XPLMVertex_t](#xplmvertex_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMLineStripWithWidth" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMLineStripWithWidth { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws a connected line strip with a caller-specified line width.
Vertex interpretation is the same as XPLMLineStrip.

- lineWidth: the line width in pixels.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMLineStripWithWidth(
    color,        -- see uint32_t / XPLMMakeColor
    lineWidth,    -- float
    pts,          -- see XPLMVertex_t
    count         -- ArraySize
)</code></pre>
</div>


**See associated types:**

- [XPLMMakeColor](#xplmmakecolor)
- [XPLMVertex_t](#xplmvertex_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMLineStripc" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMLineStripc { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws a connected line strip with per-vertex colors. Vertex
interpretation is the same as XPLMLineStrip; colors are interpolated along
each segment.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMLineStripc(
    pts,      -- see XPLMVertexColor_t
    count     -- ArraySize
)</code></pre>
</div>


**See associated types:**

- [XPLMVertexColor_t](#xplmvertexcolor_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMLineStripcWithWidth" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMLineStripcWithWidth { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws a connected line strip with per-vertex colors and a
caller-specified line width.

- lineWidth: the line width in pixels.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMLineStripcWithWidth(
    lineWidth,    -- float
    pts,          -- see XPLMVertexColor_t
    count         -- ArraySize
)</code></pre>
</div>


**See associated types:**

- [XPLMVertexColor_t](#xplmvertexcolor_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMLineStripStipple" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMLineStripStipple { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws a connected dashed line strip. Vertex interpretation is
the same as XPLMLineStrip. The dash pattern alternates between drawn and
undrawn segments of equal length.

- dashLength: the length of each dash and gap, in pixels.
- lineWidth: the line width in pixels.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMLineStripStipple(
    color,         -- see uint32_t / XPLMMakeColor
    pts,           -- see XPLMVertex_t
    count,         -- ArraySize
    dashLength,    -- float
    lineWidth      -- float
)</code></pre>
</div>


**See associated types:**

- [XPLMMakeColor](#xplmmakecolor)
- [XPLMVertex_t](#xplmvertex_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMLineLoop" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMLineLoop { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws a closed line loop. Vertices are connected in order, and
the last vertex is automatically connected back to the first, forming a closed
shape. The interior is not filled.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMLineLoop(
    color,    -- see uint32_t / XPLMMakeColor
    pts,      -- see XPLMVertex_t
    count     -- ArraySize
)</code></pre>
</div>


**See associated types:**

- [XPLMMakeColor](#xplmmakecolor)
- [XPLMVertex_t](#xplmvertex_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMLineLoopWithWidth" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMLineLoopWithWidth { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws a closed line loop with a caller-specified line width.
Vertex interpretation is the same as XPLMLineLoop.

- lineWidth: the line width in pixels.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMLineLoopWithWidth(
    color,        -- see uint32_t / XPLMMakeColor
    lineWidth,    -- float
    pts,          -- see XPLMVertex_t
    count         -- ArraySize
)</code></pre>
</div>


**See associated types:**

- [XPLMMakeColor](#xplmmakecolor)
- [XPLMVertex_t](#xplmvertex_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMLineLoopc" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMLineLoopc { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws a closed line loop with per-vertex colors. Vertex
interpretation is the same as XPLMLineLoop; colors are interpolated along
each segment.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMLineLoopc(
    pts,      -- see XPLMVertexColor_t
    count     -- ArraySize
)</code></pre>
</div>


**See associated types:**

- [XPLMVertexColor_t](#xplmvertexcolor_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMLineLoopcWithWidth" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMLineLoopcWithWidth { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws a closed line loop with per-vertex colors and a
caller-specified line width.

- lineWidth: the line width in pixels.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMLineLoopcWithWidth(
    lineWidth,    -- float
    pts,          -- see XPLMVertexColor_t
    count         -- ArraySize
)</code></pre>
</div>


**See associated types:**

- [XPLMVertexColor_t](#xplmvertexcolor_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMLineLoopStipple" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMLineLoopStipple { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws a closed dashed line loop. Vertex interpretation is
the same as XPLMLineLoop. The dash pattern alternates between drawn and
undrawn segments of equal length.

- dashLength: the length of each dash and gap, in pixels.
- lineWidth: the line width in pixels.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMLineLoopStipple(
    color,         -- see uint32_t / XPLMMakeColor
    pts,           -- see XPLMVertex_t
    count,         -- ArraySize
    dashLength,    -- float
    lineWidth      -- float
)</code></pre>
</div>


**See associated types:**

- [XPLMMakeColor](#xplmmakecolor)
- [XPLMVertex_t](#xplmvertex_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMPolygon" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMPolygon { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws a filled convex polygon. The vertices define the outline
of the polygon, and the interior is filled with the specified color.

- count: the number of vertices. You must provide at least 3 vertices.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMPolygon(
    color,       -- see uint32_t / XPLMMakeColor
    vertices,    -- see XPLMVertex_t
    count        -- ArraySize
)</code></pre>
</div>


**See associated types:**

- [XPLMMakeColor](#xplmmakecolor)
- [XPLMVertex_t](#xplmvertex_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMPolygonc" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMPolygonc { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws a filled convex polygon with per-vertex colors. Colors
are interpolated across the polygon interior.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMPolygonc(
    vertices,    -- see XPLMVertexColor_t
    count        -- ArraySize
)</code></pre>
</div>


**See associated types:**

- [XPLMVertexColor_t](#xplmvertexcolor_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMQuadstrip" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMQuadstrip { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws a series of connected filled quadrilaterals. Vertices
are taken in pairs: the first quad is formed by vertices[0], vertices[1],
vertices[2], vertices[3]; the next quad shares its leading edge with the
previous one, formed by vertices[2], vertices[3], vertices[4], vertices[5];
and so on.

- count: the number of vertices. Must be even and at least 4.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMQuadstrip(
    color,       -- see uint32_t / XPLMMakeColor
    vertices,    -- see XPLMVertex_t
    count        -- ArraySize
)</code></pre>
</div>


**See associated types:**

- [XPLMMakeColor](#xplmmakecolor)
- [XPLMVertex_t](#xplmvertex_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMQuadstripc" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMQuadstripc { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws a quad strip with per-vertex colors. Vertex
interpretation is the same as XPLMQuadstrip; colors are interpolated across
each quad.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMQuadstripc(
    vertices,    -- see XPLMVertexColor_t
    count        -- ArraySize
)</code></pre>
</div>


**See associated types:**

- [XPLMVertexColor_t](#xplmvertexcolor_t)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>