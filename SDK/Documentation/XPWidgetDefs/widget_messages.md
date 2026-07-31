<h1>Widget Messages</h1>

---

<div class="sym-block sym-enum" data-name="XPWidgetMessage" data-type="enum" markdown="1">

## XPWidgetMessage { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

Widgets receive 32-bit messages indicating what action is to be taken or
notifications of events. The list of messages may be expanded.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xpMsg_None | 0 | No message, should not be sent. |
| xpMsg_Create | 1 | The create message is sent once per widget that is created with your widget function and once for any widget that has your widget function attached.  Dispatching: Direct  Param 1: 1 if you are being added as a subclass, 0 if the widget is first being created. |
| xpMsg_Destroy | 2 | The destroy message is sent once for each message that is destroyed that has your widget function.  Dispatching: Direct for all  Param 1: 1 if being deleted by a recursive delete to the parent, 0 for explicit deletion. |
| xpMsg_Paint | 3 | The paint message is sent to your widget to draw itself. The paint message is the bare-bones message; in response you must draw yourself, draw your children, set up clipping and culling, check for visibility, etc. If you don't want to do all of this, ignore the paint message and a draw message (see below) will be sent to you.  Dispatching: Direct |
| xpMsg_Draw | 4 | The draw message is sent to your widget when it is time to draw yourself. OpenGL will be set up to draw in 2-d global screen coordinates, but you should use the XPLM to set up OpenGL state.  Dispatching: Direct |
| xpMsg_KeyPress | 5 | The key press message is sent once per key that is pressed. The first parameter is the type of key code (integer or char) and the second is the code itself. By handling this event, you consume the key stroke.  Handling this message 'consumes' the keystroke; not handling it passes it to your parent widget.  Dispatching: Up Chain  Param 1: A pointer to an XPKeyState_t structure with the keystroke. |
| xpMsg_KeyTakeFocus | 6 | Keyboard focus is being given to you. By handling this message you accept keyboard focus. The first parameter will be one if a child of yours gave up focus to you, 0 if someone set focus on you explicitly.  Handling this message accepts focus; not handling refuses focus.  Dispatching: direct  Param 1: 1 if you are gaining focus because your child is giving it up, 0 if someone is explicitly giving you focus. |
| xpMsg_KeyLoseFocus | 7 | Keyboard focus is being taken away from you. The first parameter will be 1 if you are losing focus because another widget is taking it, or 0 if someone called the API to make you lose focus explicitly.  Dispatching: Direct  Param 1: 1 if focus is being taken by another widget, 0 if code requested to remove focus. |
| xpMsg_MouseDown | 8 | You receive one mousedown event per click with a mouse-state structure pointed to by parameter 1. By accepting this you eat the click, otherwise your parent gets it. You will not receive drag and mouse up messages if you do not accept the down message.  Handling this message consumes the mouse click, not handling it passes it to the next widget. You can act 'transparent' as a window by never handling moues clicks to certain areas.  Dispatching: Up chain NOTE: Technically this is direct dispatched, but the widgets library will ship it to each widget until one consumes the click, making it effectively "up chain".  Param 1: A pointer to an XPMouseState_t containing the mouse status. |
| xpMsg_MouseDrag | 9 | You receive a series of mouse drag messages (typically one per frame in the sim) as the mouse is moved once you have accepted a mouse down message. Parameter one points to a mouse-state structure describing the mouse location. You will continue to receive these until the mouse button is released. You may receive multiple mouse state messages with the same mouse position. You will receive mouse drag events even if the mouse is dragged out of your current or original bounds at the time of the mouse down.  Dispatching: Direct  Param 1: A pointer to an XPMouseState_t containing the mouse status. |
| xpMsg_MouseUp | 10 | The mouseup event is sent once when the mouse button is released after a drag or click. You only receive this message if you accept the mouseDown message. Parameter one points to a mouse state structure.  Dispatching: Direct  Param 1: A pointer to an XPMouseState_t containing the mouse status. |
| xpMsg_Reshape | 11 | Your geometry or a child's geometry is being changed.  Dispatching: Up chain  Param 1: The widget ID of the original reshaped target.  Param 2: A pointer to a XPWidgetGeometryChange_t struct describing the change. |
| xpMsg_ExposedChanged | 12 | Your exposed area has changed.  Dispatching: Direct |
| xpMsg_AcceptChild | 13 | A child has been added to you. The child's ID is passed in parameter one.  Dispatching: Direct  Param 1: The Widget ID of the child being added. |
| xpMsg_LoseChild | 14 | A child has been removed from you. The child's ID is passed in parameter one.  Dispatching: Direct  Param 1: The Widget ID of the child being removed. |
| xpMsg_AcceptParent | 15 | You now have a new parent, or have no parent. The parent's ID is passed in, or 0 for no parent.  Dispatching: Direct  Param 1: The Widget ID of your parent |
| xpMsg_Shown | 16 | You or a child has been shown. Note that this does not include you being shown because your parent was shown, you were put in a new parent, your root was shown, etc.  Dispatching: Up chain  Param 1: The widget ID of the shown widget. |
| xpMsg_Hidden | 17 | You have been hidden. See limitations above.  Dispatching: Up chain  Param 1: The widget ID of the hidden widget. |
| xpMsg_DescriptorChanged | 18 | Your descriptor has changed.  Dispatching: Direct |
| xpMsg_PropertyChanged | 19 | A property has changed. Param 1 contains the property ID.  Dispatching: Direct  Param 1: The Property ID being changed.  Param 2: The new property value |
| xpMsg_MouseWheel | 20 | The mouse wheel has moved.  Return 1 to consume the mouse wheel move, or 0 to pass the message to a parent. Dispatching: Up chain  Param 1: A pointer to an XPMouseState_t containing the mouse status. |
| xpMsg_CursorAdjust | 21 | The cursor is over your widget. If you consume this message, change the XPLMCursorStatus value to indicate the desired result, with the same rules as in XPLMDisplay.h.  Return 1 to consume this message, 0 to pass it on.  Dispatching: Up chain Param 1: A pointer to an XPMouseState_t struct containing the mouse status.  Param 2: A pointer to a XPLMCursorStatus - set this to the cursor result you desire. |
| xpMsg_UserStart | 10000 | NOTE: Message IDs 1000 - 9999 are allocated to the standard widget classes provided with the library with 1000 - 1099 for widget class 0, 1100 - 1199 for widget class 1, etc. Message IDs 10,000 and beyond are for plugin use. |

</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>