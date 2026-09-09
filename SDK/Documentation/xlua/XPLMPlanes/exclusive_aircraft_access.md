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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_PlanesAvailable_callback(
    inRefcon     -- any Lua var/table
)
    -- your code here
end</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns boolean -> assign to local/var
local my_result = XPLMAcquirePlanes(
    inAircraft,    -- char const
    inCallback,    -- see XPLMPlanesAvailable_f
    inRefcon       -- any Lua var/table
)</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMReleasePlanes(
)</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetActiveAircraftCount(
    inCount     -- int
)</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMSetAircraftModel(
    inIndex,           -- int
    inAircraftPath     -- string
)</code></pre>
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

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMDisableAIForPlane(
    inPlaneIndex     -- int
)</code></pre>
</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>