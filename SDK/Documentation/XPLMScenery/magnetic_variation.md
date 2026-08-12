<h1>Magnetic Variation</h1>

Use the magnetic variation (more properly, the "magnetic declination") API to find the offset of magnetic north
from true north at a given latitude and longitude within the simulator.

In the real world, the Earth's magnetic field is irregular, such that true north (the direction along a meridian
toward the north pole) does not necessarily match what a magnetic compass shows as north.

Using this API ensures that you present the same offsets to users as X-Plane's built-in instruments.

---

<div class="sym-block sym-function" data-name="XPLMGetMagneticVariation" data-type="function" markdown="1">

## XPLMGetMagneticVariation { .symbol-title }

<span class="sym-badge badge-fn">function</span>

Returns X-Plane's simulated magnetic variation (declination) at the indication latitude and longitude.

```cpp
XPLM_API float      XPLMGetMagneticVariation(
                         double               latitude,
                         double               longitude
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMDegTrueToDegMagnetic" data-type="function" markdown="1">

## XPLMDegTrueToDegMagnetic { .symbol-title }

<span class="sym-badge badge-fn">function</span>

Converts a heading in degrees relative to true north into a value relative to magnetic north at the user's current location.

```cpp
XPLM_API float      XPLMDegTrueToDegMagnetic(
                         float                headingDegreesTrue
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMDegMagneticToDegTrue" data-type="function" markdown="1">

## XPLMDegMagneticToDegTrue { .symbol-title }

<span class="sym-badge badge-fn">function</span>

Converts a heading in degrees relative to magnetic north at the user's current location into a value relative to true north.

```cpp
XPLM_API float      XPLMDegMagneticToDegTrue(
                         float                headingDegreesMagnetic
                    );
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>