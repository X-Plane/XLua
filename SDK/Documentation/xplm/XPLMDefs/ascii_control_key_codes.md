<h1>Ascii Control Key Codes</h1>

These definitions define how various control keys are mapped to ASCII key codes.
Not all key presses generate an ASCII value, so plugin code should be prepared to
see null characters come from the keyboard...this usually represents a key stroke
that has no equivalent ASCII, like a page-down press.  Use virtual key codes to find
these key strokes.

ASCII key codes take into account modifier keys; shift keys will affect capitals and
punctuation; control key combinations may have no vaild ASCII and produce NULL.  To
detect control-key combinations, use virtual key codes, not ASCII keys.

---

<div class="sym-block sym-define" data-name="XPLM_KEY_RETURN" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_KEY_RETURN { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_KEY_RETURN 13`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_KEY_ESCAPE" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_KEY_ESCAPE { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_KEY_ESCAPE 27`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_KEY_TAB" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_KEY_TAB { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_KEY_TAB 9`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_KEY_DELETE" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_KEY_DELETE { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_KEY_DELETE 8`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_KEY_LEFT" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_KEY_LEFT { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_KEY_LEFT 28`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_KEY_RIGHT" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_KEY_RIGHT { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_KEY_RIGHT 29`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_KEY_UP" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_KEY_UP { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_KEY_UP 30`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_KEY_DOWN" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_KEY_DOWN { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_KEY_DOWN 31`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_KEY_0" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_KEY_0 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_KEY_0 48`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_KEY_1" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_KEY_1 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_KEY_1 49`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_KEY_2" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_KEY_2 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_KEY_2 50`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_KEY_3" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_KEY_3 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_KEY_3 51`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_KEY_4" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_KEY_4 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_KEY_4 52`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_KEY_5" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_KEY_5 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_KEY_5 53`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_KEY_6" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_KEY_6 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_KEY_6 54`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_KEY_7" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_KEY_7 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_KEY_7 55`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_KEY_8" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_KEY_8 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_KEY_8 56`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_KEY_9" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_KEY_9 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_KEY_9 57`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_KEY_DECIMAL" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_KEY_DECIMAL { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_KEY_DECIMAL 46`

</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>