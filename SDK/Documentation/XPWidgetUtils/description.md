<h1>XP Widget Utils API</h1>
---

## USAGE NOTES

The XPWidgetUtils library contains useful functions that make writing and using
widgets less of a pain.

One set of functions are the widget behavior functions. These functions each add
specific useful behaviors to widgets. They can be used in two manners:

1. You can add a widget behavior function to a widget as a callback proc using
the XPAddWidgetCallback function. The widget will gain that behavior. Remember
that the last function you add has highest priority. You can use this to change
or augment the behavior of an existing finished widget.

2. You can call a widget function from inside your own widget function. This allows
you to include useful behaviors in custom-built widgets. A number of the standard
widgets get their behavior from this library. To do this, call the behavior
function from your function first. If it returns 1, that means it handled the event
and you don't need to; simply return 1.



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>