<h1>X-Plane Command Management</h1>

The command management APIs let plugins interact with the command-system in X-Plane, the abstraction behind
keyboard presses and joystick buttons. This API lets you create new commands and modify the behavior (or get
notification) of existing ones.

X-Plane Command Phases
----------------------

X-Plane commands are not instantaneous; they operate over a duration. (Think of a joystick button press - you
can press, hold down, and then release the joystick button; X-Plane commands model this entire process.)

An X-Plane command consists of three phases: a beginning, continuous repetition, and an ending. The command
may be repeated zero times in its duration, followed by one command ending. Command begin and end messges are
balanced, but a command may be bound to more than one event source (e.g. a keyboard key and a joystick button),
in which case you may receive a second begin during before any end).

When you issue commands in the plugin system, you *must* balance every call to XPLMCommandBegin with a call
to XPLMCommandEnd with the same command reference.

Command Behavior Modification
-----------------------------

You can register a callback to handle a command either before or after X-Plane does; if you receive the command
before X-Plane you have the option to either let X-Plane handle the command or hide the command from X-Plane.
This lets plugins both augment commands and replace them.

If you register for an existing command, be sure that you are *consistent* in letting X-Plane handle or not handle
the command; you are responsible for passing a *balanced* number of begin and end messages to X-Plane. (E.g. it
is not legal to pass all the begin messages to X-Plane but hide all the end messages).

---

<div class="sym-block sym-enum" data-name="XPLMCommandPhase" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCommandPhase { .symbol-title }

<span class="sym-badge badge-enum">enum</span>

</div>

The phases of a command.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_CommandBegin | 0 | The command is being started. |
| xplm_CommandContinue | 1 | The command is continuing to execute. |
| xplm_CommandEnd | 2 | The command has ended. |

</div>

**Used by:**

- [XPLMCommandCallback_f](#xplmcommandcallback_f)

</div>

---

<div class="sym-block sym-typedef" data-name="XPLMCommandRef" data-type="typedef" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCommandRef { .symbol-title }

<span class="sym-badge badge-typedef">typedef</span>

</div>

A command ref is an opaque identifier for an X-Plane command. Command references stay the same for the
life of your plugin but not between executions of X-Plane. Command refs are used to execute commands, create
commands, and create callbacks for particular commands.

Note that a command is not "owned" by a particular plugin. Since many plugins may participate in a
command's execution, the command does not go away if the plugin that created it is unloaded.

<div class="xplm-code" markdown="1">

```cpp
typedef void * XPLMCommandRef;
```

</div>


**Used by:**

- [XPLMCommandBegin](#xplmcommandbegin)
- [XPLMCommandCallback_f](#xplmcommandcallback_f)
- [XPLMCommandEnd](#xplmcommandend)
- [XPLMCommandOnce](#xplmcommandonce)
- [XPLMRegisterCommandHandler](#xplmregistercommandhandler)
- [XPLMUnregisterCommandHandler](#xplmunregistercommandhandler)
</div>

---

<div class="sym-block sym-callback" data-name="XPLMCommandCallback_f" data-type="callback" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCommandCallback_f { .symbol-title }

<span class="sym-badge badge-cb">callback</span>

</div>

A command callback is a function in your plugin that is called when a command is pressed. Your callback
receives the command reference for the particular command, the phase of the command that is executing, and a
reference pointer that you specify when registering the callback.

Your command handler should return true to let processing of the command continue to other plugins and
X-Plane, or false to halt processing, potentially bypassing X-Plane code.

<div class="xplm-code" markdown="1">

```cpp
typedef int (* XPLMCommandCallback_f)(
                         XPLMCommandRef       inCommand,
                         XPLMCommandPhase     inPhase,
                         void*                inRefcon
                    );
```

</div>


**See associated types:**

- [XPLMCommandPhase](#xplmcommandphase)
- [XPLMCommandRef](#xplmcommandref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMFindCommand" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMFindCommand { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

XPLMFindCommand looks up a command by name, and returns its command reference or NULL if the command
does not exist.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API XPLMCommandRef XPLMFindCommand(
                         const char *         inName
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMCommandBegin" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCommandBegin { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

XPLMCommandBegin starts the execution of a command, specified by its command reference. The command is
"held down" until XPLMCommandEnd is called.  You must balance each XPLMCommandBegin call with an XPLMCommandEnd
call.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMCommandBegin(
                         XPLMCommandRef       inCommand
                    );
```

</div>


**See associated types:**

- [XPLMCommandRef](#xplmcommandref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMCommandEnd" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCommandEnd { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

XPLMCommandEnd ends the execution of a given command that was started with XPLMCommandBegin.  You must not
issue XPLMCommandEnd for a command you did not begin.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMCommandEnd(
                         XPLMCommandRef       inCommand
                    );
```

</div>


**See associated types:**

- [XPLMCommandRef](#xplmcommandref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMCommandOnce" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCommandOnce { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This executes a given command momentarily, that is, the command begins and ends immediately. This is the
equivalent of calling XPLMCommandBegin() and XPLMCommandEnd() back to back.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMCommandOnce(
                         XPLMCommandRef       inCommand
                    );
```

</div>


**See associated types:**

- [XPLMCommandRef](#xplmcommandref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMCreateCommand" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCreateCommand { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

XPLMCreateCommand creates a new command for a given string. If the command already exists, the
existing command reference is returned. The description may appear in user interface contexts, such
as the joystick configuration screen.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API XPLMCommandRef XPLMCreateCommand(
                         const char *         inName,
                         const char *         inDescription
                    );
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMRegisterCommandHandler" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMRegisterCommandHandler { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

XPLMRegisterCommandHandler registers a callback to be called when a command is executed. You provide
a callback with a reference pointer.

If inBefore is true, your command handler callback will be executed before X-Plane executes the command,
and returning 0 from your callback will disable X-Plane's processing of the command. If inBefore is
false, your callback will run after X-Plane. (You can register a single callback both before and after
a command.)

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMRegisterCommandHandler(
                         XPLMCommandRef       inComand,
                         XPLMCommandCallback_f inHandler,
                         int                  inBefore,
                         void*                inRefcon
                    );
```

</div>


**See associated types:**

- [XPLMCommandCallback_f](#xplmcommandcallback_f)
- [XPLMCommandRef](#xplmcommandref)
</div>

---

<div class="sym-block sym-function" data-name="XPLMUnregisterCommandHandler" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMUnregisterCommandHandler { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

XPLMUnregisterCommandHandler removes a command callback registered with XPLMRegisterCommandHandler.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPLMUnregisterCommandHandler(
                         XPLMCommandRef       inComand,
                         XPLMCommandCallback_f inHandler,
                         int                  inBefore,
                         void*                inRefcon
                    );
```

</div>


**See associated types:**

- [XPLMCommandCallback_f](#xplmcommandcallback_f)
- [XPLMCommandRef](#xplmcommandref)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>