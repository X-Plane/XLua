# Migrating XLua 1.x Scripts to XLua 2.0

Practical translation guidance for moving an XLua 1 aircraft script to XLua 2. For the shared concepts see [`README.md`](README.md); for the source and target surfaces see [`xlua1-syntax.md`](xlua1-syntax.md) and [`xlua2-syntax.md`](xlua2-syntax.md).

## Scope

The audience is both human authors migrating scripts by hand and automated / AI-assisted translators doing it in bulk. The rules below cover every helper and convention in use across the shipped Laminar Research fleet. A handful of items are still pending verification — those are collected in the [Pending items](#pending-items) section at the end.

## Translation goal: functional equality

The aim of a migration is that the v2 script has the **same observable behaviour** as the v1 original, not that it preserves the v1 structure verbatim. This permits — and in some cases requires — the translator to:

- drop truly dead code: empty notifier callbacks, stub functions never referenced, identical duplicated callback bodies, inert arguments to v2 calls that have no meaningful v1 counterpart;
- collapse boilerplate into local helpers when the compressed form is clearer and has the same behaviour;
- elide v1 arguments that have no v2 meaning (the empty third argument to `create_dataref` being the common case).

**One explicit exception: commented-out code stays.** The author meant something by commenting a line out — a debugging `print` left for next time, a callback skeleton kept as a reminder that the hook exists, a `dofile("")` preserving a slot for future loader work. A translation is not the right moment to decide any of it is gone for good. Preserve commented-out lines verbatim. If a commented-out construct references v1 helpers that no longer exist in v2 (e.g. `--find_dataref(…)`), leave it in the v1 form — it is a comment, not code to be rewritten.

Any judgement call the translator makes under this rule — what got removed, what got collapsed, what got inlined — belongs in the migrated file's header note (see [Recording doubts and assumptions](#recording-doubts-and-assumptions-automatedai-migration)) so a reviewer can find every such decision without re-running the translator.

## Migration workflow and output layout

**Never overwrite the source.** A migration must leave the original `scripts/` folder untouched and write its output to a sibling folder:

```
<aircraft folder>/plugins/xlua/
    scripts/                   <- source, untouched
        foo/foo.lua
        bar/bar.lua
    scripts_migrated/          <- migration output
        foo/foo.lua            <- translated copy
        bar/bar.lua
```

The `scripts_migrated/` folder mirrors the `scripts/` folder's subfolder layout exactly (folder name = master-script filename, same as under v1). Leaving the source in place preserves:

- rollback — no original script is harmed, and no new script is accidentally distributed or executed since scripts_migrated is ignored by XLua;
- comparison — diff the two folders while debugging the migration;
- re-translation — a tool can be run again after a rule fix, with fresh output, without having destroyed its input;
- an untouched v1 copy for users or environments that still run XLua 1.

This rule applies strictly to automated and AI-assisted migration. Manual migration should follow it too.

### Recording doubts and assumptions (automated/AI migration)

Any assumption or uncertainty the migrator makes while translating a file — a defaulted dataref type, a lifecycle callback collapsed into a particular entry point, a timer with ambiguous teardown semantics — must be recorded as a **Lua comment block at the top of the migrated file**. Each note should give:

- the subject (symbol, line number in the source, enclosing function);
- the assumption or doubt;
- what a reviewer should verify.

Example header:

```lua
-- XLua 2 migration notes (auto-generated):
-- [L14  find_dataref]    assumed type Dataf for "laminar/aircraft/custom_thing" —
--                         not found in DataRefs.txt and not locally declared.
-- [L87  after_physics]   moved to XPLMCreateFlightLoop at AfterFlightModel,
--                         interval -1. Verify phase is correct for this logic.
-- [L122 flight_crash]    mapped to XPLM_MSG_PLANE_CRASHED branch in
--                         XPluginReceiveMessage. Verify param usage.
```

The notes let a reviewer find every spot the tool was not confident without re-running the translator. The original script's line numbers are the authoritative reference.

### Going live — activating a migrated master

The `scripts_migrated/` folder is a staging area. XLua does not load it — whatever sits there has no runtime effect. To activate a migrated master, **the user manually copies the file from `scripts_migrated/<name>/<name>.lua` to `scripts/<name>/<name>.lua`, overwriting the v1 original**. This is intentional:

- the folder-name-equals-filename rule still applies, so the path the file lives at after activation is determined by its folder name, identical to its staged location;
- activation is per-master, not per-tree — each master can be reviewed and switched over independently;
- because the XLua 2 runtime hosts both syntaxes (see [Key conceptual shifts](#key-conceptual-shifts)), the unmigrated masters in `scripts/` keep working while individual masters switch to v2 syntax one at a time.

A migration tool **must not** perform the copy itself: activation is a deliberate act by the author, usually after reading the migration-notes header and satisfying themselves that the translated file does what the original did.

### Symbol categorisation — the first pass

Before applying any translation rule, the migrator must scan the source to build a table of every top-level identifier and its binding category. The rule picked for each later reference depends on which category the identifier belongs to, and the same syntactic form (`foo = 2`, `if foo == 1 then …`) means different things across categories:

- **Sim-owned dataref handles** — bound by `find_dataref` against a `sim/…` name. Reads and writes translate to `XPLMGet/SetData*` calls.
- **Script-owned custom dataref handles** — bound by `create_dataref` in *this* script. Reads go through the storage variable; writes can go **direct to the storage variable** (see [Custom datarefs](#custom-datarefs)).
- **Foreign-plugin dataref handles** — bound by `find_dataref` against a name published by another plugin. Translated like sim-owned (through `XPLMGet/SetData*`); flag the call site if the handle may be `nil` because the producing plugin is not loaded.
- **Command handles** — bound by `find_command` or `create_command`.
- **Handler functions** — referenced by `create_command` / `replace_command` / `wrap_command` / `filter_command`.
- **Plain Lua locals and module globals** — everything else. No translation; the v2 script uses the same names and values.

The rule sections below assume this table has been built. A linear pass down the file that applies rules without the categorisation will misclassify writes to symbols whose definitions are hundreds of lines away.

### Handle persistence and naming

Every handle created in `XPluginStart` or `XPluginEnable` — dataref handles from `XPLMFindDataRef`, custom-dataref handles from `XPLMRegisterDataAccessor`, command handles from `XPLMFindCommand` / `XPLMCreateCommand`, flight-loop handles from `XPLMCreateFlightLoop` — must live in a variable that outlives the creation function. A `local` declared inside `XPluginStart` is useless to `XPluginDisable`, which needs the same handle to tear the asset down. The standard shape is a forward-declared module-scope `local`:

```lua
local simDR_throttle            -- forward decl
local myDR_smoothed_amps        -- forward decl
local CMD_reset                 -- forward decl
local fl_tick                   -- forward decl

function XPluginStart()
    simDR_throttle = XPLMFindDataRef("sim/…")
    CMD_reset      = XPLMCreateCommand("laminar/…", "…")
    return true
end

function XPluginEnable()
    myDR_smoothed_amps = XPLMRegisterDataAccessor("laminar/…", …)
    fl_tick            = XPLMCreateFlightLoop({ … })
    XPLMRegisterCommandHandler(CMD_reset, reset_handler, true, nil)
    …
end
```

When the v1 source bound the return of `find_dataref` / `create_dataref` / `find_command` / `create_command` to a name, **reuse that name** for the v2 handle. When the v1 source did not (e.g. `create_command(name, desc, handler)` with the return discarded — fine in v1 where the script never re-invokes the command, but the v2 code still needs a handle for `XPLMUnregisterCommandHandler`), invent one using **prefix + last path component** of the dataref or command name:

- `CMD_` for command handles — `create_command("laminar/sr22/fuel_sel_left_off", …)` → `CMD_fuel_sel_left_off`.
- `simDR_` for sim-owned dataref handles — `find_dataref("sim/cockpit2/electrical/battery_on[0]")` → `simDR_battery_on_0` (sanitise any character that cannot appear in a Lua identifier).
- `myDR_` for script-owned custom dataref handles — `create_dataref("laminar/sr22/boost_pump", …)` → `myDR_boost_pump`.

Existing aircraft-specific prefixes (`simDR_`, `sr22_`, `simCMD_`, etc.) are fine to carry over unchanged; the invent-a-name scheme above applies only to handles the v1 source did not bind.

### File skeleton

A migrated v2 file follows this top-to-bottom shape. The newly-created `XPlugin*` entry points sit **close to the top** of the file, where a reader arriving for the first time finds them immediately; everything else keeps its relative position from the v1 source so an author familiar with the v1 layout can still find each piece of logic roughly where it used to be.

1. **XLua 2.0 marker** — `--[[ XLua 2.0 ]]` as the **literal first line of the file**, with nothing (not even whitespace-only lines) preceding it. This is how the runtime distinguishes XLua 2 scripts from XLua 1 scripts; it overrides any "preserve original leading comments in place" rule — the marker goes first, always.
2. **Original file header comments** — purpose, author, copyright, licence, revision history. Preserve verbatim, shifted down by the one-line marker.
3. **Migration-notes block** — the per-file header of assumptions and doubts described in [Recording doubts and assumptions](#recording-doubts-and-assumptions-automatedai-migration). Place before or after the original header per tool preference, but clearly delimited from it.
4. **`require` statements** — the XPLM modules the script uses.
5. **Module-scope state** — in order: any v1 module-level locals being carried over, storage variables for custom datarefs (`local g_<name> = 0`), and forward-declared `local` bindings for the dataref, command, and flight-loop handles that `XPluginStart` and `XPluginEnable` populate.
6. **`XPluginStart`** — dataref lookups, command creation, any one-off setup.
7. **`XPluginEnable`** — custom-dataref registration, command-handler registration, flight-loop creation.
8. **`XPluginDisable`** — mirror teardown of everything `XPluginEnable` armed.
9. **`XPluginStop`** — final teardown (usually empty for migrated scripts; keep as a stub so the entry-point set is complete).
10. **`XPluginReceiveMessage`** — message dispatch. Keep the body small; branch on `inMessage` and call out to named helper functions for anything non-trivial.
11. **Everything else in the v1 source's relative order** — command-handler function bodies, per-subsystem helpers, rate-dependent utilities, the per-frame flight-loop callback, commented-out v1 skeletons, any trailing submodule-loader comments. Keep v1's relative layout so a familiar reader finds each piece of logic in its accustomed place.

**Scoping consequence.** Because `XPluginStart` and `XPluginEnable` reference helper and handler functions defined further down the file, those functions must be **callable at call-time** from the top-of-file entry points. The simplest approach is to keep those later definitions as **global functions** (unqualified `function foo()`): the v1 source already used this form, and each XLua 2 script runs in its own isolated environment so global functions don't pollute any wider namespace. The alternative is to forward-declare the names as `local` bindings in step 4 alongside the handles, then assign them later with `foo = function(...) end`; use this form where keeping helper scopes explicit is wanted.

## Key conceptual shifts

- **Dataref proxies → explicit typed accessors.** `find_dataref(name)` + plain variable access becomes `XPLMFindDataRef(name)` + `XPLMGetData{f,i,d}` / `XPLMSetData{f,i,d}`. Each read and each write commits to a type at the call site.
- **Named-global callbacks → XPlugin entry points.** v1 callbacks like `flight_start`, `after_physics`, `aircraft_load` become bodies of `XPluginStart` / `XPluginEnable` / `XPluginDisable` / `XPluginStop` or branches inside `XPluginReceiveMessage`, or flight-loop callbacks for per-frame work.
- **Automatic per-flight reload → explicit per-flight work.** The v1 runtime re-runs the whole script chunk on every new flight. In v2 the chunk runs once by default; per-flight state is re-initialised in response to `XPLM_MSG_AIRPORT_LOADED`. A porting shim `XLuaReloadOnFlightChange()` exists but is a compatibility aid, not the recommended default.
- **Timer helpers are unchanged.** `run_after_time`, `run_at_interval`, `run_timer`, `stop_timer`, `is_timer_scheduled`, and `get_timer_remaining` all work in XLua 2 with identical semantics. A migration does not rewrite timer calls.
- **No implicit imports.** Each XPLM module the script uses has to be `require`d explicitly at the top of the file (`require("XPLMDataAccess")`, `require("XPLMProcessing")`, …).
- **Don't put non-trivial logic inside `XPluginReceiveMessage`.** Anything larger than a few lines should go into its own function, and that function should be called from `XPluginReceiveMessage`.
- **The XLua 2 runtime hosts both syntaxes.** The XLua 2 binary paired with its stock `init.lua` runs both XLua 1 and XLua 2 master scripts. Migration is therefore per-master: an aircraft can have some masters still in v1 syntax and others already in v2 syntax at the same time, all backed by one XLua 2 deployment.

## Symbol mapping

At-a-glance index; each entry points forward to the section that covers it in detail.

| XLua 1 | XLua 2 | Section |
|---|---|---|
| `find_dataref(name)` | `XPLMFindDataRef(name)` + typed accessors at every use | [Dataref access](#dataref-access) |
| `create_dataref(name, type[, notifier])` | `XPLMRegisterDataAccessor(…)` in `XPluginEnable`; `XPLMUnregisterDataAccessor` in `XPluginDisable` | [Custom datarefs](#custom-datarefs) |
| `find_command(name)` | `XPLMFindCommand(name)` | [Command handlers](#command-handlers) |
| `create_command(name, desc, h)` | `XPLMCreateCommand` + `XPLMRegisterCommandHandler` | [Command handlers](#command-handlers) |
| `replace_command` / `wrap_command` / `filter_command` | `XPLMRegisterCommandHandler` with appropriate `beforeFlag` and return value | [Command handlers](#command-handlers) |
| `cmd:once()` / `:start()` / `:stop()` | `XPLMCommandOnce` / `XPLMCommandBegin` / `XPLMCommandEnd` | [Command handlers](#command-handlers) |
| `run_after_time` / `run_at_interval` / `run_timer` / `stop_timer` / `is_timer_scheduled` / `get_timer_remaining` | **Unchanged** — same helpers available in v2 | [Timers — no change required](#timers--no-change-required) |
| `aircraft_load()` | Body of `XPluginEnable()` | [Lifecycle entry points](#lifecycle-entry-points) |
| `aircraft_unload()` | Body of `XPluginDisable()` | [Lifecycle entry points](#lifecycle-entry-points) |
| `flight_start()` | Branch on `XPLM_MSG_AIRPORT_LOADED` inside `XPluginReceiveMessage` | [Lifecycle entry points](#lifecycle-entry-points) |
| `before_physics()` | Flight loop at `xplm_FlightLoop_Phase_BeforeFlightModel`, interval `-1` | [Lifecycle entry points](#lifecycle-entry-points) |
| `after_physics()` | Flight loop at `xplm_FlightLoop_Phase_AfterFlightModel`, interval `-1` | [Lifecycle entry points](#lifecycle-entry-points) |
| `after_replay()` | Flight-loop callback that branches on `sim/time/is_in_replay`; see notes | [Lifecycle entry points](#lifecycle-entry-points) |
| `flight_crash()` | Branch on `XPLM_MSG_PLANE_CRASHED` inside `XPluginReceiveMessage` | [Lifecycle entry points](#lifecycle-entry-points) |
| `receive_message(fromWho, msg, param)` | `XPluginReceiveMessage(fromWho, inMessage, param)` | [Lifecycle entry points](#lifecycle-entry-points) |
| `SIM_PERIOD` | `elapsedSinceLastLoop` flight-loop argument; `sim/operation/misc/frame_rate_period` dataref outside a loop | [Implicit globals](#implicit-globals) |
| `IN_REPLAY` | `sim/time/is_in_replay` dataref | [Implicit globals](#implicit-globals) |
| `dofile`, `real_table`, `raw_table`, `make_prop`, `create_namespace` | See escape-hatch translations | [v1 escape-hatch helpers](#v1-escape-hatch-helpers) |
| `plugins/xlua/init.lua` (v1 or modified copy) | Must be the stock XLua 2 `init.lua` before migration proceeds | [The `init.lua` file](#the-initlua-file) |

## Lifecycle entry points

### `aircraft_load()` → `XPluginEnable()`

`aircraft_load` fires once when the aircraft and all its scripts have finished loading. In v2 that work goes into the body of `XPluginEnable` — the entry point that arms state around an active session. If the work is truly once-per-script-lifetime (e.g. computing derived constants that never change) prefer `XPluginStart`; if it needs to be re-run on a user disable/re-enable cycle, keep it in `XPluginEnable`. `XPluginEnable` returns `true` to proceed; a missing function counts as `true`.

### `aircraft_unload()` → `XPluginDisable()`

`aircraft_unload` fires just before the aircraft is torn down. The v2 mirror is `XPluginDisable`, which should release everything `XPluginEnable` armed: destroy flight loops, unregister command handlers, unregister custom datarefs, and clear any `sim/operation/override/*` datarefs the script set. The script may be re-enabled later, so leave it in a clean "not running" state, not a half-torn-down one.

### `flight_start()` → `XPLM_MSG_AIRPORT_LOADED` branch

`flight_start` fires at the start of every new flight. In v2 the equivalent is a branch inside `XPluginReceiveMessage`:

```lua
function XPluginReceiveMessage(fromWho, inMessage, param)
    if fromWho == XPLM_PLUGIN_XPLANE and inMessage == XPLM_MSG_AIRPORT_LOADED then
        -- per-flight initialisation
    end
end
```

### `before_physics()` / `after_physics()` → flight-loop callbacks

Per-frame v1 callbacks become `XPLMCreateFlightLoop` calls in `XPluginEnable`, with the appropriate phase and an interval of `-1` (fire every frame). Example translation for `after_physics`:

```lua
-- v1:
function after_physics()
    -- per-frame work
end

-- v2:
local fl_handle

local function after_physics_cb(elapsed, elapsedSinceLast, counter, refcon)
    -- per-frame work (was the body of after_physics)
    return -1
end

function XPluginEnable()
    fl_handle = XPLMCreateFlightLoop({
        phase        = XPLMFlightLoopPhaseType.xplm_FlightLoop_Phase_AfterFlightModel,
        callbackFunc = after_physics_cb,
        refcon       = nil })
    XPLMScheduleFlightLoop(fl_handle, -1, true)
    return true
end

function XPluginDisable()
    if fl_handle then XPLMDestroyFlightLoop(fl_handle); fl_handle = nil end
end
```

`before_physics` is the same shape with `xplm_FlightLoop_Phase_BeforeFlightModel`.

### `after_replay()`

Flight-loop callbacks fire in both normal flight and replay. Replay state in v2 is queryable from the dataref `sim/time/is_in_replay` (0 when flying normally, non-zero in replay). There is currently **no XPLM message for replay start/stop** — a script that needs to react to the transition does it by monitoring the dataref and comparing against the previous frame's value.

The v2 translation of `after_replay` is therefore a flight-loop callback that branches on the dataref:

```lua
local function per_frame(elapsed, elapsedSinceLast, counter, refcon)
    if XPLMGetDatai(is_in_replay) ~= 0 then
        -- what after_replay used to do
    else
        -- what after_physics used to do
    end
    return -1
end
```

If the script defined both `after_physics` and `after_replay` (a common pattern in shipped aircraft), collapse them into a single flight-loop callback. When the two bodies are **identical** (once any comments are ignored), collapse to a single callback with no `is_in_replay` branch at all — the per-frame function just runs once per frame in both modes. When the bodies **differ**, use the branching shape shown above.

To react specifically to replay *starting* or *stopping*, track the previous frame's value:

```lua
local prev_replay = 0

local function per_frame(elapsed, elapsedSinceLast, counter, refcon)
    local replay = XPLMGetDatai(is_in_replay)
    if replay ~= 0 and prev_replay == 0 then
        -- replay just started
    elseif replay == 0 and prev_replay ~= 0 then
        -- replay just stopped
    end
    prev_replay = replay
    -- ... rest of per-frame work
    return -1
end
```

### `flight_crash()` → `XPLM_MSG_PLANE_CRASHED` branch

Maps to a branch inside `XPluginReceiveMessage`, alongside the other message-driven events:

```lua
if inMessage == XPLM_MSG_PLANE_CRASHED then
    -- what flight_crash used to do
end
```

### `receive_message(inFromWho, inMessage, inParam)` → `XPluginReceiveMessage(fromWho, inMessage, param)`

Direct mapping — same three arguments, same semantics.

## Dataref access

`find_dataref(name)` returns a proxy in v1; `XPLMFindDataRef(name)` returns a plain handle in v2. Reads and writes that used the proxy transparently become explicit typed calls at every use:

```lua
-- v1
battery_on = find_dataref("sim/cockpit2/electrical/battery_on[0]")

function after_physics()
    if battery_on == 1 then
        battery_on = 0
    end
end

-- v2
battery_on = XPLMFindDataRef("sim/cockpit2/electrical/battery_on[0]")

local function tick(...)
    if XPLMGetDatai(battery_on) == 1 then
        XPLMSetDatai(battery_on, 0)
    end
    return -1
end
```

Arrays carry over the 0-based indexing from v1. The element-access and bulk-assignment forms translate as:

```lua
-- v1
first = battery_array[0]         -- element 0
battery_array[1] = 1             -- set element 1
battery_array = { 1, 0, 0 }      -- bulk set 0..2

-- v2
local tmp = {}
XPLMGetDatavi(battery_array, tmp, 0, 1); first = tmp[1]   -- element 0 into tmp[1]
XPLMSetDatavi(battery_array, { 1 }, 1, 1)                  -- set element 1
XPLMSetDatavi(battery_array, { 1, 0, 0 }, 0, 3)            -- bulk set 0..2
```

`XPLMFindDataRef` returns `nil` for missing datarefs; guard the handle if the dataref is not guaranteed to exist.

### Dataref type inference

`XPLMGet/SetData*` are typed — the translator must commit to `f`, `i`, or `d` at every call site. Apply the following rules in order:

1. **Declared-by-this-script.** If the dataref was created by `create_dataref` in the source being translated, use its declared type (`"number"` → Dataf, `"string"` → Datab, `"array[N]"` → Datavf).
2. **In DataRefs.txt.** X-Plane ships the built-in dataref catalogue at the sim-root-relative path `Resources/plugins/DataRefs.txt`. It is a plain text file (tab-separated; columns: *name*, *type*, *writable*, *units*, *description*; type values include `int`, `float`, `double`, `byte[N]` and their array variants). The translator should read this file at translation time, match the dataref name against it, then pick `f` / `i` / `d` / `vf` / `vi` / `b` from the recorded type.

   **Locating the file from an aircraft path.** An aircraft under migration is itself at a sim-root-relative path (`Aircraft/<publisher>/<aircraft>/plugins/xlua/scripts/<name>/`), so a tool can walk up from the script folder until it finds a sibling `Resources/` directory; `DataRefs.txt` is then at `Resources/plugins/DataRefs.txt` under that root. No absolute path ever needs to be hard-coded, and there is no other stable way to refer to the file since installations sit at different locations on disk.
3. **Neither of the above.** This typically means a dataref published by a third-party plugin. Emit `TODO(XLUA2-TYPE): <dataref name> — type unverified; defaulted to Dataf` both as an inline comment at the call site and as a header note (see *Recording doubts and assumptions* above). Default to `XPLMGetDataf` / `XPLMSetDataf` as a safe fallback.

Usage context (comparisons against integer literals, arithmetic, etc.) is **not** a reliable type signal — the literal `0` or `1` fits both int and float datarefs and leads to wrong choices. Do not infer from context.

## Custom datarefs

`create_dataref` is the largest structural expansion in the migration. The helper is replaced by explicit storage, accessor closures, an `XPLMRegisterDataAccessor` call in `XPluginEnable`, and a matching `XPLMUnregisterDataAccessor` in `XPluginDisable`:

```lua
-- v1
my_dr = create_dataref("laminar/example/my_dr", "number")

-- v2
local g_my_dr = 0
local function read_my_dr(refcon)      return g_my_dr end
local function write_my_dr(refcon, v)  g_my_dr = v    end

local my_dr  -- accessor handle, for teardown

function XPluginEnable()
    my_dr = XPLMRegisterDataAccessor(
        "laminar/example/my_dr", XPLMDataTypeID.xplmType_Float, true,
        nil,         nil,                -- Int
        read_my_dr,  write_my_dr,        -- Float
        nil,         nil,                -- Double
        nil,         nil,                -- IntArray
        nil,         nil,                -- FloatArray
        nil,         nil,                -- ByteArray
        nil,         nil)                -- refcons
    return true
end

function XPluginDisable()
    if my_dr then XPLMUnregisterDataAccessor(my_dr); my_dr = nil end
end
```

Type → accessor-pair mapping when translating the second argument of `create_dataref`:

| v1 `type` | v2 type constant | Accessor pair |
|---|---|---|
| `"number"` | `xplmType_Float` | `read`/`write` via `XPLMGetDataf` / `XPLMSetDataf` contract |
| `"string"` | `xplmType_Data` | Byte-block pair (read returns length if `outValues == nil`, else fills it) |
| `"array[N]"` | `xplmType_FloatArray` | Float-array pair implementing the size-query contract — reader returns `N` when called with `outvalues == nil` |

### Writing to an owned dataref: direct vs through the setter

Within the script that owns a custom dataref, writes should update the **storage variable directly** rather than routing through `XPLMSetData*`:

```lua
-- v1
sr22_fuel_selector = 2            -- proxy write

-- v2
g_sr22_fuel_selector = 2          -- direct storage update; observers see the new
                                  -- value via the read accessor on their next get
```

There is no benefit to calling `XPLMSetDataf(sr22_fuel_selector, 2)` from inside the script that owns `sr22_fuel_selector`; it just round-trips through the setter closure to produce the same storage-variable assignment.

The rule **does not apply** to foreign datarefs (anything returned by `XPLMFindDataRef` — sim-owned or produced by another plugin). Those writes must go through `XPLMSetData*` because the script does not own the storage.

### Writability and the optional notifier

v1's `create_dataref` distinguishes three cases by the presence and content of the third (notifier) argument. Each translates to a different shape of `XPLMRegisterDataAccessor` call:

| v1 shape | v2 `writable` | v2 writer slot |
|---|---|---|
| No notifier argument | `false` | Pass `nil` in the type-correct writer slot |
| Notifier with a real body | `true` | Writer closure that stores the new value **and** runs the ported notifier logic |
| Empty / no-op notifier | `true` | Writer closure that stores the new value. **Add a migration-header note** flagging the dataref for review |

**Why the third case gets a flag.** A writable dataref whose setter does nothing beyond storing the value is unusual. The empty notifier in the v1 source may indicate a forgotten stub (the author intended to fill in the body later, or intended the dataref to be read-only but got the `create_dataref` signature wrong) rather than a deliberate "anything can write anything" design. This is not an error — the translation is correct — but a reviewer should decide whether the v2 dataref should stay writable (leave as translated) or become read-only (change `writable=true → false`, drop the writer).

Example for the "notifier with body" case:

```lua
-- v1
function on_knob_change()
    if knob_oat < 2 then cmd_thermo_units_toggle:once() end
end
knob_oat = create_dataref("laminar/c172/knob_OAT", "number", on_knob_change)

-- v2
local g_knob_oat = 0
local function write_knob_oat(refcon, v)
    g_knob_oat = v
    if g_knob_oat < 2 then XPLMCommandOnce(cmd_thermo_units_toggle) end
end
-- read_knob_oat and the XPLMRegisterDataAccessor call follow the shape above,
-- with writable=true and write_knob_oat in the Float writer slot.
```

If the notifier reads the new value from the v1 proxy (as in the example above — `knob_oat` is being read inside `on_knob_change`), rewire it to read the incoming `v` argument instead. A purely mechanical rename would read the storage variable *before* it has been updated; use `v`, or update the storage variable first and then read it.

## Command handlers

All four of v1's command-handler helpers collapse into patterns of `XPLMCreateCommand` + `XPLMRegisterCommandHandler`. The `beforeFlag` argument and the handler's boolean return value together cover everything the v1 helpers did separately:

| XLua 1 idiom | XLua 2 equivalent |
|---|---|
| `create_command(name, desc, h)` | `XPLMCreateCommand(name, desc)` + register with `beforeFlag=true`; wrapper does the work and returns `true`. |
| `replace_command(name, h)` | Register with `beforeFlag=true`; wrapper returns `false` to suppress the default. |
| `wrap_command(name, before, after)` | Two registrations — one with `beforeFlag=true`, one with `beforeFlag=false`; both return `true`. |
| `filter_command(name, predicate)` | Register with `beforeFlag=true`; wrapper returns the predicate's boolean. |

Additional translation points:

- **Placement across entry points.** Split each v1 `create_command` across three v2 entry points: `XPLMCreateCommand` goes in `XPluginStart` (one-off, survives enable/disable cycles); `XPLMRegisterCommandHandler` goes in `XPluginEnable`; `XPLMUnregisterCommandHandler` goes in `XPluginDisable`. Putting `XPLMCreateCommand` inside `XPluginEnable` also works but re-creates the command on every user enable/disable cycle, which is wasteful and not the recommended shape.
- **Handler signature.** v1 handlers have `(phase, duration)`. v2 handlers have `(inCommand, inPhase, refcon) -> bool`. `inPhase` replaces `phase`; `inCommand` and `refcon` are typically ignored unless the script wants to share one handler across several commands; `duration` has no direct v2 equivalent — if you need elapsed-since-begin, track it yourself using `XPLMGetElapsedTime` at the begin phase.
- **Phase values.** Prefer the named `XPLMCommandPhase.xplm_Command*` constants over the raw `0` / `1` / `2` that v1 scripts often used.
- **Return value.** v1 handlers return nothing meaningful. v2 handlers must return a boolean — default to `true` (passthrough) unless the original idiom was `replace_command` or `filter_command` and suppression is wanted.
- **Teardown.** v1 handlers have no teardown step. v2 handlers must be torn down with `XPLMUnregisterCommandHandler` at script disable, passing the same `beforeFlag` and `refcon` used at registration. Every `XPLMRegisterCommandHandler` call needs a matching unregister.

## Timers — no change required

The six timer helpers — `run_after_time`, `run_at_interval`, `run_timer`, `stop_timer`, `is_timer_scheduled`, `get_timer_remaining` — all work in XLua 2 with identical semantics to v1. A v1→v2 migration **does not rewrite timer calls**. Leave them as they are.

See [**Timer helpers** in the XLua 1 doc](xlua1-syntax.md#timer-helpers) for the API; the same section is the reference for XLua 2. The one-timer-per-function identity rule and the "do not use anonymous functions" constraint both carry across unchanged.

Modernisation option (optional, not part of the translation): a timer that needs phase control, elapsed-time arguments, or multiple instances backed by the same function can be rewritten as an `XPLMCreateFlightLoop` in v2. Do this only when an author genuinely wants the extra flexibility — not as a routine part of the migration.

## Implicit globals

### `SIM_PERIOD`

**Primary rule: read the dataref `sim/operation/misc/frame_rate_period` with `XPLMGetDataf`.** Look up the handle once at load time, cache it, and read it anywhere v1 would have referenced the global — inside flight-loop callbacks, inside timer callbacks, inside helper functions, at chunk scope. The dataref's semantics are guaranteed to match v1's `SIM_PERIOD`, and the same rule applies to every call site, so there is no branching on context.

A flight-loop callback also receives `elapsedSinceLastLoop` as an argument. This looks like a zero-cost replacement (no dataref lookup needed) but its exact semantics have not been verified to match `SIM_PERIOD` in every case, and a mismatch produces subtle drift in rate-dependent logic (animation smoothing, integration helpers). Use `elapsedSinceLastLoop` only where you have verified the semantics match for the logic being translated; the dataref read is the safe default.

### `IN_REPLAY`

Maps to the dataref `sim/time/is_in_replay` — an integer, `0` while flying normally and non-zero in replay mode. Look up the handle once at load time and read it with `XPLMGetDatai` wherever v1 would have referenced the global.

## The `init.lua` file

`init.lua` is part of the XLua binary distribution. Every XLua plugin instance — per-aircraft or system-level — has exactly one `init.lua` and one `scripts/` directory, and the `init.lua` is paired with the binary it ships alongside:

- an XLua 1 binary requires the XLua 1 `init.lua`, and runs XLua 1 master scripts only;
- an XLua 2 binary requires the XLua 2 `init.lua`, and runs **both XLua 1 and XLua 2 master scripts** — the XLua 2 `init.lua` knows how to host either.

The two files are not interchangeable. An XLua 1 `init.lua` under an XLua 2 binary, or an XLua 2 `init.lua` under an XLua 1 binary, will not work.

**The file is not author-editable territory.** The only sanctioned modifications are the LuaJIT knobs documented in its header comment (see [LuaJIT tuning](README.md#luajit-tuning)) — those are system-level tweaks the file explicitly invites. Any other edit is unsupported. Future XLua point releases make no compatibility promise to a modified `init.lua`, and can break it at any time; the LuaJIT-knob area is the one exception.

Historically, some aircraft shipped customised copies of the v1 `init.lua`: often verbatim, occasionally with LuaJIT-knob tweaks, rarely with genuinely custom additions. That practice was already unsupported ground before migration was on the table; migration just brings it to a head.

### Migration precondition

Migration only makes sense in an XLua 2 environment. Before translating any master script, a migration tool (or a human) must confirm the environment is **stock XLua 2**:

- the binary is the XLua 2 binary;
- the `init.lua` alongside it is the stock XLua 2 `init.lua`, unmodified except for any LuaJIT-knob values the author has legitimately set.

If either check fails, migration is blocked. Common cases and their remediation:

- **Stock XLua 1 `init.lua` (verbatim copy).** Overwrite with the stock XLua 2 `init.lua`. Because the XLua 2 `init.lua` hosts both syntaxes, the aircraft's existing v1 master scripts keep working.
- **XLua 1 `init.lua` with LuaJIT-knob tweaks.** Port the knob values onto the stock XLua 2 `init.lua` in the same header-comment area, then overwrite.
- **XLua 1 or XLua 2 `init.lua` with genuinely custom additions.** The additions should not have been in `init.lua` in the first place; extract them into a regular helper file and have the master scripts that need them `require` it, then overwrite `init.lua` with the stock XLua 2 version. The [helper file must match the master script's syntax version](README.md#where-scripts-live), unless the additions are pure Lua with no XPLM or XLua calls — in which case either syntax will load it.

Once the environment is stock XLua 2, per-master migration can proceed as described earlier, one master at a time.

## Hazards and manual-review triggers

- **Dataref type erasure.** v1 proxies are type-agnostic; v2 accessors are typed. Handled by the DataRefs.txt strategy in [Dataref access](#dataref-access), but every dataref the tool could not type-check should still be flagged in the header note.
- **Command phase literals.** Translate `if phase == 0` / `== 1` / `== 2` to `XPLMCommandPhase.xplm_CommandBegin` / `xplm_CommandContinue` / `xplm_CommandEnd`.
- **Command handler return value.** v1 handlers return nothing meaningful; v2 handlers must return an explicit boolean. Default to `true`; use `false` only for the `replace_command` and `filter_command` suppression cases.
- **Array element writes in hot loops.** A literal translation of `for i = 1, n do dr[i] = v end` produces one `XPLMSetDatav*` call per iteration — catastrophic for large arrays. Flag any loop writing two or more consecutive array elements for a batched `XPLMSetDatav*` rewrite.
- **Anonymous-function timers.** The one-timer-per-function identity rule carries over from v1. Inline lambdas passed to `run_after_time` / `run_at_interval` were a bug in v1 and remain a bug in v2.
- **Silently-dead v1 callbacks.** A v1 named-global declared with `local function aircraft_load()` (or similar) is invisible to the v1 runtime and was never called. Flag on detection; translate the body to the v2 equivalent only if the author confirms the logic was supposed to run.
- **Shared globals between scripts.** XLua scripts are isolated — the usual cross-script channel is a shared custom dataref. If the translator encounters references to globals that appear to be produced by another script in the same aircraft, flag for manual review: the channel must survive the migration, typically by promoting it to an explicit dataref in both the producing and consuming scripts. Note that the same reference or utility script may be used (require or dofile) by multiple masters without implying that they share the same Lua virtual machine.
- **Chunk-scope locals persist across flights in v2.** v1 re-executes the script chunk on every new flight, so a `local x = 0` at the top of the file re-initialises each time. v2 runs the chunk once at script load; module-scope locals keep their values across flights. Audit every chunk-scope local in the source. If the script relied on the v1 per-flight reset — e.g. accumulators, timers counted in seconds-since-flight-start, mode flags that should default to a known state on each new flight — move the reset into the `XPLM_MSG_AIRPORT_LOADED` branch (the translated home of `flight_start`). If the local is only ever set by command handlers or runtime logic before it's read, no action is needed.

## Optional optimisations

These transformations are **not part of the translation** — they change nothing observable about the script's behaviour. They can improve runtime performance or readability, but they also widen the diff between v1 and v2 copies, which makes review harder. A migration tool should not apply them by default; offer them as a user choice per script. Manual translation can use discretion.

### Hoist repeated foreign-dataref reads into per-frame locals

A v1 per-frame function that reads the same sim-owned or foreign-plugin dataref many times keeps the same number of sim calls per frame after a literal translation — every `XPLMGetDataf(simDR_x)` is its own round-trip:

```lua
-- v2, literal translation (30+ sim calls per frame just for these two datarefs)
g_sr22_annun_o2_full = o2_full * XPLMGetDataf(simDR_indicator_light_level) * XPLMGetDatai(simDR_oxy_on)
g_sr22_annun_o2_1600 = o2_1600 * XPLMGetDataf(simDR_indicator_light_level) * XPLMGetDatai(simDR_oxy_on)
-- …
```

Hoisting each read into a local once at the top of the callback eliminates the repetition:

```lua
-- v2 with hoist
local light_level = XPLMGetDataf(simDR_indicator_light_level)
local oxy_on      = XPLMGetDatai(simDR_oxy_on)

g_sr22_annun_o2_full = o2_full * light_level * oxy_on
g_sr22_annun_o2_1600 = o2_1600 * light_level * oxy_on
-- …
```

The v1 code already had the same inefficiency (every proxy read was a sim call), so a literal translation faithfully preserves both behaviour and performance. Applying the hoist is a polish step the translator can offer.

### Compress custom-dataref boilerplate via a local helper

A script with many `create_dataref("…", "number")` calls produces equally many `XPLMRegisterDataAccessor` calls of identical shape. A short local helper captures the common form:

```lua
local function register_float_dr(name, read_fn, write_fn)
    return XPLMRegisterDataAccessor(
        name, XPLMDataTypeID.xplmType_Float, true,
        nil,     nil,                    -- Int
        read_fn, write_fn,                -- Float
        nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
end
```

Either form is correct. Emit the full 14-argument call at every site for an easier diff against the doc's rule; collapse into the helper for a shorter and more readable file.

## v1 escape-hatch helpers

A handful of v1 helpers are escape hatches into parts of the helper layer itself. They are rare in practice but a migration tool or author should know what each one does and how to translate it. Expected handling:

- **`dofile(path)`** — a v1 helper that loads another Lua file into the current script's environment. In v2 there is no wrapped environment, so this collapses to plain `dofile` (or `require`, or inlining the loaded code). **Rare in shipped aircraft** — almost always commented out where it appears; treat each call site individually.
- **`real_table(key, real_lua_table)`** — forces the named key to hold a plain Lua table, bypassing the v1 helper layer. Used only to avoid surprises when a script wants a literal data table (e.g. lookup tables, config). In v2 every table is already a plain Lua table, so calls collapse to a direct assignment: `real_table("lut", { ... })` becomes `lut = { ... }`.
- **`raw_table(key)`** — a v1 opt-out from the helper layer for a specific key. In v2 this has no meaning; drop the call.
- **`make_prop(name, { __get = ..., __set = ... })`** — lets a script install a synthetic proxy object that behaves like a dataref (any read calls `__get`, any write calls `__set`). Used when a script wants a computed pseudo-dataref inside its own namespace without publishing it to the sim. In v2 the equivalent is either plain Lua getters/setters on a table, or — if external visibility is actually wanted — a proper custom dataref via `XPLMRegisterDataAccessor`. Flag for author judgement.
- **`create_namespace()`** — wholly internal to v1's helper layer; no user script in the shipped fleet calls it. If one turns up during migration, translate by deleting — v2's plain Lua environment has no equivalent to reimplement.

## Pending items

- **Worked examples.** Planned end-to-end translations of three shipped scripts (`c172_IAS`, `c172_starter`, `c172_custom_datarefs`) are not yet written. Once added they will serve as the authoritative reference shape for each of dataref-override, custom-command, and custom-dataref patterns.
- **Automated translator tooling.** Whether a separate tool will consume this doc to do bulk translations is still open. The current doc is plain Markdown; the translation sections are structured enough to retrofit machine-parseable metadata (YAML front-matter per rule, or similar) later if a tool is built.
