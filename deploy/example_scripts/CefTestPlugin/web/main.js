// CEF Test Plugin SPA driver.
//
// The host plugin registers a set of `xplane.*` JS-callable functions and a
// matching set of XPLMCommandRefs. Each tab below either calls one or more of
// the bridge functions directly (testing the JS->C path) or fires a host
// command (testing the C->JS path: SetURL, Refresh, InjectScript).
//
// PASS criteria are explicit per tab. The host's navigation callback injects
// __cef_nav__(url, success, error) into the page so we can observe nav events
// from JS.

(function() {
"use strict";

// ---- Tab definitions -------------------------------------------------------

const tabs = [
    {
        id: "hello",
        label: "1. file:// load",
        autorun: true,
        run: ctx => {
            // Initial nav was the load that brought us here. The host fires
            // __cef_nav__ on every successful navigation. Treat receiving it
            // for our own URL as the pass condition.
            return new Promise(resolve => {
                if (ctx.firstNavSeen) return resolve({ ok: true, info: "already navigated" });
                ctx.onceFirstNav = () => resolve({ ok: true, info: "navigation completed" });
                setTimeout(() => resolve({ ok: ctx.firstNavSeen, info: ctx.firstNavSeen ? "got it late" : "timed out" }), 2000);
            });
        }
    },
    {
        id: "switch_url",
        label: "2. switch URL",
        autorun: false,
        run: ctx => xplane.echo("switch URL test ready").then(s => ({
            ok: s === "switch URL test ready",
            info: "Click 'Load page2 from C' below. Use the back button on page2 to return.",
            value: s
        }))
    },
    {
        id: "online",
        label: "3. Online (developer.x-plane.com)",
        autorun: false,
        run: ctx => xplane.echo("online test ready").then(s => ({
            ok: true,
            info: "Click 'Load online from C' below. Page navigates to developer.x-plane.com. Use Back to return.",
            value: s
        }))
    },
    {
        id: "bad_url",
        label: "4. Bad URL → nav-failure",
        autorun: false,
        run: ctx => xplane.echo("bad URL test ready").then(() => ({
            ok: true,
            info: "Click 'Load bad URL from C' below. The navigation-failure callback should fire and append a 'nav-fail' entry to the log."
        }))
    },
    {
        id: "refresh",
        label: "5. Refresh ±cache",
        autorun: false,
        run: () => Promise.resolve({
            ok: true,
            info: "Buttons below trigger XPLMWindowRefresh with cache on/off. Each refresh reloads the SPA from scratch; verify the page-load timestamp in the log changes."
        })
    },
    {
        id: "inject_dom",
        label: "6. InjectScript: DOM",
        autorun: false,
        run: ctx => {
            // Set up a listener that the C-injected script will trigger.
            return new Promise(resolve => {
                window.__inject_dom_seen__ = (msg) => resolve({ ok: true, info: "Inject ran: " + msg, value: msg });
                setTimeout(() => resolve({ ok: !!window.__inject_dom_marker__, info: window.__inject_dom_marker__ ? "marker present" : "no inject seen yet — click button" }), 100);
            });
        }
    },
    {
        id: "inject_bridge",
        label: "7. InjectScript: bridge call",
        autorun: false,
        // Mirror tab 6's pattern: the C-side inject stashes a marker AND
        // optionally calls the result fn, so both orderings work:
        //   button-first: marker is set, Run sees it and PASSes immediately
        //   Run-first:    callback fires within 100ms, Run resolves PASS
        run: () => new Promise(resolve => {
            if (window.__inject_bridge_marker__ !== undefined) {
                return resolve({ ok: true, info: "Inject already ran", value: window.__inject_bridge_marker__ });
            }
            window.__inject_bridge_result__ = (s) => resolve({ ok: typeof s === "string", info: "Bridge result delivered to JS: " + s, value: s });
            setTimeout(() => resolve({ ok: !!window.__inject_bridge_marker__, info: window.__inject_bridge_marker__ ? "marker present" : "no inject seen yet — click button" }), 100);
        })
    },
    {
        id: "echo_json",
        label: "8. JS→C echo + JSON",
        autorun: true,
        run: async () => {
            // The bridge auto-JSON-parses C return values, so we receive native
            // JS types directly — no JSON.parse on the JS side.
            const s1 = await xplane.echo("hello world");
            if (s1 !== "hello world") return { ok: false, info: "echo mismatch", value: s1 };
            const s2 = await xplane.uppercase("hello");
            if (s2 !== "HELLO") return { ok: false, info: "uppercase mismatch", value: s2 };
            const r = await xplane.add({ a: 7, b: 35 });
            if (!r || r.sum !== 42) return { ok: false, info: "add result wrong", value: r };
            return { ok: true, value: { echo: s1, upper: s2, add: r } };
        }
    },
    {
        id: "unicode",
        label: "9. Unicode round-trip",
        autorun: true,
        run: async () => {
            const samples = ["héllo", "日本語", "العربية", "🚀✈️🌍", "mixed: αβγ + 漢字 + 🎉"];
            const results = [];
            for (const s of samples) {
                const obj = await xplane.unicode(s);
                results.push({ in: s, out: obj.s, byteLen: obj.byte_len });
                if (obj.s !== s) return { ok: false, info: "round-trip differs for: " + s, value: obj };
            }
            return { ok: true, value: results };
        }
    },
    {
        id: "bigarray",
        label: "10. Large payload (~100 KB)",
        autorun: true,
        run: async () => {
            const N = 5000;
            const arr = [];
            for (let i = 0; i < N; ++i) arr.push(i);
            const json_in_size = JSON.stringify(arr).length;
            const obj = await xplane.bigarray(arr);
            const ok = obj && obj.len === N && obj.first === 0 && obj.last === N - 1;
            return {
                ok,
                info: ok ? "Round-tripped " + json_in_size + " bytes." : "Mismatch.",
                value: obj
            };
        }
    },
    {
        id: "refcon",
        label: "11. refcon discrimination",
        autorun: true,
        run: async () => {
            const a = await xplane.refcon_a();
            const b = await xplane.refcon_b();
            const c = await xplane.refcon_c();
            const ok = a && b && c && a.refcon === 1 && b.refcon === 2 && c.refcon === 3;
            return { ok, value: { a, b, c } };
        }
    },
    {
        id: "errors",
        label: "12. Error paths",
        autorun: true,
        run: async () => {
            const results = {};
            // 12.1: send malformed input to xplane.add — C should return {error:...}
            results.bad_json = await xplane.add("not json at all");

            // 12.2: xplane.bad_json always returns a fixed error object regardless of input
            results.fixed_error = await xplane.bad_json("anything");

            // 12.3: xplane.null_return — the API requires a XPLMReturnString-allocated
            // pointer; returning nullptr triggers a plugin assert that crashes the host.
            // The C-side stub returns a documentation object instead.
            try {
                const r3 = await xplane.null_return("input");
                results.null_return = { resolved: true, value: r3, type: typeof r3 };
            } catch (e) {
                results.null_return = { resolved: false, error: String(e) };
            }

            // 12.4: invoke an unregistered function name
            try {
                const r4 = await xplane.does_not_exist("x");
                results.unregistered = { resolved: true, value: r4 };
            } catch (e) {
                results.unregistered = { resolved: false, error: String(e) };
            }

            return { ok: true, info: "Documents what JS sees on each error path.", value: results };
        }
    },
    {
        id: "two_windows",
        label: "13. Two CEF windows",
        autorun: false,
        run: async () => {
            const obj = await xplane.window_id();
            return {
                ok: true,
                info: "This window's id: " + obj.id + ". Click 'Spawn 2nd window' to open another. The two windows should report different ids when each runs the test.",
                value: obj
            };
        }
    },
    {
        id: "destroy_mid_load",
        label: "14. Destroy mid-load",
        autorun: false,
        run: () => Promise.resolve({
            ok: true,
            info: "Click 'Destroy mid-load'. Host will spawn a third window pointing at slow.html, then immediately destroy it. Pass = no crash, this window remains responsive."
        })
    },
    {
        id: "js_alert",
        label: "15. JS alert() / confirm() / prompt()",
        autorun: false,
        // PASS criterion: at least one dialog has been triggered and dismissed.
        // The window/SPA having survived the dismissal is implied — if we got
        // here to read this, JS is alive on the post-dismiss page.
        run: () => new Promise(resolve => {
            if (window.__js_dialog_results__) {
                return resolve({ ok: true, info: "Dialogs dismissed cleanly; SPA still responsive", value: window.__js_dialog_results__ });
            }
            resolve({ ok: false, info: "Click one of the dialog buttons below and dismiss the dialog, then Re-run." });
        })
    }
];

// ---- DOM scaffolding -------------------------------------------------------

const ctx = { firstNavSeen: false, onceFirstNav: null, hostCommands: [] };
const sidebar = document.getElementById("sidebar");
const panel   = document.getElementById("panel");
const logEl   = document.getElementById("log");
let active = null;

function logEntry(cls, text) {
    const div = document.createElement("div");
    div.className = "entry " + cls;
    const ts = new Date().toLocaleTimeString();
    div.innerHTML = '<span class="ts">[' + ts + ']</span> ' + text;
    logEl.insertBefore(div, logEl.firstChild);
    while (logEl.children.length > 100) logEl.removeChild(logEl.lastChild);
}

function recomputePills() {
    let p = 0, f = 0, n = 0;
    for (const t of tabs) {
        if (t.status === "pass") ++p;
        else if (t.status === "fail") ++f;
        else ++n;
    }
    document.getElementById("pass-pill").textContent = p + " PASS";
    document.getElementById("fail-pill").textContent = f + " FAIL";
    document.getElementById("pending-pill").textContent = n + " PENDING";
}

function setStatus(tab, status) {
    tab.status = status;
    const btn = document.querySelector('.tab-button[data-tab="' + tab.id + '"]');
    if (btn) {
        const dot = btn.querySelector(".status-dot");
        dot.className = "status-dot " + (status === "pass" || status === "fail" || status === "running" ? status : "");
    }
    recomputePills();
}

function showResult(tab, res) {
    const pre = document.querySelector('#panel-' + tab.id + ' pre.result');
    if (!pre) return;
    pre.classList.remove("pass", "fail");
    pre.classList.add(res.ok ? "pass" : "fail");
    const head = (res.ok ? "PASS — " : "FAIL — ") + (res.info || "");
    const body = res.value !== undefined ? JSON.stringify(res.value, null, 2) : "";
    pre.textContent = head + (body ? "\n\n" + body : "");
    setStatus(tab, res.ok ? "pass" : "fail");
    // Mirror to plugin so state survives SPA reloads.
    if (window.xplane && window.xplane.report_status) {
        window.xplane.report_status({ tab_id: tab.id, result: res }).catch(() => {});
    }
}

async function runTab(tab) {
    setStatus(tab, "running");
    try {
        const res = await tab.run(ctx);
        showResult(tab, res);
    } catch (e) {
        showResult(tab, { ok: false, info: "Exception: " + (e && e.message ? e.message : String(e)) });
    }
}

function buildSidebar() {
    for (const tab of tabs) {
        const tpl = document.getElementById("tab-template").content.cloneNode(true);
        const btn = tpl.querySelector(".tab-button");
        btn.dataset.tab = tab.id;
        btn.querySelector(".label").textContent = tab.label;
        btn.addEventListener("click", () => activate(tab.id));
        sidebar.appendChild(btn);
    }
}

function buildPanels() {
    for (const tab of tabs) {
        const div = document.createElement("div");
        div.className = "panel-content";
        div.id = "panel-" + tab.id;

        const h2 = document.createElement("h2");
        h2.textContent = tab.label;
        div.appendChild(h2);

        // Per-tab control buttons. Tabs that need C-side actions get extra buttons.
        const ctrlsHtml = perTabControls(tab.id);
        if (ctrlsHtml) {
            const ctrls = document.createElement("div");
            ctrls.innerHTML = ctrlsHtml;
            div.appendChild(ctrls);
        }

        const runBtn = document.createElement("button");
        runBtn.className = "action";
        runBtn.textContent = "Run";
        runBtn.addEventListener("click", () => runTab(tab));
        div.appendChild(runBtn);

        const re = document.createElement("button");
        re.className = "action";
        re.textContent = "Re-run";
        re.style.background = "#666";
        re.addEventListener("click", () => runTab(tab));
        div.appendChild(re);

        const result = document.createElement("pre");
        result.className = "result";
        result.textContent = "(not run yet)";
        div.appendChild(result);

        panel.appendChild(div);
    }
}

function perTabControls(tabId) {
    // Buttons that fire host-side XPLMCommandRefs by injecting via the bridge.
    // We can't fire commands from JS directly — the bridge is one-way unless
    // we expose a "fire_command" host function. To keep the dependency minimal
    // we instead surface clear instructions; the C side fires the command in
    // response to either a button click handler or a direct command invocation
    // from the X-Plane MCP / keyboard shortcut.
    //
    // For tabs 6, 7, 13, 14 we DO need a JS-button-driven path, so we expose
    // a `xplane.fire_command(name)` bridge function (registered in C++) that
    // simply calls XPLMCommandOnce on the named command.
    switch (tabId) {
        case "switch_url":
            return '<button class="action" onclick="xplane.fire_command(\'xpsdk/ceftest/load/page2\')">Load page2 from C</button>';
        case "online":
            return '<button class="action" onclick="xplane.fire_command(\'xpsdk/ceftest/load/online\')">Load online from C</button>' +
                   '<button class="action" onclick="xplane.fire_command(\'xpsdk/ceftest/load/index\')" style="background:#666;">Back to index</button>';
        case "bad_url":
            return '<button class="action" onclick="xplane.fire_command(\'xpsdk/ceftest/load/bad_url\')">Load bad URL from C</button>' +
                   '<button class="action" onclick="xplane.fire_command(\'xpsdk/ceftest/load/index\')" style="background:#666;">Back to index</button>';
        case "refresh":
            return '<button class="action" onclick="xplane.fire_command(\'xpsdk/ceftest/refresh/cached\')">Refresh (cached)</button>' +
                   '<button class="action" onclick="xplane.fire_command(\'xpsdk/ceftest/refresh/nocache\')">Refresh (no cache)</button>';
        case "inject_dom":
            return '<button class="action" onclick="xplane.fire_command(\'xpsdk/ceftest/inject/dom\')">Trigger inject from C</button>';
        case "inject_bridge":
            return '<button class="action" onclick="xplane.fire_command(\'xpsdk/ceftest/inject/call_bridge\')">Trigger inject (calls bridge)</button>';
        case "two_windows":
            return '<button class="action" onclick="xplane.fire_command(\'xpsdk/ceftest/spawn_second_window\')">Spawn 2nd window</button>' +
                   '<button class="action" onclick="xplane.fire_command(\'xpsdk/ceftest/destroy_second_window\')" style="background:#666;">Destroy 2nd window</button>';
        case "destroy_mid_load":
            return '<button class="action" onclick="xplane.fire_command(\'xpsdk/ceftest/destroy_mid_load\')">Destroy mid-load</button>';
        case "js_alert":
            // Each button calls the JS dialog primitive directly. alert() blocks
            // the JS thread until dismissed; confirm/prompt also block and return
            // a value. The dismiss result is stashed on a window global so the
            // tab's run() can verify the dialog completed cleanly.
            return '<button class="action" onclick="(function(){alert(\'hello from CEF Test Plugin\');window.__js_dialog_results__=Object.assign(window.__js_dialog_results__||{},{alert:\'dismissed\'});})()">Trigger alert()</button>' +
                   '<button class="action" onclick="(function(){var r=confirm(\'Confirm test? OK→true, Cancel→false\');window.__js_dialog_results__=Object.assign(window.__js_dialog_results__||{},{confirm:r});})()">Trigger confirm()</button>' +
                   '<button class="action" onclick="(function(){var r=prompt(\'Type something:\',\'default value\');window.__js_dialog_results__=Object.assign(window.__js_dialog_results__||{},{prompt:r});})()">Trigger prompt()</button>';
        default: return "";
    }
}

function activate(id) {
    active = id;
    for (const btn of document.querySelectorAll(".tab-button")) {
        btn.classList.toggle("active", btn.dataset.tab === id);
    }
    for (const p of document.querySelectorAll(".panel-content")) {
        p.classList.toggle("active", p.id === "panel-" + id);
    }
    const tab = tabs.find(t => t.id === id);
    if (tab && tab.autorun && (tab.status === undefined || tab.status === "pending")) runTab(tab);
}

// ---- Host integration hooks -----------------------------------------------

// Called by the host's navigation callback via XPLMWindowInjectScript.
window.__cef_nav__ = function(url, success, error) {
    if (success) {
        ctx.firstNavSeen = true;
        if (ctx.onceFirstNav) { ctx.onceFirstNav(); ctx.onceFirstNav = null; }
        logEntry("nav-ok", "nav OK: " + url);
    } else {
        logEntry("nav-fail", "nav FAIL: " + (error || "(no error string)") + " for " + url);
    }
};

// Called by the host's inject scripts.
window.__inject_dom_marker__ = false;
// Tab 7 marker — `undefined` until the C-side inject_bridge has run; set
// to the bridge result string by the inject script.
window.__inject_bridge_marker__ = undefined;
// Tab 15 marker — `undefined` until at least one of alert/confirm/prompt has
// been triggered and dismissed; the inline button handlers populate it with
// the per-primitive dismiss result.
window.__js_dialog_results__ = undefined;

// ---- Boot ------------------------------------------------------------------

(async () => {
    buildSidebar();
    buildPanels();
    setStatus(tabs[0], "pending");  // initialise pills
    for (const t of tabs) if (!t.status) t.status = "pending";
    recomputePills();

    // Hydrate prior pass/fail from the plugin so state survives SPA reloads.
    if (window.xplane && window.xplane.get_status) {
        try {
            const saved = await window.xplane.get_status();
            if (saved) {
                for (const tab of tabs) {
                    if (saved[tab.id]) showResult(tab, saved[tab.id]);
                }
            }
        } catch (e) { /* ignore */ }
    }

    activate(tabs[0].id);
    logEntry("bridge", "SPA loaded. Click a tab to run its test.");
})();

})();