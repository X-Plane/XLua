<h1>X-Plane Graphics</h1>

These routines allow you to use OpenGL with X-Plane.

---

<div class="sym-block sym-enum" data-name="XPLMTextureID" data-type="enum" markdown="1">

## XPLMTextureID { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

XPLM Texture IDs name well-known textures in the sim for you to use.
This allows you to recycle textures from X-Plane, saving VRAM.

*Warning*: do not use these enums.  The only remaining use they have is to
access the legacy compatibility v10 UI texture; if you need this, get it via the
Widgets library.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_Tex_GeneralInterface | 0 | The bitmap that contains window outlines, button outlines, fonts, etc. |
| xplm_Tex_AircraftPaint | 1 | The exterior paint for the user's aircraft (daytime). |
| xplm_Tex_AircraftLiteMap | 2 | The exterior light map for the user's aircraft. |
| xplm_Tex_Radar_Pilot | 3 | The weather radar instrument texture as controlled by the pilot-side radar controls |
| xplm_Tex_Radar_Copilot | 4 | The weather radar instrument texture as controlled by the copilot-side radar controls |

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMSetGraphicsState" data-type="function" markdown="1">

## XPLMSetGraphicsState { .symbol-title }

<span class="sym-badge badge-fn">function</span>

XPLMSetGraphicsState changes OpenGL's fixed function pipeline state.  You are not responsible
for restoring any state that is accessed via XPLMSetGraphicsState, but you are responsible for
not accessing this state directly.

- inEnableFog - enables or disables fog, equivalent to: glEnable(GL_FOG);
- inNumberTexUnits - enables or disables a number of multitexturing units.
  If the number is 0, 2d texturing is disabled entirely, as in
  glDisable(GL_TEXTURE_2D);  Otherwise, 2d texturing is enabled, and
  a number of multitexturing units are enabled sequentially, starting
  with unit 0, e.g. glActiveTextureARB(GL_TEXTURE0_ARB);
  glEnable (GL_TEXTURE_2D);
- inEnableLighting - enables or disables OpenGL lighting, e.g.
  glEnable(GL_LIGHTING); glEnable(GL_LIGHT0);
- inEnableAlphaTesting - enables or disables the alpha test per pixel, e.g.
  glEnable(GL_ALPHA_TEST);
- inEnableAlphaBlending - enables or disables alpha blending per pixel, e.g.
  glEnable(GL_BLEND);
- inEnableDepthTesting - enables per pixel depth testing, as in
  glEnable(GL_DEPTH_TEST);
- inEnableDepthWriting - enables writing back of depth information to the depth
  buffer, as in glDepthMask(GL_TRUE);

The purpose of this function is to change OpenGL state while keeping X-Plane
aware of the state changes; this keeps X-Plane from getting surprised by OGL
state changes, and prevents X-Plane and plug-ins from having to set all state
before all draws; XPLMSetGraphicsState internally skips calls to change state
that is already properly enabled.

X-Plane does not have a 'default' OGL state for plug-ins with respect to the
above state vector; plug-ins should totally set OGL state using this API before
drawing.  Use XPLMSetGraphicsState instead of any of the above OpenGL calls.

WARNING: Any routine that performs drawing (e.g. XPLMDrawString or widget code)
may change X-Plane's state.  Always set state before drawing after unknown code
has executed.

*Deprecation Warnings*: X-Plane's lighting and fog environment is significantly
more complex than the fixed function pipeline can express; do not assume that
lighting and fog state is a good approximation for 3-d drawing.  Prefer to use
XPLMInstancing to draw objects.  All calls to XPLMSetGraphicsState should have
no fog or lighting.

```cpp
XPLM_API void       XPLMSetGraphicsState(
                         int                  inEnableFog,
                         int                  inNumberTexUnits,
                         int                  inEnableLighting,
                         int                  inEnableAlphaTesting,
                         int                  inEnableAlphaBlending,
                         int                  inEnableDepthTesting,
                         int                  inEnableDepthWriting
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMBindTexture2d" data-type="function" markdown="1">

## XPLMBindTexture2d { .symbol-title }

<span class="sym-badge badge-fn">function</span>

XPLMBindTexture2d changes what texture is bound to the 2d texturing target.
This routine caches the current 2d texture across all texturing units in the sim
and plug-ins, preventing extraneous binding.  For example, consider several
plug-ins running in series; if they all use the 'general interface' bitmap to do
UI, calling this function will skip the rebinding of the general interface texture
on all but the first plug-in, which can provide better frame rates on some graphics
cards.

inTextureID is the ID of the texture object to bind; inTextureUnit is a zero-based
texture unit (e.g. 0 for the first one), up to a maximum of 4 units.  (This number
may increase in future versions of X-Plane.)

Use this routine instead of glBindTexture(GL_TEXTURE_2D, ....);

```cpp
XPLM_API void       XPLMBindTexture2d(
                         int                  inTextureNum,
                         int                  inTextureUnit
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMGenerateTextureNumbers" data-type="function" markdown="1">

## XPLMGenerateTextureNumbers { .symbol-title }

<span class="sym-badge badge-fn">function</span>

Use this routine instead of glGenTextures to generate new texture object IDs.
This routine historically ensured that plugins don't use texure IDs that X-Plane is
reserving for its own use.

```cpp
XPLM_API void       XPLMGenerateTextureNumbers(
                         int *                outTextureIDs,
                         int                  inCount
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetTexture" data-type="function" markdown="1">

## XPLMGetTexture { .symbol-title }

<span class="sym-badge badge-fn">function</span>

XPLMGetTexture returns the OpenGL texture ID of an X-Plane texture based on a
generic identifying code.  For example, you can get the texture for X-Plane's
weather radar.

```cpp
XPLM_API int        XPLMGetTexture(
                         XPLMTextureID        inTexture
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMDrawTranslucentDarkBox" data-type="function" markdown="1">

## XPLMDrawTranslucentDarkBox { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This routine draws a translucent dark box, partially obscuring parts of the
screen but making text easy to read.  This is the same graphics primitive used
by X-Plane to show text files.

```cpp
XPLM_API void       XPLMDrawTranslucentDarkBox(
                         int                  inLeft,
                         int                  inTop,
                         int                  inRight,
                         int                  inBottom
                    );
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>