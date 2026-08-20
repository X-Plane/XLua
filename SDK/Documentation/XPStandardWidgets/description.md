<h1>XP Standard Widgets API</h1>
---

## THEORY OF OPERATION

The standard widgets are widgets built into the widgets library. While you can
gain access to the widget function that drives them, you generally use them by
calling XPCreateWidget and then listening for special messages, etc.

The standard widgets often send messages to themselves when the user performs an
event; these messages are sent up the widget hierarchy until they are handled. So
you can add a widget proc directly to a push button (for example) to intercept the
message when it is clicked, or you can put one widget proc on a window for all of
the push buttons in the window. Most of these messages contain the original widget
ID as a parameter so you can know which widget is messaging no matter who it is sent to.



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>