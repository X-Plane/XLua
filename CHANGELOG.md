# XLua Changelog

This file lists the changes in each XLua release, newest first.

**Which version do I have?** In X-Plane, open **Plugins > Plugin Admin**. XLua is listed there as `XLua` followed by its version number, for example `XLua 2.0.0-r1`.

## 2.0.0-r1 - 2026-10-29

* First release of XLua 2.0. For everything new since 1.5.0r1, see the 2.0.0-b1 to 2.0.0-b5 entries below.
* XLua now shows its real version in Plugin Admin. All 2.0 betas showed `XLua 2.0.0a1`.
* The release zip now includes this changelog.
* Synced to the latest X-Plane SDK.
* XLua now fills in `structSize` for `XPLMSVTCustomData_t`; scripts no longer set it.

## 2.0.0-b5 - 2026-10-20

* Improved callbacks to the X-Plane SDK:
  * Removed the limit of 500 callback records per script. A script could register at most 250 datarefs before this change.
  * A module that fails to start is muted: its datarefs read 0, and its command handlers let the command go on to other handlers.

## 2.0.0-b3 - 2026-10-01

* Improved mouse handling in ImGui windows
* Improved error handling for browser callbacks

## 2.0.0-b2 - 2026-09-25

* Fixed an error where syntax errors didn't trigger corresponding error messages

## 2.0.0-b1 - 2026-09-10

* Full support for Panel Graphics
* Full support of the X-Plane SDK
* Support of Dear ImGui
* New XLua 2.0 script syntax. XLua 1.x scripts run unchanged. To move a script to the new syntax, see `migrating-v1-to-v2.md` in the docs folder.

## 1.5.0r1 - 2025-08-01

* Adds imgui features to lua
* Small performance improvements
* Adds "isnan" utility function

## 1.3.0r2 - 2024-09-05

* Adds `get_timer_remaining` stub to init.lua.

## 1.3.0r1 - 2023-08-09

* Improved logging of lua errors
* Lua print() and other log lines go to both console and X-Plane log file, tagged as `?/LUA:`
* Add ability to query a timer's time remaining `XLuaGetTimerRemaining()`. Pass in a timer reference created by `XLuaCreateTimer()`, returns a Number.
* Adds `filter_command` support.

## 1.2.0r1 - 2022-02-16

* Adds script reload support:
  * Via menu item under the aircraft menu
  * Via command `laminar/xlua/reload_all_scripts`
  * Via a new instruction `XLuaReloadOnFlightChange()` that flags the aircraft for reload when flight conditions change (engines running / engines off)

## 1.1.0r1 - 2021-08-21

Features:
* Upgraded to LuaJIT 2.1
* LuaJIT GC64 support is now enabled so that custom allocator is no longer necessary.
* Mac arm64 support

## 1.0.0r1 - 2017-11-06

Bug fixes:
* Support for unicode install paths on Windows.
* Timing source is now sim time and not user interface time. Fixes scripts breaking on pause.
* Debug logging of missing datarefs.
* Full back-trace of uncaught Lua exceptions.

## 1.0.0b1 - 2016-11-26

Initial Release
