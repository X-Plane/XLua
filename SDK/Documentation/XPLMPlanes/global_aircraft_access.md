<h1>Global Aircraft Access</h1>

These APIs let you control the AI aircraft and take over multiplayer/aI aircraft control.

---

<div class="sym-block sym-define" data-name="XPLM_USER_AIRCRAFT" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_USER_AIRCRAFT { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

The user's aircraft is always index 0.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLM_USER_AIRCRAFT  -- 0</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMCountAircraft" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCountAircraft { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function returns the number of aircraft X-Plane is capable of having,
as well as the number of aircraft that are currently active.  These
numbers count the user's aircraft.  It can also return the plugin that
is currently controlling aircraft.  In X-Plane 7, this routine reflects
the number of aircraft the user has enabled in the rendering options window.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMCountAircraft(
)
-- outs = { outTotalAircraft, outActiveAircraft, outController }</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetNthAircraftModel" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetNthAircraftModel { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function returns the aircraft model for the Nth aircraft.  Indices
are zero based, with zero being the user's aircraft.  The file name should
be at least 256 chars in length; the path should be at least 512 chars
in length.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMGetNthAircraftModel(
    inIndex     -- int
)
-- outs = { outFileName, outPath }</code></pre>
</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>