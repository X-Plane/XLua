<h1>Text Field</h1>

The text field widget provides an editable text field including mouse selection and keyboard navigation.
The contents of the text field are its descriptor. (The descriptor changes as the user types.)

The text field can have a number of types, that affect the visual layout of the text field.
The text field sends messages to itself so you may control its behavior.

If you need to filter keystrokes, add a new handler and intercept the key press message. Since
key presses are passed by pointer, you can modify the keystroke and pass it through to the text field
widget.

WARNING: in X-Plane before 7.10 (including 6.70) null characters could crash X-Plane. To prevent this, wrap
this object with a filter function (more instructions can be found on the SDK website).

---

<div class="sym-block sym-define" data-name="xpWidgetClass_TextField" data-type="define" markdown="1">

## xpWidgetClass_TextField { .symbol-title }

<span class="sym-badge badge-define">define</span>

`#define xpWidgetClass_TextField 4`

</div>

---

<div class="sym-block sym-enum" data-name="Text Field Type Values" data-type="enum" markdown="1">

## Text Field Type Values { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

These control the look of the text field.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xpTextEntryField | 0 | A field for text entry. |
| xpTextTransparent | 3 | A transparent text field. The user can type and the text is drawn, but no background is drawn. You can draw your own background by adding a widget handler and prehandling the draw message. |
| xpTextTranslucent | 4 | A translucent edit field, dark gray. |

</div>

</div>

---

<div class="sym-block sym-enum" data-name="Text Field Properties" data-type="enum" markdown="1">

## Text Field Properties { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xpProperty_EditFieldSelStart | 1400 | This is the character position the selection starts at, zero based. If it is the same as the end insertion point, the insertion point is not a selection. |
| xpProperty_EditFieldSelEnd | 1401 | This is the character position of the end of the selection. |
| xpProperty_EditFieldSelDragStart | 1402 | This is the character position a drag was started at if the user is dragging to select text, or -1 if a drag is not in progress. |
| xpProperty_TextFieldType | 1403 | This is the type of text field to display, from the above list. |
| xpProperty_PasswordMode | 1404 | Set this property to 1 to password protect the field. Characters will be drawn as *s even though the descriptor will contain plain-text. |
| xpProperty_MaxCharacters | 1405 | The max number of characters you can enter, if limited.  Zero means unlimited. |
| xpProperty_ScrollPosition | 1406 | The first visible character on the left.  This effectively scrolls the text field. |
| xpProperty_Font | 1407 | The font to draw the field's text with.  (An XPLMFontID.) |
| xpProperty_ActiveEditSide | 1408 | This is the active side of the insert selection.  (Internal) |

</div>

</div>

---

<div class="sym-block sym-enum" data-name="Text Field Messages" data-type="enum" markdown="1">

## Text Field Messages { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xpMsg_TextFieldChanged | 1400 | The text field sends this message to itself when its text changes. It sends the message up the call chain; param1 is the text field's widget ID. |

</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>