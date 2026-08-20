<h1>Scroll Bar</h1>

A standard scroll bar or slider control. The scroll bar has a minimum,
maximum and current value that is updated when the user drags it. The scroll
bar sends continuous messages as it is dragged.

---

<div class="sym-block sym-define" data-name="xpWidgetClass_ScrollBar" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## xpWidgetClass_ScrollBar { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="lua-code" markdown="1">
<pre><code class="language-lua">xpWidgetClass_ScrollBar  -- 5</code></pre>
</div>

</div>

---

<div class="sym-block sym-enum" data-name="Scroll Bar Type Values" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## Scroll Bar Type Values { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

This defines how the scroll bar looks.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xpScrollBarTypeScrollBar | 0 | A standard X-Plane scroll bar (with arrows on the ends). |
| xpScrollBarTypeSlider | 1 | A slider, no arrows. |

</div>

</div>

---

<div class="sym-block sym-enum" data-name="Scroll Bar Properties" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## Scroll Bar Properties { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xpProperty_ScrollBarSliderPosition | 1500 | The current position of the thumb (in between the min and max, inclusive) |
| xpProperty_ScrollBarMin | 1501 | The value the scroll bar has when the thumb is in the lowest position. |
| xpProperty_ScrollBarMax | 1502 | The value the scroll bar has when the thumb is in the highest position. |
| xpProperty_ScrollBarPageAmount | 1503 | How many units to move the scroll bar when clicking next to the thumb. The scroll bar always moves one unit when the arrows are clicked. |
| xpProperty_ScrollBarType | 1504 | The type of scrollbar from the enums above. |
| xpProperty_ScrollBarSlop | 1505 | Used internally. |

</div>

</div>

---

<div class="sym-block sym-enum" data-name="Scroll Bar Messages" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## Scroll Bar Messages { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xpMsg_ScrollBarSliderPositionChanged | 1500 | The scroll bar sends this message when the slider position changes. It sends the message up the call chain; param1 is the scroll bar widget ID. |

</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>