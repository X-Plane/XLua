# XLua 1.x Syntax Reference

Reference documentation for the XLua 1.x helper API. For the shared concepts (script layout, lifecycle, primitives), see [`README.md`](README.md). For the XLua 2 surface, see [`xlua2-syntax.md`](xlua2-syntax.md). For translating v1 scripts to v2, see [`migrating-v1-to-v2.md`](migrating-v1-to-v2.md).

## At a glance

XLua 1 presents an ergonomic helper layer, defined in `deploy/init.lua` and auto-loaded before any user script runs. It includes:

- **Dataref proxies** (`find_dataref`, `create_dataref`) — return objects that behave like plain Lua variables: reading them returns the dataref's current value, assigning to them writes back. Array-valued datarefs use `[i]` for element access.
- **Command helpers** (`find_command`, `create_command`, and the intercept variants `replace_command`, `wrap_command`, `filter_command`) — return a command object with `:start()`, `:stop()`, `:once()` methods.
- **Timers** (`run_after_time`, `run_at_interval`, `stop_timer`, `is_timer_scheduled`, `get_timer_remaining`) — keyed by function reference, so each Lua function can have at most one pending timer.

## Reload on flight start

XLua 1 automatically re-executes every script chunk when the user begins a new flight. There is no opt-out.

## Named-global callbacks

An XLua 1 script participates in the lifecycle by defining **global** functions with specific well-known names. The runtime looks them up by name after the script loads and calls them when the corresponding event occurs. All are optional; omit any that do not apply.

**Watch out:** declaring any of these as `local function` means the runtime cannot find them and they are silently never called.

### `aircraft_load()`

Fires once, after the aircraft and all its scripts have finished loading and before the first flight starts. No arguments.

Use this for one-off aircraft-level setup that has to wait until every script is loaded — for example, caching values derived from PlaneMaker datarefs that only settle after load, or initialising per-aircraft panel state that should persist across flights.

### `flight_start()`

Fires at the start of every new flight: the user selected a new location, swapped aircraft, loaded a situation, or completed initial load. No arguments.

Use this to reset per-flight state. Typical work: set switch positions according to whether the flight begins cold-and-dark or with engines running, zero any counters or accumulators, and configure the panel for the selected startup mode.

### `before_physics()`

Fires every frame, just before X-Plane integrates the flight model. No arguments.

Use this to feed inputs *into* the flight model — for example, overriding pilot control values before the sim reads them.

### `after_physics()`

Fires every frame, just after X-Plane has integrated the flight model. No arguments.

Use this for the bulk of continuous per-frame logic: reading updated flight-model state, driving custom animations, patching sim outputs through custom datarefs, running smoothing filters. Most shipped aircraft put almost all of their runtime logic here. Does not fire during replay — use `after_replay()` for work that needs to run in replay too.

### `after_replay()`

Fires every frame while X-Plane is in replay mode. No arguments.

Use this for logic that must keep running during replay — typically driving animations that need to stay in sync with recorded state. Because the flight model is paused in replay, `after_physics` does not fire; anything that must run in both modes is typically implemented by defining both `after_physics` and `after_replay` and routing through a shared helper function.

### `aircraft_unload()`

Fires once, immediately before the aircraft is unloaded (the user picked a different aircraft, quit the sim, etc.). No arguments.

Use this to undo anything that would outlive the script's own teardown — most importantly, clear any `sim/operation/override/*` datarefs the script set, so the sim resumes normal behaviour. Custom datarefs, commands, and the script's own globals are cleaned up automatically; this callback is only needed when the script has mutated state the sim itself owns.

### `flight_crash()`

Fires when X-Plane detects that the aircraft has crashed. No arguments.

Use this for a custom response to a crash event. Very rarely needed and almost never used in shipped aircraft.

### `receive_message(inFromWho, inMessage, inParam)`

Fires when a plugin message is delivered to this script. Arguments:

- `inFromWho` — the plugin ID of the sender (or a well-known ID such as `XPLM_PLUGIN_XPLANE`).
- `inMessage` — the numeric message ID (`XPLM_MSG_*` constants).
- `inParam` — an integer parameter whose meaning depends on the message.

Use this only if the script needs to participate in an inter-plugin message protocol. The named-global lifecycle callbacks already cover every event an aircraft script typically needs, and `receive_message` is effectively unused across shipped aircraft.

## Dataref helpers

`find_dataref(name)` looks up a dataref published by the sim or another plugin. `create_dataref(name, type, notifier)` registers a new dataref owned by the script. Both return a **proxy object** that stands in for the dataref for the rest of the script's life.

### Typical usage

Call both at script load, outside any callback, and keep the returned proxy in a script-level variable:

```lua
-- Sim datarefs, looked up once
startup_running = find_dataref("sim/operation/prefs/startup_running")
battery_on      = find_dataref("sim/cockpit2/electrical/battery_on[0]")

-- Custom dataref, owned by this script
amps_needle = create_dataref("laminar/c172/electrical/battery_amps", "number")

function flight_start()
    -- Reads and writes use the proxy as a plain variable
    if startup_running == 1 then
        battery_on = 1
    end
end
```

Looking up a dataref by string is **expensive** and the returned handle does not change over the life of the script. Never call `find_dataref` or `create_dataref` inside a per-frame callback.

### Proxy reads and writes are sim calls — watch out in loops

Every read of a proxy (`local v = battery_on`, `if battery_on == 1 then …`, `battery_on + 1`) makes a call into the simulator. Every write (`battery_on = 1`) makes another. Each call carries a fixed overhead that dwarfs normal Lua work, so **accessing the same dataref repeatedly in a loop or a long chain of conditionals is a performance trap**. This is the single largest source of avoidable overhead in XLua 1 scripts.

The fix is always the same: hoist the value into a plain local before the loop and use the local inside it.

```lua
-- BAD: every iteration reads the proxy, every comparison reads it again
for i = 1, n do
    if battery_on == 1 and main_bus_volts > 22 then
        ...
    end
end

-- GOOD: one sim read each, then plain Lua thereafter
local bat   = battery_on
local volts = main_bus_volts
for i = 1, n do
    if bat == 1 and volts > 22 then
        ...
    end
end
```

### Array datarefs

When the underlying dataref is an array, the proxy supports element access via the square-bracket operator — and **the index is 0-based, not Lua's usual 1-based**. This matches XPLM's convention and the `sim/…/name[0]` syntax used in dataref path strings.

```lua
battery_array = find_dataref("sim/cockpit2/electrical/battery_on")

local first = battery_array[0]   -- first battery
battery_array[1] = 1             -- writes the second battery
```

Every `[i]` access is a sim call, exactly like a scalar read or write — the hoist-to-local rule applies in loops.

The proxy also exposes its declared size as the `len` field:

```lua
for i = 0, battery_array.len - 1 do
    ...
end
```

To replace the whole array in one sim call, assign a Lua table to the proxy:

```lua
battery_array = { 1, 0, 0 }   -- writes dataref indices 0, 1, 2 in one call
```

The Lua table itself is 1-based (that is standard Lua), but the values are placed into the dataref starting at element 0 — so table position 1 lands at dataref `[0]`, table position 2 at `[1]`, and so on.

### Types for `create_dataref`

The `type` argument is one of:

- `"number"` — a scalar; the common case.
- `"string"` — a byte-block dataref exposed as a Lua string.
- `"array[N]"` — an array of length `N`, indexed 0 through N−1.

### The notifier argument

The optional third argument of `create_dataref` is a callback that fires whenever *something else* (the sim, a panel click, another plugin) writes to the script's custom dataref. Typical use: a cockpit knob exposes its position as a custom dataref, the sim writes the new position when the user turns it, and the notifier reacts.

```lua
function on_knob_change()
    if knob_oat < 2 then
        cmd_thermo_units_toggle:once()
    end
end

knob_oat = create_dataref("laminar/c172/knob_OAT", "number", on_knob_change)
```

Omitting the notifier makes the dataref writable without any callback — the script is simply publishing a value.

## Command helpers

`find_command(name)` looks up a command that already exists — either a built-in X-Plane command or one created by another plugin. `create_command(name, description, handler)` registers a new command owned by the script. Both return a **command object** with `:start()`, `:stop()`, and `:once()` methods.

### Typical usage

Look up built-in commands and register custom ones at script load. Keep the returned objects in script-level variables:

```lua
-- Sim commands
simCMD_ignition_up     = find_command("sim/magnetos/magnetos_up_1")
simCMD_engage_starter  = find_command("sim/starters/engage_starter_1")

-- Custom command, with a handler function defined elsewhere in the script
C172CMD_ignition_up = create_command(
    "laminar/c172/ignition_up",
    "Ignition Selector Up",
    C172_ignition_up_handler)
```

Neither `find_command` nor `create_command` should be called from a per-frame callback.

### Invoking a command — begin / continue / end

A command has three phases: **begin** (the key or button went down), **continue** (it is being held), and **end** (it was released). The command object exposes three ways to invoke a command from the script:

- **`cmd:once()`** — fires the complete begin → end cycle in a single frame. Equivalent to a quick key press. This is the common case.
- **`cmd:start()`** — emits the begin phase. The command then remains in the continue phase, ticking every frame, until explicitly stopped.
- **`cmd:stop()`** — emits the end phase for a command previously started with `:start()`.

**Every `:start()` must be matched by exactly one `:stop()`.** This is the top-level *Gotchas* rule applied here: a missing `:stop()` leaves the command stuck in its held state and the sim keeps treating the button as held down.

Example — from the C172 starter logic, where holding the ignition key runs the starter motor:

```lua
-- Key turned to START position: engage the starter motor
simCMD_engage_starter:start()

-- ... later, when the key is released ...
simCMD_engage_starter:stop()
```

Use `:once()` when you want the command fired and forgotten; use the `:start()` / `:stop()` pair only when the script needs to hold a command down across frames.

### Writing a handler

The handler passed to `create_command` (and to `replace_command` / `wrap_command` below) has the signature:

```lua
function handler(phase, duration)
    ...
end
```

- **`phase`** is `0` (begin), `1` (continue), or `2` (end).
- **`duration`** is the elapsed time in seconds since the begin phase fired; it is `0` during begin itself and grows through continue until end.

Most handlers branch on `phase` and only do work on begin and/or end — continue-phase work is common for held actions (holding a trim wheel) but rare otherwise. Mirror the begin/end matching rule in your own code: if you run logic at begin, make sure you have matching logic at end.

```lua
function C172_ignition_up_handler(phase, duration)
    if phase == 0 then
        -- key was just turned up
        if simDR_ignition_pos == 3 or simDR_ignition_pos == 4 then
            simCMD_engage_starter:start()
        elseif simDR_ignition_pos < 3 then
            simCMD_ignition_up_1:once()
        end
    elseif phase == 2 then
        -- key was released
        if simDR_ignition_pos == 4 then
            simCMD_engage_starter:stop()
        end
    end
end
```

### Intercepting an existing command: `replace`, `wrap`, `filter`

Three helpers attach a handler to a command that already exists — a built-in command, or a custom one owned by another script or plugin. They differ in how they relate to that command's original behaviour.

#### `replace_command(name, handler)`

Installs the handler *instead of* the command's default behaviour. Signature matches the handler described above. When the command fires, the original behaviour is suppressed and only this handler runs. Use this when you want to completely take over a sim command — for example, rewriting the flaps-up command to route through custom aircraft logic.

Only one replacement handler can be installed per command.

#### `wrap_command(name, before, after)`

Installs a *pre-handler* that runs before the command's default behaviour and/or a *post-handler* that runs after. Both have the standard `(phase, duration)` signature. Either argument may be `nil`, but at least one must be non-nil. The command's original behaviour is **preserved**; the wrappers run around it.

Use this to observe or augment a command without changing what it does — for example, logging when the user toggles a switch, playing a custom sound on a release, or updating a custom dataref after the sim has processed the input.

Only one pre-handler and one post-handler can be installed per command.

#### `filter_command(name, predicate)`

Installs a gating **predicate** that decides, on every tick of the command, whether the command is allowed through. The predicate signature is different from the other handlers:

```lua
function predicate()
    return <bool>
end
```

It takes **no arguments** and returns a boolean. Returning `true` lets the command proceed (including any `replace_command` handler and the sim's default behaviour); returning `false` suppresses it. The predicate is called once per frame while the command is active, so its result can change during a hold — the runtime synthesises the necessary begin/end events on the main handler to keep things consistent if the predicate flips from allow to block or vice versa mid-hold.

Use this for conditional blocking — for example, the F-14 uses `filter_command("sim/flight_controls/drop_tank", …)` to only allow the drop-tank command when the aircraft is actually configured with droppable tanks.

Only one filter can be installed per command.

## Timer helpers

The timer helpers let a script schedule a function to run later — once or repeatedly. They are defined in `init.lua` and are **available to both XLua 1 and XLua 2 scripts** (this section is the reference for both; the XLua 2 doc links back here). An XLua 2 script that needs lower-level control — flight-loop phase selection, elapsed-time callback arguments, or multiple loops backed by the same function — has the XPLM flight-loop API available as well; see the XLua 2 doc.

### API

| Helper | Purpose |
|---|---|
| `run_after_time(fn, delay)` | Schedule `fn` to run once, `delay` seconds from now. |
| `run_at_interval(fn, interval)` | Schedule `fn` to run every `interval` seconds, starting `interval` seconds from now. |
| `run_timer(fn, delay, rep)` | General form. `delay` is the time until the first call; `rep` is the interval between subsequent calls, or negative to fire only once. `run_after_time` and `run_at_interval` are thin wrappers around this. |
| `stop_timer(fn)` | Cancel any pending timer for `fn`. |
| `is_timer_scheduled(fn)` | `true` if a timer is currently pending for `fn`, `false` otherwise. |
| `get_timer_remaining(fn)` | Seconds until `fn`'s next scheduled call, or `0` if none. |

### Function identity — one timer per function

Every helper takes a function reference as its key. The runtime uses that reference as the identity of the timer, so **a given function can have at most one timer scheduled at a time**. Calling `run_after_time(fn, 5)` and then `run_at_interval(fn, 1)` does not produce two timers — the second call replaces the first. This is what makes `stop_timer(fn)` and the query helpers work: you identify the timer by passing the same function reference you used to schedule it.

### Do not use anonymous functions

Because timers are keyed by function identity, a timer callback **must be a real named function, not an inline anonymous function (lambda)**.

```lua
-- BAD: every call constructs a brand-new function reference
run_at_interval(function() do_something() end, 1)

-- GOOD: a named function has a stable identity
function tick()
    do_something()
end
run_at_interval(tick, 1)
```

With an inline lambda the script has no reference it can later pass to `stop_timer` or `is_timer_scheduled`, and if the scheduling call itself ever runs more than once (for example from another callback) each invocation creates a fresh function object and the identity-based deduplication and lookup stop working.

This is an architectural limitation of the timer system, not a style preference. Scheduling a timer always means scheduling "this named function", not "this piece of code".

### When not to use a timer

For work that must run every frame, define the appropriate per-frame callback — `after_physics`, `before_physics`, or `after_replay` in XLua 1; a flight-loop callback in XLua 2 — rather than scheduling a timer with a very short interval. The per-frame callbacks are purpose-built for this and avoid the per-tick timer-table lookup.

## Implicit globals

XLua 1 injects two globals into every script's environment:

- **`SIM_PERIOD`** — the duration of the current frame, in seconds. Multiply a per-second rate by this to get a per-frame increment.
- **`IN_REPLAY`** — `0` when the sim is flying normally, `1` when replay mode is active.

## A small worked example

A minimal script that exercises the core helpers — one sim dataref, one custom dataref, and a per-frame callback:

```lua
-- Publish a smoothed version of the battery ammeter value
-- so the panel needle animates gently instead of jumping.

battery_amps  = find_dataref("sim/cockpit2/electrical/battery_amps[0]")
smoothed_amps = create_dataref("laminar/example/smoothed_amps", "number")

function after_physics()
    local target  = battery_amps       -- one sim read
    local current = smoothed_amps      -- one sim read
    smoothed_amps = current + (target - current) * (10 * SIM_PERIOD)
end
```

Three things to notice:

- `find_dataref` and `create_dataref` are called once, at script load, outside any callback.
- Inside the callback, each proxy is read into a plain local before being used — one sim call per dataref, then plain Lua from there.
- `SIM_PERIOD` makes the rate of change frame-rate-independent.

## Learning from the shipped aircraft

For working examples, read the scripts that ship with the default Laminar Research aircraft. They live at `Aircraft/Laminar Research/<aircraft>/plugins/xlua/scripts/`. In roughly increasing complexity:

- **Aero-Works Aerolite 103** — getting started. One short script; the smallest illustration of the v1 shape.
- **Piper PA-18 Super Cub** — a simple piston single with logic split into small per-subsystem scripts (fuel, lights, vibration, transponder).
- **Cessna 172 SP** — more capable piston. Shows custom commands, override-datarefs, and several scripts cooperating via shared datarefs.
- **Airbus A330-300** — complex modern airliner. Large-scale system simulation across dozens of interacting scripts; a reference for how a full aircraft is structured.
