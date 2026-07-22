<h1>Panel Graphics Texture Atlas</h1>

These routines manage texture atlases for drawing images on the panel. A texture
atlas packs multiple source images into a single GPU texture for efficient
rendering. The typical workflow is:

- Create an atlas with XPLMCreateTextureAtlas.
- Add images from files or raw pixel data. Each image (or cell of an image set)
  receives a zero-based index.
- Call XPLMTextureAtlasBake to upload the atlas to the GPU.
- Draw images using the DrawAt, DrawIn, DrawStretched, DrawScaled, or DrawMesh
  routines.
- Destroy the atlas with XPLMDestroyTextureAtlas when it is no longer needed.

All images are stored as RGBA, 4 bytes per pixel.

---

<div class="sym-block sym-typedef" data-name="XPLMTextureAtlasRef" data-type="typedef" markdown="1">

## XPLMTextureAtlasRef { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

An opaque handle to a texture atlas. Create one with XPLMCreateTextureAtlas
and destroy it with XPLMDestroyTextureAtlas.

```cpp
typedef void * XPLMTextureAtlasRef;
```

</div>

---

<div class="sym-block sym-struct" data-name="XPLMTextureVertex_t" data-type="struct" markdown="1">

## XPLMTextureVertex_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

A vertex for textured mesh drawing. Combines a position in panel coordinates
with normalized texture coordinates within the image.

```cpp
typedef struct {
     float                     x;
     float                     y;
     float                     s;
     float                     t;
} XPLMTextureVertex_t;
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMCreateTextureAtlas" data-type="function" markdown="1">

## XPLMCreateTextureAtlas { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function creates a new, empty texture atlas. After creating the atlas,
add images with the XPLMTextureAtlasAddImage or XPLMTextureAtlasAddImageFile
family of functions, then call XPLMTextureAtlasBake before drawing.

Returns an opaque atlas handle.

```cpp
XPLM_API XPLMTextureAtlasRefXPLMCreateTextureAtlas(void);
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMDestroyTextureAtlas" data-type="function" markdown="1">

## XPLMDestroyTextureAtlas { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function destroys a texture atlas and frees all associated GPU and CPU
resources.

```cpp
XPLM_API void       XPLMDestroyTextureAtlas(
                         XPLMTextureAtlasRef  inTextureAtlas
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasAddImageFile" data-type="function" markdown="1">

## XPLMTextureAtlasAddImageFile { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function loads a PNG image file and adds it to the atlas as a single
image. Call this before XPLMTextureAtlasBake.

- inImageFilePath: the file system path to a PNG file.

Returns the zero-based image index assigned to this image.

```cpp
XPLM_API int        XPLMTextureAtlasAddImageFile(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         const char *         inImageFilePath
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasAddImageFileSet" data-type="function" markdown="1">

## XPLMTextureAtlasAddImageFileSet { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function loads a PNG image file and subdivides it into a grid of cells,
adding each cell to the atlas as a separate image. This is useful for sprite
sheets and image strip assets. Call this before XPLMTextureAtlasBake.

- inImageFilePath: the file system path to a PNG file.
- inCellsX: the number of columns to divide the image into.
- inCellsY: the number of rows to divide the image into.

Returns the zero-based image index of the first cell (top-left). Subsequent
cells are numbered in row-major order: index + y * inCellsX + x.

```cpp
XPLM_API int        XPLMTextureAtlasAddImageFileSet(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         const char *         inImageFilePath,
                         int                  inCellsX,
                         int                  inCellsY
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasAddImage" data-type="function" markdown="1">

## XPLMTextureAtlasAddImage { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function adds a single image from raw pixel data to the atlas. The
pixel data must be RGBA format, 4 bytes per pixel, with rows ordered from
top to bottom. Call this before XPLMTextureAtlasBake.

- inImage: pointer to the raw RGBA pixel data.
- inWidth: the image width in pixels.
- inHeight: the image height in pixels.

Returns the zero-based image index assigned to this image.

```cpp
XPLM_API int        XPLMTextureAtlasAddImage(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         const unsigned char * inImage,
                         int                  inWidth,
                         int                  inHeight
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasAddImageSet" data-type="function" markdown="1">

## XPLMTextureAtlasAddImageSet { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function adds raw pixel data to the atlas, subdividing it into a grid
of cells. Each cell is added as a separate image. The pixel data must be
RGBA format, 4 bytes per pixel, with rows ordered from top to bottom. Call
this before XPLMTextureAtlasBake.

- inImage: pointer to the raw RGBA pixel data.
- inWidth: the total image width in pixels.
- inHeight: the total image height in pixels.
- inCellsX: the number of columns to divide the image into.
- inCellsY: the number of rows to divide the image into.

Returns the zero-based image index of the first cell. Subsequent cells are
numbered in row-major order: index + y * inCellsX + x.

```cpp
XPLM_API int        XPLMTextureAtlasAddImageSet(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         const uint8_t *      inImage,
                         int                  inWidth,
                         int                  inHeight,
                         int                  inCellsX,
                         int                  inCellsY
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasBake" data-type="function" markdown="1">

## XPLMTextureAtlasBake { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function packs all previously added images into a GPU texture. You must
call this after adding all images and before any draw calls. Once baked, you
cannot add more images to the atlas.

```cpp
XPLM_API void       XPLMTextureAtlasBake(
                         XPLMTextureAtlasRef  inTextureAtlas
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasGetImageWidth" data-type="function" markdown="1">

## XPLMTextureAtlasGetImageWidth { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function returns the width in pixels of a single image (or cell) in the
atlas.

Returns the image width in pixels.

```cpp
XPLM_API int        XPLMTextureAtlasGetImageWidth(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         int                  inImageIndex
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasGetImageHeight" data-type="function" markdown="1">

## XPLMTextureAtlasGetImageHeight { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function returns the height in pixels of a single image (or cell) in
the atlas.

Returns the image height in pixels.

```cpp
XPLM_API int        XPLMTextureAtlasGetImageHeight(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         int                  inImageIndex
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasGetImageUVMap" data-type="function" markdown="1">

## XPLMTextureAtlasGetImageUVMap { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function returns the UV coordinates of an image within the atlas
texture. This is useful for custom mesh rendering with
XPLMTextureAtlasDrawMesh.

- outUV: a pointer to an array of 4 floats that receives [s1, t1, s2, t2],
  where (s1, t1) is the bottom-left corner and (s2, t2) is the top-right
  corner in atlas texture space.

```cpp
XPLM_API void       XPLMTextureAtlasGetImageUVMap(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         int                  inImageIndex,
                         float *              outUV
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasDrawAt" data-type="function" markdown="1">

## XPLMTextureAtlasDrawAt { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function draws an atlas image at its native resolution. The image is
positioned with its top-left corner at (inX, inY) and extends rightward and
downward by its native pixel dimensions.

- inTintColor: a color that is multiplied with the texture. Use
  XPLMMakeColor(1, 1, 1, 1) for no tinting.
- inX: the left edge of the image, in panel coordinates.
- inY: the top edge of the image, in panel coordinates.

```cpp
XPLM_API void       XPLMTextureAtlasDrawAt(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         int                  inImageIndex,
                         uint32_t             inTintColor,
                         float                inX,
                         float                inY
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasDrawIn" data-type="function" markdown="1">

## XPLMTextureAtlasDrawIn { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function draws an atlas image scaled to fill a rectangular region. The
image is stretched or compressed to exactly match the specified bounds.

- inTintColor: a color that is multiplied with the texture.
- inLeft, inTop, inRight, inBottom: the bounding rectangle in panel
  coordinates.

```cpp
XPLM_API void       XPLMTextureAtlasDrawIn(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         int                  inImageIndex,
                         uint32_t             inTintColor,
                         float                inLeft,
                         float                inTop,
                         float                inRight,
                         float                inBottom
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasDrawStretched" data-type="function" markdown="1">

## XPLMTextureAtlasDrawStretched { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function draws an atlas image using 9-slice scaling into a rectangular
region. The image is divided into a 3x3 grid (each slice being one third of
the original width and height). The four corner slices are drawn at their
native size, the four edge slices are stretched along one axis, and the
center slice is stretched in both directions. This preserves corners and
borders when scaling UI elements like buttons or panels.

- inTintColor: a color that is multiplied with the texture.
- inLeft, inTop, inRight, inBottom: the bounding rectangle in panel
  coordinates.

```cpp
XPLM_API void       XPLMTextureAtlasDrawStretched(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         int                  inImageIndex,
                         uint32_t             inTintColor,
                         float                inLeft,
                         float                inTop,
                         float                inRight,
                         float                inBottom
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasDrawScaled" data-type="function" markdown="1">

## XPLMTextureAtlasDrawScaled { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function draws an atlas image with arbitrary scaling, rotation, and
positioning. The image is placed so that the atlas-space pivot point
(inXAtlas, inYAtlas) aligns with the panel-space position (inXPanel,
inYPanel), then scaled and rotated around that point.

- inTintColor: a color that is multiplied with the texture.
- inXPanel, inYPanel: the destination point in panel coordinates.
- inXAtlas, inYAtlas: the pivot point within the image, in pixels from
  the image's bottom-left corner.
- inXScale, inYScale: horizontal and vertical scale factors. 1.0 draws at
  native resolution.
- inRotateCW: clockwise rotation in degrees around the pivot point.

```cpp
XPLM_API void       XPLMTextureAtlasDrawScaled(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         int                  inImageIndex,
                         uint32_t             inTintColor,
                         float                inXPanel,
                         float                inYPanel,
                         float                inXAtlas,
                         float                inYAtlas,
                         float                inXScale,
                         float                inYScale,
                         float                inRotateCW
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureAtlasDrawMesh" data-type="function" markdown="1">

## XPLMTextureAtlasDrawMesh { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function draws an atlas image onto an arbitrary triangle-strip mesh.
Each vertex specifies both a panel-space position and a normalized texture
coordinate within the image (0.0 to 1.0). This gives you full control over
how the image is mapped onto geometry.

- inTintColor: a color that is multiplied with the texture.
- vertices: an array of XPLMTextureVertex_t vertices defining the triangle
  strip.
- count: the number of vertices. Must be at least 3.

```cpp
XPLM_API void       XPLMTextureAtlasDrawMesh(
                         XPLMTextureAtlasRef  inTextureAtlas,
                         int                  inImageIndex,
                         uint32_t             inTintColor,
                         const XPLMTextureVertex_t * vertices,
                         ArraySize            count
                    );
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>