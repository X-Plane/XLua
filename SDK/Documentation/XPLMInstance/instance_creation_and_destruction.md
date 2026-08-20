<h1>Instance Creation And Destruction</h1>

Registers and unregisters instances.

---

<div class="sym-block sym-typedef" data-name="XPLMInstanceRef" data-type="typedef" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMInstanceRef { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

</div>

An opaque handle to an instance.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local my_instanceRef = nil  -- XPLMInstanceRef</code></pre>
</div>


**Used by:**

- [XPLMDestroyInstance](#xplmdestroyinstance)
- [XPLMInstanceSetAutoShift](#xplminstancesetautoshift)
- [XPLMInstanceSetCoordinateSpace](instance_manipulation.md#xplminstancesetcoordinatespace)
- [XPLMInstanceSetPosition](instance_manipulation.md#xplminstancesetposition)
- [XPLMInstanceSetPositionDouble](instance_manipulation.md#xplminstancesetpositiondouble)
</div>

---

<div class="sym-block sym-function" data-name="XPLMCreateInstance" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCreateInstance { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

XPLMCreateInstance creates a new instance, managed by your plug-in, and returns a handle to the instance. A few important requirements:

* The object passed in must be fully loaded and returned from the XPLM before you can create your instance; you cannot pass a null obj ref,
  nor can you change the ref later.

* If you use any custom datarefs in your object, they must be registered before the object is loaded. This is true even if their data will be
  provided via the instance dataref list.

* The instance dataref array must be a valid pointer to a null-terminated array.  That is, if you do not want any
  datarefs, you must pass a pointer to a one-element array containing a null item.  You cannot pass null for the array itself.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPLMInstanceRef -> assign to local/var
local my_instanceRef = XPLMCreateInstance(
    obj,         -- XPLMObjectRef
    datarefs     -- char const
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMInstanceSetAutoShift" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMInstanceSetAutoShift { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM420</span>

</div>

XPLMInstanceSetAutoShift tells X-Plane to move the location of your instance every time the sim\'s local coordinate sytem changes, so that
a static instance does not have to be moved. Without this, a plugin is responsible for updating an instance's local position when the
coordinate system shifts. Use this for static instances that you would not otherwise have to move.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMInstanceSetAutoShift(
    instance     -- XPLMInstanceRef
)</code></pre>
</div>


**See associated types:**

- [XPLMInstanceRef](#xplminstanceref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMDestroyInstance" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDestroyInstance { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

XPLMDestroyInstance destroys and deallocates your instance; once called, you are still responsible for releasing the OBJ ref.

Tip: you can release your OBJ ref after you call XPLMCreateInstance as long as you never use it again; the instance will maintain its own
reference to the OBJ and the object OBJ be deallocated when the instance is destroyed.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMDestroyInstance(
    instance     -- XPLMInstanceRef
)</code></pre>
</div>


**See associated types:**

- [XPLMInstanceRef](#xplminstanceref)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>