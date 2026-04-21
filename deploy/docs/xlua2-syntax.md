# XLua 2.0 Syntax Reference

Reference documentation for the XLua 2.0 surface, in which the X-Plane Plugin Manager (XPLM) C API is exposed directly as Lua bindings. For the shared concepts (script layout, lifecycle, primitives), see [`README.md`](README.md). For the XLua 1 surface, see [`xlua1-syntax.md`](xlua1-syntax.md). For translating v1 scripts to v2, see [`migrating-v1-to-v2.md`](migrating-v1-to-v2.md).

The canonical end-to-end example is `deploy/example_scripts/xplm_test/xplm_test.lua`; per-module signatures are in `deploy/include/XPLM*.lua` (auto-generated from the SDK headers).

## At a glance

XLua 2 exposes the XPLM C API as Lua bindings, generated 1:1 from the SDK headers. There is no helper layer — no dataref proxies, no named-global callbacks. Scripts look and feel like native XPLM plugins written in Lua. A script:

- `require`s the XPLM modules it uses (`XPLMDataAccess`, `XPLMProcessing`, `XPLMUtilities`, …);
- defines the standard XPLM plugin entry points (`XPluginStart`, `XPluginEnable`, `XPluginDisable`, `XPluginStop`, `XPluginReceiveMessage`);
- looks up datarefs and commands through `XPLMFindDataRef` / `XPLMFindCommand`, keeping the returned handles for reuse;
- reads and writes datarefs with typed accessors (`XPLMGetDataf`, `XPLMSetDatai`, `XPLMGetDatavf`, …);
- installs periodic work through the timer helpers from `init.lua` (shared with XLua 1);
- installs per-frame work through the through the XPLM flight-loop API (`XPLMCreateFlightLoop`, `XPLMScheduleFlightLoop`).


Globally available in XLua 2: the two plugin-ID constants `XPLM_NO_PLUGIN_ID` and `XPLM_PLUGIN_XPLANE`, plus the shared timer helpers. Everything else comes from the XPLM modules you `require`.

Error handling, logging, and the `I/LUA` Log.txt convention are the same as for XLua 1 — see [**Error handling**](README.md#error-handling) in the top-level doc.

The canonical end-to-end example is `deploy/example_scripts/xplm_test/xplm_test.lua`. The per-module documentation stubs under `deploy/include/XPLM*.lua` are generated from the SDK headers and describe the signatures and enumerations available via `require("XPLM<module>")`. They are reference material only — the real implementations are provided at runtime, not by the stub files.

## Deployment: per-aircraft or system-level

Unlike XLua 1, which only ever lives inside an aircraft folder and follows the aircraft's load / unload lifecycle, XLua 2 can be deployed in either of two shapes:

- **Per-aircraft.** The classic XLua layout: the plugin and its scripts live under `<aircraft folder>/plugins/xlua/scripts/…` (see [**Where scripts live**](README.md#where-scripts-live)). The plugin loads when the aircraft loads and unloads when the aircraft unloads — each aircraft-switch is an unload/reload cycle.
- **System-level.** The XLua plugin is installed under X-Plane's `Resources/plugins/` folder, alongside other third-party plugins. In this shape the plugin's lifetime is **the entire simulation session**: `XPluginStart` fires once at sim startup, `XPluginStop` fires at sim shutdown, and the plugin sees every aircraft load, flight start, and replay transition through `XPluginReceiveMessage` events rather than being torn down between them.

`XPluginEnable` / `XPluginDisable` can still be cycled by the user from the plugin admin menu in either shape, so the enable/disable pair must always tear down and re-arm cleanly regardless of how the plugin is deployed.

Pick system-level deployment for logic that is intended to affect the operation of the simulator itself, and independent of any aircraft. Pick per-aircraft for anything whose behaviour is specific to one aircraft. Both shapes use the same script structure and the same XPLM API; the only difference is where the files live on disk and when the plugin's outer lifecycle fires.

## Working with the XPLM SDK

XLua 2 exposes the full X-Plane Plugin Manager (XPLM) SDK to Lua scripts — not just the dataref and command surface XLua 1 provided, but the whole API: processing, display, menus, navigation, planes, weather, scenery, sound, instances, maps, and more. An XLua 2 script is meaningfully more capable than its XLua 1 counterpart, and is constrained only by the set of XPLM modules that are exposed.

> **Note: `XPLMSound` is currently unimplemented** in the XLua 2 preview runtime and will be enabled in a near-future release. Scripts that need audio playback have to defer that feature until the module lands.

Two practical consequences follow:

**A module written in XLua 2 is much closer to a compiled XPLM plugin than an XLua 1 script ever was.** If a script eventually grows large or performance-sensitive enough to justify being rewritten as a native C or C++ plugin, the translation is structural rather than conceptual — the entry points, the lookup / register / destroy patterns, the handler signatures, and the SDK surface all correspond directly. Starting in XLua 2 keeps that door open.

**C and C++ example code for the XPLM SDK is directly useful to Lua developers.** The SDK's sample plugins, third-party tutorials, and header-level documentation all describe the same API a Lua script uses. Translating an idiom from C into Lua is largely a mechanical exercise — only the handful of calling-convention differences listed below need adjustment.

### Where to find the SDK documentation

- **`deploy/include/XPLM*.lua`** — the local per-module reference, one file per XPLM module. Auto-generated from the SDK headers. **These files are part of the plugin distribution and must not be edited.** They are overwritten whenever XLua is rebuilt from a newer SDK, so any local changes will be lost; worse, a diverged local copy can silently misrepresent what the runtime actually does.
- **<https://developer.x-plane.com/sdk/>** — the full online SDK documentation. Covers every XPLM module, enumeration, and concept in longer prose than the generated stubs. When writing an XLua 2 script, treat this as the primary reference.

Both sources describe the API in its native C form; with a handful of small adjustments to calling conventions, every function and enumeration described there is directly callable from Lua.

### Calling-convention differences from the C API

A handful of mechanical adjustments translate a C-shaped XPLM signature into its Lua equivalent:

- **Out parameters → a returned table.** C functions that write results through pointer arguments return a single Lua table in the Lua form, whose fields carry the same `out*` names the C signature uses. For example, `local v = XPLMGetVersions()` gives `v.outXPlaneVersion`, `v.outXPLMVersion`, `v.outHostID`.
- **Caller-supplied buffers → Lua tables.** Where C takes a pre-allocated buffer (e.g. `XPLMGetDatavf(dr, outValues, offset, max)`), the Lua form takes a Lua table and resizes it in place to hold the returned data. Pass `{}` to receive fresh values. **Offsets and counts remain 0-based** (the dataref-side position, as in C), but the Lua table itself is 1-based (standard Lua) — the rule is covered in full in [Dataref access](#dataref-access).
- **Strong typing.** Lua's boolean is its own type, separate from integers and strings. A function that returns a bool must return `true` or `false`, not `1` or `0`; a function that takes a bool must be passed `true` or `false`. Returning `1` from a bool-returning function is an error, not an implicit conversion.
- **`NULL` → `nil`.** Unused refcons, absent accessor-slot callbacks in `XPLMRegisterDataAccessor`, and any other sentinel use of `NULL` all become `nil`.
- **Enum constants.** Use the named Lua tables rather than the raw integer values — see [Enumerations and constants](#enumerations-and-constants).
- **Refcons / user data.** C's `void *` is any Lua value — see [User references (`refcon` / `userref`)](#user-references-refcon--userref).

`deploy/example_scripts/xplm_test/xplm_test.lua` exercises every one of these in practice.

## Modules and `require`

XLua 2 groups the XPLM bindings into one Lua module per XPLM header. A script `require`s the modules it uses at the top of the file — there is no auto-import:

```lua
require("XPLMDataAccess")
require("XPLMProcessing")
require("XPLMUtilities")
require("XPLMPlugin")
-- ... and any other modules the script needs
```

The available modules:

| Module | Purpose |
|---|---|
| `XPLMDataAccess` | Datarefs — look up, read, write, register custom ones. |
| `XPLMProcessing` | Flight-loop callbacks, elapsed time, cycle counters. |
| `XPLMUtilities` | System paths, versions, logging, speech, built-in command invocation, custom commands. |
| `XPLMPlugin` | Plugin IDs, inter-plugin messages, feature enumeration. |
| `XPLMDisplay` | Hot keys, avionics draw callbacks. *Partially exposed* — see below. |
| `XPLMGraphics` | Text drawing, font metrics, coordinate conversions. *Partially exposed* — see below. |
| `XPLMMenus` | Plugin-menu integration with X-Plane's menu bar. |
| `XPLMNavigation` | Navaid and airport database, FMS entries, flight plans, GPS. |
| `XPLMPlanes` | User and AI aircraft access, TCAS-override integration. |
| `XPLMScenery` | Terrain probing, magnetic variation, library lookups, async object loading. |
| `XPLMWeather` | Weather at a location, METAR fetch, layer data. |
| `XPLMInstance` | Instanced object rendering at arbitrary world positions. |
| `XPLMMap` | Map layers — icons and labels drawn on X-Plane's map. |
| `XPLMCamera` | Camera position read/control. |
| `XPLMSound` | *Currently unimplemented* — see **Working with the XPLM SDK** above. |

A few modules are deliberately **excluded or partial**:

- `XPLMUIGraphics` — not exposed. Use **ImGui** for any interactive UI.
- The window-drawing portion of `XPLMDisplay` and the 3D-drawing portion of `XPLMGraphics` — excluded. Again, use ImGui.
- Key sniffers in `XPLMDisplay` — excluded.
- A handful of individual functions that map awkwardly to Lua (`XPLMFindSymbol`, `XPLMExtractFileAndPath`, `XPLMGetDirectoryContents`, the shared-data accessors) — see the comments in `deploy/example_scripts/xplm_test/xplm_test.lua` for specifics.

## Enumerations and constants

Every XPLM enumeration is exposed as a Lua table named after its C counterpart, with fields named after the C enum values. For example, where C code would write `xplm_FlightLoop_Phase_AfterFlightModel` or `xplmType_Float`, a Lua script writes:

```lua
XPLMFlightLoopPhaseType.xplm_FlightLoop_Phase_AfterFlightModel
XPLMDataTypeID.xplmType_Float
```

Well-known plugin IDs are exposed as plain globals (not tables): `XPLM_NO_PLUGIN_ID`, `XPLM_PLUGIN_XPLANE`.

**Using the named constants is optional but strongly recommended.** An XPLM enum is ultimately a small integer, and passing the literal works — checking command phase against `0` / `1` / `2` is valid, as is passing `8` for a `xplmType_FloatArray`. In XLua 1 the helpers gave authors no choice but to use raw numbers, and it was common to see `if phase == 0 then …` throughout shipped scripts.

In XLua 2 the named constants are available for every enum the SDK defines, and using them is the better default:

- they are clearer at the call site — `phase == XPLMCommandPhase.xplm_CommandBegin` explains itself;
- they survive any future renumbering the SDK might do — the Lua name stays stable even if the integer value changes;
- they match the way the online SDK documentation and the `include/XPLM*.lua` stubs describe the API, so translating between doc and code is straightforward.

The full list of enumerations is in the `include/XPLM*.lua` stubs — search for `= {` to enumerate them. Common ones a script reaches for are `XPLMFlightLoopPhaseType`, `XPLMDataTypeID`, `XPLMCommandPhase`, `XPLMNavType`, `XPLMKeyFlags`, `XPLMFontID`, and `XPLMMapLayerType`.

## User references (`refcon` / `userref`)

Almost every XPLM callback registration takes a **refcon** — also spelled `userref` in some APIs, `inRefcon` in others. It is a value the script supplies at registration time, and that the runtime passes back, unchanged, every time the callback fires. The purpose is to let the script identify the context a callback was registered in, so a single Lua function can service many registrations without the registrations having to be remembered separately:

```lua
-- Two flight loops, same Lua function, different userrefs
g_pre  = XPLMCreateFlightLoop({ phase = XPLMFlightLoopPhaseType.xplm_FlightLoop_Phase_BeforeFlightModel,
                                callbackFunc = tick, refcon = "pre"  })
g_post = XPLMCreateFlightLoop({ phase = XPLMFlightLoopPhaseType.xplm_FlightLoop_Phase_AfterFlightModel,
                                callbackFunc = tick, refcon = "post" })

function tick(elapsed, elapsedSinceLast, counter, refcon)
    if refcon == "pre" then
        ...  -- before-flight-model work
    else
        ...  -- after-flight-model work
    end
end
```

Refcons are **untyped** — any Lua value works: a number, a string, a table, a function, a handle, `nil`. The runtime passes whatever you registered verbatim to the callback and does nothing else with it. Pick whichever shape is easiest for the callback to read: a table is a good default when the context has several fields; a simple string or number is fine when one identifier is all that is needed.

The name varies across the API (`refcon`, `userref`, `inRefcon`, `readRefcon` / `writeRefcon` for datarefs, and so on) but the meaning is always the same.

## Reload on flight start

By default XLua 2 does **not** re-execute the script chunk when the user begins a new flight — the script keeps running across flight changes, and it is the script's responsibility to re-initialise any per-flight state from its message-handler entry point.

To opt into the XLua 1 behaviour (full chunk re-execution on every flight start), call `XLuaReloadOnFlightChange()` at the top of the script.

Opting in is straightforward but blunt: every piece of state the chunk sets up is destroyed and rebuilt on each flight start, including custom datarefs, command handlers, and flight loops. A well-written XLua 2 script is usually better off catching `XPLM_MSG_AIRPORT_LOADED` in `XPluginReceiveMessage` and re-initialising only what actually needs per-flight work. Reach for `XLuaReloadOnFlightChange()` mainly as a backwards-compatibility aid when porting XLua 1 code that relies on reload behaviour, or in the rare cases where full chunk re-execution is genuinely what you want.

## Lifecycle entry points

XLua 2 uses the standard XPLM plugin lifecycle. A script participates by defining any of the following global functions; the runtime calls them at the appropriate times.

**None of these functions are required.** Unlike a compiled C or C++ plugin, an XLua 2 script with none of them defined is valid — a missing function is simply not called, and a missing bool-returning function is treated as if it had returned `true`. Even so, **use them**. Putting setup and teardown into `XPluginStart` / `XPluginEnable` / `XPluginDisable` / `XPluginStop` is cleaner than scattering live statements at chunk scope, and it gives the script a well-defined place to arm and disarm its state.

| Event | Function to define | Return |
|---|---|---|
| One-off setup, immediately after load | `XPluginStart()` | bool — `true` to proceed; a missing function counts as `true` |
| Activation — may fire more than once per script lifetime | `XPluginEnable()` | bool — `true` to proceed; a missing function counts as `true` |
| Deactivation — partner to `XPluginEnable` | `XPluginDisable()` | none |
| Final teardown, immediately before unload | `XPluginStop()` | none |
| Message from X-Plane or another plugin | `XPluginReceiveMessage(fromWho, inMessage, param)` | none |

**`XPluginEnable` and `XPluginDisable` can each be called more than once over the life of the script** — for example when the user disables and re-enables the script from the plugin admin menu. Anything that must be torn down and re-armed (handler registrations, flight loops, custom datarefs, ImGui windows, and so on) belongs in this pair of functions, not in one-shot code at chunk scope.

Per-flight events — aircraft load, flight start, replay transitions — arrive as messages to `XPluginReceiveMessage` rather than as separate callbacks. Branch on `inMessage` (for example `XPLM_MSG_AIRPORT_LOADED`) and on the sender (`XPLM_PLUGIN_XPLANE` for messages from the sim).

### `XPluginStart()`

Fires once, immediately after the script chunk has loaded. This is the right place for **one-off** setup that needs to happen exactly once per script lifetime — creating custom commands that must be visible before `XPluginEnable` runs, computing derived constants, validating that required datarefs exist. Return `true` to proceed; return `false` to abort script loading.

Do **not** register flight loops, install command handlers, or do anything that a disable/re-enable cycle should tear down — put that work in `XPluginEnable` instead.

### `XPluginEnable()`

Fires after `XPluginStart`, and again every time the user re-enables the script from the plugin admin menu. Use this for setup that must be paired with matching teardown in `XPluginDisable` — registering command handlers, creating flight loops, registering custom datarefs. Return `true` on success; returning `false` leaves the script disabled until the user tries to enable it again.

### `XPluginDisable()`

Fires when the script is being deactivated — either because the user disabled it or as part of unload. Teardown partner to `XPluginEnable`. Every asset armed in `XPluginEnable` should be released here: destroy flight loops, unregister command handlers, unregister custom datarefs, release any TCAS planes acquired, close windows. The script may be re-enabled later, so leave it in a clean "not running" state rather than a half-torn-down one.

### `XPluginStop()`

Fires once, immediately before the script chunk is unloaded. Final teardown — release anything that `XPluginStart` created and that `XPluginDisable` did not already tear down (typically the custom commands created in `XPluginStart`). Normally called right after `XPluginDisable`, but do not rely on `XPluginDisable` having fired immediately before — in some unload paths the two can be closer together or further apart.

### `XPluginReceiveMessage(fromWho, inMessage, param)`

Fires whenever an XPLM message is delivered to this script — from X-Plane itself, from another plugin, or from another XLua script. Arguments:

- **`fromWho`** — the plugin handle of the sender. A plugin handle is just a numeric identifier the runtime uses for each loaded plugin. Two *well-known senders* are exposed as globals: `XPLM_PLUGIN_XPLANE` (the sim itself) and `XPLM_NO_PLUGIN_ID` (the sentinel for "none"). These are nothing more than pre-cached plugin handles — you can compare `fromWho` against them to recognise sim-originated messages, and you can equally look up any other plugin's handle at script load with `XPLMFindPluginBySignature` (or one of its siblings) and compare `fromWho` against that cached value. This is how a script gates behaviour on the presence or absence of a specific third-party plugin: look it up once, check whether the result is `XPLM_NO_PLUGIN_ID`, and activate the integration path only when the plugin is present and its messages arrive.
- **`inMessage`** — the numeric message ID. The full list of `XPLM_MSG_*` values is in the online SDK reference for **XPLMPlugin** at <https://developer.x-plane.com/sdk/>. Common values a script branches on include `XPLM_MSG_AIRPORT_LOADED` (per-flight initialisation), `XPLM_MSG_PLANE_CRASHED`, and `XPLM_MSG_PLANE_LOADED`.
- **`param`** — a message-specific parameter. Its meaning depends on `inMessage`; for most messages it is unused.

This is where per-flight lifecycle events land — `XPLM_MSG_AIRPORT_LOADED` for flight-start logic, for example — along with any inter-plugin protocol messages the script participates in.

## Dataref access

The shape is the same as XLua 1 — look up at load time, read and write during runtime, release custom ones at teardown — but XLua 2 replaces v1's proxy objects with explicit typed accessor calls. No hidden machinery: each read or write is an obvious function call, and the type is always explicit at the call site.

This section covers the general pattern. For the full API — every helper, every flag, every error condition — see the online reference for **XPLMDataAccess** at <https://developer.x-plane.com/sdk/>.

### Typical usage

Call `XPLMFindDataRef` once at load time and keep the returned handle in a script-level variable:

```lua
battery_amps = XPLMFindDataRef("sim/cockpit2/electrical/battery_amps[0]")
battery_on   = XPLMFindDataRef("sim/cockpit2/electrical/battery_on[0]")
```

`XPLMFindDataRef` returns `nil` if the dataref does not exist — always check before using the handle, especially for datarefs published by other plugins that may not be present. Never look up by string inside a per-frame callback.

### Reading and writing

Every read and every write goes through a typed accessor:

| Accessor | Type |
|---|---|
| `XPLMGetDataf(dr)` / `XPLMSetDataf(dr, v)` | 32-bit float |
| `XPLMGetDatai(dr)` / `XPLMSetDatai(dr, v)` | 32-bit int |
| `XPLMGetDatad(dr)` / `XPLMSetDatad(dr, v)` | 64-bit double |

Pick the accessor that matches what the dataref publishes. A dataref can publish more than one type — `XPLMGetDataRefTypes(dr)` returns a bitmask if you need to probe. `XPLMCanWriteDataRef(dr)` reports whether writes will be accepted (some datarefs require an `override_*` sibling to be set first).

The **"calls into the sim are expensive"** rule from the top-level Gotchas still applies: if you need a dataref's value more than once in a block of logic, read it into a plain local first and use the local from then on.

### Array datarefs

Array accessors take the dataref handle, a Lua table for input or output, an offset into the dataref's array, and a count:

```lua
-- Read up to 3 elements starting at dataref index 0
local values = {}
local count  = XPLMGetDatavf(dr, values, 0, 3)

-- Write elements 0 through 4 from a fresh table
XPLMSetDatavf(dr, {1.0, 2.0, 3.0, 4.0, 5.0}, 0, 5)
```

**Array indexing is 0-based, not Lua's usual 1-based.** The `offset` argument is the starting dataref index, counted from zero. The Lua table is still a Lua table and thus 1-based — table position 1 corresponds to dataref offset, position 2 to offset+1, and so on. The get accessor auto-resizes the table to hold the returned values.

A size query is the idiom `XPLMGetDatav*(dr, nil, 0, 0)` — passing `nil` for the out-table returns the declared array size.

Integer arrays use `XPLMGetDatavi` / `XPLMSetDatavi` with the same shape. Byte-block datarefs (including strings) use `XPLMGetDatab` / `XPLMSetDatab`.

### Custom datarefs

A script creates a custom dataref by calling `XPLMRegisterDataAccessor`, which takes the name, a type bitmask, a writable flag, and pairs of reader/writer closures — one pair per type the dataref supports — plus two refcons the runtime passes back to the closures:

```lua
local g_store = 5

function read_int(refcon)         return g_store end
function write_int(refcon, v)     g_store = v    end

my_dr = XPLMRegisterDataAccessor(
    "laminar/example/custom", XPLMDataTypeID.xplmType_Int, true,
    read_int, write_int,         -- [GS]etDatai
    nil, nil,                    -- [GS]etDataf
    nil, nil,                    -- [GS]etDatad
    nil, nil,                    -- [GS]etDatavi
    nil, nil,                    -- [GS]etDatavf
    nil, nil,                    -- [GS]etDatab
    "read_refcon", "write_refcon")
```

Array readers have a **size-query contract**: when the runtime calls the reader with `outvalues == nil`, return the maximum element count; otherwise fill `outvalues[1..max]` and return the number actually written. See `deploy/example_scripts/xplm_test/xplm_test.lua` (`TestGetArrayOfInts`) for the canonical shape.

`XPLMUnregisterDataAccessor(dr)` tears the dataref down. **Every custom dataref the script creates must be unregistered when the script disables** — this is the *Initialisation and cleanup* rule from the top-level README applied here.

## Commands

The XPLM command API also keeps the shape of XLua 1's — look up or create at load time, invoke the begin / continue / end cycle to fire them, register handlers to react — with XLua 2 replacing v1's command object with a plain handle plus explicit begin / end / once calls.

For the full API, see the **XPLMUtilities** module in the online SDK reference at <https://developer.x-plane.com/sdk/> (commands live alongside the other utility bindings there).

### Typical usage

Call `XPLMFindCommand` for existing commands, or `XPLMCreateCommand` to register a new one, at script load:

```lua
simCMD_engage_starter = XPLMFindCommand("sim/starters/engage_starter_1")

my_cmd = XPLMCreateCommand("laminar/example/custom", "Example custom command")
```

As with datarefs, never look up by string inside a per-frame callback.

### Invoking a command

Three functions are relevant for invoking commands:

- `XPLMCommandOnce(cmd)` — fires the complete begin → end cycle. The common case.
- `XPLMCommandBegin(cmd)` — emits the begin phase; the command remains in the continue phase until explicitly ended.
- `XPLMCommandEnd(cmd)` — emits the end phase.

**Every `XPLMCommandBegin` must be matched by exactly one `XPLMCommandEnd`** — the top-level Gotcha applied.

### Handling a command

Register a handler with `XPLMRegisterCommandHandler`:

```lua
XPLMRegisterCommandHandler(cmd, handler, beforeFlag, refcon)
```

- **`handler`** — signature `function(inCommand, inPhase, refcon) -> bool`. `inPhase` takes the values in `XPLMCommandPhase` (use `xplm_CommandBegin` / `xplm_CommandContinue` / `xplm_CommandEnd` rather than raw `0`/`1`/`2`).
- **`beforeFlag`** — `true` runs the handler before the command's default behaviour, `false` runs it after.
- **Return value** — `true` lets the command pass through to any remaining handlers and to the sim's default behaviour; `false` consumes it (the sim's default does not run).

Together, `beforeFlag` and the return value cover everything XLua 1's separate helpers did — `create_command`, `replace_command`, `wrap_command`, and `filter_command` all collapse into patterns of `XPLMRegisterCommandHandler`. See [`migrating-v1-to-v2.md`](migrating-v1-to-v2.md) for the one-to-one translation table.

Tear handlers down at script disable with `XPLMUnregisterCommandHandler`, passing the same `beforeFlag` and `refcon` used during registration. **Every registered handler must be unregistered.**

## Timer helpers

The timer helpers (`run_after_time`, `run_at_interval`, `run_timer`, `stop_timer`, `is_timer_scheduled`, `get_timer_remaining`) are defined in `init.lua` and are shared between XLua 1 and XLua 2 scripts unchanged. They are the simplest way to schedule one-off or periodic work. See [**Timer helpers** in the XLua 1 doc](xlua1-syntax.md#timer-helpers) for the full API — it is identical here, including the one-timer-per-function identity rule and the **do not use anonymous functions** constraint.

Use the flight-loop API below instead when you need phase control (before or after the flight model), elapsed-time arguments inside the callback, or multiple independent loops backed by the same Lua function.

## Flight-loop API

The flight-loop API is the lower-level alternative to the shared timer helpers. Use it when you need its extras — phase selection, elapsed-time callback arguments, or multiple independent loops backed by the same Lua function.

The three calls:

- `XPLMCreateFlightLoop({phase=…, callbackFunc=…, refcon=…})` — returns an opaque handle.
- `XPLMScheduleFlightLoop(handle, interval, relativeToNow)` — arms or re-arms the loop.
- `XPLMDestroyFlightLoop(handle)` — tears it down. **Destroy every flight loop the script creates at disable.**

Callback signature: `function(elapsed, elapsedSinceLastLoop, counter, refcon) -> nextInterval`. A **positive** return value reschedules after that many seconds, a **negative** value reschedules after that many frames, and **zero** disables the loop without destroying the handle.

Unlike the timer helpers, a single Lua function can back any number of flight loops — the handle, not the function reference, is the identity.

For work that must run every frame, create the loop at `XPLMFlightLoopPhaseType.xplm_FlightLoop_Phase_AfterFlightModel` (or `BeforeFlightModel`) and schedule it with an interval of `-1`.

For the full API — every field, every flag, every edge case — see the **XPLMProcessing** module in the online SDK reference at <https://developer.x-plane.com/sdk/>.

## A small worked example

A complete XLua 2 script exercising each of the major pieces — the XPlugin entry points, a sim dataref, a custom dataref, a custom command with a handler, a per-frame flight loop, and a message-driven flight-start hook:

```lua
-- Publish a smoothed version of the battery ammeter value so a panel
-- needle animates gently. Provides a custom command to snap the value
-- to the live reading on demand.

require("XPLMDataAccess")
require("XPLMProcessing")
require("XPLMUtilities")

local battery_amps   -- sim dataref handle
local smoothed_amps  -- our custom dataref handle
local reset_cmd      -- our custom command handle
local fl_handle      -- flight-loop handle
local stored_value = 0

-- Accessors for the custom dataref. Each type the dataref supports
-- needs its own reader/writer pair; here we only expose float.
local function read_smoothed(refcon)       return stored_value end
local function write_smoothed(refcon, v)   stored_value = v    end

-- Per-frame callback: exponentially approach the live reading.
local function smooth(elapsed, elapsedSinceLast, counter, refcon)
    local target = XPLMGetDataf(battery_amps)
    stored_value = stored_value + (target - stored_value) * (10 * elapsedSinceLast)
    return -1   -- fire again next frame
end

-- Command handler: snap the smoothed value to the live reading on press.
local function reset_handler(cmd, phase, refcon)
    if phase == XPLMCommandPhase.xplm_CommandBegin then
        stored_value = XPLMGetDataf(battery_amps)
    end
    return true   -- always passthrough; irrelevant for a custom command
end

function XPluginStart()
    battery_amps = XPLMFindDataRef("sim/cockpit2/electrical/battery_amps[0]")
    reset_cmd    = XPLMCreateCommand("laminar/example/reset_smoothed",
                                     "Snap smoothed ammeter to live reading")
    return true
end

function XPluginEnable()
    smoothed_amps = XPLMRegisterDataAccessor(
        "laminar/example/smoothed_amps", XPLMDataTypeID.xplmType_Float, true,
        nil,           nil,                     -- Int
        read_smoothed, write_smoothed,          -- Float
        nil,           nil,                     -- Double
        nil,           nil,                     -- IntArray
        nil,           nil,                     -- FloatArray
        nil,           nil,                     -- ByteArray
        nil,           nil)                     -- read/write refcons

    XPLMRegisterCommandHandler(reset_cmd, reset_handler, true, nil)

    fl_handle = XPLMCreateFlightLoop({
        phase        = XPLMFlightLoopPhaseType.xplm_FlightLoop_Phase_AfterFlightModel,
        callbackFunc = smooth,
        refcon       = nil })
    XPLMScheduleFlightLoop(fl_handle, -1, true)   -- fire every frame

    return true
end

function XPluginDisable()
    -- Teardown is the mirror image of XPluginEnable.
    if fl_handle ~= nil then
        XPLMDestroyFlightLoop(fl_handle)
        fl_handle = nil
    end

    XPLMUnregisterCommandHandler(reset_cmd, reset_handler, true, nil)

    if smoothed_amps ~= nil then
        XPLMUnregisterDataAccessor(smoothed_amps)
        smoothed_amps = nil
    end
end

function XPluginStop()
    -- Nothing to tear down here: the custom command created in XPluginStart
    -- has no explicit destroy call and disappears with the script.
end

function XPluginReceiveMessage(fromWho, inMessage, param)
    if fromWho == XPLM_PLUGIN_XPLANE and inMessage == XPLM_MSG_AIRPORT_LOADED then
        -- New flight: snap the smoothed value so the needle starts steady.
        stored_value = XPLMGetDataf(battery_amps)
    end
end
```

Things to notice:

- Every entry point — `XPluginStart`, `XPluginEnable`, `XPluginDisable`, `XPluginStop`, `XPluginReceiveMessage` — is defined, and each does only what is appropriate for its phase. One-off `XPLMCreateCommand` in `Start`; armed state in `Enable`; matching teardown in `Disable`.
- The dataref and command handles are looked up (or created) once, not per frame.
- The flight-loop callback reads the sim dataref through the typed accessor; no proxy magic.
- The custom-dataref registration passes `nil` for every type it does not expose. The `Float` pair is the one that matters.
- The flight-loop callback returns `-1` to fire again next frame; the command handler returns `true` to passthrough.
- `XPluginReceiveMessage` handles per-flight work by branching on `XPLM_MSG_AIRPORT_LOADED` from `XPLM_PLUGIN_XPLANE`.

