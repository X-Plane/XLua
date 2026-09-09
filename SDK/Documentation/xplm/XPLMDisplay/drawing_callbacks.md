<h1>Drawing Callbacks</h1>

Basic drawing callbacks, for low level intercepting of X-Plane's render loop.
The purpose of drawing callbacks is to provide targeted additions or
replacements to X-Plane's graphics environment (for example, to add extra
custom objects, or replace drawing of the AI aircraft).  Do not assume that
the drawing callbacks will be called in the order implied by the enumerations.
Also do not assume that each drawing phase ends before another begins; they
may be nested.

Note that all APIs in this section are deprecated, and will likely be removed
during the X-Plane 11 run as part of the transition to Vulkan/Metal/etc. See the
XPLMInstance API for future-proof drawing of 3-D objects.

---

<div class="sym-block sym-enum" data-name="XPLMDrawingPhase" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDrawingPhase { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

This constant indicates which part of drawing we are in.  Drawing is done
from the back to the front.  We get a callback before or after each item.
Metaphases provide access to the beginning and end of the 3d (scene) and
2d (cockpit) drawing in a manner that is independent of new phases added
via X-Plane implementation.

**NOTE**: As of XPLM302 the legacy 3D drawing phases (xplm_Phase_FirstScene
to xplm_Phase_LastScene) are deprecated. When running under X-Plane 11.50
with the modern Vulkan or Metal backend, X-Plane will no longer call
these drawing phases. There is a new drawing phase, xplm_Phase_Modern3D,
which is supported under OpenGL and Vulkan which is called out roughly
where the old before xplm_Phase_Airplanes phase was for blending. This
phase is *NOT* supported under Metal and comes with potentially substantial
performance overhead. Please do *NOT* opt into this phase if you don't do
any actual drawing that requires the depth buffer in some way!

**WARNING**: As X-Plane's scenery evolves, some drawing phases may cease to
exist and new ones may be invented.  If you need a particularly specific
use of these codes, consult Austin and/or be prepared to revise your
code as X-Plane evolves.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_Phase_FirstScene | 0 | Deprecated as of XPLM302. This is the earliest point at which you can draw in 3-d. |
| xplm_Phase_Terrain | 5 | Deprecated as of XPLM302. Drawing of land and water. |
| xplm_Phase_Airports | 10 | Deprecated as of XPLM302. Drawing runways and other airport detail. |
| xplm_Phase_Vectors | 15 | Deprecated as of XPLM302. Drawing roads, trails, trains, etc. |
| xplm_Phase_Objects | 20 | Deprecated as of XPLM302. 3-d objects (houses, smokestacks, etc. |
| xplm_Phase_Airplanes | 25 | Deprecated as of XPLM302. External views of airplanes, both yours and the AI aircraft. |
| xplm_Phase_LastScene | 30 | Deprecated as of XPLM302. This is the last point at which you can draw in 3-d. |
| xplm_Phase_Modern3D | 31 | A chance to do modern 3D drawing. |
| xplm_Phase_FirstCockpit | 35 | This is the first phase where you can draw in 2-d. |
| xplm_Phase_Panel | 40 | The non-moving parts of the aircraft panel. |
| xplm_Phase_Gauges | 45 | The moving parts of the aircraft panel. |
| xplm_Phase_Window | 50 | Floating windows from plugins. |
| xplm_Phase_LastCockpit | 55 | The last chance to draw in 2d. |
| xplm_Phase_LocalMap3D | 100 | Removed as of XPLM300; Use the full-blown XPLMMap API instead. |
| xplm_Phase_LocalMap2D | 101 | Removed as of XPLM300; Use the full-blown XPLMMap API instead. |
| xplm_Phase_LocalMapProfile | 102 | Removed as of XPLM300; Use the full-blown XPLMMap API instead. |

</div>

**Used by:**

- [XPLMDrawCallback_f](#xplmdrawcallback_f)
- [XPLMRegisterDrawCallback](#xplmregisterdrawcallback)
- [XPLMUnregisterDrawCallback](#xplmunregisterdrawcallback)

</div>

---

<div class="sym-block sym-callback" data-name="XPLMDrawCallback_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDrawCallback_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

This is the prototype for a low level drawing callback.  You are passed in the phase
and whether it is before or after.  If you are before the phase, return true to let
X-Plane draw or false to suppress X-Plane drawing.  If you are after the phase the return
value is ignored.

Refcon is a unique value that you specify when registering the callback, allowing you
to slip a pointer to your own data to the callback.

Upon entry the OpenGL context will be correctly set up for you and OpenGL will be in
'local' coordinates for 3d drawing and panel coordinates for 2d drawing.  The OpenGL
state (texturing, etc.) will be unknown.

<div class="xplm-code" markdown="1">

```cpp
typedef int (* XPLMDrawCallback_f)(
                         XPLMDrawingPhase     inPhase,
                         int                  inIsBefore,
                         void*                inRefcon
                    );
```

</div>


**See associated types:**

- [XPLMDrawingPhase](#xplmdrawingphase)
</div>

---

<div class="sym-block sym-function sym-deprecated-block" data-name="XPLMRegisterDrawCallback" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMRegisterDrawCallback { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-deprecated">deprecated XPLM300</span>

</div>

This routine registers a low level drawing callback.  Pass in the phase you want
to be called for and whether you want to be called before or after.  This routine
returns true if the registration was successful, or false if the phase does not exist in
this version of X-Plane.  You may register a callback multiple times for the same or
different phases as long as the refcon is unique each time.

Note that this function will likely be removed during the X-Plane 11 run as part of the
transition to Vulkan/Metal/etc. See the XPLMInstance API for future-proof drawing of 3-D objects.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMRegisterDrawCallback(
                         XPLMDrawCallback_f   inCallback,
                         XPLMDrawingPhase     inPhase,
                         int                  inWantsBefore,
                         void*                inRefcon
                    );
```

</div>


**See associated types:**

- [XPLMDrawCallback_f](#xplmdrawcallback_f)
- [XPLMDrawingPhase](#xplmdrawingphase)
</div>

---

<div class="sym-block sym-function sym-deprecated-block" data-name="XPLMUnregisterDrawCallback" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMUnregisterDrawCallback { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-deprecated">deprecated XPLM300</span>

</div>

This routine unregisters a draw callback.  You must unregister a callback for each
time you register a callback if you have registered it multiple times with different
refcons.  The routine returns true if it can find the callback to unregister, false otherwise.

Note that this function will likely be removed during the X-Plane 11 run as part of the
transition to Vulkan/Metal/etc. See the XPLMInstance API for future-proof drawing of 3-D objects.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMUnregisterDrawCallback(
                         XPLMDrawCallback_f   inCallback,
                         XPLMDrawingPhase     inPhase,
                         int                  inWantsBefore,
                         void*                inRefcon
                    );
```

</div>


**See associated types:**

- [XPLMDrawCallback_f](#xplmdrawcallback_f)
- [XPLMDrawingPhase](#xplmdrawingphase)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>