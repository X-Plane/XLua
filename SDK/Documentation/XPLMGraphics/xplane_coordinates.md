<h1>X-Plane Coordinates</h1>

These routines allow you to use OpenGL with X-Plane.

---

<div class="sym-block sym-function" data-name="XPLMWorldToLocal" data-type="function" markdown="1">

## XPLMWorldToLocal { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This routine translates coordinates from latitude, longitude, and altitude to local
scene coordinates. Latitude and longitude are in decimal degrees, and altitude is
in meters MSL (mean sea level).  The XYZ coordinates are in meters in the local
OpenGL coordinate system.

```cpp
XPLM_API void       XPLMWorldToLocal(
                         double               inLatitude,
                         double               inLongitude,
                         double               inAltitude,
                         double *             outX,
                         double *             outY,
                         double *             outZ
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMLocalToWorld" data-type="function" markdown="1">

## XPLMLocalToWorld { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This routine translates a local coordinate triplet back into latitude, longitude,
and altitude.  Latitude and longitude are in decimal degrees, and altitude is
in meters MSL (mean sea level).  The XYZ coordinates are in meters in the local
OpenGL coordinate system.

NOTE: world coordinates are less precise than local coordinates; you should
try to avoid round tripping from local to world and back.

```cpp
XPLM_API void       XPLMLocalToWorld(
                         double               inX,
                         double               inY,
                         double               inZ,
                         double *             outLatitude,
                         double *             outLongitude,
                         double *             outAltitude
                    );
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>