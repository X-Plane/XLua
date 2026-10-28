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

<div class="xplm-code" markdown="1">

```cpp
typedef void * XPLMFlightLoopID;
```

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

<div class="xplm-code" markdown="1">

```cpp
typedef float (* XPLMFlightLoop_f)(
                         float                inElapsedSinceLastCall,
                         float                inElapsedTimeSinceLastFlightLoop,
                         int                  inCounter,
                         void*                inRefcon
                    );
```

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

<div class="xplm-code" markdown="1">

```cpp
typedef struct {
     int                       structSize;
     XPLMFlightLoopPhaseType   phase;
     XPLMFlightLoop_f          callbackFunc;
     void*                     refcon;
} XPLMCreateFlightLoop_t;
```

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

<div class="xplm-code" markdown="1">

```cpp
XPLM_API float XPLMGetElapsedTime(void);
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetCycleNumber" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetCycleNumber { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns a counter starting at zero for each sim cycle computed/video frame rendered.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API int XPLMGetCycleNumber(void);
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMRegisterFlightLoopCallback" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMRegisterFlightLoopCallback { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine registers your flight loop callback. Pass in a pointer to a flight
loop function and a refcon (an optional reference value determined by you).
inInterval defines when you will be called. Pass in
a positive number to specify seconds from registration time to the next callback.
Pass in a negative number to indicate when you will be called (e.g. pass -1 to be
called at the next cylcle). Pass 0 to not be called; your callback will be inactive.

(This legacy function only installs pre-flight-loop callbacks; use XPLMCreateFlightLoop
for more control.)

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMRegisterFlightLoopCallback(
                         XPLMFlightLoop_f     inFlightLoop,
                         float                inInterval,
                         void*                inRefcon
                    );
```

</div>


**See associated types:**

- [XPLMFlightLoop_f](#xplmflightloop_f)
</div>

---

<div class="sym-block sym-function" data-name="XPLMUnregisterFlightLoopCallback" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMUnregisterFlightLoopCallback { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine unregisters your flight loop callback. Do NOT call it from your
flight loop callback. Once your flight loop callback is unregistered, it will not
be called again.

Only use this on flight loops registered via XPLMRegisterFlightLoopCallback.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMUnregisterFlightLoopCallback(
                         XPLMFlightLoop_f     inFlightLoop,
                         void*                inRefcon
                    );
```

</div>


**See associated types:**

- [XPLMFlightLoop_f](#xplmflightloop_f)
</div>

---

<div class="sym-block sym-function" data-name="XPLMSetFlightLoopCallbackInterval" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMSetFlightLoopCallbackInterval { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine sets when a callback will be called. Do NOT call it from your callback;
use the return value of the callback to change your callback interval from inside
your callback.

inInterval is formatted the same way as in XPLMRegisterFlightLoopCallback; positive
for seconds, negative for cycles, and 0 for deactivating the callback. If
inRelativeToNow is true, times are from the time of this call; otherwise they are from
the time the callback was last called (or the time it was registered if it has never
been called.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMSetFlightLoopCallbackInterval(
                         XPLMFlightLoop_f     inFlightLoop,
                         float                inInterval,
                         int                  inRelativeToNow,
                         void*                inRefcon
                    );
```

</div>


**See associated types:**

- [XPLMFlightLoop_f](#xplmflightloop_f)
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

<div class="xplm-code" markdown="1">

```cpp
XPLM_API XPLMFlightLoopID XPLMCreateFlightLoop(
                         XPLMCreateFlightLoop_t * inParams
                    );
```

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

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMDestroyFlightLoop(
                         XPLMFlightLoopID     inFlightLoopID
                    );
```

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

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMScheduleFlightLoop(
                         XPLMFlightLoopID     inFlightLoopID,
                         float                inInterval,
                         int                  inRelativeToNow
                    );
```

</div>


**See associated types:**

- [XPLMFlightLoopID](#xplmflightloopid)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>