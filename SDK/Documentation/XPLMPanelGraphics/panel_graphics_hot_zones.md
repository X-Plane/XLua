<h1>Panel Graphics Hot Zones</h1>

These routines define interactive touch zones on a panel surface. You call
XPLMAccumulateTouchZone during your drawing callback to declare rectangular
regions that respond to mouse clicks or touches. Each zone can either fire
an X-Plane command automatically or deliver raw touch events to a callback
you register with XPLMAvionicsSetTouchEventHandler.

---

<div class="sym-block sym-enum" data-name="XPLMTouchZone" data-type="enum" markdown="1">

## XPLMTouchZone { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

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

## XPLMTouchEvent_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

Your touch event callback is invoked when the user interacts with a touch
zone whose type is xplm_TouchZone_Identifier. You receive the zone's
identifier, the mouse status, the current position, the delta from the
initial click point, and the mouse button involved.

```cpp
typedef void (* XPLMTouchEvent_f)(
                         int                  identifier,
                         XPLMMouseStatus      status,
                         int                  x,
                         int                  y,
                         int                  dx,
                         int                  dy,
                         int                  button,
                         void *               ref
                    );
```

</div>

---

<div class="sym-block sym-struct" data-name="XPLMTouchZoneSpec_t" data-type="struct" markdown="1">

## XPLMTouchZoneSpec_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

XPLMTouchZoneSpec_t describes a single interactive touch zone on the panel.
Pass a pointer to this struct to XPLMAccumulateTouchZone during your drawing
callback. The structure may be expanded in future SDKs - always set
structSize to the size of your structure in bytes.

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

---

<div class="sym-block sym-function" data-name="XPLMAccumulateTouchZone" data-type="function" markdown="1">

## XPLMAccumulateTouchZone { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function registers a touch zone for the current frame. Call this during
your avionics drawing callback each frame for every interactive region on
your panel. Zones registered later take priority over earlier ones when they
overlap.

Returns true if the zone is currently being clicked or held by the user,
false otherwise. You can use this to provide visual feedback (for example,
drawing a button in its pressed state).

```cpp
XPLM_API int        XPLMAccumulateTouchZone(
                         XPLMTouchZoneSpec_t * inSpec
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMAvionicsSetTouchEventHandler" data-type="function" markdown="1">

## XPLMAvionicsSetTouchEventHandler { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function registers a callback to receive touch events for zones of type
xplm_TouchZone_Identifier on a specific avionics device. When the user
interacts with an identifier-type zone, your callback is invoked with the
zone's identifier and the mouse event details.

- avionic: the avionics device handle (from XPLMRegisterAvionicsCallbacksEx
  or XPLMCreateAvionicsEx).
- handler: your XPLMTouchEvent_f callback.
- ref: a reference pointer passed through to your callback.

```cpp
XPLM_API void       XPLMAvionicsSetTouchEventHandler(
                         XPLMAvionicsID       avionic,
                         XPLMTouchEvent_f     handler,    /* Can be NULL */
                         void *               ref
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMWindowSetTouchEventHandler" data-type="function" markdown="1">

## XPLMWindowSetTouchEventHandler { .symbol-title }

<span class="sym-badge badge-fn">function</span>

```cpp
XPLM_API void       XPLMWindowSetTouchEventHandler(
                         XPLMWindowID         window,
                         XPLMTouchEvent_f     handler,    /* Can be NULL */
                         void *               ref
                    );
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>