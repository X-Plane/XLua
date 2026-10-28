<h1>Virtual Key Codes</h1>

These are cross-platform defines for every distinct keyboard press on the computer.
Every physical key on the keyboard has a virtual key code.  So the "two" key on the
top row of the main keyboard has a different code from the "two" key on the numeric
key pad.  But the 'w' and 'W' character are indistinguishable by virtual key code
because they are the same physical key (one with and one without the shift key).

Use virtual key codes to detect keystrokes that do not have ASCII equivalents,
allow the user to map the numeric keypad separately from the main keyboard, and detect
control key and other modifier-key combinations that generate ASCII control key sequences
(many of which are not available directly via character keys in the SDK).

To assign virtual key codes we started with the Microsoft set but made some additions
and changes.  A few differences:

1. Modifier keys are not available as virtual key codes.  You cannot get distinct modifier press
and release messages.  Please do not try to use modifier keys as regular keys; doing so
will almost certainly interfere with users' abilities to use the native X-Plane key bindings.
2. Some keys that do not exist on both Mac and PC keyboards are removed.
3. Do not assume that the values of these keystrokes are interchangeable with MS v-keys.

---

<div class="sym-block sym-define" data-name="XPLM_VK_BACK" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_BACK { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_BACK 0x08`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_TAB" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_TAB { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_TAB 0x09`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_CLEAR" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_CLEAR { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_CLEAR 0x0C`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_RETURN" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_RETURN { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_RETURN 0x0D`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_ESCAPE" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_ESCAPE { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_ESCAPE 0x1B`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_SPACE" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_SPACE { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_SPACE 0x20`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_PRIOR" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_PRIOR { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_PRIOR 0x21`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_NEXT" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_NEXT { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_NEXT 0x22`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_END" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_END { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_END 0x23`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_HOME" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_HOME { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_HOME 0x24`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_LEFT" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_LEFT { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_LEFT 0x25`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_UP" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_UP { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_UP 0x26`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_RIGHT" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_RIGHT { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_RIGHT 0x27`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_DOWN" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_DOWN { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_DOWN 0x28`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_SELECT" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_SELECT { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_SELECT 0x29`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_PRINT" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_PRINT { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_PRINT 0x2A`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_EXECUTE" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_EXECUTE { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_EXECUTE 0x2B`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_SNAPSHOT" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_SNAPSHOT { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_SNAPSHOT 0x2C`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_INSERT" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_INSERT { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_INSERT 0x2D`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_DELETE" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_DELETE { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_DELETE 0x2E`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_HELP" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_HELP { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_HELP 0x2F`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_0" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_0 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

XPLM_VK_0 thru XPLM_VK_9 are the same as ASCII '0' thru '9' (0x30 - 0x39)

<div class="xplm-code" markdown="1">

`#define XPLM_VK_0 0x30`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_1" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_1 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_1 0x31`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_2" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_2 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_2 0x32`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_3" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_3 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_3 0x33`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_4" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_4 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_4 0x34`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_5" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_5 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_5 0x35`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_6" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_6 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_6 0x36`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_7" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_7 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_7 0x37`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_8" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_8 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_8 0x38`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_9" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_9 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_9 0x39`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_A" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_A { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

XPLM_VK_A thru XPLM_VK_Z are the same as ASCII 'A' thru 'Z' (0x41 - 0x5A)

<div class="xplm-code" markdown="1">

`#define XPLM_VK_A 0x41`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_B" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_B { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_B 0x42`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_C" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_C { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_C 0x43`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_D" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_D { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_D 0x44`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_E" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_E { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_E 0x45`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F 0x46`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_G" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_G { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_G 0x47`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_H" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_H { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_H 0x48`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_I" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_I { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_I 0x49`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_J" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_J { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_J 0x4A`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_K" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_K { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_K 0x4B`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_L" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_L { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_L 0x4C`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_M" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_M { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_M 0x4D`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_N" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_N { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_N 0x4E`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_O" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_O { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_O 0x4F`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_P" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_P { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_P 0x50`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_Q" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_Q { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_Q 0x51`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_R" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_R { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_R 0x52`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_S" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_S { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_S 0x53`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_T" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_T { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_T 0x54`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_U" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_U { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_U 0x55`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_V" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_V { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_V 0x56`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_W" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_W { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_W 0x57`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_X" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_X { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_X 0x58`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_Y" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_Y { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_Y 0x59`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_Z" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_Z { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_Z 0x5A`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_NUMPAD0" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_NUMPAD0 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_NUMPAD0 0x60`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_NUMPAD1" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_NUMPAD1 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_NUMPAD1 0x61`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_NUMPAD2" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_NUMPAD2 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_NUMPAD2 0x62`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_NUMPAD3" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_NUMPAD3 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_NUMPAD3 0x63`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_NUMPAD4" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_NUMPAD4 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_NUMPAD4 0x64`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_NUMPAD5" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_NUMPAD5 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_NUMPAD5 0x65`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_NUMPAD6" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_NUMPAD6 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_NUMPAD6 0x66`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_NUMPAD7" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_NUMPAD7 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_NUMPAD7 0x67`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_NUMPAD8" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_NUMPAD8 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_NUMPAD8 0x68`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_NUMPAD9" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_NUMPAD9 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_NUMPAD9 0x69`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_MULTIPLY" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_MULTIPLY { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_MULTIPLY 0x6A`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_ADD" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_ADD { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_ADD 0x6B`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_SEPARATOR" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_SEPARATOR { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_SEPARATOR 0x6C`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_SUBTRACT" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_SUBTRACT { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_SUBTRACT 0x6D`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_DECIMAL" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_DECIMAL { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_DECIMAL 0x6E`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_DIVIDE" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_DIVIDE { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_DIVIDE 0x6F`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F1" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F1 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F1 0x70`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F2" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F2 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F2 0x71`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F3" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F3 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F3 0x72`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F4" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F4 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F4 0x73`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F5" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F5 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F5 0x74`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F6" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F6 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F6 0x75`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F7" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F7 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F7 0x76`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F8" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F8 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F8 0x77`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F9" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F9 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F9 0x78`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F10" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F10 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F10 0x79`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F11" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F11 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F11 0x7A`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F12" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F12 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F12 0x7B`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F13" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F13 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F13 0x7C`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F14" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F14 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F14 0x7D`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F15" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F15 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F15 0x7E`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F16" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F16 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F16 0x7F`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F17" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F17 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F17 0x80`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F18" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F18 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F18 0x81`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F19" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F19 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F19 0x82`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F20" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F20 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F20 0x83`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F21" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F21 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F21 0x84`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F22" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F22 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F22 0x85`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F23" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F23 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F23 0x86`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_F24" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_F24 { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_F24 0x87`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_EQUAL" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_EQUAL { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

The following definitions are extended and are not based on the Microsoft key set.

<div class="xplm-code" markdown="1">

`#define XPLM_VK_EQUAL 0xB0`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_MINUS" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_MINUS { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_MINUS 0xB1`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_RBRACE" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_RBRACE { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_RBRACE 0xB2`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_LBRACE" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_LBRACE { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_LBRACE 0xB3`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_QUOTE" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_QUOTE { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_QUOTE 0xB4`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_SEMICOLON" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_SEMICOLON { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_SEMICOLON 0xB5`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_BACKSLASH" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_BACKSLASH { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_BACKSLASH 0xB6`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_COMMA" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_COMMA { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_COMMA 0xB7`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_SLASH" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_SLASH { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_SLASH 0xB8`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_PERIOD" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_PERIOD { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_PERIOD 0xB9`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_BACKQUOTE" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_BACKQUOTE { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_BACKQUOTE 0xBA`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_ENTER" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_ENTER { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_ENTER 0xBB`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_NUMPAD_ENT" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_NUMPAD_ENT { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_NUMPAD_ENT 0xBC`

</div>

</div>

---

<div class="sym-block sym-define" data-name="XPLM_VK_NUMPAD_EQ" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLM_VK_NUMPAD_EQ { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define XPLM_VK_NUMPAD_EQ 0xBD`

</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>