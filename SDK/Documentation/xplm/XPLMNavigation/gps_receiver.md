<h1>Gps Receiver</h1>

These APIs let you read data from the GPS unit.

---

<div class="sym-block sym-function" data-name="XPLMGetGPSDestinationType" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetGPSDestinationType { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the type of the currently selected
GPS destination, one of fix, airport, VOR or NDB.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API XPLMNavType XPLMGetGPSDestinationType(void);
```

</div>

</div>

---

<div class="sym-block sym-function" data-name="XPLMGetGPSDestination" data-type="function" markdown="1">

<div class="sym-title-row" markdown="1">

## XPLMGetGPSDestination { .symbol-title }

<span class="sym-badge badge-fn">function</span>

</div>

This routine returns the current GPS destination.

<div class="xplm-code" markdown="1">

```cpp
XPLM_API XPLMNavRef XPLMGetGPSDestination(void);
```

</div>

</div>

---



<!-- whitespace for navigation purposes -->
<div class="page-spacer"></div>