<h1>Panel Graphics Texture Atlas</h1>

These routines manage texture atlases for drawing images on the panel. A texture
atlas packs multiple source images into a single GPU texture for efficient
rendering. The typical workflow is:

- Create an atlas with XPLMCreateTextureAtlas.
- Add images from files or raw pixel data. Each image (or cell of an image set)
  receives a zero-based index. Every routine below that takes an inImageIndex
  requires an index that one of the add routines returned to you.
- Call XPLMTextureAtlasBake to upload the atlas to the GPU.
- Draw images using the DrawAt, DrawIn, DrawStretched, DrawScaled, or DrawMesh
  routines.
- Destroy the atlas with XPLMDestroyTextureAtlas when it is no longer needed.

All images are stored as RGBA, 4 bytes per pixel.

That order is a requirement, not a suggestion. An atlas is either being filled or
baked, and most routines here have a precondition on which of the two it is: the
XPLMTextureAtlasAddImage family and XPLMTextureAtlasBake require an atlas that has
not been baked, and every draw routine requires one that has. Each routine states
its own precondition below. X-Plane reports a violated precondition to your error
callback and to Log.txt so that you can find it, but a violated precondition is a
bug in your plugin, so no return value is defined for one - do not write code that
tests for it.

XPLMDestroyTextureAtlas, XPLMTextureAtlasGetImageWidth and
XPLMTextureAtlasGetImageHeight have no precondition on the bake state - they are
legal at any point in an atlas's life. In particular you can measure your images before you
bake, which is usually when you want to know: laying out a panel around art you
have added but not yet packed.

---

<div class="sym-block sym-typedef" data-name="XPLMTextureAtlasRef" data-type="typedef" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTextureAtlasRef { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

</div>

An opaque handle to a texture atlas. Create one with XPLMCreateTextureAtlas
and destroy it with XPLMDestroyTextureAtlas.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local my_textureAtlasRef = nil  -- XPLMTextureAtlasRef</code></pre>
</div>


**Used by:**

- [XPLMDestroyTextureAtlas](#xplmdestroytextureatlas)
- [XPLMTextureAtlasAddImage](#xplmtextureatlasaddimage)
- [XPLMTextureAtlasAddImageFile](#xplmtextureatlasaddimagefile)
- [XPLMTextureAtlasAddImageFileSet](#xplmtextureatlasaddimagefileset)
- [XPLMTextureAtlasBake](#xplmtextureatlasbake)
- [XPLMTextureAtlasDrawAt](#xplmtextureatlasdrawat)
- [XPLMTextureAtlasDrawIn](#xplmtextureatlasdrawin)
- [XPLMTextureAtlasDrawMesh](#xplmtextureatlasdrawmesh)
- [XPLMTextureAtlasDrawScaled](#xplmtextureatlasdrawscaled)
- [XPLMTextureAtlasDrawStretched](#xplmtextureatlasdrawstretched)
- [XPLMTextureAtlasGetImageHeight](#xplmtextureatlasgetimageheight)
- [XPLMTextureAtlasGetImageWidth](#xplmtextureatlasgetimagewidth)
</div>

---

<div class="sym-block sym-struct" data-name="XPLMTextureVertex_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTextureVertex_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

A vertex for textured mesh drawing. Combines a position in panel coordinates
with normalized texture coordinates within the image.

Texture coordinates are always relative to the image you are drawing, never to
the atlas sheet it happens to be packed into. This is true for both
XPLMTextureAtlasDrawMesh and XPLMTextureSourceDrawMesh, so the same vertex
array means the same thing to either one.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local My_TextureVertex_t = {
    x  = 0.0,     -- float
    y  = 0.0,     -- float
    s  = 0.0,     -- float
    t  = 0.0,     -- float
}</code></pre>
</div>

<div class="field-table" markdown="1">

| Field | Type | Description |
|:--|:--|:--|
| x | float | Horizontal position in panel coordinates, pixels. |
| y | float | Vertical position in panel coordinates, pixels. |
| s | float | Horizontal texture coordinate, 0.0 (left) to 1.0 (right), within the image. |
| t | float | Vertical texture coordinate, 0.0 (bottom) to 1.0 (top), within the image. |

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMCreateTextureAtlas" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCreateTextureAtlas { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function creates a new, empty texture atlas. After creating the atlas,
add images with the XPLMTextureAtlasAddImage or XPLMTextureAtlasAddImageFile
family of functions, then call XPLMTextureAtlasBake before drawing.

Returns an opaque atlas handle.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPLMTextureAtlasRef -> assign to local/var
local my_textureAtlasRef = XPLMCreateTextureAtlas(
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMDestroyTextureAtlas" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDestroyTextureAtlas { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function destroys a texture atlas and frees all associated GPU and CPU
resources.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMDestroyTextureAtlas(
    inTextureAtlas     -- XPLMTextureAtlasRef
)</code></pre>
</div>


**See associated types:**

- [XPLMTextureAtlasRef](#xplmtextureatlasref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasAddImageFile" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTextureAtlasAddImageFile { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function loads a PNG image file and adds it to the atlas as a single
image. The atlas must not have been baked yet.

- inImageFilePath: the file system path to a PNG file.

Returns the zero-based image index assigned to this image.

Returns -1 if the image could not be loaded.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPLMTextureAtlasAddImageFile(
    inTextureAtlas,     -- XPLMTextureAtlasRef
    inImageFilePath     -- string
)</code></pre>
</div>


**See associated types:**

- [XPLMTextureAtlasRef](#xplmtextureatlasref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasAddImageFileSet" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTextureAtlasAddImageFileSet { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function loads a PNG image file and subdivides it into a grid of cells,
adding each cell to the atlas as a separate image. This is useful for sprite
sheets and image strip assets. The atlas must not have been baked yet.

- inImageFilePath: the file system path to a PNG file.
- inCellsX: the number of columns to divide the image into.
- inCellsY: the number of rows to divide the image into.

Returns the zero-based image index of the first cell (top-left). Subsequent
cells are numbered in row-major order: index + y * inCellsX + x.

Returns -1 if the image could not be loaded.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPLMTextureAtlasAddImageFileSet(
    inTextureAtlas,     -- XPLMTextureAtlasRef
    inImageFilePath,    -- string
    inCellsX,           -- int
    inCellsY            -- int
)</code></pre>
</div>


**See associated types:**

- [XPLMTextureAtlasRef](#xplmtextureatlasref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasAddImage" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTextureAtlasAddImage { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function adds a single image from raw pixel data to the atlas. The
pixel data must be RGBA format, 4 bytes per pixel, with rows ordered from
top to bottom. The atlas must not have been baked yet.

- inImage: pointer to the raw RGBA pixel data.
- inWidth: the image width in pixels.
- inHeight: the image height in pixels.

Returns the zero-based image index assigned to this image.

Returns -1 if the image could not be loaded.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPLMTextureAtlasAddImage(
    inTextureAtlas,    -- XPLMTextureAtlasRef
    inImage,           -- unsigned char
    inWidth,           -- int
    inHeight           -- int
)</code></pre>
</div>


**See associated types:**

- [XPLMTextureAtlasRef](#xplmtextureatlasref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasBake" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTextureAtlasBake { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function packs all previously added images into a GPU texture. Call it
after adding all of your images and before any draw calls. The atlas must not have
been baked yet - an atlas is baked exactly once, and takes no more images after
that.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMTextureAtlasBake(
    inTextureAtlas     -- XPLMTextureAtlasRef
)</code></pre>
</div>


**See associated types:**

- [XPLMTextureAtlasRef](#xplmtextureatlasref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasGetImageWidth" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTextureAtlasGetImageWidth { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function returns the width in pixels of a single image (or cell) in the
atlas. This works both before and after XPLMTextureAtlasBake, and returns the same
answer either way - packing an atlas never resizes your images.

Returns the image width in pixels.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPLMTextureAtlasGetImageWidth(
    inTextureAtlas,    -- XPLMTextureAtlasRef
    inImageIndex       -- int
)</code></pre>
</div>


**See associated types:**

- [XPLMTextureAtlasRef](#xplmtextureatlasref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasGetImageHeight" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTextureAtlasGetImageHeight { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function returns the height in pixels of a single image (or cell) in
the atlas. This works both before and after XPLMTextureAtlasBake, and returns the
same answer either way - packing an atlas never resizes your images.

Returns the image height in pixels.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPLMTextureAtlasGetImageHeight(
    inTextureAtlas,    -- XPLMTextureAtlasRef
    inImageIndex       -- int
)</code></pre>
</div>


**See associated types:**

- [XPLMTextureAtlasRef](#xplmtextureatlasref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasDrawAt" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTextureAtlasDrawAt { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws an atlas image at its native resolution. The image is
positioned with its top-left corner at (inX, inY) and extends rightward and
downward by its native pixel dimensions. The atlas must already be baked.

- inTintColor: a color that is multiplied with the texture. Use
  XPLMMakeColor(1, 1, 1, 1) for no tinting.
- inX: the left edge of the image, in panel coordinates.
- inY: the top edge of the image, in panel coordinates.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMTextureAtlasDrawAt(
    inTextureAtlas,    -- XPLMTextureAtlasRef
    inImageIndex,      -- int
    inTintColor,       -- see uint32_t / XPLMMakeColor
    inX,               -- float
    inY                -- float
)</code></pre>
</div>


**See associated types:**

- [XPLMTextureAtlasRef](#xplmtextureatlasref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasDrawIn" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTextureAtlasDrawIn { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws an atlas image scaled to fill a rectangular region. The
image is stretched or compressed to exactly match the specified bounds.
The atlas must already be baked.

- inTintColor: a color that is multiplied with the texture.
- inLeft, inTop, inRight, inBottom: the bounding rectangle in panel
  coordinates.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMTextureAtlasDrawIn(
    inTextureAtlas,    -- XPLMTextureAtlasRef
    inImageIndex,      -- int
    inTintColor,       -- see uint32_t / XPLMMakeColor
    inLeft,            -- float
    inTop,             -- float
    inRight,           -- float
    inBottom           -- float
)</code></pre>
</div>


**See associated types:**

- [XPLMTextureAtlasRef](#xplmtextureatlasref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasDrawStretched" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTextureAtlasDrawStretched { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws an atlas image using 9-slice scaling into a rectangular
region. The image is divided into a 3x3 grid (each slice being one third of
the original width and height). The four corner slices are drawn at their
native size, the four edge slices are stretched along one axis, and the
center slice is stretched in both directions. This preserves corners and
borders when scaling UI elements like buttons or panels.
The atlas must already be baked.

- inTintColor: a color that is multiplied with the texture.
- inLeft, inTop, inRight, inBottom: the bounding rectangle in panel
  coordinates.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMTextureAtlasDrawStretched(
    inTextureAtlas,    -- XPLMTextureAtlasRef
    inImageIndex,      -- int
    inTintColor,       -- see uint32_t / XPLMMakeColor
    inLeft,            -- float
    inTop,             -- float
    inRight,           -- float
    inBottom           -- float
)</code></pre>
</div>


**See associated types:**

- [XPLMTextureAtlasRef](#xplmtextureatlasref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasDrawScaled" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTextureAtlasDrawScaled { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws an atlas image with arbitrary scaling, rotation, and
positioning. The image is placed so that the atlas-space pivot point
(inXAtlas, inYAtlas) aligns with the panel-space position (inXPanel,
inYPanel), then scaled and rotated around that point.
The atlas must already be baked.

- inTintColor: a color that is multiplied with the texture.
- inXPanel, inYPanel: the destination point in panel coordinates.
- inXAtlas, inYAtlas: the pivot point within the image, in pixels from
  the image's bottom-left corner.
- inXScale, inYScale: horizontal and vertical scale factors. 1.0 draws at
  native resolution.
- inRotateCW: clockwise rotation in degrees around the pivot point.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMTextureAtlasDrawScaled(
    inTextureAtlas,    -- XPLMTextureAtlasRef
    inImageIndex,      -- int
    inTintColor,       -- see uint32_t / XPLMMakeColor
    inXPanel,          -- float
    inYPanel,          -- float
    inXAtlas,          -- float
    inYAtlas,          -- float
    inXScale,          -- float
    inYScale,          -- float
    inRotateCW         -- float
)</code></pre>
</div>


**See associated types:**

- [XPLMTextureAtlasRef](#xplmtextureatlasref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasDrawMesh" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTextureAtlasDrawMesh { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function draws an atlas image onto an arbitrary triangle-strip mesh.
Each vertex specifies both a panel-space position and a normalized texture
coordinate within the image (0.0 to 1.0). This gives you full control over
how the image is mapped onto geometry.

Texture coordinates are relative to the image, not to the atlas sheet; the
mapping onto wherever the image was packed is applied for you, exactly as it
is for the other atlas drawing routines. One consequence is that the same
vertex array can be drawn with any inImageIndex - you do not have to rebuild
the mesh to switch images.

Coordinates outside 0.0 to 1.0 are not clamped, and will sample whatever
neighboring image shares the atlas sheet. Keep them in range.

- inTintColor: a color that is multiplied with the texture.
- vertices: an array of XPLMTextureVertex_t vertices defining the triangle
  strip.
- count: the number of vertices. Must be at least 3.

The atlas must already be baked.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMTextureAtlasDrawMesh(
    inTextureAtlas,    -- XPLMTextureAtlasRef
    inImageIndex,      -- int
    inTintColor,       -- see uint32_t / XPLMMakeColor
    vertices,          -- see XPLMTextureVertex_t
    count              -- ArraySize
)</code></pre>
</div>


**See associated types:**

- [XPLMTextureAtlasRef](#xplmtextureatlasref)
- [XPLMTextureVertex_t](#xplmtexturevertex_t)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>