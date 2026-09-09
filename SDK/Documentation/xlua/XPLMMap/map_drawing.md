<h1>Map Drawing</h1>

These APIs are only valid from within a map drawing callback (one of XPLMIconDrawingCallback_t or XPLMMapLabelDrawingCallback_f).
Your drawing callbacks are registered when you create a new map layer as part of your XPLMCreateMapLayer_t.
The functions here hook into X-Plane's built-in map drawing functionality for icons and labels, so that you
get a consistent style with the rest of the X-Plane map.

Note that the X-Plane 11 map introduces a strict ordering: layers of type xplm_MapLayer_Fill get drawn beneath
all xplm_MapLayer_Markings layers. Likewise, all OpenGL drawing (performed in your layer's XPLMMapDrawingCallback_f)
will appear beneath any icons and labels you draw.

---

<div class="sym-block sym-enum" data-name="XPLMMapOrientation" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMapOrientation { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

Indicates whether a map element should be match its rotation to the map itself, or to the user interface.
For instance, the map itself may be rotated such that "up" matches the user's aircraft, but you may want
to draw a text label such that it is always rotated zero degrees relative to the user's perspective.
In that case, you would have it draw with UI orientation.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_MapOrientation_Map | 0 | Orient such that a 0 degree rotation matches the map's north |
| xplm_MapOrientation_UI | 1 | Orient such that a 0 degree rotation is "up" relative to the user interface |

</div>

**Used by:**

- [XPLMDrawMapIconFromSheet](#xplmdrawmapiconfromsheet)
- [XPLMDrawMapLabel](#xplmdrawmaplabel)

</div>

---

<div class="sym-block sym-function" data-name="XPLMDrawMapIconFromSheet" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDrawMapIconFromSheet { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Enables plugin-created map layers to draw PNG icons using X-Plane's built-in icon drawing functionality.
Only valid from within an XPLMIconDrawingCallback_t (but you can request an arbitrary number of icons
to be drawn from within your callback).

X-Plane will automatically manage the memory for your texture so that it only has to be loaded from disk
once as long as you continue drawing it per-frame. (When you stop drawing it, the memory may purged in
a "garbage collection" pass, require a load from disk in the future.)

Instead of having X-Plane draw a full PNG, this method allows you to use UV coordinates to
request a portion of the image to be drawn. This allows you to use a single texture load (of an icon sheet,
for example) to draw many icons. Doing so is much more efficient than drawing a dozen different small PNGs.

The UV coordinates used here treat the texture you load as being comprised of a number of identically sized "cells".
You specify the width and height in cells (ds and dt, respectively), as well as the coordinates within
the cell grid for the sub-image you'd like to draw.

Note that you can use different ds and dt values in subsequent calls with the same texture sheet.
This enables you to use icons of different sizes in the same sheet if you arrange them properly in the PNG.

This function is only valid from within an XPLMIconDrawingCallback_t
(but you can request an arbitrary number of icons to be drawn from within your callback).

- layer: the map layer you want to add icons to.
- inPngPath: an X-Plane-relative path to the PNG you would like to draw as an icon.
- s: the column index of the sub-image (cell) you want to draw; 0 is the leftmost column,
  ds - 1 is the rightmost.
- t: the row index of the sub-image (cell) you want to draw; 0 is the bottommost row,
  dt - 1 is the topmost.
- ds, dt: the number of columns and rows in your texture sheet.
- mapX, mapY: the coordinate (in map units) at which the icon should be centered.
- orientation: the orientation of the icon; this affects what the rotation parameter is
  defined relative to.
- rotationDegrees: the rotation, in degrees, of the icon relative to your orientation.
  Depending on the orientation, this is relative either to the map's 'up' or the UI's
  'up'---not north.
- mapWidth: the width (in map units) of the icon. Note that the icon's height will be scaled
  relative to its width.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMDrawMapIconFromSheet(
    layer,              -- XPLMMapLayerID
    inPngPath,          -- string
    s,                  -- int
    t,                  -- int
    ds,                 -- int
    dt,                 -- int
    mapX,               -- float
    mapY,               -- float
    orientation,        -- XPLMMapOrientation
    rotationDegrees,    -- float
    mapWidth            -- float
)</code></pre>
</div>


**See associated types:**

- [XPLMMapLayerID](drawing_callbacks.md#xplmmaplayerid)
- [XPLMMapOrientation](#xplmmaporientation)
</div>

---

<div class="sym-block sym-function" data-name="XPLMDrawMapLabel" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDrawMapLabel { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Enables plugin-created map layers to draw text labels using X-Plane's built-in labeling functionality.
Only valid from within an XPLMMapLabelDrawingCallback_f
(but you can request an arbitrary number of text labels to be drawn from within your callback).

- layer: the map layer you want to add labels to.
- mapX, mapY: the coordinate (in map units) at which the text should be centered.
- orientation: the orientation of the text; this affects what the rotation parameter is
  defined relative to.
- rotationDegrees: the rotation, in degrees, of the text relative to your orientation.
  Depending on the orientation, this is relative either to the map's 'up' or the UI's
  'up'---not north.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMDrawMapLabel(
    layer,              -- XPLMMapLayerID
    inText,             -- string
    mapX,               -- float
    mapY,               -- float
    orientation,        -- XPLMMapOrientation
    rotationDegrees     -- float
)</code></pre>
</div>


**See associated types:**

- [XPLMMapLayerID](drawing_callbacks.md#xplmmaplayerid)
- [XPLMMapOrientation](#xplmmaporientation)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>