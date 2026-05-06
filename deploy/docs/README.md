# XLua

XLua is an X-Plane plugin that embeds a Lua runtime so aircraft authors can attach logic to an aircraft without building a native C or C++ plugin. System simulation, panel animation, custom datarefs, and custom key-bindable commands are all reachable from a script file that ships inside the aircraft folder.

Two versions of the scripting surface are supported:

- **XLua 1.x** — the original syntax. See [`xlua1-syntax.md`](xlua1-syntax.md).
- **XLua 2.0** — the current syntax. See [`xlua2-syntax.md`](xlua2-syntax.md).

The two surfaces are not source-compatible. This document covers the structure and lifecycle common to both; the per-version files cover the spellings. If you are moving an existing script from one version to the other, see [`migrating-v1-to-v2.md`](migrating-v1-to-v2.md).

The underlying runtime is Lua 5.1 via LuaJIT, on all platforms and in every syntax version.

## Where scripts live

XLua is loaded per aircraft. For every aircraft that wants scripted logic, XLua expects this layout:

```
<aircraft folder>/
    plugins/
        xlua/
            init.lua          -- Lua-side setup for the plugin. Should rarely be modified.
            scripts/
                <name>/
                    <name>.lua
                <other_name>/
                    <other_name>.lua
```

Each subfolder under `scripts/` corresponds to one independent, auto-loaded Lua module — its **master script**. **The folder name and the `.lua` filename inside it must match.** If an aircraft needs its scripted logic split across several independent modules, each gets its own folder.

Beyond the master scripts, a script is free to pull in additional Lua files using Lua's standard `require`, either from the same folder or from another location reachable via Lua's module search path. These helper files are not master scripts themselves; they are ordinary Lua modules pulled in at the master script's request.

**A helper inherits the syntax version of the master script that `require`s it.** You cannot `require` a helper written in XLua 1 syntax from a master script written in XLua 2, or vice versa — the helper runs inside the master's environment and has to match it. Shared helpers pulled in by multiple master scripts must therefore all be written to the same syntax version as their callers.

## Loading and isolation

Each master script file is loaded as its own Lua chunk in its own environment. Scripts do **not** share global state with each other, even when they live in the same aircraft. Communication between scripts — and between XLua scripts and the rest of the sim — happens through two X-Plane primitives: **datarefs** and **commands**.

A script is loaded when the aircraft is loaded, and unloaded when the aircraft is unloaded. Depending on configuration, a script may also be reloaded when the user starts a new flight. Whether that happens automatically or has to be opted into is version-specific; see the per-version files.

## Lifecycle events

A script sees the following lifecycle, in roughly this order. The bullets below name each concept neutrally; the spelling — which functions to define, what entry points to register, which callback signatures to use — is in the per-version files.

- **Script load** — the chunk runs once. Use this to look up datarefs and commands, register custom ones, and install any per-frame or per-flight handlers.
- **Plugin enable / disable** — the script is given the chance to arm and disarm its handlers around a period of active flying.
- **Aircraft load** — fired when the simulator finishes loading the aircraft's files and is ready to fly.
- **Flight start** — fired whenever a new flight begins (user selected a new location, aircraft, or situation). Use this to set initial state.
- **Per-frame physics tick** — fires every frame, both before and after the flight model integrates.
- **Replay** — X-Plane's replay mode keeps the flight model paused and drives the aircraft from recorded state. A script can arrange to run logic - or, more commonly, not run logic - during replay.
- **Aircraft unload** — last chance to clean up before the aircraft goes away.

A script is only required to implement the callbacks it cares about. Unused callbacks can be omitted entirely.

## Interacting with X-Plane: the two primitives

Nearly every script is built on two building blocks. Neither is specific to XLua — they are how every X-Plane plugin talks to the sim.

### Datarefs

A **dataref** is a named, typed value the sim publishes. Examples: the aircraft's indicated airspeed, the state of the battery master switch, the position of the flaps handle. Datarefs are identified by a path-like string such as `sim/cockpit2/electrical/battery_on[0]`. Each has a type (number, integer array, float array, byte block / string) and may be read-only or writable. Plugins can also publish their own datarefs so their state is visible to other plugins, the instrument panel, or X-Plane's animation system.

A script typically looks up its datarefs once at load time and reuses the resulting handles for the life of the script. Reading or writing is cheap; looking up by string is comparatively expensive.

The catalogue of datarefs published by X-Plane ships with the sim at `Resources/plugins/DataRefs.txt` and is documented at <https://developer.x-plane.com/datarefs/>.

### Commands

A **command** is a named, invokable action. Examples: `sim/magnetos/magnetos_up_1`, `sim/starters/engage_starter_1`. X-Plane publishes thousands of built-in commands, and plugins and scripts can publish their own.

**The same command can be triggered from many sources.** A keyboard shortcut, a click on a cockpit panel hot spot, a button or axis on a joystick or yoke, a USB hardware device (radio panels, throttle quadrants, switch panels), a VR controller action, another plugin, or another Lua script — all of these funnel into the same command and look identical to anything handling it. A script that registers logic against a command does not need to — and cannot — tell one trigger source from another. This is what makes commands the right way to expose any user-actionable behaviour: attach the logic to a command once, and every input path the user has configured triggers it for free.

A command has three phases: **begin** (the trigger fires), **continue** (the trigger is held), and **end** (the trigger is released). A script can:

- invoke a built-in command (fire a magneto up, raise the gear);
- create its own command for custom cockpit logic; and
- intercept an existing command to replace, wrap, or filter its behaviour.

As with datarefs, lookup is done once and the handle is reused.

## Custom datarefs and custom commands

Most non-trivial aircraft scripts create their own datarefs and commands in addition to consuming the built-in ones.

**Custom datarefs** are the normal way to expose a script-computed value to other parts of the aircraft. A smoothly animated needle, a knob position, a custom "autopilot is armed" flag — the script computes the value each frame and writes it into its dataref. The instrument panel and `.obj` animations read the same dataref by name, with no need to know anything about Lua.

**Custom commands** are how a script exposes a button or switch action in a way the user can rebind. Rather than hard-wiring a keystroke to Lua behaviour, the script creates a command with a stable path (for example `laminar/c172/ignition_up`) and installs a handler. The user — or a panel click spot — can then trigger that command from anywhere.

## Timed and per-frame work

Scripts commonly need to run a piece of logic on a schedule: animate a needle, time out a warning, run a periodic check. Every version provides a mechanism for this; the spelling is covered in the per-version files.

If a script needs to run every frame, the idiomatic answer is always a per-frame / flight-loop callback rather than a self-rescheduling timer.

## Initialisation and cleanup

Setup and teardown follow the same shape in every syntax version. The rule is simple: do one-off work once, from the appropriate lifecycle callback for the version you are using; do per-frame work per frame. The per-version documents name the exact callbacks to use for each stage.

**Look up references once, at initialisation.** Looking up a dataref or command by its string name is comparatively expensive, and the returned handle does not change over the life of the script. Do the lookup at script or aircraft load and keep the result in a local or script-level variable for reuse. Never look up by string inside a per-frame callback.

**Create assets once, at initialisation.** Custom datarefs, custom commands, command handlers installed on built-in commands, flight loops, menus — anything the script registers with the runtime — should be created during the same initialisation step as the lookups above. Never create them inside a per-frame callback.

**Release every asset the script created, at shutdown.** If the script registered it, the script must tear it down: custom datarefs unregistered, custom commands destroyed, installed command handlers unregistered, flight loops destroyed. This is not optional. X-Plane does try to clean up any abandoned assets but this can still leave the sim in a state that only a full restart clears, or cause runtime crashes.

**Clear overrides too.** If the script set a `sim/operation/override/*` dataref to take control of a sim behaviour, clear it again at shutdown so the sim resumes normal operation. The override is not an asset the script "owns", but it has the same lifecycle rule. You should almost certainly clear override for the disable stage and re-enable them in the enable stage, so that if the script or entire plugin is disabled, your overridden behaviour does not remain in place.

Dataref and command *lookups* do not need to be released — those handles are owned by the runtime, not by the script. Only things the script explicitly *created* need explicit teardown.

## Debugging

**`Log.txt` is the first place to look for anything a script does or gets wrong.** Scripts share X-Plane's main log file — there is no separate Lua log and no runtime call to arrange. Anything a script passes to Lua's standard **`print()`** appears in `Log.txt` with a timestamp and an `I/LUA` tag:

```
0:01:05.103 I/LUA: Running scripts/A333.math/A333.math.lua
0:01:05.103 I/LUA: Running scripts/A333.sound/A333.sound.lua
0:01:05.103 I/LUA: Running scripts/A333.switches/A333.switches.lua
0:01:05.103 I/LUA: Running scripts/A333.systems/A333.systems.lua
```

Uncaught Lua errors and exceptions — a nil indexed as a table, a bad argument to a runtime call, a syntax error at script load — are logged the same way, with the error message and any available traceback tagged `I/LUA`. A script that is misbehaving will almost always have left an explanation in `Log.txt`; check there before anywhere else.

`print()` is the primary debugging tool — reach for it first. For stack context at an error site, use Lua's standard **`debug.traceback()`**; a typical idiom inside an error handler is `print(debug.traceback())`.

The standard workflow for diagnosing a script problem is to watch `Log.txt` live while working on the aircraft. On macOS and Linux:

```
tail -f "<X-Plane folder>/Log.txt"
```

On Windows, PowerShell's `Get-Content -Wait -Tail 200 Log.txt` does the same job. Whichever tool you use, the principle is the same: keep the log in view, reload the aircraft or exercise the script, and the error — with its trace — will appear inline with the rest of the sim's output.

Lua's standard `pcall` is available if a script needs to catch an error itself rather than let it propagate to the runtime — for example, when loading an optional file that may not exist.

Other debugging approaches are possible. In particular, **XLua 1.5 and later** make **Dear ImGui** available to scripts, which can be used to build interactive debug windows (live variable inspectors, button-driven state tweaks, and so on). Building those is out of scope for this document.

**StackTracePlus** (<https://github.com/ignacio/StackTracePlus>) is an optional third-party library that produces richer traces than the stock `debug.traceback`. To enable it, drop `StackTracePlus.lua` next to the runtime's `init.lua` and uncomment the short activation block at the top of that file.

## LuaJIT tuning

XLua runs on LuaJIT. The compiler's default parameters are tuned for the kind of scripts that typically ship with X-Plane and **as a rule should be left alone**.

Two known exceptions:

- **Extremely large scripts** (for example the ones that ship with the Airbus A330) are currently known to cause problems on macOS. The LuaJIT base parameters can be adjusted in that case; the procedure and the specific knobs to turn are documented in the header comment at the top of `init.lua`. This doc does not duplicate that — follow the instructions there. (The A330 ships with a customised init.lua script).
- **General performance problems on one unsupported Linux distribution** are believed to trace back to LuaJIT. If you are seeing unexplained slowness on Linux and your distribution is not in X-Plane's supported list, that is a likely culprit.

Unless one of the above applies, leave LuaJIT parameters at their defaults.

## Files that ship with XLua

The XLua deployment tree contains four things a script author may care about:

- **`init.lua`** — the XLua bootstrap file. Auto-loaded before any user script runs; exposes the helpers each syntax version needs.
- **`scripts/`** — where the user's own scripts live when XLua is deployed as a standalone plugin (outside an aircraft). See `scripts/README.txt` for the placement rule; it is the same one described under *Where scripts live* above.
- **`example_scripts/`** — runnable reference scripts. Which version each example targets is noted inside the example itself.
- **`include/`** — per-module documentation stubs auto-generated from the SDK headers. **New in XLua 2 and not relevant to XLua 1** — these describe the X-Plane Plugin Manager (XPLM) API that XLua 2 scripts call directly. See [`xlua2-syntax.md`](xlua2-syntax.md) for how they are used.
- **`docs/`** — Quick-reference documentation about the plugin in general, XLua 1 vs. XLua 2 syntax, and migration from XLua 1 to XLua 2.

## Gotchas

Short points that apply across every syntax version. The per-version documents note anything version-specific.

- **Command begin must be matched by exactly one command end.** Whenever a script invokes the *begin* phase of a command, it is responsible for later invoking the matching *end* phase exactly once. A missing end leaves the command stuck in its held state (the sim keeps treating the button as held down). This applies whether the begin was issued by the script itself or by the runtime delivering a user input to a handler the script wrapped.
- **Calls into the simulator are relatively expensive — avoid unnecessary ones.** Reading or writing a dataref, invoking a command, or calling any other runtime function crosses from Lua into the sim and back; each call carries a fixed overhead that dwarfs plain Lua work. XLua 1 is especially sensitive — its dataref proxies turn what *looks* like a variable access into a sim call on every read and every write. If you need a dataref's value more than once in a block of logic (a loop, a chain of comparisons, a formula), read it into a plain local variable once and use the local inside the block. The same rule applies to anything you would otherwise call repeatedly with the same result.
- **Strip debug logging before releasing a script.** `print()` is cheap to write and essential while developing, but the log is shared across the whole sim and `Log.txt` is the first place every other developer looks when something goes wrong. Some third-party aircraft have left verbose per-frame or per-tick logging enabled, producing log files with millions of lines of Lua output that bury real problems. Before a release build, remove or gate any per-frame `print()`; reserve logging for one-off events (load, unload, unexpected state) that a user or another developer would actually want to see.
- **Register custom datarefs or commands with a suitable prefix.** A suitable one might be your company name; don't register anything that starts with `sim/`, `private/`, `laminar/` etc.
- **Timed events need care.** If you create a timed event, always check that the event is still valid when the timer fires - for example, you don't want to fire "doors open" logic if the user has re-spawned the aircraft airborne. Kill off any pending timers during disable, respawn and similar events. Also note that if the user enables "AI Flies your aircraft", certain things especially engine start and boarding/servicing phases are managed by X-Plane's internal simulation. If your script overrides these it can cause these events to become stuck. You can detect if this is the case with the "sim/operation/prefs/ai_flies_aircraft" dataref.

## Choosing a syntax version

For any new aircraft, use the latest supported syntax version. Older syntax versions remain supported so existing aircraft continue to work without modification, and there is no obligation to update a working script just because a new syntax version has appeared.

If you do choose to update an older script to a newer syntax version, see the migration guide(s) — currently [`migrating-v1-to-v2.md`](migrating-v1-to-v2.md).

## Further reading

- [`xlua1-syntax.md`](xlua1-syntax.md) — reference for the XLua 1.x surface.
- [`xlua2-syntax.md`](xlua2-syntax.md) — reference for the XLua 2.0 surface.
- [`migrating-v1-to-v2.md`](migrating-v1-to-v2.md) — rules for translating XLua 1 scripts to XLua 2.
- [`../init.lua`](../init.lua) — `init.lua` itself; the authoritative source for what each version exposes.
- [`../example_scripts/`](../example_scripts/) — runnable reference scripts.
- <https://developer.x-plane.com/sdk/> — the X-Plane SDK documentation site, including the XPLM C API reference.
- <https://developer.x-plane.com/datarefs/> — searchable catalogue of built-in datarefs.
