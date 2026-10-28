<h1>Flight Management Computer</h1>

Note: the FMS works based on an array of entries.  Indices into the array
are zero-based.  Each entry is a navaid plus an altitude.  The FMS
tracks the currently displayed entry and the entry that it is flying to.

The FMS must be programmed with contiguous entries, so clearing an entry
at the end shortens the effective flight plan.  There is a max of 100
waypoints in the flight plan.

---

<div class="sym-block sym-function" data-name="XPLMCountFMSEntries" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCountFMSEntries { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the number of entries in the FMS.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMCountFMSEntries(void);
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetDisplayedFMSEntry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDisplayedFMSEntry { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the index of the entry the pilot is viewing.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMGetDisplayedFMSEntry(void);
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetDestinationFMSEntry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDestinationFMSEntry { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the index of the entry the FMS is flying to.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMGetDestinationFMSEntry(void);
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMSetDisplayedFMSEntry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDisplayedFMSEntry { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine changes which entry the FMS is showing to the index specified.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMSetDisplayedFMSEntry(
                         int                  inIndex
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMSetDestinationFMSEntry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDestinationFMSEntry { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine changes which entry the FMS is flying the aircraft toward. The track is from the n-1'th point to the n'th point.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMSetDestinationFMSEntry(
                         int                  inIndex
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetFMSEntryInfo" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetFMSEntryInfo { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns information about a given FMS entry. If the entry is an airport
or navaid, a reference to a nav entry can be returned allowing you to find additional
information (such as a frequency, ILS heading, name, etc.). Note that this reference
can be XPLM_NAV_NOT_FOUND until the information has been looked up asynchronously,
so after flightplan changes, it might take up to a second for this field to become
populated. The other information is available immediately.
For a lat/lon entry, the lat/lon is returned by this routine
but the navaid cannot be looked up (and the reference will be XPLM_NAV_NOT_FOUND).
FMS name entry buffers should be at least 256 chars in length.

WARNING: Due to a bug in X-Plane prior to 11.31, the navaid reference will not be set to
XPLM_NAV_NOT_FOUND while no data is available, and instead just remain the value of the
variable that you passed the pointer to. Therefore, always initialize the variable
to XPLM_NAV_NOT_FOUND before passing the pointer to this function.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMGetFMSEntryInfo(
                         int                  inIndex,
                         XPLMNavType *        outType,    /* Can be NULL */
                         char                 outID[256],    /* Can be NULL */
                         XPLMNavRef *         outRef,    /* Can be NULL */
                         int *                outAltitude,    /* Can be NULL */
                         float *              outLat,    /* Can be NULL */
                         float *              outLon    /* Can be NULL */
                    );
```

</div>


**See associated types:**

- [XPLMNavRef](navigation_database_access.md#xplmnavref)
- [XPLMNavType](navigation_database_access.md#xplmnavtype)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetFMSEntryInfo" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetFMSEntryInfo { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine changes an entry in the FMS to have the destination navaid passed
in and the altitude specified.  Use this only for airports, fixes, and radio-beacon
navaids.  Currently of radio beacons, the FMS can only support VORs and NDBs.
Use the routines below to clear or fly to a lat/lon.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMSetFMSEntryInfo(
                         int                  inIndex,
                         XPLMNavRef           inRef,
                         int                  inAltitudeFt
                    );
```

</div>


**See associated types:**

- [XPLMNavRef](navigation_database_access.md#xplmnavref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetFMSEntryLatLon" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetFMSEntryLatLon { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine changes the entry in the FMS to a lat/lon entry with the given
coordinates.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMSetFMSEntryLatLon(
                         int                  inIndex,
                         float                inLat,
                         float                inLon,
                         int                  inAltitudeFt
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMClearFMSEntry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMClearFMSEntry { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine clears the given entry, potentially shortening the flight plan.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMClearFMSEntry(
                         int                  inIndex
                    );
```

</div>

</div>

---

<div class="sym-block sym-enum" data-name="XPLMNavFlightPlan" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMNavFlightPlan { .symbol-title }

<span class="sym-badge badge-enum">enum</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

These enumerations defines the flightplan you are accesing using the FMSFlightPlan functions.
An airplane can have up to two navigation devices (GPS or FMS) and each device can have two flightplans.
A GPS has an enroute and an approach flightplan.
An FMS has an active and a temporary flightplan.
If you are trying to access a flightplan that doesn't exist in your aircraft, e.g. asking a GPS for a temp flightplan, FMSFlighPlan functions have no effect and will return no information.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_Fpl_Pilot_Primary | 0 |  |
| xplm_Fpl_CoPilot_Primary | 1 |  |
| xplm_Fpl_Pilot_Approach | 2 |  |
| xplm_Fpl_CoPilot_Approach | 3 |  |
| xplm_Fpl_Pilot_Temporary | 4 |  |
| xplm_Fpl_CoPilot_Temporary | 5 |  |

</div>

**Used by:**

- [XPLMClearFMSFlightPlanEntry](#xplmclearfmsflightplanentry)
- [XPLMCountFMSFlightPlanEntries](#xplmcountfmsflightplanentries)
- [XPLMGetDestinationFMSFlightPlanEntry](#xplmgetdestinationfmsflightplanentry)
- [XPLMGetDisplayedFMSFlightPlanEntry](#xplmgetdisplayedfmsflightplanentry)
- [XPLMGetFMSFlightPlanEntryInfo](#xplmgetfmsflightplanentryinfo)
- [XPLMSetDestinationFMSFlightPlanEntry](#xplmsetdestinationfmsflightplanentry)
- [XPLMSetDirectToFMSFlightPlanEntry](#xplmsetdirecttofmsflightplanentry)
- [XPLMSetDisplayedFMSFlightPlanEntry](#xplmsetdisplayedfmsflightplanentry)
- [XPLMSetFMSFlightPlanEntryInfo](#xplmsetfmsflightplanentryinfo)
- [XPLMSetFMSFlightPlanEntryLatLon](#xplmsetfmsflightplanentrylatlon)
- [XPLMSetFMSFlightPlanEntryLatLonWithId](#xplmsetfmsflightplanentrylatlonwithid)

</div>

---

<div class="sym-block sym-function" data-name="XPLMCountFMSFlightPlanEntries" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCountFMSFlightPlanEntries { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

This routine returns the number of entries in the FMS.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMCountFMSFlightPlanEntries(
                         XPLMNavFlightPlan    inFlightPlan
                    );
```

</div>


**See associated types:**

- [XPLMNavFlightPlan](#xplmnavflightplan)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetDisplayedFMSFlightPlanEntry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDisplayedFMSFlightPlanEntry { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

This routine returns the index of the entry the pilot is viewing.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMGetDisplayedFMSFlightPlanEntry(
                         XPLMNavFlightPlan    inFlightPlan
                    );
```

</div>


**See associated types:**

- [XPLMNavFlightPlan](#xplmnavflightplan)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetDestinationFMSFlightPlanEntry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDestinationFMSFlightPlanEntry { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

This routine returns the index of the entry the FMS is flying to.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMGetDestinationFMSFlightPlanEntry(
                         XPLMNavFlightPlan    inFlightPlan
                    );
```

</div>


**See associated types:**

- [XPLMNavFlightPlan](#xplmnavflightplan)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetDisplayedFMSFlightPlanEntry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDisplayedFMSFlightPlanEntry { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

This routine changes which entry the FMS is showing to the index specified.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMSetDisplayedFMSFlightPlanEntry(
                         XPLMNavFlightPlan    inFlightPlan,
                         int                  inIndex
                    );
```

</div>


**See associated types:**

- [XPLMNavFlightPlan](#xplmnavflightplan)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetDestinationFMSFlightPlanEntry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDestinationFMSFlightPlanEntry { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

This routine changes which entry the FMS is flying the aircraft toward. The track is from the n-1'th point to the n'th point.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMSetDestinationFMSFlightPlanEntry(
                         XPLMNavFlightPlan    inFlightPlan,
                         int                  inIndex
                    );
```

</div>


**See associated types:**

- [XPLMNavFlightPlan](#xplmnavflightplan)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetDirectToFMSFlightPlanEntry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDirectToFMSFlightPlanEntry { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

This routine changes which entry the FMS is flying the aircraft toward. The track is from the current position of the aircraft directly to the n'th point, ignoring the point before it.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMSetDirectToFMSFlightPlanEntry(
                         XPLMNavFlightPlan    inFlightPlan,
                         int                  inIndex
                    );
```

</div>


**See associated types:**

- [XPLMNavFlightPlan](#xplmnavflightplan)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetFMSFlightPlanEntryInfo" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetFMSFlightPlanEntryInfo { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

This routine returns information about a given FMS entry. If the entry is an airport
or navaid, a reference to a nav entry can be returned allowing you to find additional
information (such as a frequency, ILS heading, name, etc.). Note that this reference
can be XPLM_NAV_NOT_FOUND until the information has been looked up asynchronously,
so after flightplan changes, it might take up to a second for this field to become
populated. The other information is available immediately.
For a lat/lon entry, the lat/lon is returned by this routine
but the navaid cannot be looked up (and the reference will be XPLM_NAV_NOT_FOUND).
FMS name entry buffers should be at least 256 chars in length.

WARNING: Due to a bug in X-Plane prior to 11.31, the navaid reference will not be set to
XPLM_NAV_NOT_FOUND while no data is available, and instead just remain the value of the
variable that you passed the pointer to. Therefore, always initialize the variable
to XPLM_NAV_NOT_FOUND before passing the pointer to this function.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMGetFMSFlightPlanEntryInfo(
                         XPLMNavFlightPlan    inFlightPlan,
                         int                  inIndex,
                         XPLMNavType *        outType,    /* Can be NULL */
                         char                 outID[256],    /* Can be NULL */
                         XPLMNavRef *         outRef,    /* Can be NULL */
                         int *                outAltitude,    /* Can be NULL */
                         float *              outLat,    /* Can be NULL */
                         float *              outLon    /* Can be NULL */
                    );
```

</div>


**See associated types:**

- [XPLMNavFlightPlan](#xplmnavflightplan)
- [XPLMNavRef](navigation_database_access.md#xplmnavref)
- [XPLMNavType](navigation_database_access.md#xplmnavtype)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetFMSFlightPlanEntryInfo" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetFMSFlightPlanEntryInfo { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

This routine changes an entry in the FMS to have the destination navaid passed
in and the altitude specified.  Use this only for airports, fixes, and radio-beacon
navaids.  Currently of radio beacons, the FMS can only support VORs, NDBs and TACANs.
Use the routines below to clear or fly to a lat/lon.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMSetFMSFlightPlanEntryInfo(
                         XPLMNavFlightPlan    inFlightPlan,
                         int                  inIndex,
                         XPLMNavRef           inRef,
                         int                  inAltitudeFt
                    );
```

</div>


**See associated types:**

- [XPLMNavFlightPlan](#xplmnavflightplan)
- [XPLMNavRef](navigation_database_access.md#xplmnavref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetFMSFlightPlanEntryLatLon" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetFMSFlightPlanEntryLatLon { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

This routine changes the entry in the FMS to a lat/lon entry with the given
coordinates.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMSetFMSFlightPlanEntryLatLon(
                         XPLMNavFlightPlan    inFlightPlan,
                         int                  inIndex,
                         float                inLat,
                         float                inLon,
                         int                  inAltitudeFt
                    );
```

</div>


**See associated types:**

- [XPLMNavFlightPlan](#xplmnavflightplan)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetFMSFlightPlanEntryLatLonWithId" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetFMSFlightPlanEntryLatLonWithId { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

This routine changes the entry in the FMS to a lat/lon entry with the given
coordinates. You can specify the display ID of the waypoint.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMSetFMSFlightPlanEntryLatLonWithId(
                         XPLMNavFlightPlan    inFlightPlan,
                         int                  inIndex,
                         float                inLat,
                         float                inLon,
                         int                  inAltitudeFt,
                         const char*          inId,
                         unsigned int         inIdLength
                    );
```

</div>


**See associated types:**

- [XPLMNavFlightPlan](#xplmnavflightplan)
</div>

---

<div class="sym-block sym-function" data-name="XPLMClearFMSFlightPlanEntry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMClearFMSFlightPlanEntry { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

This routine clears the given entry, potentially shortening the flight plan.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMClearFMSFlightPlanEntry(
                         XPLMNavFlightPlan    inFlightPlan,
                         int                  inIndex
                    );
```

</div>


**See associated types:**

- [XPLMNavFlightPlan](#xplmnavflightplan)
</div>

---

<div class="sym-block sym-function" data-name="XPLMLoadFMSFlightPlan" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMLoadFMSFlightPlan { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Loads an X-Plane 11 and later formatted flightplan from the buffer into the FMS or GPS, including instrument procedures.
Use device index 0 for the pilot-side and device index 1 for the co-pilot side unit.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMLoadFMSFlightPlan(
                         int                  inDevice,
                         const char *         inBuffer,
                         unsigned int         inBufferLen
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMSaveFMSFlightPlan" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSaveFMSFlightPlan { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM410</span>

</div>

Saves an X-Plane 11 formatted flightplan from the FMS or GPS into a char buffer that you provide.
Use device index 0 for the pilot-side and device index 1 for the co-pilot side unit.
Provide the length of the buffer you allocated. X-Plane will write a null-terminated string if the full flight plan fits into the buffer.
If your buffer is too small, X-Plane will write inBufferLen characters, and the resulting buffer is not null-terminated.
The return value is the number of characters (including null terminator) that X-Plane needed to write the flightplan. If this number is larger than the buffer you provided, the flightplan in the buffer will be incomplete and the buffer not null-terminated.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API unsigned int XPLMSaveFMSFlightPlan(
                         int                  inDevice,
                         char *               inBuffer,
                         unsigned int         inBufferLen
                    );
```

</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>