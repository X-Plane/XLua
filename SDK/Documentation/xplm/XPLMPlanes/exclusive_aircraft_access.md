<h1>Exclusive Aircraft Access</h1>

The following routines require exclusive access to the airplane APIs.
Only one plugin may have this access at a time.

---

<div class="sym-block sym-callback" data-name="XPLMPlanesAvailable_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMPlanesAvailable_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

Your airplanes available callback is called when another plugin gives
up access to the multiplayer planes.  Use this to wait for access
to multiplayer.

<div class="xplm-code" markdown="1">

```cpp
typedef void (* XPLMPlanesAvailable_f)(
                         void*                inRefcon
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMAcquirePlanes" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMAcquirePlanes { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

XPLMAcquirePlanes grants your plugin exclusive access to the
aircraft.  It returns true if you gain access, false if you do not.

inAircraft - pass in an array of pointers to strings specifying
the planes you want loaded.  For any plane index you do not
want loaded, pass a 0-length string.  Other strings should be
full paths with the .acf extension.  NULL terminates this array,
or pass NULL if there are no planes you want loaded.

Aircraft paths for this API are full, not relative aircraft paths.

If you pass in a callback and do not receive access to the planes
your callback will be called when the airplanes are available.
If you do receive airplane access, your callback will not be called.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMAcquirePlanes(
                         char const*          inAircraft[],    /* Can be NULL */
                         XPLMPlanesAvailable_f inCallback,    /* Can be NULL */
                         void*                inRefcon
                    );
```

</div>


**See associated types:**

- [XPLMPlanesAvailable_f](#xplmplanesavailable_f)
</div>

---

<div class="sym-block sym-function" data-name="XPLMReleasePlanes" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMReleasePlanes { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Call this function to release access to the planes.  Note that if
you are disabled, access to planes is released for you and you must
reacquire it.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMReleasePlanes(void);
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMSetActiveAircraftCount" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetActiveAircraftCount { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine sets the number of active planes.  If you pass in a number
higher than the total number of planes availables, only the total number
of planes available is actually used.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMSetActiveAircraftCount(
                         int                  inCount
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMSetAircraftModel" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetAircraftModel { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine loads an aircraft model.  It may only be called if you
have exclusive access to the airplane APIs.  Pass in the path of the
model with the .acf extension.  The index is zero based, but you
may not pass in 0 (use XPLMSetUsersAircraft to load the user's aircracft).

This API takes a full aircraft path.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMSetAircraftModel(
                         int                  inIndex,
                         const char *         inAircraftPath
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMDisableAIForPlane" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDisableAIForPlane { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine turns off X-Plane's AI for a given plane.  The plane
will continue to draw and be a real plane in X-Plane, but will not
move itself.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMDisableAIForPlane(
                         int                  inPlaneIndex
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMDrawAircraft" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDrawAircraft { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-deprecated">XPLM_DEPRECATED</span>

</div>

WARNING: Aircraft drawing via this API is deprecated and WILL NOT WORK in future
versions of X-Plane.  Use XPLMInstance for 3-d drawing of custom aircraft models.

This routine draws an aircraft.  It can only be called from a 3-d drawing
callback.  Pass in the position of the plane in OpenGL local coordinates
and the orientation of the plane.  True for full drawing indicates that the
whole plane must be drawn; false indicates you only need the nav lights drawn.
(This saves rendering time when planes are far away.)

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMDrawAircraft(
                         int                  inPlaneIndex,
                         float                inX,
                         float                inY,
                         float                inZ,
                         float                inPitch,
                         float                inRoll,
                         float                inYaw,
                         int                  inFullDraw,
                         XPLMPlaneDrawState_t * inDrawStateInfo
                    );
```

</div>


**See associated types:**

- [XPLMPlaneDrawState_t](global_aircraft_access.md#xplmplanedrawstate_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMReinitUsersPlane" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMReinitUsersPlane { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-deprecated">XPLM_DEPRECATED</span>

</div>

WARNING: DO NOT USE.  Use XPLMPlaceUserAtAirport or XPLMPlaceUserAtLocation.

This function recomputes the derived flight model data from the aircraft structure in
memory.  If you have used the data access layer to modify the aircraft structure,
use this routine to resynchronize X-Plane; since X-Plane works at least partly from
derived values, the sim will not behave properly until this is called.

WARNING: this routine does not necessarily place the airplane at the airport; use
XPLMSetUsersAircraft to be compatible.  This routine is provided to do special
experimentation with flight models without resetting flight.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMReinitUsersPlane(void);
```

</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>