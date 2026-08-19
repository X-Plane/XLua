<h1>Sub Window</h1>

X-Plane dialogs are divided into separate areas; the sub window widgets allow you to make these areas.
Create one main window and place several subwindows inside it. Then place your controls inside the
subwindows.

---

<div class="sym-block sym-define" data-name="xpWidgetClass_SubWindow" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## xpWidgetClass_SubWindow { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define xpWidgetClass_SubWindow 2`

</div>

</div>

---

<div class="sym-block sym-enum" data-name="SubWindow Type Values" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## SubWindow Type Values { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

These values control the appearance of the subwindow.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xpSubWindowStyle_SubWindow | 0 | A panel that sits inside a main window. |
| xpSubWindowStyle_Screen | 2 | A screen that sits inside a panel for showing text information. |
| xpSubWindowStyle_ListView | 3 | A list view for scrolling lists. |

</div>

</div>

---

<div class="sym-block sym-enum" data-name="SubWindow Properties" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## SubWindow Properties { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xpProperty_SubWindowType | 1200 | This property specifies the type of window.  Set to one of the subwindow types above. |

</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>