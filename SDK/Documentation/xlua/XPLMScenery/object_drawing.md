<h1>Object Drawing</h1>

The object drawing routines let you load and draw X-Plane OBJ files. Objects are loaded by file path and
managed via an opaque handle. X-Plane naturally reference counts objects, so it is important that you
balance every successful call to XPLMLoadObject with a call to XPLMUnloadObject!

---

<div class="sym-block sym-typedef" data-name="XPLMObjectRef" data-type="typedef" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMObjectRef { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span> <span class="sym-badge badge-version">XPLM200</span>

</div>

An XPLMObjectRef is a opaque handle to an .obj file that has been loaded into memory.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local my_objectRef = nil  -- XPLMObjectRef</code></pre>
</div>


**Used by:**

- [XPLMObjectLoaded_f](#xplmobjectloaded_f)
- [XPLMUnloadObject](#xplmunloadobject)
</div>

---

<div class="sym-block sym-struct" data-name="XPLMDrawInfo_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDrawInfo_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span> <span class="sym-badge badge-version">XPLM200</span>

</div>

The XPLMDrawInfo_t structure contains positioning info for one object that is to be drawn.
Be sure to set structSize to the size of the structure for future expansion.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local My_DrawInfo_t = {
    structSize  = 0,       -- int
    x           = 0.0,     -- float
    y           = 0.0,     -- float
    z           = 0.0,     -- float
    pitch       = 0.0,     -- float
    heading     = 0.0,     -- float
    roll        = 0.0,     -- float
}</code></pre>
</div>

</div>

---

<div class="sym-block sym-struct" data-name="XPLMDrawInfoDouble_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDrawInfoDouble_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span> <span class="sym-badge badge-version">XPLM420</span>

</div>

The XPLMDrawInfo_t structure contains positioning info for one object that is to be drawn.
Be sure to set structSize to the size of the structure for future expansion.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">local My_DrawInfoDouble_t = {
    structSize  = 0,       -- int
    x           = 0.0,     -- float
    y           = 0.0,     -- float
    z           = 0.0,     -- float
    pitch       = 0.0,     -- float
    heading     = 0.0,     -- float
    roll        = 0.0,     -- float
}</code></pre>
</div>

</div>

---

<div class="sym-block sym-callback" data-name="XPLMObjectLoaded_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMObjectLoaded_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span> <span class="sym-badge badge-version">XPLM210</span>

</div>

You provide this callback when loading an object asynchronously; it will be called once the object is
loaded. Your refcon is passed back. The object ref passed in is the newly loaded object (ready for use) or
NULL if an error occured. It will not be called more than once per object.

If your plugin is disabled, this callback will be delivered as soon as the plugin is re-enabled. If your
plugin is unloaded before this callback is ever called, the SDK will release the object handle for you.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">function my_ObjectLoaded_callback(
    inObject,    -- XPLMObjectRef
    inRefcon     -- any Lua var/table
)
    -- your code here
end</code></pre>
</div>


**See associated types:**

- [XPLMObjectRef](#xplmobjectref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMLoadObject" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMLoadObject { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM200</span>

</div>

This routine loads an OBJ file and returns a handle to it. If X-Plane has already loaded the object, the
handle to the existing object is returned. Do not assume you will get the same handle back twice, but do make
sure to call unload once for every load to avoid "leaking" objects. The object will be purged from memory when
no plugins and no scenery are using it.

The path for the object must be relative to the X-System base folder. If the path is in the root of the
X-System folder you may need to prepend ./ to it; loading objects in the root of the X-System folder is STRONGLY
discouraged - your plugin should not dump art resources in the root folder!

XPLMLoadObject will return NULL if the object cannot be loaded (either because it is not found or the
file is misformatted). This routine will load any object that can be used in the X-Plane scenery system.

It is important that the datarefs an object uses for animation already be registered before you load the
object. For this reason it may be necessary to defer object loading until the sim has fully started.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns XPLMObjectRef -> assign to local/var
local my_objectRef = XPLMLoadObject(
    inPath     -- string
)</code></pre>
</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMLoadObjectAsync" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMLoadObjectAsync { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM210</span>

</div>

This routine loads an object asynchronously; control is returned to you immediately while X-Plane loads
the object. The sim will not stop flying while the object loads. For large objects, it may be several
seconds before the load finishes.

You provide a callback function that is called once the load has completed. Note that if the object
cannot be loaded, you will not find out until the callback function is called with a NULL object handle.

There is no way to cancel an asynchronous object load; you must wait for the load to complete and then
release the object if it is no longer desired.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMLoadObjectAsync(
    inPath,        -- string
    inCallback,    -- see XPLMObjectLoaded_f
    inRefcon       -- any Lua var/table
)</code></pre>
</div>


**See associated types:**

- [XPLMObjectLoaded_f](#xplmobjectloaded_f)
</div>

---

<div class="sym-block sym-function" data-name="XPLMUnloadObject" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMUnloadObject { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM200</span>

</div>

This routine marks an object as no longer being used by your plugin. Objects are reference counted: once
no plugins are using an object, it is purged from memory. Make sure to call XPLMUnloadObject once for each
successful call to XPLMLoadObject.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMUnloadObject(
    inObject     -- XPLMObjectRef
)</code></pre>
</div>


**See associated types:**

- [XPLMObjectRef](#xplmobjectref)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>