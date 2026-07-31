<h1>XPLM Data Access API</h1>
---

The data access API gives you a generic, flexible, high performance way to
read and write data to and from X-Plane and other plug-ins. For example,
this API allows you to read and set the nav radios, get the plane location,
determine the current effective graphics frame rate, etc.

The data access APIs are the way that you read and write data from the sim
as well as other plugins.

The API works using opaque data references. A data reference is a source of
data; you do not know where it comes from, but once you have it you can read
the data quickly and possibly write it.

Dataref Lookup
--------------

Data references are identified by verbose, permanent string names; by convention
these names use path separators to form a hierarchy of datarefs, e.g. (sim/cockpit/radios/nav1_freq_hz).
The actual opaque numeric value of the data reference, as returned by the XPLM
API, is implementation defined and changes each time X-Plane is launched; therefore
you need to look up the dataref by path every time your plugin runs.

The task of looking up a data reference is relatively expensive; look up your
data references once based on the verbose path strings, and save the opaque data
reference value for the duration of your plugin's operation. Reading and writing data
references is relatively fast (the cost is equivalent to two function calls
through function pointers).

X-Plane publishes many thousands of datarefs; a complete list may be found in the
reference section of the SDK online documentation (from the SDK home page, choose
Documentation) and the Resources/plugins/DataRefs.txt file.

Dataref Types
-------------

A note on typing: you must know the correct data type to read and write. APIs
are provided for reading and writing data in a number of ways. You can also
double check the data type for a dataref. Automatic type conversion is
not done for you.

Dataref types are a set, e.g. a dataref can be more than one type.  When this happens,
you can choose which API you want to use to read.  For example, it is not uncommon for
a dataref to be available both as float and double.  This means you can use either XPLMGetDatad or
XPLMGetDataf to read it.

Creating New Datarefs
---------------------

X-Plane provides datarefs that come with the sim, but plugins can also create their own
datarefs.  A plugin creates a dataref by registering function callbacks to read and write
the dataref.  The XPLM will call your plugin each time some other plugin (or X-Plane) tries
to read or write the dataref.  You must provide a read (and optional write) callback for
each data type you support.

A note for plugins sharing data with other plugins: the load order of plugins
is not guaranteed. To make sure that every plugin publishing data has published
their data references before other plugins try to subscribe, publish your
data references in your start routine but resolve others' datarefs the first time your 'enable'
routine is called, or the first time they are needed in code.

When a plugin that created a dataref is unloaded, it becomes "orphaned".  The dataref
handle continues to be usable, but the dataref is not writable, and reading it will always
return 0 (or 0 items for arrays).  If the plugin is reloaded and re-registers the dataref,
the handle becomes un-orphaned and works again.

Introspection: Finding All Datarefs
-----------------------------------

In the XPLM400 API, it is possible for a plugin to iterate the entire set of datarefs. This
functionality is meant only for "tool" add-ons, like dataref browsers; normally all add-ons
should find the dataref they want by name.

Because datarefs are never destroyed during a run of the simulator (they are orphaned when
their providing plugin goes away until a new one re-registers the dataref), the set of
datarefs for a given run of X-Plane can be enumerated by index. A plugin that wants to find
all new datarefs can use XPLMCountDataRefs to find the number of datarefs and iterate only
the ones with higher index numbers than the last iteration.

Plugins can also receive notifications when datarefs are registered; see the XPLMPlugin
feature-enable API for more details.



<!-- whitespace for navigation purposes -->
<div style="height:100vh;"></div>