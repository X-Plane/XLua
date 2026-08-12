<h1>Panel_graphics Transform/Scissors/Masks</h1>

These routines modify the drawing state for subsequent panel graphics calls.
The transformation matrix controls the position, rotation, and scale of all
drawing. The scissor rectangle clips drawing to a rectangular region. The
stencil mask clips drawing to an arbitrary shape.

The transform and the scissor rectangle each have a push/pop stack. Always
push before modifying either one and pop to restore the previous state when
you are done.

The stencil has no stack. Instead the stencil buffer holds up to eight
independent one-bit masks, and you select which of them clips your drawing by
calling XPLMUseStencilMask as often as you like. X-Plane restores the stencil
state for you at the end of your drawing callback.

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

The stencil buffer is eight bits wide, so you can record up to eight
independent masks and pick among them later with XPLMUseStencilMask - one bit
per mask - without having to re-draw them.

- bits: the stencil bit pattern to write into the stencil buffer where
  geometry is drawn.
- mask: a bitmask selecting which stencil bits are written.

Both parameters must be in the range 0 to 255, and every bit set in bits must
also be set in mask - a bit outside the mask can never be written. Stencil
testing must be off (see XPLMUseStencilMask) when you call this.

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
once again render to the screen, and stencil testing is off. Call
XPLMUseStencilMask to start drawing through the mask you just recorded.

The mask stays in the stencil buffer until you overwrite it or call
XPLMClearStencilMask, so you may record several masks up front and then
switch among them.

```cpp
XPLM_API void       XPLMEndSetupStencilMask(void);
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMUseStencilMask" data-type="function" markdown="1">

## XPLMUseStencilMask { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function selects which stencil mask clips your drawing. Subsequent
drawing is clipped to the region you recorded with XPLMBeginSetupStencilMask:
only pixels where the stencil buffer matches the specified bit pattern are
drawn.

- bits: the reference bit pattern to test against.
- mask: a bitmask selecting which stencil bits participate in the test.

Both parameters must be in the range 0 to 255, and every bit set in bits must
also be set in mask - a bit outside the mask can never match.

You may call this as often as you like within one drawing callback to switch
between masks you have recorded; each call replaces the previous test. Pass
(0, 0) to stop stencil testing entirely. You do not have to do that at the
end of your callback - X-Plane turns stencil testing off for you, and for a
window it also clears any mask you recorded, so nothing you draw leaks into
another window.

This function may not be called between XPLMBeginSetupStencilMask and
XPLMEndSetupStencilMask.

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

This function erases the entire stencil buffer, discarding every mask you
have recorded. It does not change whether stencil testing is on - use
XPLMUseStencilMask(0, 0) for that.

Because this throws away all eight masks at once, you rarely need it: to stop
drawing through a mask, call XPLMUseStencilMask(0, 0), and to replace one,
just record over it. It is safe to call at any time as a way of asking for a
known starting state, even if you have recorded nothing.

Stencil testing must be off, and you may not call this between
XPLMBeginSetupStencilMask and XPLMEndSetupStencilMask.

```cpp
XPLM_API void       XPLMClearStencilMask(void);
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>