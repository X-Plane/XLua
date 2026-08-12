<h1>Panel Graphics Radar Texture</h1>

These routines draw stock simulator textures, such as weather radar displays,
into your avionics panel. Unlike texture atlas images which are loaded from
files you provide, texture sources are live textures rendered by the simulator
each frame. If the aircraft does not have the requested hardware (e.g. no
weather radar installed), the draw call is silently skipped.

---

<div class="sym-block sym-enum" data-name="XPLMTextureSource" data-type="enum" markdown="1">

## XPLMTextureSource { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

An XPLMTextureSource identifies a stock simulator texture that can be drawn
with the texture source drawing functions.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_Texture_WeatherRadar1 | 0 | The pilot-side weather radar display. |
| xplm_Texture_WeatherRadar2 | 1 | The copilot-side weather radar display. |

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureSourceDrawIn" data-type="function" markdown="1">

## XPLMTextureSourceDrawIn { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function draws a texture source scaled to fill a rectangular region. The
texture is stretched or compressed to exactly match the specified bounds.

- tex: the texture source to draw.
- tint: a color that is multiplied with the texture. Use
  XPLMMakeColor(1, 1, 1, 1) for no tinting.
- left, top, right, bottom: the bounding rectangle in panel coordinates.

```cpp
XPLM_API void       XPLMTextureSourceDrawIn(
                         XPLMTextureSource    tex,
                         uint32_t             tint,
                         int                  left,
                         int                  top,
                         int                  right,
                         int                  bottom
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMTextureSourceDrawMesh" data-type="function" markdown="1">

## XPLMTextureSourceDrawMesh { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function draws a texture source onto an arbitrary triangle-strip mesh.
Each vertex specifies both a panel-space position and a normalized texture
coordinate (0.0 to 1.0) within the source texture. This gives you full
control over how the texture is mapped onto geometry.

- tex: the texture source to draw.
- tint: a color that is multiplied with the texture.
- mesh: an array of XPLMTextureVertex_t vertices defining the triangle strip.
- count: the number of vertices. Must be at least 3.

```cpp
XPLM_API void       XPLMTextureSourceDrawMesh(
                         XPLMTextureSource    tex,
                         uint32_t             tint,
                         const XPLMTextureVertex_t * mesh,
                         ArraySize            count
                    );
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>