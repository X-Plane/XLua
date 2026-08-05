<h1>Panel_graphics Transform/Scissors/Masks</h1>

These routines modify the drawing state for subsequent panel graphics calls.
The transformation matrix controls the position, rotation, and scale of all
drawing. The scissor rectangle clips drawing to a rectangular region. The
stencil mask clips drawing to an arbitrary shape.

Each state type has a push/pop stack. Always push before modifying state and
pop to restore the previous state when you are done.

---

<div class="sym-block sym-function" data-name="XPLMTransformPush" data-type="function" markdown="1">

## XPLMTransformPush { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function saves the current transformation matrix onto the transform
stack. Call XPLMTransformPop to restore it. Calls must be balanced.

```cpp
XPLM_API void       XPLMTransformPush(void);
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMTransformPop" data-type="function" markdown="1">

## XPLMTransformPop { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function restores the transformation matrix from the top of the
transform stack, undoing all translate, rotate, and scale operations since
the matching XPLMTransformPush.

```cpp
XPLM_API void       XPLMTransformPop(void);
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMTransformTranslate" data-type="function" markdown="1">

## XPLMTransformTranslate { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function translates (offsets) all subsequent drawing by the specified
amounts. The translation is applied on top of the current transformation
matrix.

- dx: horizontal offset in pixels, positive to the right.
- dy: vertical offset in pixels, positive upward.

```cpp
XPLM_API void       XPLMTransformTranslate(
                         float                dx,
                         float                dy
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMTransformRotate" data-type="function" markdown="1">

## XPLMTransformRotate { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function rotates all subsequent drawing around a center point. The
rotation is applied on top of the current transformation matrix.

- centerX, centerY: the center of rotation in panel coordinates.
- angle: the rotation angle in degrees, positive counterclockwise.

```cpp
XPLM_API void       XPLMTransformRotate(
                         float                centerX,
                         float                centerY,
                         float                angle
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMTransformScale" data-type="function" markdown="1">

## XPLMTransformScale { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function scales all subsequent drawing relative to the origin of the
current coordinate system. The scale is applied on top of the current
transformation matrix.

- scaleX: horizontal scale factor. 1.0 is no change, 2.0 doubles width.
- scaleY: vertical scale factor. 1.0 is no change, 2.0 doubles height.

```cpp
XPLM_API void       XPLMTransformScale(
                         float                scaleX,
                         float                scaleY
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMScissorPush" data-type="function" markdown="1">

## XPLMScissorPush { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function saves the current scissor rectangle onto the scissor stack.
Call XPLMScissorPop to restore it. Calls must be balanced.

```cpp
XPLM_API void       XPLMScissorPush(void);
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMScissorPop" data-type="function" markdown="1">

## XPLMScissorPop { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function restores the scissor rectangle from the top of the scissor
stack, undoing any set or shrink operations since the matching
XPLMScissorPush.

```cpp
XPLM_API void       XPLMScissorPop(void);
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMScissorSet" data-type="function" markdown="1">

## XPLMScissorSet { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function sets an absolute scissor rectangle. Only pixels within this
rectangle are drawn; everything outside is clipped.

- left, top, right, bottom: the scissor bounds in panel coordinates.

```cpp
XPLM_API void       XPLMScissorSet(
                         int                  left,
                         int                  top,
                         int                  right,
                         int                  bottom
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMScissorIntersect" data-type="function" markdown="1">

## XPLMScissorIntersect { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function sets the scissors box to the intersection of the existing
scissors box. The result is always a same or smaller drawable area.
This is useful for nested clipping.

- left: inset from the left edge, in pixels.
- top: inset from the top edge, in pixels.
- right: inset from the right edge, in pixels.
- bottom: inset from the bottom edge, in pixels.

```cpp
XPLM_API void       XPLMScissorIntersect(
                         int                  left,
                         int                  top,
                         int                  right,
                         int                  bottom
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMBeginSetupStencilMask" data-type="function" markdown="1">

## XPLMBeginSetupStencilMask { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function begins stencil mask setup. While in setup mode, drawing
commands write to the stencil buffer instead of to the screen. Draw the
shapes that define your mask region, then call XPLMEndSetupStencilMask to
finish.

- bits: the stencil bit pattern to write into the stencil buffer where
  geometry is drawn.
- mask: a bitmask selecting which stencil bits are written.

```cpp
XPLM_API void       XPLMBeginSetupStencilMask(
                         unsigned int         bits,
                         unsigned int         mask
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMEndSetupStencilMask" data-type="function" markdown="1">

## XPLMEndSetupStencilMask { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function ends stencil mask setup. After this call, drawing commands
once again render to the screen. Call XPLMUseStencilMask to activate the
mask for subsequent drawing, or XPLMClearStencilMask to discard it.

```cpp
XPLM_API void       XPLMEndSetupStencilMask(void);
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMUseStencilMask" data-type="function" markdown="1">

## XPLMUseStencilMask { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function activates stencil testing. Subsequent drawing is clipped to
the region defined during stencil setup: only pixels where the stencil
buffer matches the specified bit pattern are drawn.

- bits: the reference bit pattern to test against.
- mask: a bitmask selecting which stencil bits participate in the test.

```cpp
XPLM_API void       XPLMUseStencilMask(
                         unsigned int         bits,
                         unsigned int         mask
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMClearStencilMask" data-type="function" markdown="1">

## XPLMClearStencilMask { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function clears the stencil buffer and disables stencil testing.
Subsequent drawing is no longer clipped by the stencil mask.

```cpp
XPLM_API void       XPLMClearStencilMask(void);
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>