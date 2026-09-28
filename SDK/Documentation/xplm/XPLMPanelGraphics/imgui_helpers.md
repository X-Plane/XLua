<h1>Imgui Helpers</h1>

These routines let panel graphics render textured indexed triangle meshes
that exactly match the layout produced by Dear ImGui's `ImDrawData`, so a
plugin can plug an ImGui frame straight into X-Plane panel graphics.

Coordinate system: positions and scissors are in panel coordinates under
the current transform, exactly like every other panel-graphics primitive.
Nothing is translated or flipped for you. Dear ImGui works in window-local
pixels with a TOP-LEFT origin and Y increasing downward, so set up that
space with the transform stack before drawing - the same conversion your
mouse handler does in reverse:

    XPLMTransformPush();
    XPLMTransformTranslate(left, top);   // from XPLMGetWindowGeometry; (0, height) on an avionics screen
    XPLMTransformScale(1.0f, -1.0f);     // Y down, as ImGui expects
    XPLMDrawCalls(...);                  // once per ImDrawList
    XPLMTransformPop();

Because the transform is yours, a retained drawing of an ImGui frame
captures the frame itself, not where the window was: replay it under the
translate for the window's current position and it follows the window.

Vertex layout (matches `ImDrawVert` exactly): each vertex is 5 floats =
20 bytes, in this order: pos.x, pos.y, uv.x, uv.y, RGBA8 packed as a
uint32_t in little-endian byte order (R is the low byte). The vertex
stride passed in `XPLMMesh_t::vertices` must be 5 floats per vertex.

Color and alpha: vertex colors and texture pixels are interpreted as
**straight (non-pre-multiplied) alpha** and blended accordingly. Submit
ImGui's `ImDrawData` verts and font atlas as-is (no premultiply) -- this
matches ImGui's own defaults.

Sampler: bilinear filter, clamp-to-edge in both dimensions, no mipmaps.
UV coordinates outside [0,1] sample the edge texels (no wrap).

Scissor: the per-`XPLMDrawCall_t` scissor rect is two opposite corners,
{x1, y1, x2, y2}, in the same space as the vertices - ImGui's `ClipRect`
as-is. It is intersected with the scissor already in force (for example one
set with XPLMScissorSet), so a draw call can narrow the clip but never
escape it. Zero-width or zero-height rects produce no output. The scissor state is automatically saved on entry to
`XPLMDrawCalls` and restored on exit, so subsequent panel-graphics calls
in the same frame are unaffected.

XPLMDrawCalls may only be called while drawing: from a panel-graphics draw
callback, or while recording a retained drawing. XPLMCreateTexture and
XPLMDestroyTexture may be called anywhere.

---

<div class="sym-block sym-struct" data-name="XPLMDrawCall_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDrawCall_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

A single draw call within an `XPLMMesh_t`. Each call binds a texture and a
scissor rect, then draws `element_count` indices starting at
`idx_offset`. `vtx_offset` is added to each fetched index by the GPU
(matching `glDrawElementsBaseVertex` semantics) -- this lets a single mesh
hold multiple sub-meshes whose indices are written relative to their
own start.

<div class="xplm-code" markdown="1">

```cpp
typedef struct {
     void *                    tex_ref;
     float                     scissors[4];
     int                       idx_offset;
     int                       element_count;
     int                       vtx_offset;
} XPLMDrawCall_t;
```

</div>

<div class="field-table" markdown="1">

| Field | Type | Description |
|:--|:--|:--|
| tex_ref | void * | Texture handle from XPLMCreateTexture. That is the ONLY valid source - this is not a general texture handle, and passing anything else (an XPLMTextureAtlasRef, say) is undefined behavior, not a no-op. |
| scissors[4] | float | Clip rect: two opposite corners {x1, y1, x2, y2}, in the same space as the vertices (ImGui's ClipRect as-is). |
| idx_offset | int | First index into XPLMMesh_t::indices to use. |
| element_count | int | Number of indices to consume (must be a multiple of 3 for triangles). Zero is allowed and produces no output. |
| vtx_offset | int | Added to each fetched index before vertex lookup. |

</div>

</div>

---

<div class="sym-block sym-struct" data-name="XPLMMesh_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMesh_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

A vertex/index buffer pair shared across one or more `XPLMDrawCall_t`
entries. The `vertices` array must be `5 * vertex_count` floats long
matching the layout described in the IMGUI HELPERS component desc.
Indices are 16-bit unsigned, matching `ImDrawIdx` at its default
(`#define ImDrawIdx unsigned short`).

<div class="xplm-code" markdown="1">

```cpp
typedef struct {
     int                       vertex_count;
     const float *             vertices;
     int                       index_count;
     const uint16_t*           indices;
} XPLMMesh_t;
```

</div>

<div class="field-table" markdown="1">

| Field | Type | Description |
|:--|:--|:--|
| vertex_count | int |  |
| vertices | const float * | Pointer to vertex_count * 5 floats. |
| index_count | int |  |
| indices | const uint16_t* |  |

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMCreateTexture" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCreateTexture { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Creates a GPU texture from a contiguous RGBA8 byte buffer. The buffer is
read top-to-bottom, with byte order R, G, B, A per pixel. Any width and
height are accepted, including non-power-of-two and 1-pixel-wide strips;
the host does not require power-of-two dimensions.

The returned handle is opaque; pass it to `XPLMDrawCall_t::tex_ref` and
free it with `XPLMDestroyTexture` when done. The sampler used at draw
time is bilinear, clamp-to-edge, no mipmaps.

You may call this anywhere, including inside a panel-graphics draw callback;
the texture can be used by draw calls later in the same callback.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void * XPLMCreateTexture(
                         const unsigned char * rgba_image,
                         int                  width,
                         int                  height
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMDestroyTexture" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDestroyTexture { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Frees a texture obtained from `XPLMCreateTexture`. Do not use the handle
after calling this. It is safe to create and destroy textures every frame.

You may call this anywhere, including inside a panel-graphics draw callback,
even right after drawing with the texture: X-Plane keeps it alive until that
drawing has been rendered. Do not destroy a texture that a retained drawing
still uses - destroy the retained drawing first.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMDestroyTexture(
                         void *               tex_ref
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMDrawCalls" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDrawCalls { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Renders `inCount` draw calls against the shared `inMesh`. Issues one
GPU dispatch per call (each can rebind texture and scissor) but uploads
the mesh only once. `inCount = 0` is a no-op. `element_count = 0` on a
specific draw call is also a no-op for that call.

The scissor state is saved on entry and restored on exit; subsequent
panel-graphics primitives in the same frame are unaffected.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMDrawCalls(
                         const XPLMMesh_t *   inMesh,
                         int                  inCount,
                         const XPLMDrawCall_t inDrawCalls[]
                    );
```

</div>


**See associated types:**

- [XPLMDrawCall_t](#xplmdrawcall_t)
- [XPLMMesh_t](#xplmmesh_t)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>