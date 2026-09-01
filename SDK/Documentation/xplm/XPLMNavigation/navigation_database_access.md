<h1>Navigation Database Access</h1>

---

<div class="sym-block sym-typedef" data-name="XPLMNavRef" data-type="typedef" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMNavRef { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

</div>

XPLMNavRef is an iterator into the navigation database.  The navigation
database is essentially an array, but it is not necessarily densely populated.
The only assumption you can safely make is that like-typed nav-aids are
grouped together.

Use XPLMNavRef to refer to a nav-aid.

XPLM_NAV_NOT_FOUND is returned by functions that return an XPLMNavRef
when the iterator must be invalid.

<div class="xplm-code" markdown="1">

```cpp
typedef int XPLMNavRef;
```

</div>


**Used by:**

- [XPLMGetFMSEntryInfo](flight_management_computer.md#xplmgetfmsentryinfo)
- [XPLMGetFMSFlightPlanEntryInfo](flight_management_computer.md#xplmgetfmsflightplanentryinfo)
- [XPLMGetNavAidInfo](#xplmgetnavaidinfo)
- [XPLMGetNextNavAid](#xplmgetnextnavaid)
- [XPLMSetFMSEntryInfo](flight_management_computer.md#xplmsetfmsentryinfo)
- [XPLMSetFMSFlightPlanEntryInfo](flight_management_computer.md#xplmsetfmsflightplanentryinfo)
</div>

---

<div class="sym-block sym-enum" data-name="XPLMNavType" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMNavType { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

These enumerations define the different types of navaids.  They are each
defined with a separate bit so that they may be bit-wise added together
to form sets of nav-aid types.

NOTE: xplm_Nav_LatLon is a specific lat-lon coordinate entered into the FMS.
It will not exist in the database, and cannot be programmed into the FMS.
Querying the FMS for navaids will return it.  Use XPLMSetFMSEntryLatLon to
set a lat/lon waypoint.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_Nav_Unknown | 0 |  |
| xplm_Nav_Airport | 1 |  |
| xplm_Nav_NDB | 2 |  |
| xplm_Nav_VOR | 4 |  |
| xplm_Nav_ILS | 8 |  |
| xplm_Nav_Localizer | 16 |  |
| xplm_Nav_GlideSlope | 32 |  |
| xplm_Nav_OuterMarker | 64 |  |
| xplm_Nav_MiddleMarker | 128 |  |
| xplm_Nav_InnerMarker | 256 |  |
| xplm_Nav_Fix | 512 |  |
| xplm_Nav_DME | 1024 |  |
| xplm_Nav_LatLon | 2048 |  |
| xplm_Nav_TACAN | 4096 |  |

</div>

**Used by:**

- [XPLMFindFirstNavAidOfType](#xplmfindfirstnavaidoftype)
- [XPLMFindLastNavAidOfType](#xplmfindlastnavaidoftype)
- [XPLMFindNavAid](#xplmfindnavaid)
- [XPLMGetFMSEntryInfo](flight_management_computer.md#xplmgetfmsentryinfo)
- [XPLMGetFMSFlightPlanEntryInfo](flight_management_computer.md#xplmgetfmsflightplanentryinfo)
- [XPLMGetNavAidInfo](#xplmgetnavaidinfo)

</div>

---

<div class="sym-block sym-define" data-name="XPLM_NAV_NOT_FOUND" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_NAV_NOT_FOUND { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_NAV_NOT_FOUND -1`

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetFirstNavAid" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetFirstNavAid { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This returns the very first navaid in the database.  Use this to traverse
the entire database.  Returns XPLM_NAV_NOT_FOUND if the nav database is empty.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API XPLMNavRef XPLMGetFirstNavAid(void);
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetNextNavAid" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetNextNavAid { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Given a valid navaid ref, this routine returns the next navaid.  It returns
XPLM_NAV_NOT_FOUND if the navaid passed in was invalid or if the navaid
passed in was the last one in the database.  Use this routine to iterate
across all like-typed navaids or the entire database.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API XPLMNavRef XPLMGetNextNavAid(
                         XPLMNavRef           inNavAidRef
                    );
```

</div>


**See associated types:**

- [XPLMNavRef](#xplmnavref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMFindFirstNavAidOfType" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMFindFirstNavAidOfType { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the ref of the first navaid of the given type in the
database or XPLM_NAV_NOT_FOUND if there are no navaids of that type in the
database.  You must pass exactly one navaid type to this routine.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API XPLMNavRef XPLMFindFirstNavAidOfType(
                         XPLMNavType          inType
                    );
```

</div>


**See associated types:**

- [XPLMNavType](#xplmnavtype)
</div>

---

<div class="sym-block sym-function" data-name="XPLMFindLastNavAidOfType" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMFindLastNavAidOfType { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the ref of the last navaid of the given type in the
database or XPLM_NAV_NOT_FOUND if there are no navaids of that type in the
database.  You must pass exactly one navaid type to this routine.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API XPLMNavRef XPLMFindLastNavAidOfType(
                         XPLMNavType          inType
                    );
```

</div>


**See associated types:**

- [XPLMNavType](#xplmnavtype)
</div>

---

<div class="sym-block sym-function" data-name="XPLMFindNavAid" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMFindNavAid { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine provides a number of searching capabilities for the nav database.
XPLMFindNavAid will search through every navaid whose type is within inType
(multiple types may be added together) and return any navaids found based
on the following rules:

* If inLat and inLon are not NULL, the navaid nearest to that lat/lon will be
  returned, otherwise the last navaid found will be returned.

* If inFrequency is not NULL, then any navaids considered must match this
  frequency.  Note that this will screen out radio beacons that do not have
  frequency data published (like inner markers) but not fixes and airports.

* If inNameFragment is not NULL, only navaids that contain the fragment in their
  name will be returned.

* If inIDFragment is not NULL, only navaids that contain the fragment in their
  IDs will be returned.

This routine provides a simple way to do a number of useful searches:
* Find the nearest navaid on this frequency.
* Find the nearest airport.
* Find the VOR whose ID is "BOS".
* Find the nearest airport whose name contains "Chicago".

<div class="xplm-code" markdown="1">

```cpp
XPLM_API XPLMNavRef XPLMFindNavAid(
                         const char *         inNameFragment,    /* Can be NULL */
                         const char *         inIDFragment,    /* Can be NULL */
                         float *              inLat,    /* Can be NULL */
                         float *              inLon,    /* Can be NULL */
                         int *                inFrequency,    /* Can be NULL */
                         XPLMNavType          inType
                    );
```

</div>


**See associated types:**

- [XPLMNavType](#xplmnavtype)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetNavAidInfo" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetNavAidInfo { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns information about a navaid.  Any non-null field is filled
out with information if it is available.

Frequencies are in the nav.dat convention as described in the X-Plane nav
database FAQ: NDB frequencies are exact, all others are multiplied by 100.

The buffer for IDs should be at least 6 chars and the buffer for names should
be at least 41 chars, but since these values are likely to go up, I recommend
passing at least 32 chars for IDs and 256 chars for names when possible.

The outReg parameter tells if the navaid is within the local "region" of loaded
DSFs.  (This information may not be particularly useful to plugins.)  The parameter
is a single byte value 1 for true or 0 for false, not a C string.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMGetNavAidInfo(
                         XPLMNavRef           inRef,
                         XPLMNavType *        outType,    /* Can be NULL */
                         float *              outLatitude,    /* Can be NULL */
                         float *              outLongitude,    /* Can be NULL */
                         float *              outHeight,    /* Can be NULL */
                         int *                outFrequency,    /* Can be NULL */
                         float *              outHeading,    /* Can be NULL */
                         char                 outID[32],    /* Can be NULL */
                         char                 outName[256],    /* Can be NULL */
                         char                 outReg[1]    /* Can be NULL */
                    );
```

</div>


**See associated types:**

- [XPLMNavRef](#xplmnavref)
- [XPLMNavType](#xplmnavtype)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>