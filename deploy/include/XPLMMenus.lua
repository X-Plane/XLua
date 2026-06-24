---@meta XPLMMenus

-- The functions, typedefs, enums, and defines in this file are
-- installed into the Lua VM at startup by the host's add_xplm_to_interp()
-- call. Scripts do NOT need to require('XPLMMenus') to access them; this file
-- exists solely as type metadata for lua-language-server / EmmyLua.

--[[
   Copyright 2005-2026 Laminar Research, Sandy Barbour and Ben Supnik All
   rights reserved.  See license.txt for usage. X-Plane SDK Version: 4.0.0
]]--

-----------------------------------------------------------------------------
-- XPLMMenus
-----------------------------------------------------------------------------

--[[
   Plug-ins can create menus in the menu bar of X-Plane.  This is done by
   creating a menu and then creating items.  Menus are referred to by an
   opaque ID.  Items are referred to by (zero-based) index number.
   
   Menus are "sandboxed" between plugins - no plugin can access the menus of
   any other plugin. Furthermore, all menu indices are relative to your
   plugin's menus only; if your plugin creates two sub-menus in the Plugins
   menu at different times, it doesn't matter how many other plugins also
   create sub-menus of Plugins in the intervening time: your sub-menus will be
   given menu indices 0 and 1. (The SDK does some work in the back-end to
   filter out menus that are irrelevant to your plugin in order to deliver
   this consistency for each plugin.)
   
   When you create a menu item, you specify how we should handle clicks on
   that menu item. You can either have the XPLM trigger a callback (the
   XPLMMenuHandler_f associated with the menu that contains the item), or you
   can simply have a command be triggered (with no associated call to your
   menu handler). The advantage of the latter method is that X-Plane will
   display any keyboard shortcuts associated with the command. (In contrast,
   there are no keyboard shortcuts associated with menu handler callbacks with
   specific parameters.)
   
   Menu text in X-Plane is UTF8; X-Plane's character set covers latin, greek
   and cyrillic characters, Katakana, as well as some Japanese symbols. Some
   APIs have a inDeprecatedAndIgnored parameter that used to select a
   character set; since X-Plane 9 all localization is done via UTF-8 only.
]]--

require("XPLMDefs")
require("XPLMUtilities")

--[[
These enumerations define the various 'check' states for an X-Plane menu.  'Checking'
in X-Plane actually appears as a light which may or may not be lit.  So there are
three possible states.
]]--

---@enum XPLMMenuCheck
local XPLMMenuCheck = {
    -- There is no symbol to the left of the menu item.
    xplm_Menu_NoCheck                        = 0,
    -- The menu has a mark next to it that is unmarked (not lit).
    xplm_Menu_Unchecked                      = 1,
    -- The menu has a mark next to it that is checked (lit).
    xplm_Menu_Checked                        = 2,
}
---@class _G
---@field XPLMMenuCheck XPLMMenuCheck

--- This is a unique ID for each menu you create.
---@class XPLMMenuID : userdata
---@field private __XPLMMenuID_marker any

--- A menu handler function takes two reference pointers, one for the menu (specified when the menu was created) and one for the item (specified when the item was created).
---@alias XPLMMenuHandler_f fun(inMenuRef: any, inItemRef: any)

---@class _G
--- This function returns the ID of the plug-ins menu, which is created for you at startup.
---
---@field XPLMFindPluginsMenu fun(): XPLMMenuID

---@class _G
--- This function returns the ID of the menu for the currently-loaded aircraft,
--- used for showing aircraft-specific commands.
---
--- The aircraft menu is created by X-Plane at startup, but it remains hidden until it is populated via
--- XPLMAppendMenuItem() or XPLMAppendMenuItemWithCommand().
---
--- Only plugins loaded with the user's current aircraft are allowed to access the aircraft menu.
--- For all other plugins, this will return NULL, and any attempts to add menu items to it will fail.
---
---@field XPLMFindAircraftMenu fun(): XPLMMenuID

---@class _G
--- This function creates a new menu and returns its ID.  It returns NULL if the menu cannot
--- be created.  Pass in a parent menu ID and an item index to create a submenu, or NULL
--- for the parent menu to put the menu in the menu bar.  The menu's name is only used if
--- the menu is in the menubar.  You also pass a handler function and a menu reference value.
--- Pass NULL for the handler if you do not need callbacks from the menu (for example, if it
--- only contains submenus).
---
--- Important: you must pass a valid, non-empty menu title even if the menu is a submenu where
--- the title is not visible.
---
---@field XPLMCreateMenu fun(inName: string, inParentMenu: XPLMMenuID, inParentItem: integer, inHandler: XPLMMenuHandler_f, inMenuRef: any): XPLMMenuID

---@class _G
--- This function destroys a menu that you have created.  Use this to remove a submenu
--- if necessary.  (Normally this function will not be necessary.)
---
---@field XPLMDestroyMenu fun(inMenuID: XPLMMenuID)

---@class _G
--- This function removes all menu items from a menu, allowing you to rebuild
--- it.  Use this function if you need to change the number of items on a menu.
---
---@field XPLMClearAllMenuItems fun(inMenuID: XPLMMenuID)

---@class _G
--- This routine appends a new menu item to the bottom of a menu and returns its index.
--- Pass in the menu to add the item to, the items name, and a void * ref for this item.
---
--- Returns a negative index if the append failed (due to an invalid parent menu argument).
---
--- Note that all menu indices returned are relative to your plugin's menus only; if your plugin
--- creates two sub-menus in the Plugins menu at different times, it doesn't matter how many other
--- plugins also create sub-menus of Plugins in the intervening time: your sub-menus will be
--- given menu indices 0 and 1.
--- (The SDK does some work in the back-end to filter out menus that are irrelevant to your plugin
--- in order to deliver this consistency for each plugin.)
---
---@field XPLMAppendMenuItem fun(inMenu: XPLMMenuID, inItemName: string, inItemRef: any, inDeprecatedAndIgnored: integer): integer

---@class _G
--- Like XPLMAppendMenuItem(), but instead of the new menu item triggering the XPLMMenuHandler_f of
--- the containiner menu, it will simply execute the command you pass in. Using a command for your menu item
--- allows the user to bind a keyboard shortcut to the command and see that shortcut represented in the menu.
---
--- Returns a negative index if the append failed (due to an invalid parent menu argument).
---
--- Like XPLMAppendMenuItem(), all menu indices are relative to your plugin's menus only.
---
---@field XPLMAppendMenuItemWithCommand fun(inMenu: XPLMMenuID, inItemName: string, inCommandToExecute: XPLMCommandRef): integer

---@class _G
--- This routine adds a separator to the end of a menu.
---
---@field XPLMAppendMenuSeparator fun(inMenu: XPLMMenuID)

---@class _G
--- This routine changes the name of an existing menu item.  Pass in the menu ID and
--- the index of the menu item.
---
---@field XPLMSetMenuItemName fun(inMenu: XPLMMenuID, inIndex: integer, inItemName: string, inDeprecatedAndIgnored: integer)

---@class _G
--- Set whether a menu item is checked.  Pass in the menu ID and item index.
---
---@field XPLMCheckMenuItem fun(inMenu: XPLMMenuID, index: integer, inCheck: XPLMMenuCheck)

---@class _G
--- This routine returns whether a menu item is checked or not.
--- A menu item's check mark may be on or off, or a menu may
--- not have an icon at all.
---
---@field XPLMCheckMenuItemState fun(inMenu: XPLMMenuID, index: integer): { outCheck: XPLMMenuCheck }

---@class _G
--- Sets whether this menu item is enabled.  Items start out enabled.
---
---@field XPLMEnableMenuItem fun(inMenu: XPLMMenuID, index: integer, enabled: boolean)

---@class _G
--- Removes one item from a menu.  Note that all menu items below are moved up one; your plugin
--- must track the change in index numbers.
---
---@field XPLMRemoveMenuItem fun(inMenu: XPLMMenuID, inIndex: integer)

