<h1>Main Window</h1>

The main window widget class provides a "window" as the user knows it. These windows
are draggable and can be selected. Use them to create floating windows and non-modal
dialogs.

---

<div class="sym-block sym-define" data-name="xpWidgetClass_MainWindow" data-type="define" markdown="1">

## xpWidgetClass_MainWindow { .symbol-title }

<span class="sym-badge badge-define">define</span>

`#define xpWidgetClass_MainWindow 1`

</div>

---

<div class="sym-block sym-enum" data-name="Main Window Type Values" data-type="enum" markdown="1">

## Main Window Type Values { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

These type values are used to control the appearance of a main window.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xpMainWindowStyle_MainWindow | 0 | The standard main window; pin stripes on XP7, metal frame on XP 6. |
| xpMainWindowStyle_Translucent | 1 | A translucent dark gray window. |

</div>

</div>

---

<div class="sym-block sym-enum" data-name="Main Window Properties" data-type="enum" markdown="1">

## Main Window Properties { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xpProperty_MainWindowType | 1100 | This property specifies the type of window.  Set to one of the main window types above. |
| xpProperty_MainWindowHasCloseBoxes | 1200 | This property specifies whether the main window has close boxes in its corners. |

</div>

</div>

---

<div class="sym-block sym-enum" data-name="MainWindow Messages" data-type="enum" markdown="1">

## MainWindow Messages { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xpMessage_CloseButtonPushed | 1200 | This message is sent when the close buttons for your window are pressed. |

</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>