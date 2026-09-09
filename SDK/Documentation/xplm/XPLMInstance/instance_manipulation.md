<h1>Instance Manipulation</h1>

---

<div class="sym-block sym-function" data-name="XPLMInstanceSetPosition" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMInstanceSetPosition { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Updates both the position of the instance and all datarefs you registered for it.  Call this from a flight loop callback or UI callback.

__DO_NOT__ call XPLMInstanceSetPosition from a drawing callback; the whole point of instancing is that you do not need any drawing callbacks.
Setting instance data from a drawing callback may have undefined consequences, and the drawing callback hurts FPS unnecessarily.

The memory pointed to by the data pointer must be large enough to hold one float for every dataref you have registered, and must contain valid
floating point data.

BUG: before X-Plane 11.50, if you have no dataref registered, you must still pass a valid pointer for data and not null.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMInstanceSetPosition(
                         XPLMInstanceRef      instance,
                         const XPLMDrawInfo_t * new_position,
                         const float          data[]
                    );
```

</div>


**See associated types:**

- [XPLMInstanceRef](instance_creation_and_destruction.md#xplminstanceref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMInstanceSetPositionDouble" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMInstanceSetPositionDouble { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM420</span>

</div>

Updates both the position of the instance and all datarefs you registered for it.  Call this from a flight loop callback or UI callback.

__DO_NOT__ call XPLMInstanceSetPositionDouble from a drawing callback; the whole point of instancing is that you do not need any drawing
callbacks. Setting instance data from a drawing callback may have undefined consequences, and the drawing callback hurts FPS unnecessarily.

The memory pointed to by the data pointer must be large enough to hold one float for every dataref you have registered, and must contain valid
floating point data.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMInstanceSetPositionDouble(
                         XPLMInstanceRef      instance,
                         const XPLMDrawInfoDouble_t * new_position,
                         const float          data[]
                    );
```

</div>


**See associated types:**

- [XPLMInstanceRef](instance_creation_and_destruction.md#xplminstanceref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMInstanceSetCoordinateSpace" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMInstanceSetCoordinateSpace { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

XPLMInstanceSetCoordinateSpace changes the coordinate space used to interpret the positions you pass to
XPLMInstanceSetPosition or XPLMInstanceSetPositionDouble. You can set the coordinate space once up front
with XPLMCreateInstanceEx(), or change it on the fly with this call. By default, positions are in world
space. In aircraft space, positions are relative to the specified aircraft's CG and body axes; in camera
space, positions are relative to the camera/view.

For the two aircraft spaces (xplm_CoordSpace_AircraftInterior and xplm_CoordSpace_AircraftExterior),
aircraft_index specifies which aircraft (0 = user's aircraft). For world and camera space, aircraft_index
is ignored.

Changing the coordinate space does not make the instance jump: X-Plane re-expresses the instance's current
world location in the new space, so the object stays exactly where it is and then begins tracking the new
parent. After the change it is up to you to feed positions that are correct for the new space - pushing the
old space's numbers again will move the object.

Auto-shift (XPLMInstanceSetAutoShift) is independent of the coordinate space: changing the space does not
turn auto-shift off, but auto-shift only has an effect while the instance is in world space.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMInstanceSetCoordinateSpace(
                         XPLMInstanceRef      instance,
                         XPLMCoordinateSpace_t space,
                         int                  aircraft_index
                    );
```

</div>


**See associated types:**

- [XPLMCoordinateSpace_t](multiobject_instance_creation.md#xplmcoordinatespace_t)
- [XPLMInstanceRef](instance_creation_and_destruction.md#xplminstanceref)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>