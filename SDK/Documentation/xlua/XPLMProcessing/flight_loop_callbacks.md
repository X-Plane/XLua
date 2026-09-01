<h1>Flight Loop Callbacks</h1>

---

<div class="sym-block sym-enum" data-name="XPLMFlightLoopPhaseType" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMFlightLoopPhaseType { .symbol-title }

<span class="sym-badge badge-enum">enum</span> <span class="sym-badge badge-version">XPLM210</span>

</div>

You can register a flight loop callback to run either before or after the flight model is
integrated by X-Plane.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_FlightLoop_Phase_BeforeFlightModel | 0 | Your callback runs before X-Plane integrates the flight model. |
| xplm_FlightLoop_Phase_AfterFlightModel | 1 | Your callback runs after X-Plane integrates the flight model. |

</div>

</div>

---

<div class="sym-block sym-typedef" data-name="XPLMFlightLoopID" data-type="typedef" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMFlightLoopID { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span> <span class="sym-badge badge-version">XPLM210</span>

</div>

This is an opaque identifier for a flight loop callback. You can use this identifier to easily
track and remove your callbacks, or to use the new flight loop APIs.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local my_flightLoopID = nil  -- XPLMFlightLoopID</code></pre>
</div>


**Used by:**

- [XPLMDestroyFlightLoop](#xplmdestroyflightloop)
- [XPLMScheduleFlightLoop](#xplmscheduleflightloop)
</div>

---

<div class="sym-block sym-callback" data-name="XPLMFlightLoop_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMFlightLoop_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

This is your flight loop callback. Each time the flight loop is iterated through,
you receive this call at the end.

Flight loop callbacks receive a number of input timing parameters. These input timing parameters
are not particularly useful; you may need to track your own timing data (e.g. by reading datarefs).
The input parameters are:

- inElapsedSinceLastCall: the wall time since your last callback.
- inElapsedTimeSinceLastFlightLoop: the wall time since any flight loop was dispatched.
- inCounter: a monotonically increasing counter, bumped once per flight loop dispatch from the sim.
- inRefcon: your own pointer constant provided when you registered yor callback.

Your return value controls when you will next be called.

 - Return 0 to stop receiving callbacks.
 - Return a positive number to specify how many
seconds until the next callback. (You will be called at or after this time,
 not before.)
 - Return a negative number to specify how many loops must go by until you
are called. For example, -1.0 means call me the very next loop.

Try to run your flight loop as infrequently as is practical, and suspend it
(using return value 0) when you do not need it; lots of flight loop callbacks
that do nothing lowers X-Plane's frame rate.

Your callback will NOT be unregistered if you return 0; it will merely be inactive.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_FlightLoop_callback(
    inElapsedSinceLastCall,              -- float
    inElapsedTimeSinceLastFlightLoop,    -- float
    inCounter,                           -- int
    inRefcon                             -- any Lua var/table
)
    -- your code here
    return nil  -- float
end</code></pre>
</div>

</div>

---

<div class="sym-block sym-struct" data-name="XPLMCreateFlightLoop_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCreateFlightLoop_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span> <span class="sym-badge badge-version">XPLM210</span>

</div>

XPLMCreateFlightLoop_t contains the parameters to create a new flight loop callback. The structure
may be expanded in future SDKs - always set structSize to the size of your structure in bytes.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local My_CreateFlightLoop_t = {
    structSize    = 0,       -- int
    phase         = nil,     -- XPLMFlightLoopPhaseType
    callbackFunc  = nil,     -- see XPLMFlightLoop_f
    refcon        = nil,     -- any Lua var/table
}</code></pre>
</div>


**See available callback(s):**

- [XPLMFlightLoop_f](#xplmflightloop_f)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetElapsedTime" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetElapsedTime { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the elapsed time since the sim started up in decimal seconds. This is a wall timer;
it keeps counting upward even if the sim is pasued.

__WARNING__: XPLMGetElapsedTime is not a very good timer!  It lacks precision in both its data type
and its source.  Do not attempt to use it for timing critical applications like network multiplayer.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns float -> assign to local/var
local my_result = XPLMGetElapsedTime(
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetCycleNumber" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetCycleNumber { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns a counter starting at zero for each sim cycle computed/video frame rendered.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns int -> assign to local/var
local my_result = XPLMGetCycleNumber(
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMCreateFlightLoop" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCreateFlightLoop { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM210</span>

</div>

This routine creates a flight loop callback and returns its ID. The flight loop callback is created
using the input param struct, and is inited to be unscheduled. Use XPLMScheduleFlightLoop
to schedule it.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPLMFlightLoopID -> assign to local/var
local my_flightLoopID = XPLMCreateFlightLoop(
    inParams     -- see XPLMCreateFlightLoop_t
)</code></pre>
</div>


**See associated types:**

- [XPLMCreateFlightLoop_t](#xplmcreateflightloop_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMDestroyFlightLoop" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDestroyFlightLoop { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM210</span>

</div>

This routine destroys a flight loop callback by ID. Only call it on flight loops created with
the newer XPLMCreateFlightLoop API.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMDestroyFlightLoop(
    inFlightLoopID     -- XPLMFlightLoopID
)</code></pre>
</div>


**See associated types:**

- [XPLMFlightLoopID](#xplmflightloopid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMScheduleFlightLoop" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMScheduleFlightLoop { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM210</span>

</div>

This routine schedules a flight loop callback for future execution. If inInterval is negative, it is run
in a certain number of frames based on the absolute value of the input. If the interval is positive, it is
a duration in seconds.

If inRelativeToNow is true, times are interpreted relative to the time this routine is called; otherwise
they are relative to the last call time or the time the flight loop was registered (if never called).

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMScheduleFlightLoop(
    inFlightLoopID,     -- XPLMFlightLoopID
    inInterval,         -- float
    inRelativeToNow     -- boolean
)</code></pre>
</div>


**See associated types:**

- [XPLMFlightLoopID](#xplmflightloopid)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>