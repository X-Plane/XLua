<h1>Camera Control</h1>

---

<div class="sym-block sym-enum" data-name="XPLMCameraControlDuration" data-type="enum" markdown="1">

## XPLMCameraControlDuration { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

This enumeration states how long you want to retain control of the camera.
You can retain it indefinitely or until the user selects a new view.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_ControlCameraUntilViewChanges | 1 | Control the camera until the user picks a new view. |
| xplm_ControlCameraForever | 2 | Control the camera until your plugin is disabled or another plugin forcibly takes control. |

</div>

</div>

---

<div class="sym-block sym-struct" data-name="XPLMCameraPosition_t" data-type="struct" markdown="1">

## XPLMCameraPosition_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

This structure contains a full specification of the camera. X, Y, and Z are
the camera's position in OpenGL coordinates; pitch, roll, and yaw are rotations
from a camera facing flat north in degrees. Positive pitch means nose up,
positive roll means roll right, and positive yaw means yaw right, all in degrees.
Zoom is a zoom factor, with 1.0 meaning normal zoom and 2.0 magnifying by 2x
(objects appear larger).

```cpp
typedef struct {
     float                     x;
     float                     y;
     float                     z;
     float                     pitch;
     float                     heading;
     float                     roll;
     float                     zoom;
} XPLMCameraPosition_t;
```

</div>

---

<div class="sym-block sym-callback" data-name="XPLMCameraControl_f" data-type="callback" markdown="1">

## XPLMCameraControl_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

You use an XPLMCameraControl function to provide continuous control over the
camera. You are passed a structure in which to put the new camera position;
modify it and return true to reposition the camera. Return false to surrender control
of the camera; camera control will be handled by X-Plane on this draw loop.
The contents of the structure as you are called are undefined.

If X-Plane is taking camera control away from you, this function will be called
with inIsLosingControl set to true and ioCameraPosition NULL.

```cpp
typedef int (* XPLMCameraControl_f)(
                         XPLMCameraPosition_t * outCameraPosition,    /* Can be NULL */
                         int                  inIsLosingControl,
                         void *               inRefcon
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMControlCamera" data-type="function" markdown="1">

## XPLMControlCamera { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function repositions the camera on the next drawing cycle. You must pass
a non-null control function. Specify in inHowLong how long you'd like control
(indefinitely or until a new view mode is set by the user).

```cpp
XPLM_API void       XPLMControlCamera(
                         XPLMCameraControlDuration inHowLong,
                         XPLMCameraControl_f  inControlFunc,
                         void *               inRefcon
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMDontControlCamera" data-type="function" markdown="1">

## XPLMDontControlCamera { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function stops you from controlling the camera. If you have a camera control
function, it will not be called with an inIsLosingControl flag. X-Plane will control
the camera on the next cycle.

For maximum compatibility you should not use this routine unless you are in posession
of the camera.

```cpp
XPLM_API void       XPLMDontControlCamera(void);
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMIsCameraBeingControlled" data-type="function" markdown="1">

## XPLMIsCameraBeingControlled { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This routine returns true if the camera is being controlled, false if it is not. If it
is and you pass in a pointer to a camera control duration, the current control duration
will be returned.

```cpp
XPLM_API int        XPLMIsCameraBeingControlled(
                         XPLMCameraControlDuration * outCameraControlDuration    /* Can be NULL */
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMReadCameraPosition" data-type="function" markdown="1">

## XPLMReadCameraPosition { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function reads the current camera position.

```cpp
XPLM_API void       XPLMReadCameraPosition(
                         XPLMCameraPosition_t * outCameraPosition
                    );
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>