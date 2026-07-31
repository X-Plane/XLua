<h1>Xplm Menus</h1>

---

<div class="sym-block sym-enum" data-name="XPLMMenuCheck" data-type="enum" markdown="1">

## XPLMMenuCheck { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

These enumerations define the various 'check' states for an X-Plane menu.  'Checking'
in X-Plane actually appears as a light which may or may not be lit.  So there are
three possible states.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_Menu_NoCheck | 0 | There is no symbol to the left of the menu item. |
| xplm_Menu_Unchecked | 1 | The menu has a mark next to it that is unmarked (not lit). |
| xplm_Menu_Checked | 2 | The menu has a mark next to it that is checked (lit). |

</div>

</div>

---

<div class="sym-block sym-typedef" data-name="XPLMMenuID" data-type="typedef" markdown="1">

## XPLMMenuID { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

This is a unique ID for each menu you create.

```cpp
typedef void * XPLMMenuID;
```

</div>

---

<div class="sym-block sym-callback" data-name="XPLMMenuHandler_f" data-type="callback" markdown="1">

## XPLMMenuHandler_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

A menu handler function takes two reference pointers, one for the menu (specified
when the menu was created) and one for the item (specified when the item was created).

```cpp
typedef void (* XPLMMenuHandler_f)(
                         void *               inMenuRef,
                         void *               inItemRef
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMFindPluginsMenu" data-type="function" markdown="1">

## XPLMFindPluginsMenu { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function returns the ID of the plug-ins menu, which is created for you at startup.

```cpp
XPLM_API XPLMMenuID XPLMFindPluginsMenu(void);
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMFindAircraftMenu" data-type="function" markdown="1">

## XPLMFindAircraftMenu { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM300</span>

This function returns the ID of the menu for the currently-loaded aircraft,
used for showing aircraft-specific commands.

The aircraft menu is created by X-Plane at startup, but it remains hidden until it is populated via
XPLMAppendMenuItem() or XPLMAppendMenuItemWithCommand().

Only plugins loaded with the user's current aircraft are allowed to access the aircraft menu.
For all other plugins, this will return NULL, and any attempts to add menu items to it will fail.

```cpp
XPLM_API XPLMMenuID XPLMFindAircraftMenu(void);
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMCreateMenu" data-type="function" markdown="1">

## XPLMCreateMenu { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function creates a new menu and returns its ID.  It returns NULL if the menu cannot
be created.  Pass in a parent menu ID and an item index to create a submenu, or NULL
for the parent menu to put the menu in the menu bar.  The menu's name is only used if
the menu is in the menubar.  You also pass a handler function and a menu reference value.
Pass NULL for the handler if you do not need callbacks from the menu (for example, if it
only contains submenus).

Important: you must pass a valid, non-empty menu title even if the menu is a submenu where
the title is not visible.

```cpp
XPLM_API XPLMMenuID XPLMCreateMenu(
                         const char *         inName,
                         XPLMMenuID           inParentMenu,
                         int                  inParentItem,
                         XPLMMenuHandler_f    inHandler,    /* Can be NULL */
                         void *               inMenuRef
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMDestroyMenu" data-type="function" markdown="1">

## XPLMDestroyMenu { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function destroys a menu that you have created.  Use this to remove a submenu
if necessary.  (Normally this function will not be necessary.)

```cpp
XPLM_API void       XPLMDestroyMenu(
                         XPLMMenuID           inMenuID
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMClearAllMenuItems" data-type="function" markdown="1">

## XPLMClearAllMenuItems { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This function removes all menu items from a menu, allowing you to rebuild
it.  Use this function if you need to change the number of items on a menu.

```cpp
XPLM_API void       XPLMClearAllMenuItems(
                         XPLMMenuID           inMenuID
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMAppendMenuItem" data-type="function" markdown="1">

## XPLMAppendMenuItem { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This routine appends a new menu item to the bottom of a menu and returns its index.
Pass in the menu to add the item to, the items name, and a void * ref for this item.

Returns a negative index if the append failed (due to an invalid parent menu argument).

Note that all menu indices returned are relative to your plugin's menus only; if your plugin
creates two sub-menus in the Plugins menu at different times, it doesn't matter how many other
plugins also create sub-menus of Plugins in the intervening time: your sub-menus will be
given menu indices 0 and 1.
(The SDK does some work in the back-end to filter out menus that are irrelevant to your plugin
in order to deliver this consistency for each plugin.)

```cpp
XPLM_API int        XPLMAppendMenuItem(
                         XPLMMenuID           inMenu,
                         const char *         inItemName,
                         void *               inItemRef,
                         int                  inDeprecatedAndIgnored
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMAppendMenuItemWithCommand" data-type="function" markdown="1">

## XPLMAppendMenuItemWithCommand { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM300</span>

Like XPLMAppendMenuItem(), but instead of the new menu item triggering the XPLMMenuHandler_f of
the containiner menu, it will simply execute the command you pass in. Using a command for your menu item
allows the user to bind a keyboard shortcut to the command and see that shortcut represented in the menu.

Returns a negative index if the append failed (due to an invalid parent menu argument).

Like XPLMAppendMenuItem(), all menu indices are relative to your plugin's menus only.

```cpp
XPLM_API int        XPLMAppendMenuItemWithCommand(
                         XPLMMenuID           inMenu,
                         const char *         inItemName,
                         XPLMCommandRef       inCommandToExecute
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMAppendMenuSeparator" data-type="function" markdown="1">

## XPLMAppendMenuSeparator { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This routine adds a separator to the end of a menu.

```cpp
XPLM_API void       XPLMAppendMenuSeparator(
                         XPLMMenuID           inMenu
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMSetMenuItemName" data-type="function" markdown="1">

## XPLMSetMenuItemName { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This routine changes the name of an existing menu item.  Pass in the menu ID and
the index of the menu item.

```cpp
XPLM_API void       XPLMSetMenuItemName(
                         XPLMMenuID           inMenu,
                         int                  inIndex,
                         const char *         inItemName,
                         int                  inDeprecatedAndIgnored
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMCheckMenuItem" data-type="function" markdown="1">

## XPLMCheckMenuItem { .symbol-title }

<span class="sym-badge badge-fn">function</span>

Set whether a menu item is checked.  Pass in the menu ID and item index.

```cpp
XPLM_API void       XPLMCheckMenuItem(
                         XPLMMenuID           inMenu,
                         int                  index,
                         XPLMMenuCheck        inCheck
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMCheckMenuItemState" data-type="function" markdown="1">

## XPLMCheckMenuItemState { .symbol-title }

<span class="sym-badge badge-fn">function</span>

This routine returns whether a menu item is checked or not.
A menu item's check mark may be on or off, or a menu may
not have an icon at all.

```cpp
XPLM_API void       XPLMCheckMenuItemState(
                         XPLMMenuID           inMenu,
                         int                  index,
                         XPLMMenuCheck *      outCheck
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMEnableMenuItem" data-type="function" markdown="1">

## XPLMEnableMenuItem { .symbol-title }

<span class="sym-badge badge-fn">function</span>

Sets whether this menu item is enabled.  Items start out enabled.

```cpp
XPLM_API void       XPLMEnableMenuItem(
                         XPLMMenuID           inMenu,
                         int                  index,
                         int                  enabled
                    );
```

</div>

---

<div class="sym-block sym-function" data-name="XPLMRemoveMenuItem" data-type="function" markdown="1">

## XPLMRemoveMenuItem { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM210</span>

Removes one item from a menu.  Note that all menu items below are moved up one; your plugin
must track the change in index numbers.

```cpp
XPLM_API void       XPLMRemoveMenuItem(
                         XPLMMenuID           inMenu,
                         int                  inIndex
                    );
```

</div>

---



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>