<h1>XPLM Menus API</h1>
---

Plug-ins can create menus in the menu bar of X-Plane.  This is done
by creating a menu and then creating items.  Menus are referred to by an opaque
ID.  Items are referred to by (zero-based) index number.

Menus are "sandboxed" between plugins - no plugin can access the menus of any other plugin.
Furthermore, all menu indices are relative to your plugin's menus only; if your plugin
creates two sub-menus in the Plugins menu at different times, it doesn't matter how many other
plugins also create sub-menus of Plugins in the intervening time: your sub-menus will be
given menu indices 0 and 1.
(The SDK does some work in the back-end to filter out menus that are irrelevant to your plugin
in order to deliver this consistency for each plugin.)

When you create a menu item, you specify how we should handle clicks on that menu item.
You can either have the XPLM trigger a callback (the XPLMMenuHandler_f associated with
the menu that contains the item), or you can simply have a command be triggered (with
no associated call to your menu handler). The advantage of the latter method is that
X-Plane will display any keyboard shortcuts associated with the command. (In contrast,
there are no keyboard shortcuts associated with menu handler callbacks with specific parameters.)

Menu text in X-Plane is UTF8; X-Plane's character set covers latin, greek and cyrillic characters,
Katakana, as well as some Japanese symbols. Some APIs have a inDeprecatedAndIgnored parameter that
used to select a character set; since X-Plane 9 all localization is done via UTF-8 only.



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>