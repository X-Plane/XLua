<h1>Xlua Timers</h1>

---

<div class="sym-block sym-typedef sym-lua-only" data-name="xlua_timer" data-type="typedef" markdown="1">

<div class="sym-title-row" markdown="1">

## xlua_timer { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

</div>

Opaque handle to an XLua timer, returned by XLuaCreateTimer /
XLuaFindTimer and passed to the other timer functions.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local my_result = nil  -- xlua_timer</code></pre>
</div>


**Used by:**

- [XLuaGetTimerRemaining](#xluagettimerremaining)
- [XLuaIsTimerScheduled](#xluaistimerscheduled)
- [XLuaRunTimer](#xluaruntimer)
</div>

---

<div class="sym-block sym-function sym-lua-only" data-name="XLuaCreateTimer" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XLuaCreateTimer { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Create a timer bound to the given callback (a function called with no
arguments when the timer fires). The timer is not scheduled until you call
XLuaRunTimer.

<div class="lua-code" markdown="1">
<!-- hand-written binding; see the XLua docs -->
</div>

</div>

---

<div class="sym-block sym-function sym-lua-only" data-name="XLuaRunTimer" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XLuaRunTimer { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Schedule a timer to fire after `delay` seconds, optionally repeating
every `period` seconds. Pass period <= 0 for a one-shot timer.

<div class="lua-code" markdown="1">
<!-- hand-written binding; see the XLua docs -->
</div>


**See associated types:**

- [xlua_timer](#xlua_timer)
</div>

---

<div class="sym-block sym-function sym-lua-only" data-name="XLuaFindTimer" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XLuaFindTimer { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Find the existing timer bound to `callback` (the function passed to
XLuaCreateTimer), or nil if none exists.

<div class="lua-code" markdown="1">
<!-- hand-written binding; see the XLua docs -->
</div>

</div>

---

<div class="sym-block sym-function sym-lua-only" data-name="XLuaIsTimerScheduled" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XLuaIsTimerScheduled { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Returns true if the timer is currently scheduled to fire.

<div class="lua-code" markdown="1">
<!-- hand-written binding; see the XLua docs -->
</div>


**See associated types:**

- [xlua_timer](#xlua_timer)
</div>

---

<div class="sym-block sym-function sym-lua-only" data-name="XLuaGetTimerRemaining" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XLuaGetTimerRemaining { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Seconds until the timer next fires, or -1 if it is not scheduled.

<div class="lua-code" markdown="1">
<!-- hand-written binding; see the XLua docs -->
</div>


**See associated types:**

- [xlua_timer](#xlua_timer)
</div>

---

<div class="sym-block sym-function sym-lua-only" data-name="XLuaReloadOnFlightChange" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XLuaReloadOnFlightChange { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Mark this aircraft's scripts as needing a full reload whenever flight
details (livery, situation) change.

<div class="lua-code" markdown="1">
<!-- hand-written binding; see the XLua docs -->
</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>