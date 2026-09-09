<h1>General Utilities</h1>

---

<div class="sym-block sym-struct" data-name="XPWidgetCreate_t" data-type="struct" markdown="1">

<div class="sym-title-row" markdown="1">

## XPWidgetCreate_t { .symbol-title }

<span class="sym-badge badge-struct">struct</span>

</div>

This structure contains all of the parameters needed to create a widget.
It is used with XPUCreateWidgets to create widgets in bulk from an
array. All parameters correspond to those of XPCreateWidget except for
the container index.

If the container index is equal to the index of a widget in the array,
the widget in the array passed to XPUCreateWidgets is used as the parent
of this widget. Note that if you pass an index greater than your own
position in the array, the parent you are requesting will not exist yet.

If the container index is NO_PARENT, the parent widget is specified as NULL.
If the container index is PARAM_PARENT, the widget passed into XPUCreateWidgets
is used.

<div class="xplm-code" markdown="1">

```cpp
typedef struct {
     int                       left;
     int                       top;
     int                       right;
     int                       bottom;
     int                       visible;
     const char *              descriptor;
     int                       isRoot;
     int                       containerIndex;
     XPWidgetClass             widgetClass;
} XPWidgetCreate_t;
```

</div>

<div class="field-table" markdown="1">

| Field | Type | Description |
|:--|:--|:--|
| left | int |  |
| top | int |  |
| right | int |  |
| bottom | int |  |
| visible | int |  |
| descriptor | const char * |  |
| isRoot | int | Whether this widget is a root widget |
| containerIndex | int | The index of the widget to be contained within, or a constant |
| widgetClass | XPWidgetClass |  |

</div>

</div>

---

<div class="sym-block sym-define" data-name="NO_PARENT" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## NO_PARENT { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define NO_PARENT -1`

</div>

</div>

---

<div class="sym-block sym-define" data-name="PARAM_PARENT" data-type="define" markdown="1">

<div class="sym-title-row" markdown="1">

## PARAM_PARENT { .symbol-title }

<span class="sym-badge badge-define">define</span>

</div>

<div class="xplm-code" markdown="1">

`#define PARAM_PARENT -2`

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPUCreateWidgets" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPUCreateWidgets { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This function creates a series of widgets from a table (see XPCreateWidget_t
above). Pass in an array of widget creation structures and an array of widget IDs
that will receive each widget.

Widget parents are specified by index into the created widget table, allowing
you to create nested widget structures. You can create multiple widget trees
in one table. Generally you should create widget trees from the top down.

You can also pass in a widget ID that will be used when the widget's parent
is listed as PARAM_PARENT; this allows you to embed widgets created with
XPUCreateWidgets in a widget created previously.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPUCreateWidgets(
                         const XPWidgetCreate_t * inWidgetDefs,
                         int                  inCount,
                         XPWidgetID           inParamParent,
                         XPWidgetID *         ioWidgets
                    );
```

</div>


**See associated types:**

- [XPWidgetCreate_t](#xpwidgetcreate_t)
</div>

---

<div class="sym-block sym-function" data-name="XPUMoveWidgetBy" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPUMoveWidgetBy { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

Simply moves a widget by an amount, +x = right, +y = up, without resizing the widget.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API void XPUMoveWidgetBy(
                         XPWidgetID           inWidget,
                         int                  inDeltaX,
                         int                  inDeltaY
                    );
```

</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>