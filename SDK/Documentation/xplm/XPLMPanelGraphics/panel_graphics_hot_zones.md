<h1>Panel Graphics Hot Zones</h1>

These routines define interactive touch zones on a panel surface. You call
XPLMAccumulateTouchZone during your drawing callback to declare rectangular
regions that respond to mouse clicks or touches. Each zone can either fire
an X-Plane command automatically or deliver raw touch events to a callback
you register with XPLMAvionicsSetTouchEventHandler.

A touch zone rides the transform stack, exactly like the drawing it sits on
top of. Declare the zone in the same coordinates you drew in and X-Plane
applies the transform in force for you - do not offset or scale the rectangle
yourself, or the transform will be applied twice. This is the whole point:
draw a button and put a zone on it using the same numbers, under any
combination of translates and scales, and the two stay together.

The transform runs both ways, so your XPLMTouchEvent_f never has to undo it
either. The x and y you receive are in the coordinate system that was in
force when you declared the zone, and dx and dy are scaled to match - you can
compare them directly against the numbers you drew with.

Two limits follow from a zone being an axis-aligned rectangle:

- Do not declare a zone while a rotation is in effect. An axis-aligned
  rectangle cannot describe a rotated graphic, so this is an error.
- A zone cannot be declared inside a XPLMBeginRetainedDrawing recording. A
  zone is per-frame state rather than drawing, and a retained drawing holds
  drawing only. Accumulate your zones outside the recording, once per frame;
  they are cheap to re-declare and are meant to be re-declared.

---

<div class="sym-block sym-enum" data-name="XPLMTouchZone" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTouchZone { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

This enumeration specifies how a touch zone responds to user interaction.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_TouchZone_Nothing | 0 | The zone is registered but takes no action when touched. |
| xplm_TouchZone_Command | 1 | The zone fires an XPLMCommandRef when touched (begin on mouse-down, end on mouse-up). |
| xplm_TouchZone_Identifier | 2 | The zone delivers touch events to the callback registered via XPLMAvionicsSetTouchEventHandler, identified by the zone's identifier field. |

</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMTouchEvent_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTouchEvent_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

Your touch event callback is invoked when the user interacts with a touch
zone whose type is xplm_TouchZone_Identifier. You receive the zone's
identifier, the mouse status, the current position, the delta from the
initial click point, and the mouse button involved.

The position and the deltas are in the coordinate system that was in force
when you declared the zone with XPLMAccumulateTouchZone, so they are directly
comparable to the numbers you drew and declared with - you do not need to
undo the transform stack, and you do not need the window or device geometry
to make sense of them. The coordinate system is latched when the gesture
begins, so every event in one drag arrives in the same space even if you move
or rescale the zone part way through.

<div class="xplm-code" markdown="1">

```cpp
typedef void (* XPLMTouchEvent_f)(
                         int                  identifier,
                         XPLMMouseStatus      status,
                         int                  x,
                         int                  y,
                         int                  dx,
                         int                  dy,
                         int                  button,
                         void*                ref
                    );
```

</div>

</div>

---

<div class="sym-block sym-struct" data-name="XPLMTouchZoneSpec_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMTouchZoneSpec_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

XPLMTouchZoneSpec_t describes a single interactive touch zone on the panel.
Pass a pointer to this struct to XPLMAccumulateTouchZone during your drawing
callback. The structure may be expanded in future SDKs - always set
structSize to the size of your structure in bytes.

<div class="xplm-code" markdown="1">

```cpp
typedef struct {
     int                       structSize;
     XPLMTouchZone             type;
     XPLMCommandRef            command;
     int                       identifier;
     int                       left;
     int                       top;
     int                       right;
     int                       bottom;
} XPLMTouchZoneSpec_t;
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMAccumulateTouchZone" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMAccumulateTouchZone { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function registers a touch zone for the current frame. Call this during
your avionics drawing callback each frame for every interactive region on
your panel. Zones registered later take priority over earlier ones when they
overlap.

The rectangle is in the coordinates you are drawing in: X-Plane puts it
through the transform stack for you, so pass the same numbers you drew the
button with and do not apply the offset or scale yourself.

Returns true if the zone is currently being clicked or held by the user,
false otherwise. You can use this to provide visual feedback (for example,
drawing a button in its pressed state).

Calling this while a rotation is in effect, or while recording a retained
drawing, is an error. See the section description above for why.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMAccumulateTouchZone(
                         XPLMTouchZoneSpec_t * inSpec
                    );
```

</div>


**See associated types:**

- [XPLMTouchZoneSpec_t](#xplmtouchzonespec_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMAvionicsSetTouchEventHandler" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMAvionicsSetTouchEventHandler { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function registers a callback to receive touch events for zones of type
xplm_TouchZone_Identifier on a specific avionics device. When the user
interacts with an identifier-type zone, your callback is invoked with the
zone's identifier and the mouse event details.

- avionic: the avionics device handle (from XPLMRegisterAvionicsCallbacksEx
  or XPLMCreateAvionicsEx).
- handler: your XPLMTouchEvent_f callback.
- ref: a reference pointer passed through to your callback.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMAvionicsSetTouchEventHandler(
                         XPLMAvionicsID       avionic,
                         XPLMTouchEvent_f     handler,    /* Can be NULL */
                         void*                ref
                    );
```

</div>


**See associated types:**

- [XPLMTouchEvent_f](#xplmtouchevent_f)
</div>

---

<div class="sym-block sym-function" data-name="XPLMWindowSetTouchEventHandler" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMWindowSetTouchEventHandler { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function registers a callback to receive touch events for zones of type
xplm_TouchZone_Identifier accumulated by a window's drawing callback. It is
the window equivalent of XPLMAvionicsSetTouchEventHandler.

Note that only the registration is thread safe. Your XPLMTouchEvent_f itself
is always called on the main thread, so it is free to call anything a callback
may normally call - including
XPLMGetWindowGeometry. In practice you should not need the geometry: the
coordinates you are handed are already in the space you declared the zone in.

- window: the window whose touch zones this handler serves.
- handler: your XPLMTouchEvent_f callback.
- ref: a reference pointer passed through to your callback.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMWindowSetTouchEventHandler(
                         XPLMWindowID         window,
                         XPLMTouchEvent_f     handler,    /* Can be NULL */
                         void*                ref
                    );
```

</div>


**See associated types:**

- [XPLMTouchEvent_f](#xplmtouchevent_f)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>