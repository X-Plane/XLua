<h1>Panel Graphics Fonts</h1>

These routines create fonts from TrueType font files and draw text onto the
panel. You create a font handle, add one or more TTF faces to it, then use
the handle to measure and draw strings. Font handles must be destroyed when
no longer needed.

---

<div class="sym-block sym-enum" data-name="XPLMCharSet_t" data-type="enum" markdown="1">

## XPLMCharSet_t { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

This enumeration specifies the character set for a font created with
XPLMCreateFont. The character set determines which glyphs are rasterized
and available for drawing.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_CharSetDigits | 0 | Digits 0-9 and common numeric punctuation only. |
| xplm_CharSetASCII | 1 | The printable ASCII character range (codes 32-126). |
| xplm_CharSetUnicode | 2 | Full Unicode support; glyphs are rasterized on demand. |

</div>

</div>

---

<div class="sym-block sym-enum" data-name="XPLMJustification_t" data-type="enum" markdown="1">

## XPLMJustification_t { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

This enumeration specifies horizontal text justification for the font
drawing routines. The x and y position you pass to a drawing function is
the baseline of the text at the anchor point determined by justification:
left-aligned text anchors at the left edge, centered text at the midpoint,
and right-aligned text at the right edge.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_JustLeft | 0 | Left-justified; x is the left edge of the string. |
| xplm_JustCenter | 1 | Center-justified; x is the horizontal center of the string. |
| xplm_JustRight | 2 | Right-justified; x is the right edge of the string. |

</div>

</div>

---

<div class="sym-block sym-struct" data-name="XPLMFontMetrics_t" data-type="struct" markdown="1">

## XPLMFontMetrics_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

XPLMFontMetrics_t receives font measurement data from XPLMFontGetMetrics.
The structure may be expanded in future SDKs - always set structSize to the
size of your structure in bytes.

```cpp
typedef struct {
     int                       structSize;
     float                     lineHeight;
     float                     lineAscent;
     float                     lineDescent;
} XPLMFontMetrics_t;
```

</div>

---

<div class="sym-block sym-typedef" data-name="XPLMFontHandle" data-type="typedef" markdown="1">

## XPLMFontHandle { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

An opaque handle to a font created by XPLMCreateFont. Pass this handle to
the font measurement and drawing routines. Destroy the handle with
XPLMDestroyFont when you are done with it.

```cpp
typedef void* XPLMFontHandle;
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMCreateFont" data-type="function" markdown="1">

## XPLMCreateFont { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function creates a new font handle. The character set determines which
glyphs are available for rendering. After creating the font, add one or more
TrueType faces with XPLMFontAddFace before drawing.

Returns an opaque font handle.

```cpp
XPLM_API XPLMFontHandleXPLMCreateFont(
                         XPLMCharSet_t        charset
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMDestroyFont" data-type="function" markdown="1">

## XPLMDestroyFont { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function destroys a font handle and frees all associated resources.

```cpp
XPLM_API void       XPLMDestroyFont(
                         XPLMFontHandle       font
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMFontAddFace" data-type="function" markdown="1">

## XPLMFontAddFace { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function adds a TrueType font face to an existing font handle. You may
add multiple faces to a single font to provide fallback glyphs; if a glyph
is not found in the first face, subsequent faces are searched in the order
they were added.

- ttf_path: a file system path to a .ttf or .otf font file.

```cpp
XPLM_API void       XPLMFontAddFace(
                         XPLMFontHandle       font,
                         char const*          ttf_path
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMFontGetMetrics" data-type="function" markdown="1">

## XPLMFontGetMetrics { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function returns line metrics for a font at a given size. The metrics
describe the vertical dimensions of a line of text and are useful for
computing text layout.

- fontSize: the font size in pixels.
- outMetrics: receives the computed metrics. You must set outMetrics->structSize
  before calling.

```cpp
XPLM_API void       XPLMFontGetMetrics(
                         XPLMFontHandle       font,
                         float                fontSize,
                         XPLMFontMetrics_t*   outMetrics
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMFontMeasureString" data-type="function" markdown="1">

## XPLMFontMeasureString { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function returns the width in pixels that a string would occupy if
drawn at the given font size. The string is not drawn.

Returns the horizontal advance width, in pixels.

```cpp
XPLM_API float      XPLMFontMeasureString(
                         XPLMFontHandle       font,
                         float                fontSize,
                         char const*          string
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMFontGetLineCount" data-type="function" markdown="1">

## XPLMFontGetLineCount { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function calculates how many lines a string would occupy if word-wrapped
to the specified width at the given font size.

Returns the number of lines.

```cpp
XPLM_API int        XPLMFontGetLineCount(
                         XPLMFontHandle       font,
                         float                fontSize,
                         char const*          string,
                         float                width
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMFontFitForward" data-type="function" markdown="1">

## XPLMFontFitForward { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function returns the number of characters from the beginning of a
string that fit within the specified width at the given font size. Characters
are measured left to right.

Returns a character count.

```cpp
XPLM_API int        XPLMFontFitForward(
                         XPLMFontHandle       font,
                         float                fontSize,
                         char const*          string,
                         float                width
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMFontFitReverse" data-type="function" markdown="1">

## XPLMFontFitReverse { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function returns the number of characters in the input string that must be
skipped to fit the reset of the string into the specified space. This is useful for
right-aligning a truncated string.

Returns a character count - the number of characters that must be removed to fit.

```cpp
XPLM_API int        XPLMFontFitReverse(
                         XPLMFontHandle       font,
                         float                fontSize,
                         char const*          string,
                         float                width
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMFontDrawString" data-type="function" markdown="1">

## XPLMFontDrawString { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function draws a null-terminated string at the specified position with
the given font, size, color, and justification. The x and y coordinates
specify the baseline position at the justification anchor point.

- fontSize: the font size in pixels.
- x, y: the anchor position of the baseline, in panel coordinates.

```cpp
XPLM_API void       XPLMFontDrawString(
                         XPLMFontHandle       font,
                         uint32_t             color,
                         float                fontSize,
                         float                x,
                         float                y,
                         char const*          string,
                         XPLMJustification_t  justification
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMFontDrawStringFixedSpacing" data-type="function" markdown="1">

## XPLMFontDrawStringFixedSpacing { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function draws a null-terminated string using fixed character spacing
instead of the font's natural proportional spacing. Each character occupies
exactly fixedSpacing pixels horizontally, regardless of the glyph's actual
width. This is useful for numeric readouts where digits must not shift as
values change.

- fontSize: the font size in pixels.
- x, y: the anchor position of the baseline, in panel coordinates.
- fixedSpacing: the horizontal advance per character, in pixels.

```cpp
XPLM_API void       XPLMFontDrawStringFixedSpacing(
                         XPLMFontHandle       font,
                         uint32_t             color,
                         float                fontSize,
                         float                x,
                         float                y,
                         char const*          string,
                         int                  fixedSpacing,
                         XPLMJustification_t  justification
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMFontDrawStringWordWrapped" data-type="function" markdown="1">

## XPLMFontDrawStringWordWrapped { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function draws a null-terminated string with automatic word wrapping.
Text is broken at word boundaries to fit within the specified wrap width.
Lines are stacked downward from the initial y position, spaced by the font's
line height.

- fontSize: the font size in pixels.
- x, y: the anchor position of the first line's baseline, in panel coordinates.
- wrapWidth: the maximum line width in pixels before wrapping.

```cpp
XPLM_API void       XPLMFontDrawStringWordWrapped(
                         XPLMFontHandle       font,
                         uint32_t             color,
                         float                fontSize,
                         float                x,
                         float                y,
                         char const*          string,
                         int                  wrapWidth,
                         XPLMJustification_t  justification
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMFontDrawStringRotated" data-type="function" markdown="1">

## XPLMFontDrawStringRotated { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function draws a null-terminated string rotated by the specified angle
around the anchor point. The anchor point is determined by x, y, and the
justification, just as in XPLMFontDrawString.

- fontSize: the font size in pixels.
- x, y: the anchor position of the baseline, in panel coordinates.
- angle: the rotation angle in degrees, positive clockwise.

```cpp
XPLM_API void       XPLMFontDrawStringRotated(
                         XPLMFontHandle       font,
                         uint32_t             color,
                         float                fontSize,
                         float                x,
                         float                y,
                         char const*          string,
                         float                angle,
                         XPLMJustification_t  justification
                    );
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>