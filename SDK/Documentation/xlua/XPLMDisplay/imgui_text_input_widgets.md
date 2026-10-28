<h1>Imgui Text Input Widgets</h1>

Hand-written imgui text-entry widgets (Lua only). Each returns (changed,
new_text): changed is true on the frame the text was edited, and new_text is
the current buffer contents (echoed back unchanged when no imgui frame is
active). Lua holds the canonical string between frames; pass it back in on the
next call.

---

<div class="sym-block sym-function" data-name="InputText" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## InputText { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

imgui.InputText(label, current_text, [max_len=256], [flags=0]) returns changed, new_text

<div class="lua-code" markdown="1">
<!-- hand-written binding; see the XLua docs -->
</div>

</div>

---

<div class="sym-block sym-function" data-name="InputTextWithHint" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## InputTextWithHint { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

imgui.InputTextWithHint(label, hint, current_text, [max_len=256], [flags=0]) returns changed, new_text

<div class="lua-code" markdown="1">
<!-- hand-written binding; see the XLua docs -->
</div>

</div>

---

<div class="sym-block sym-function" data-name="InputTextMultiline" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## InputTextMultiline { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

imgui.InputTextMultiline(label, current_text, [max_len=4096], [width=0], [height=0], [flags=0]) returns changed, new_text

<div class="lua-code" markdown="1">
<!-- hand-written binding; see the XLua docs -->
</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>