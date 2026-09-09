<h1>X-Plane Text</h1>

---

<div class="sym-block sym-enum" data-name="XPLMFontID" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMFontID { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

X-Plane features some fixed-character fonts.  Each font may have its own metrics.

WARNING: Some of these fonts are no longer supported or may have changed geometries.
For maximum copmatibility, see the comments below.

Note: X-Plane 7 supports proportional-spaced fonts.  Since no measuring routine
is available yet, the SDK will normally draw using a fixed-width font.  You can
use a dataref to enable proportional font drawing on XP7 if you want to.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplmFont_Basic | 0 | Mono-spaced font for user interface.  Available in all versions of the SDK. |
| xplmFont_Proportional | 18 | Proportional UI font. |

</div>

**Used by:**

- [XPLMDrawNumber](#xplmdrawnumber)
- [XPLMDrawString](#xplmdrawstring)
- [XPLMGetFontDimensions](#xplmgetfontdimensions)
- [XPLMMeasureString](#xplmmeasurestring)

</div>

---

<div class="sym-block sym-function" data-name="XPLMDrawString" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDrawString { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine draws a NULL terminated string in a given font.  Pass in the lower
left pixel that the character is to be drawn onto.  Also pass the character and font ID.
This function returns the x offset plus the width of all drawn characters.
The color to draw in is specified as a pointer to an array of three
floating point colors, representing RGB intensities from 0.0 to 1.0.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMDrawString(
    inColorRGB,         -- float
    inXOffset,          -- int
    inYOffset,          -- int
    inChar,             -- string
    inWordWrapWidth,    -- int
    inFontID            -- XPLMFontID
)</code></pre>
</div>


**See associated types:**

- [XPLMFontID](#xplmfontid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMDrawNumber" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMDrawNumber { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine draws a number similar to the digit editing fields in PlaneMaker and data
output display in X-Plane.  Pass in a color, a position, a floating point value, and
formatting info.  Specify how many integer and how many decimal digits to show and
whether to show a sign, as well as a character set.
This routine returns the xOffset plus width of the string drawn.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">XPLMDrawNumber(
    inColorRGB,    -- float
    inXOffset,     -- int
    inYOffset,     -- int
    inValue,       -- float
    inDigits,      -- int
    inDecimals,    -- int
    inShowSign,    -- boolean
    inFontID       -- XPLMFontID
)</code></pre>
</div>


**See associated types:**

- [XPLMFontID](#xplmfontid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMGetFontDimensions" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetFontDimensions { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the width and height of a character in a given font.
It also tells you if the font only supports numeric digits.  Pass NULL
if you don't need a given field.  Note that for a proportional font the
width will be an arbitrary, hopefully average width.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns a table of out values
local outs = XPLMGetFontDimensions(
    inFontID     -- XPLMFontID
)
-- outs = { outCharWidth, outCharHeight, outDigitsOnly }</code></pre>
</div>


**See associated types:**

- [XPLMFontID](#xplmfontid)
</div>

---

<div class="sym-block sym-function" data-name="XPLMMeasureString" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMMeasureString { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM200</span>

</div>

This routine returns the width in pixels of a string using a given
font.  The string is passed as a pointer plus length (and does not need
to be null terminated); this is used to allow for measuring substrings.
The return value is floating point; it is possible that future font
drawing may allow for fractional pixels.

<div class="lua-code" markdown="1">
<pre><code class="language-lua">-- returns float -> assign to local/var
local my_result = XPLMMeasureString(
    inFontID,      -- XPLMFontID
    inChar,        -- string
    inNumChars     -- int
)</code></pre>
</div>


**See associated types:**

- [XPLMFontID](#xplmfontid)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>