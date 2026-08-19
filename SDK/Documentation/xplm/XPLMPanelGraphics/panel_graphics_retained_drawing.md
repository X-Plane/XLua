<h1>Panel Graphics Retained Drawing</h1>

These routines let you record a sequence of panel graphics drawing commands
and replay them efficiently on subsequent frames. This is useful for static
or infrequently changing parts of a display: record once, then replay each
frame without reissuing individual draw calls.

WARNING: A retained drawing captures references to the texture atlases and
fonts used during recording. If you destroy a texture atlas or font that was
used in a retained drawing, you must also destroy that retained drawing -
replaying it will reference invalid resources.

---

<div class="sym-block sym-typedef" data-name="XPLMRetainedDrawing_t" data-type="typedef" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMRetainedDrawing_t { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

</div>

An opaque handle to a recorded sequence of drawing commands. Create one by
bracketing draw calls between XPLMBeginRetainedDrawing and
XPLMEndRetainedDrawing. Destroy it with XPLMDestroyRetainedDrawing when it
is no longer needed.

<div class="xplm-code" markdown="1">

```cpp
typedef void * XPLMRetainedDrawing_t;
```

</div>


**Used by:**

- [XPLMDestroyRetainedDrawing](#xplmdestroyretaineddrawing)
- [XPLMDrawRetained](#xplmdrawretained)
</div>

---

<div class="sym-block sym-function" data-name="XPLMBeginRetainedDrawing" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMBeginRetainedDrawing { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function begins recording drawing commands. All panel graphics calls
made after this function and before XPLMEndRetainedDrawing are captured into
a retained drawing instead of being rendered immediately.

NOTE: Do not nest retained drawing sessions.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMBeginRetainedDrawing(void);
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMEndRetainedDrawing" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMEndRetainedDrawing { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function ends recording and returns a handle to the captured drawing
commands. Subsequent panel graphics calls are once again rendered immediately.

Returns an opaque handle to the retained drawing.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API XPLMRetainedDrawing_t XPLMEndRetainedDrawing(void);
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMDrawRetained" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDrawRetained { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function replays a previously recorded sequence of drawing commands.
You can call this multiple times per frame and across multiple frames to
efficiently re-draw the same content.

The drawing happens where you replay it, in the state in force at that point,
so you can freely translate, scale and rotate a retained drawing to place it -
this is one of the main reasons to use one.

The exception is a drawing that contains something axis-aligned: scissors,
XPLMDrawCalls, an SVT display or a map display. Replaying such a drawing while
a rotation is in effect is an error. Translate and scale are always fine.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMDrawRetained(
                         XPLMRetainedDrawing_t drawing
                    );
```

</div>


**See associated types:**

- [XPLMRetainedDrawing_t](#xplmretaineddrawing_t)
</div>

---

<div class="sym-block sym-function" data-name="XPLMDestroyRetainedDrawing" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDestroyRetainedDrawing { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function destroys a retained drawing and frees its resources.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMDestroyRetainedDrawing(
                         XPLMRetainedDrawing_t drawing
                    );
```

</div>


**See associated types:**

- [XPLMRetainedDrawing_t](#xplmretaineddrawing_t)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>