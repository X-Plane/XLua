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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPLMCountFMSEntries(
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetDisplayedFMSEntry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDisplayedFMSEntry { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the index of the entry the pilot is viewing.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPLMGetDisplayedFMSEntry(
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetDestinationFMSEntry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetDestinationFMSEntry { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the index of the entry the FMS is flying to.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPLMGetDestinationFMSEntry(
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMSetDisplayedFMSEntry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDisplayedFMSEntry { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine changes which entry the FMS is showing to the index specified.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetDisplayedFMSEntry(
    inIndex     -- int
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMSetDestinationFMSEntry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetDestinationFMSEntry { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine changes which entry the FMS is flying the aircraft toward. The track is from the n-1'th point to the n'th point.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetDestinationFMSEntry(
    inIndex     -- int
)</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMGetFMSEntryInfo(
    inIndex     -- int
)
-- outs = { outType, outID, outRef, outAltitude, outLat, outLon }</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetFMSEntryInfo(
    inIndex,         -- int
    inRef,           -- XPLMNavRef
    inAltitudeFt     -- int
)</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetFMSEntryLatLon(
    inIndex,         -- int
    inLat,           -- float
    inLon,           -- float
    inAltitudeFt     -- int
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMClearFMSEntry" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMClearFMSEntry { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine clears the given entry, potentially shortening the flight plan.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMClearFMSEntry(
    inIndex     -- int
)</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPLMCountFMSFlightPlanEntries(
    inFlightPlan     -- XPLMNavFlightPlan
)</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPLMGetDisplayedFMSFlightPlanEntry(
    inFlightPlan     -- XPLMNavFlightPlan
)</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPLMGetDestinationFMSFlightPlanEntry(
    inFlightPlan     -- XPLMNavFlightPlan
)</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetDisplayedFMSFlightPlanEntry(
    inFlightPlan,    -- XPLMNavFlightPlan
    inIndex          -- int
)</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetDestinationFMSFlightPlanEntry(
    inFlightPlan,    -- XPLMNavFlightPlan
    inIndex          -- int
)</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetDirectToFMSFlightPlanEntry(
    inFlightPlan,    -- XPLMNavFlightPlan
    inIndex          -- int
)</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMGetFMSFlightPlanEntryInfo(
    inFlightPlan,    -- XPLMNavFlightPlan
    inIndex          -- int
)
-- outs = { outType, outID, outRef, outAltitude, outLat, outLon }</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetFMSFlightPlanEntryInfo(
    inFlightPlan,    -- XPLMNavFlightPlan
    inIndex,         -- int
    inRef,           -- XPLMNavRef
    inAltitudeFt     -- int
)</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetFMSFlightPlanEntryLatLon(
    inFlightPlan,    -- XPLMNavFlightPlan
    inIndex,         -- int
    inLat,           -- float
    inLon,           -- float
    inAltitudeFt     -- int
)</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetFMSFlightPlanEntryLatLonWithId(
    inFlightPlan,    -- XPLMNavFlightPlan
    inIndex,         -- int
    inLat,           -- float
    inLon,           -- float
    inAltitudeFt,    -- int
    inId,            -- char
    inIdLength       -- int
)</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMClearFMSFlightPlanEntry(
    inFlightPlan,    -- XPLMNavFlightPlan
    inIndex          -- int
)</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMLoadFMSFlightPlan(
    inDevice,       -- int
    inBuffer,       -- string
    inBufferLen     -- int
)</code></pre>
</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>