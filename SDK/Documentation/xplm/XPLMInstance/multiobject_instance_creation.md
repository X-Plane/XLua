<h1>Multi-Object Instance Creation</h1>

Create an instance out of one or more objects with a single extensible call.

---

<div class="sym-block sym-enum" data-name="XPLMCoordinateSpace_t" data-type="enum" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCoordinateSpace_t { .symbol-title }

<span class="sym-badge badge-enum">enum</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

This enum defines the coordinate space used to interpret the positions of an instance created with
XPLMCreateInstanceEx(). By default, instances are in world space (the sim's global cartesian coordinate
system). You can instead place an instance relative to an aircraft - either its interior or its exterior -
or relative to the camera. Interior and exterior aircraft spaces use the same transform today; the
distinction lets X-Plane light the objects correctly in a future release.

<div class="enum-table" markdown="1">

| Name | Value | Description |
|:--|:--|:--|
| xplm_CoordSpace_World | 0 | Position is in global OGL/tangent-plane coordinates (default). |
| xplm_CoordSpace_AircraftInterior | 1 | Position is relative to an aircraft's CG and body axes (+X right wing, +Y up, +Z tail), for objects inside the cockpit/cabin. |
| xplm_CoordSpace_AircraftExterior | 2 | Position is relative to an aircraft's CG and body axes (+X right wing, +Y up, +Z tail), for objects mounted on the exterior. |
| xplm_CoordSpace_Camera | 3 | Position is relative to the camera/view position and orientation. |

</div>

**Used by:**

- [XPLMInstanceSetCoordinateSpace](instance_manipulation.md#xplminstancesetcoordinatespace)

</div>

---

<div class="sym-block sym-struct" data-name="XPLMInstanceObject_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMInstanceObject_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

XPLMInstanceObject_t describes a single object within a multi-object instance: the object itself plus a
fixed offset from the instance's origin. Every object in an instance moves rigidly together when you
reposition the instance with XPLMInstanceSetPosition; this offset places each object relative to that
shared origin and never changes after the instance is created.

<div class="xplm-code" markdown="1">

```cpp
typedef struct {
     XPLMObjectRef             object;
     float                     x;
     float                     y;
     float                     z;
     float                     pitch;
     float                     heading;
     float                     roll;
} XPLMInstanceObject_t;
```

</div>

<div class="field-table" markdown="1">

| Field | Type | Description |
|:--|:--|:--|
| object | XPLMObjectRef | A fully-loaded object to draw as part of the instance. |
| x | float | X offset from the instance origin, in instance-local coordinates. |
| y | float | Y offset from the instance origin, in instance-local coordinates. |
| z | float | Z offset from the instance origin, in instance-local coordinates. |
| pitch | float | Pitch of this object relative to the instance, in degrees, positive up. |
| heading | float | Heading of this object relative to the instance, in degrees, clockwise. |
| roll | float | Roll of this object relative to the instance, in degrees. |

</div>

</div>

---

<div class="sym-block sym-struct" data-name="XPLMCreateInstance_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCreateInstance_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

XPLMCreateInstance_t defines all of the parameters used to create an instance via XPLMCreateInstanceEx().
It is a strict superset of the older XPLMCreateInstance() call: it lets you build an instance out of more
than one object, choose the coordinate space, and enable auto-shift, all in a single call. The structure
will be expanded in future SDK versions to include more features. Always set the structSize member to the
size of your struct in bytes!

<div class="xplm-code" markdown="1">

```cpp
typedef struct {
     int                       structSize;
     const XPLMInstanceObject_t * objects;
     int                       objectCount;
     const char **             datarefs;
     XPLMCoordinateSpace_t     coordinateSpace;
     int                       aircraftIndex;
     int                       autoShift;
} XPLMCreateInstance_t;
```

</div>

<div class="field-table" markdown="1">

| Field | Type | Description |
|:--|:--|:--|
| structSize | int | Used to inform XPLMCreateInstanceEx() of the SDK version you compiled against; should always be set to sizeof(XPLMCreateInstance_t). |
| objects | const XPLMInstanceObject_t * | An array of objects (each with its own offset) that make up the instance. Must point to at least objectCount entries. |
| objectCount | int | The number of entries in the objects array. Must be at least 1. |
| datarefs | const char ** | A single NULL-terminated list of dataref identifiers shared by every object in the instance, exactly as in XPLMCreateInstance(). The data you later pass to XPLMInstanceSetPosition() fills one shared block for all objects. You cannot pass null for the array itself. |
| coordinateSpace | XPLMCoordinateSpace_t | The coordinate space in which instance positions are interpreted (see XPLMCoordinateSpace_t). Use xplm_CoordSpace_World for the classic behavior. |
| aircraftIndex | int | Aircraft index (0 = user aircraft). Only used when coordinateSpace is xplm_CoordSpace_AircraftInterior or xplm_CoordSpace_AircraftExterior. |
| autoShift | int | If non-zero, enables auto-shift (see XPLMInstanceSetAutoShift). Ignored for non-world coordinate spaces. |

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMCreateInstanceEx" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMCreateInstanceEx { .symbol-title }

<span class="sym-badge badge-fn">function</span> <span class="sym-badge badge-version">XPLM440</span>

</div>

XPLMCreateInstanceEx creates a new instance from one or more objects and returns a handle to it. It is a
strict superset of XPLMCreateInstance(): in addition to a single object, you can register several objects
that draw and move together as one rigid group, and you can choose the coordinate space and auto-shift
behavior up front in the same call.

The same requirements as XPLMCreateInstance() apply: every object must be fully loaded before you create
the instance, any custom datarefs your objects use must be registered before the objects are loaded, and
the dataref list must be a valid pointer to a NULL-terminated array. The dataref list is shared by all
objects in the instance.

The set of objects is fixed when the instance is created; you cannot add or remove objects later. Destroy
the instance with XPLMDestroyInstance() exactly as for an instance made with XPLMCreateInstance().

<div class="xplm-code" markdown="1">

```cpp
XPLM_API XPLMInstanceRef XPLMCreateInstanceEx(
                         const XPLMCreateInstance_t * inParams
                    );
```

</div>


**See associated types:**

- [XPLMCreateInstance_t](#xplmcreateinstance_t)
</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>