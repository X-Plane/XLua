<h1>XPLM Display API</h1>
---

This API provides the basic hooks to draw in X-Plane and create user interface.
All X-Plane drawing is done in OpenGL. The X-Plane plug-in manager takes care of properly setting
up the OpenGL context and matrices.  You do not decide when in your code's
execution to draw; X-Plane tells you (via callbacks) when it is ready to have your plugin draw.

X-Plane's drawing strategy is straightforward: every "frame" the screen
is rendered by drawing the 3-D scene (dome, ground, objects, airplanes, etc.)
and then drawing the cockpit on top of it.  Alpha blending is used to overlay
the cockpit over the world (and the gauges over the panel, etc.).
X-Plane user interface elements (including windows like the map, the main menu, etc.) are
then drawn on top of the cockpit.

There are two ways you can draw: directly and in a window.

Direct drawing (deprecated!---more on that below) involves drawing to the screen before or after X-Plane finishes
a phase of drawing.  When you draw directly, you can specify whether X-Plane is
to complete this phase or not.  This allows you to do three things: draw before
X-Plane does (under it), draw after X-Plane does (over it), or draw instead of
X-Plane.

To draw directly, you register a callback and specify which phase you want to
intercept.  The plug-in manager will call you over and over to draw that phase.

Direct drawing allows you to override scenery, panels, or anything.  Note that
you cannot assume that you are the only plug-in drawing at this phase.

Direct drawing is deprecated; at some point in the X-Plane 11 run, it will likely
become unsupported entirely as X-Plane transitions from OpenGL to modern graphics API backends
(e.g., Vulkan, Metal, etc.). In the long term, plugins should use the XPLMInstance API
for drawing 3-D objects---this will be much more efficient than general 3-D OpenGL drawing,
and it will actually be supported by the new graphics backends. We do not yet know
what the post-transition API for generic 3-D drawing will look like (if it exists at all).

In contrast to direct drawing, window drawing provides a higher level functionality.
With window drawing, you create a 2-D window that takes up a portion of the screen.
Window drawing is always two dimensional.  Window drawing is depth controlled; you can
specify that you want your window to be brought on top, and other plug-ins may put
their window on top of you.  Window drawing also allows you to sign up for
key presses and receive mouse clicks.

Drawing into the screen of an avionics device, like a GPS or a Primary Flight Display, is a way
to extend or replace X-Plane's avionics. Most screens can be displayed both in a 3d cockpit or
2d panel, and also in separate popup windows. By installing drawing callbacks for a certain avionics
device, you can change or extend the appearance of that device regardless whether it's installed
in a 3d cockpit or used in a separate display for home cockpits because you leave the window managing to X-Plane.

There are three ways to get keystrokes:

1. If you create a window, the window can take keyboard focus.  It will then receive
all keystrokes.  If no window has focus, X-Plane receives keystrokes.  Use this to
implement typing in dialog boxes, etc.  Only one window may have focus at a time;
your window will be notified if it loses focus.
2. If you need low level access to the keystroke stream, install a key sniffer.  Key
sniffers can be installed above everything or right in front of the sim.
3. If you would like to associate key strokes with commands/functions in your plug-in,
you should simply register a command (via XPLMCreateCommand()) and allow users to bind
whatever key they choose to that command. Another (now deprecated) method of doing so
is to use a hot key---a key-specific callback.  Hotkeys are sent based on virtual
key strokes, so any key may be distinctly mapped with any modifiers.  Hot keys
can be remapped by other plug-ins.  As a plug-in, you don't have to worry about
what your hot key ends up mapped to; other plug-ins may provide a UI for remapping
keystrokes.  So hotkeys allow a user to resolve conflicts and customize keystrokes.



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>