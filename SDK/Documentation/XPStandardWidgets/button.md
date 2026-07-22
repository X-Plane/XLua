<h1>Button</h1>

The button class provides a number of different button styles and behaviors, including push
buttons, radio buttons, check boxes, etc. The button label appears on or next to the button
depending on the button's appearance or type.

The button's behavior is a separate property
that dictates who it highlights and what kinds of messages it sends. Since behavior and type
are different, you can do strange things like make check boxes that act as push buttons or push
buttons with radio button behavior.

In X-Plane 6 there were no check box graphics. The result is the following behavior: in X-Plane
6 all check box and radio buttons are round (radio-button style) buttons; in X-Plane 7 they are
all square (check-box style) buttons. In a future version of X-Plane, the xpButtonBehavior
enums will provide the correct graphic (check box or radio button) giving the expected result.

---

<div class="sym-block sym-define" data-name="xpWidgetClass_Button" data-type="define" markdown="1">

## xpWidgetClass_Button { .symbol-title }

<span class="sym-badge badge-define">define</span>

`#define xpWidgetClass_Button 3`

</div>

---

<div class="sym-block sym-enum" data-name="Button Types" data-type="enum" markdown="1">

## Button Types { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

These define the visual appearance of buttons but not how they respond to the mouse.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xpPushButton | 0 | This is a standard push button, like an 'OK' or 'Cancel' button in a dialog box. |
| xpRadioButton | 1 | A check box or radio button.  Use this and the button behaviors below to get the desired behavior. |
| xpWindowCloseBox | 3 | A window close box. |
| xpLittleDownArrow | 5 | A small down arrow. |
| xpLittleUpArrow | 6 | A small up arrow. |

</div>

</div>

---

<div class="sym-block sym-enum" data-name="Button Behavior Values" data-type="enum" markdown="1">

## Button Behavior Values { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

These define how the button responds to mouse clicks.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xpButtonBehaviorPushButton | 0 | Standard push button behavior. The button highlights while the mouse is clicked over it and unhighlights when the mouse is moved outside of it or released. If the mouse is released over the button, the xpMsg_PushButtonPressed message is sent. |
| xpButtonBehaviorCheckBox | 1 | Check box behavior. The button immediately toggles its value when the mouse is clicked and sends out a xpMsg_ButtonStateChanged message. |
| xpButtonBehaviorRadioButton | 2 | Radio button behavior. The button immediately sets its state to one and sends out a xpMsg_ButtonStateChanged message if it was not already set to one. You must turn off other radio buttons in a group in your code. |

</div>

</div>

---

<div class="sym-block sym-enum" data-name="Button Properties" data-type="enum" markdown="1">

## Button Properties { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xpProperty_ButtonType | 1300 | This property sets the visual type of button.  Use one of the button types above. |
| xpProperty_ButtonBehavior | 1301 | This property sets the button's behavior.  Use one of the button behaviors above. |
| xpProperty_ButtonState | 1302 | This property tells whether a check box or radio button is "checked" or not. Not used for push buttons. |

</div>

</div>

---

<div class="sym-block sym-enum" data-name="Button Messages" data-type="enum" markdown="1">

## Button Messages { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

These messages are sent by the button to itself and then up the
widget chain when the button is clicked. (You may intercept them by providing a widget handler
for the button itself or by providing a handler in a parent widget.)

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xpMsg_PushButtonPressed | 1300 | This message is sent when the user completes a click and release in a button with push button behavior. Parameter one of the message is the widget ID of the button. This message is dispatched up the widget hierarchy. |
| xpMsg_ButtonStateChanged | 1301 | This message is sent when a button is clicked that has radio button or check box behavior and its value changes. (Note that if the value changes by setting a property you do not receive this message!) Parameter one is the widget ID of the button, parameter 2 is the new state value, either zero or one. This message is dispatched up the widget hierarchy. |

</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>