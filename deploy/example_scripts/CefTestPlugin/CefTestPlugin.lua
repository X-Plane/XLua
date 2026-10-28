--[[ XLua 2.0 ]]

-- Lua port of CefTestPlugin (SDK/COMMON/xplanesdk/Src/TestPlugins/CefTestPlugin.cpp).
--
-- Same SPA, same 15 tabs, same 29 commands — but driven through the XLua 2
-- bindings registered by add_xplm_to_interp(). Loadable two ways without
-- modification:
--   * As a host-loaded XPLM Lua plugin (DEV builds only):
--       Resources/test_plugins/CefTestPluginLua/main.lua
--   * As an XLua module:
--       scripts/cef_test_lua/cef_test_lua.lua
--
-- Web assets live under the C++ plugin and are referenced by file:// URL —
-- there's only one SPA, the host language is the variable under test.

-- ─────────────────────────────────────────────────────────────────────────────
-- Minimal JSON encode / decode
-- ─────────────────────────────────────────────────────────────────────────────
-- The bridge contract: inJSON arrives as a JSON literal (e.g. `"hello"`,
-- `{"a":1,"b":2}`, `[1,2,3]`, `42`, `true`, `null`). The C bridge
-- JSON-parses the return value before resolving the JS Promise, so every
-- return must be a valid JSON literal too. JS strings arrive
-- `\uXXXX`-escaped on the way in, so the input is always 7-bit ASCII.

local json = {}

local function json_encode_string(s)
    local out = { '"' }
    for i = 1, #s do
        local c = s:byte(i)
        if c == 0x22 then out[#out+1] = '\\"'
        elseif c == 0x5C then out[#out+1] = '\\\\'
        elseif c == 0x08 then out[#out+1] = '\\b'
        elseif c == 0x09 then out[#out+1] = '\\t'
        elseif c == 0x0A then out[#out+1] = '\\n'
        elseif c == 0x0C then out[#out+1] = '\\f'
        elseif c == 0x0D then out[#out+1] = '\\r'
        elseif c < 0x20 then out[#out+1] = string.format("\\u%04x", c)
        else out[#out+1] = string.char(c) end
    end
    out[#out+1] = '"'
    return table.concat(out)
end

-- Detect whether a table is a JSON array (1..n integer keys, no holes) or
-- an object. An empty table is treated as an object — the test SPA never
-- depends on the distinction for an empty value.
local function is_array(t)
    local n = 0
    for k, _ in pairs(t) do
        if type(k) ~= "number" then return false end
        n = n + 1
    end
    if n == 0 then return false end
    for i = 1, n do
        if t[i] == nil then return false end
    end
    return true, n
end

local function encode_value(v)
    local tv = type(v)
    if v == nil then return "null"
    elseif tv == "boolean" then return v and "true" or "false"
    elseif tv == "number" then
        if v ~= v then return "null"            -- NaN
        elseif v == math.huge then return "null"
        elseif v == -math.huge then return "null"
        elseif v == math.floor(v) and v > -1e15 and v < 1e15 then
            return string.format("%d", v)
        else
            return string.format("%.17g", v)
        end
    elseif tv == "string" then return json_encode_string(v)
    elseif tv == "table" then
        local arr, n = is_array(v)
        if arr then
            local parts = {}
            for i = 1, n do parts[i] = encode_value(v[i]) end
            return "[" .. table.concat(parts, ",") .. "]"
        else
            local parts = {}
            for k, vv in pairs(v) do
                parts[#parts+1] = json_encode_string(tostring(k)) .. ":" .. encode_value(vv)
            end
            return "{" .. table.concat(parts, ",") .. "}"
        end
    else
        return "null"
    end
end

function json.encode(v) return encode_value(v) end

-- Decoder (recursive descent). Returns (value, error).
local decode_value
local function skip_ws(s, i)
    while i <= #s do
        local c = s:byte(i)
        if c == 0x20 or c == 0x09 or c == 0x0A or c == 0x0D then i = i + 1
        else break end
    end
    return i
end

local function decode_string(s, i)
    -- Caller positioned at opening quote.
    local out = {}
    i = i + 1
    while i <= #s do
        local c = s:byte(i)
        if c == 0x22 then
            return table.concat(out), i + 1
        elseif c == 0x5C then
            local n = s:byte(i + 1)
            if n == 0x22 then out[#out+1] = '"' ; i = i + 2
            elseif n == 0x5C then out[#out+1] = '\\' ; i = i + 2
            elseif n == 0x2F then out[#out+1] = '/' ; i = i + 2
            elseif n == 0x62 then out[#out+1] = '\b' ; i = i + 2
            elseif n == 0x66 then out[#out+1] = '\f' ; i = i + 2
            elseif n == 0x6E then out[#out+1] = '\n' ; i = i + 2
            elseif n == 0x72 then out[#out+1] = '\r' ; i = i + 2
            elseif n == 0x74 then out[#out+1] = '\t' ; i = i + 2
            elseif n == 0x75 then
                -- \uXXXX — encode as UTF-8.
                local hex = s:sub(i + 2, i + 5)
                local cp = tonumber(hex, 16)
                if not cp then return nil, "bad \\u escape at " .. i end
                i = i + 6
                if cp >= 0xD800 and cp <= 0xDBFF then
                    -- High surrogate; expect a low surrogate to follow.
                    if s:sub(i, i + 1) == "\\u" then
                        local hex2 = s:sub(i + 2, i + 5)
                        local lo = tonumber(hex2, 16)
                        if lo and lo >= 0xDC00 and lo <= 0xDFFF then
                            cp = 0x10000 + (cp - 0xD800) * 0x400 + (lo - 0xDC00)
                            i = i + 6
                        end
                    end
                end
                if cp < 0x80 then
                    out[#out+1] = string.char(cp)
                elseif cp < 0x800 then
                    out[#out+1] = string.char(0xC0 + math.floor(cp / 0x40),
                                              0x80 + (cp % 0x40))
                elseif cp < 0x10000 then
                    out[#out+1] = string.char(0xE0 + math.floor(cp / 0x1000),
                                              0x80 + math.floor(cp / 0x40) % 0x40,
                                              0x80 + (cp % 0x40))
                else
                    out[#out+1] = string.char(0xF0 + math.floor(cp / 0x40000),
                                              0x80 + math.floor(cp / 0x1000) % 0x40,
                                              0x80 + math.floor(cp / 0x40) % 0x40,
                                              0x80 + (cp % 0x40))
                end
            else
                return nil, "bad escape at " .. i
            end
        else
            out[#out+1] = string.char(c)
            i = i + 1
        end
    end
    return nil, "unterminated string"
end

local function decode_number(s, i)
    local start = i
    if s:byte(i) == 0x2D then i = i + 1 end
    while i <= #s do
        local c = s:byte(i)
        if (c >= 0x30 and c <= 0x39) or c == 0x2E or c == 0x65 or c == 0x45
           or c == 0x2B or c == 0x2D then
            i = i + 1
        else break end
    end
    local n = tonumber(s:sub(start, i - 1))
    if n == nil then return nil, "bad number at " .. start end
    return n, i
end

local function decode_array(s, i)
    local out = {}
    i = skip_ws(s, i + 1)
    if s:byte(i) == 0x5D then return out, i + 1 end
    while true do
        local v, ni, err = decode_value(s, i)
        if not ni then return nil, v or err end
        out[#out+1] = v
        i = skip_ws(s, ni)
        local c = s:byte(i)
        if c == 0x5D then return out, i + 1
        elseif c == 0x2C then i = skip_ws(s, i + 1)
        else return nil, "expected , or ] at " .. i end
    end
end

local function decode_object(s, i)
    local out = {}
    i = skip_ws(s, i + 1)
    if s:byte(i) == 0x7D then return out, i + 1 end
    while true do
        if s:byte(i) ~= 0x22 then return nil, "expected string key at " .. i end
        local key, ni = decode_string(s, i)
        if not ni then return nil, key end
        i = skip_ws(s, ni)
        if s:byte(i) ~= 0x3A then return nil, "expected : at " .. i end
        i = skip_ws(s, i + 1)
        local v, ni2, err = decode_value(s, i)
        if not ni2 then return nil, v or err end
        out[key] = v
        i = skip_ws(s, ni2)
        local c = s:byte(i)
        if c == 0x7D then return out, i + 1
        elseif c == 0x2C then i = skip_ws(s, i + 1)
        else return nil, "expected , or } at " .. i end
    end
end

decode_value = function(s, i)
    i = skip_ws(s, i)
    if i > #s then return nil, nil, "unexpected end" end
    local c = s:byte(i)
    if c == 0x22 then
        local v, ni = decode_string(s, i)
        if not ni then return nil, nil, v end
        return v, ni
    elseif c == 0x7B then return decode_object(s, i)
    elseif c == 0x5B then return decode_array(s, i)
    elseif c == 0x74 and s:sub(i, i + 3) == "true"  then return true,  i + 4
    elseif c == 0x66 and s:sub(i, i + 4) == "false" then return false, i + 5
    elseif c == 0x6E and s:sub(i, i + 3) == "null"  then return nil,   i + 4
    elseif c == 0x2D or (c >= 0x30 and c <= 0x39) then
        return decode_number(s, i)
    else
        return nil, nil, "unexpected char at " .. i
    end
end

-- Returns the parsed value, or nil on parse error / empty input.
function json.decode(s)
    if s == nil or s == "" then return nil end
    local v, ni, err = decode_value(s, 1)
    if not ni then return nil end
    return v
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Logging
-- ─────────────────────────────────────────────────────────────────────────────
local function log_line(s) XPLMDebugString("[CefTestPluginLua] " .. s .. "\n") end

local function trunc(s, n)
    n = n or 80
    if s == nil then return "" end
    if #s <= n then return s end
    return s:sub(1, n) .. "..."
end

local function log_set_url(w, url)
    log_line("set_url " .. (url or ""))
    XPLMWindowSetURL(w, url)
end

local function log_refresh(w, ignore_cache)
    log_line("refresh ignore_cache=" .. (ignore_cache and "true" or "false"))
    XPLMWindowRefresh(w, ignore_cache)
end

local function log_inject(w, js_text)
    log_line("inject " .. tostring(#js_text) .. " bytes: " .. trunc(js_text))
    XPLMWindowInjectScript(w, js_text)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Globals (as in the C++ plugin)
-- ─────────────────────────────────────────────────────────────────────────────
local g_window           = nil
local g_second_window    = nil
local g_mid_load_window  = nil
local g_index_url        = nil
local g_page2_url        = nil
local g_slow_url         = nil
local g_status_by_tab    = {}
local g_mid_load_destroy_at = 0.0
local g_flight_loop      = nil
local g_menu             = nil
local g_cmd_specs        = nil  -- filled in XPluginEnable
local g_cmd_refs         = {}
local g_cmd_lookup       = {}   -- name -> { spec_index, ref }

-- ─────────────────────────────────────────────────────────────────────────────
-- URL helpers
-- ─────────────────────────────────────────────────────────────────────────────
local function make_file_url(xsystem_path, relpath)
    local p = xsystem_path
    if p:sub(-1) ~= "/" then p = p .. "/" end
    p = p .. relpath
    -- Percent-encode spaces (the most common offender on macOS path defaults).
    p = p:gsub(" ", "%%20")
    return "file://" .. p
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Navigation callback
-- ─────────────────────────────────────────────────────────────────────────────
-- The SDK splits browser navigation into two callbacks (finished / error) because
-- that is what the underlying browsers deliver. This plugin still presents the page
-- a single merged __cef_nav__(url, success, error) so its assertions are unchanged.
local function report_nav(win, url, success, err)
    log_line("nav " .. (success and "ok " or "FAIL ") .. (url or "")
             .. ((not success and err and err ~= "") and (" error=" .. err) or ""))

    -- Tell the page (no-op if __cef_nav__ isn't defined).
    local js_text = "if (window.__cef_nav__) __cef_nav__("
        .. json.encode(url or "") .. ", "
        .. (success and "true" or "false") .. ", "
        .. json.encode(err or "") .. ");"
    XPLMWindowInjectScript(win, js_text)
end

local function browser_load_finished_cb(win, url, refcon)
    report_nav(win, url, true, nil)
end

local function browser_load_error_cb(win, url, err, refcon)
    report_nav(win, url, false, err)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Browser callbacks (the JS-facing `xplane.*` namespace)
-- ─────────────────────────────────────────────────────────────────────────────
local function log_and_return(name, in_json, out_text)
    log_line("bridge " .. name .. " in=" .. trunc(in_json or "") .. " out=" .. trunc(out_text))
    -- The Lua binding round-trips the returned string through the host's
    -- XPLMReturnString slot automatically (see cb_XPLMBrowserCallback_f in
    -- the generated XLua glue), so callbacks just `return out_text`.
    return out_text
end

local function cb_echo(win, in_json, refcon)
    local v = json.decode(in_json)
    return log_and_return("echo", in_json, json.encode(v))
end

local function cb_uppercase(win, in_json, refcon)
    local s = json.decode(in_json)
    if type(s) ~= "string" then s = "" end
    return log_and_return("uppercase", in_json, json.encode(string.upper(s)))
end

local function cb_add(win, in_json, refcon)
    local v = json.decode(in_json)
    local out
    if type(v) ~= "table" or type(v.a) ~= "number" or type(v.b) ~= "number" then
        out = { error = "missing a/b", ["in"] = v }
    else
        out = { sum = v.a + v.b }
    end
    return log_and_return("add", in_json, json.encode(out))
end

local function cb_unicode(win, in_json, refcon)
    local s = json.decode(in_json)
    if type(s) ~= "string" then s = "" end
    return log_and_return("unicode", in_json, json.encode({ byte_len = #s, s = s }))
end

local function cb_bigarray(win, in_json, refcon)
    -- The decoder collapses `[]` and `{}` to the same empty Lua table, so to
    -- match the cpp plugin's "not an array" branch we look at the raw input.
    local trimmed = (in_json or ""):match("^%s*(.-)%s*$") or ""
    local v = json.decode(in_json)
    local out
    if trimmed:sub(1, 1) ~= "[" then
        out = { error = "not an array", ["in"] = v }
    else
        local n = type(v) == "table" and #v or 0
        if n == 0 then
            out = { len = 0, json_bytes = #(in_json or "") }
        else
            out = { len = n, first = v[1], last = v[n], json_bytes = #(in_json or "") }
        end
    end
    return log_and_return("bigarray", in_json, json.encode(out))
end

-- Closure factory for refcon discrimination — captures n in the closure so
-- each registered function returns its own refcon value to JS.
local function make_cb_refcon(n)
    return function(win, in_json, refcon)
        return log_and_return("refcon", in_json, json.encode({ refcon = n }))
    end
end

local function cb_bad_json(win, in_json, refcon)
    return log_and_return("bad_json", in_json,
        json.encode({ error = "deliberate fixed error" }))
end

local function cb_null_return(win, in_json, refcon)
    -- Same caveat as the C++ plugin: returning nil from a bridge callback
    -- triggers a plugin assert (XPLMDisplay.cpp:1355). Returning a documentation
    -- object is the safe path.
    return log_and_return("null_return", in_json,
        json.encode({ note = "null/non-XPLMReturnString returns trigger a plugin assert; never return nil from a bridge callback." }))
end

local function cb_window_id(win, in_json, refcon)
    -- In Lua the window id is opaque userdata; encode as its tostring so JS
    -- can compare ids across windows for stability.
    return log_and_return("window_id", in_json, json.encode({ id = tostring(win) }))
end

local function cb_fire_command(win, in_json, refcon)
    local name = json.decode(in_json)
    if type(name) ~= "string" then name = "" end
    local out
    local c = XPLMFindCommand(name)
    if c == nil then
        out = { error = "command not found" }
    else
        XPLMCommandOnce(c)
        out = { ok = true }
    end
    return log_and_return("fire_command", in_json, json.encode(out))
end

local function cb_report_status(win, in_json, refcon)
    local v = json.decode(in_json) or {}
    local tab_id = type(v.tab_id) == "string" and v.tab_id or ""
    local result = v.result or {}
    if tab_id ~= "" then
        g_status_by_tab[tab_id] = json.encode(result)
        local ok_label = result.ok and "ok" or "FAIL"
        local info = type(result.info) == "string" and result.info or ""
        log_line("status " .. tab_id .. " " .. ok_label
                 .. (info ~= "" and (" info=" .. info) or ""))
    end
    return log_and_return("report_status", in_json, json.encode({ ok = true }))
end

local function cb_get_status(win, in_json, refcon)
    local out = {}
    for k, v in pairs(g_status_by_tab) do
        out[k] = json.decode(v)
    end
    return log_and_return("get_status", in_json, json.encode(out))
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Window creation
-- ─────────────────────────────────────────────────────────────────────────────
local function register_bridge_funcs(w)
    XPLMWindowAddBrowserFunction(w, "echo",          cb_echo,            nil)
    XPLMWindowAddBrowserFunction(w, "uppercase",     cb_uppercase,       nil)
    XPLMWindowAddBrowserFunction(w, "add",           cb_add,             nil)
    XPLMWindowAddBrowserFunction(w, "unicode",       cb_unicode,         nil)
    XPLMWindowAddBrowserFunction(w, "bigarray",      cb_bigarray,        nil)
    XPLMWindowAddBrowserFunction(w, "refcon_a",      make_cb_refcon(1),  nil)
    XPLMWindowAddBrowserFunction(w, "refcon_b",      make_cb_refcon(2),  nil)
    XPLMWindowAddBrowserFunction(w, "refcon_c",      make_cb_refcon(3),  nil)
    XPLMWindowAddBrowserFunction(w, "bad_json",      cb_bad_json,        nil)
    XPLMWindowAddBrowserFunction(w, "null_return",   cb_null_return,     nil)
    XPLMWindowAddBrowserFunction(w, "window_id",     cb_window_id,       nil)
    XPLMWindowAddBrowserFunction(w, "fire_command",  cb_fire_command,    nil)
    XPLMWindowAddBrowserFunction(w, "report_status", cb_report_status,   nil)
    XPLMWindowAddBrowserFunction(w, "get_status",    cb_get_status,      nil)
end

local function create_browser_window(left, bottom, right, top, title, url)
    local w = XPLMCreateWindowEx({
        left   = left,
        bottom = bottom,
        right  = right,
        top    = top,
        visible                  = true,
        decorateAsFloatingWindow = XPLMWindowDecoration.xplm_WindowDecorationRoundRectangle,
        contentType              = XPLMWindowContentType.xplm_WindowContentTypeBrowser,
        browserLoadFinishedFunc  = browser_load_finished_cb,
        browserLoadErrorFunc     = browser_load_error_cb,
    })
    if w == nil then
        log_line("create_browser_window FAILED title=" .. (title or ""))
        return nil
    end
    XPLMSetWindowTitle(w, title)
    -- Register bridge functions before the first navigation: XPLMWindowSetURL
    -- freezes the browser-function set (a later XPLMWindowAddBrowserFunction is
    -- rejected via XPLMError).
    register_bridge_funcs(w)
    XPLMWindowSetURL(w, url)
    log_line('created window ' .. tostring(w) .. ' title="' .. (title or "") .. '"')
    log_line("set_url " .. (url or ""))
    return w
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Commands
-- ─────────────────────────────────────────────────────────────────────────────
local function build_cmd_specs()
    local specs = {
        { "xpsdk/ceftest/load/index",            "Load web/index.html"               },
        { "xpsdk/ceftest/load/page2",            "Load web/page2.html"               },
        { "xpsdk/ceftest/load/data_url",         "Load a data: URL"                  },
        { "xpsdk/ceftest/load/online",           "Load https://developer.x-plane.com"},
        { "xpsdk/ceftest/load/bad_url",          "Load bad URL (nav-failure test)"   },
        { "xpsdk/ceftest/refresh/cached",        "XPLMWindowRefresh(false)"          },
        { "xpsdk/ceftest/refresh/nocache",       "XPLMWindowRefresh(true)"           },
        { "xpsdk/ceftest/inject/dom",            "Inject DOM-mutating script"        },
        { "xpsdk/ceftest/inject/call_bridge",    "Inject script that calls xplane.echo" },
        { "xpsdk/ceftest/inject/large",          "Inject a ~50 KB script"            },
        { "xpsdk/ceftest/spawn_second_window",   "Open a second CEF window"          },
        { "xpsdk/ceftest/destroy_second_window", "Close the second CEF window"       },
        { "xpsdk/ceftest/destroy_mid_load",      "Spawn 3rd window, set slow URL, destroy" },
        { "xpsdk/ceftest/log/clear",             "Clear the SPA log pane"            },
    }
    local tab_ids = {
        "hello", "switch_url", "online", "bad_url", "refresh",
        "inject_dom", "inject_bridge", "echo_json", "unicode", "bigarray",
        "refcon", "errors", "two_windows", "destroy_mid_load", "js_alert"
    }
    local labels = {
        "1 (file:// load)",      "2 (switch URL)",       "3 (online)",
        "4 (bad URL)",           "5 (refresh)",          "6 (inject DOM)",
        "7 (inject bridge)",     "8 (echo + JSON)",      "9 (unicode)",
        "10 (large payload)",    "11 (refcon)",          "12 (error paths)",
        "13 (two windows)",      "14 (destroy mid-load)","15 (JS alert/confirm/prompt)"
    }
    for i, id in ipairs(tab_ids) do
        local name = string.format("xpsdk/ceftest/tab/%02d_%s", i, id)
        specs[#specs+1] = { name, "Activate tab " .. labels[i], tab_id = id }
    end
    return specs
end

local function cmd_handler(cmd, phase, refcon)
    if phase ~= XPLMCommandPhase.xplm_CommandBegin then return 0 end

    -- Identify which command fired.
    local which_name = nil
    for name, entry in pairs(g_cmd_lookup) do
        if entry.ref == cmd then which_name = name break end
    end
    if not which_name then return 0 end

    log_line("command " .. which_name)

    if which_name == "xpsdk/ceftest/load/index" then
        log_set_url(g_window, g_index_url)
    elseif which_name == "xpsdk/ceftest/load/page2" then
        log_set_url(g_window, g_page2_url)
    elseif which_name == "xpsdk/ceftest/load/data_url" then
        log_set_url(g_window,
            "data:text/html;charset=utf-8,"
            .. "<html><body style='background:%231a1c20;color:%23ffd07a;font-family:sans-serif;padding:30px'>"
            .. "<h1>Inline data: URL</h1>"
            .. "<p>This page came from a data: URL passed to XPLMWindowSetURL.</p>"
            .. "</body></html>")
    elseif which_name == "xpsdk/ceftest/load/online" then
        log_set_url(g_window, "https://developer.x-plane.com")
    elseif which_name == "xpsdk/ceftest/load/bad_url" then
        log_set_url(g_window, "http://127.0.0.1:1/")
    elseif which_name == "xpsdk/ceftest/refresh/cached" then
        log_refresh(g_window, false)
    elseif which_name == "xpsdk/ceftest/refresh/nocache" then
        log_refresh(g_window, true)
    elseif which_name == "xpsdk/ceftest/inject/dom" then
        log_inject(g_window,
            "document.title = 'mutated by inject @ ' + new Date().toISOString();"
            .. "var b = document.createElement('div');"
            .. "b.textContent = 'INJECTED BANNER';"
            .. "b.style.cssText = 'position:fixed;top:36px;right:0;background:#ffd07a;color:#000;padding:6px 10px;font-weight:600;z-index:9999;';"
            .. "document.body.appendChild(b);"
            .. "window.__inject_dom_marker__ = true;"
            .. "if (window.__inject_dom_seen__) window.__inject_dom_seen__('banner+title');")
    elseif which_name == "xpsdk/ceftest/inject/call_bridge" then
        log_inject(g_window,
            "xplane.echo('called from C-side inject').then(s => {"
            .. "  window.__inject_bridge_marker__ = s;"
            .. "  if (window.__inject_bridge_result__) window.__inject_bridge_result__(s);"
            .. "});")
    elseif which_name == "xpsdk/ceftest/inject/large" then
        local parts = { "var s = '';\n" }
        for i = 0, 1499 do
            parts[#parts+1] = string.format("s += 'chunk-%04d------------------------------';\n", i)
        end
        parts[#parts+1] = "xplane.echo('injected_large_ok len='+s.length).then(()=>{});"
        log_inject(g_window, table.concat(parts))
    elseif which_name == "xpsdk/ceftest/spawn_second_window" then
        if g_second_window == nil then
            g_second_window = create_browser_window(560, 60, 1060, 660,
                "CEF Test #2 (Lua)", g_index_url)
        end
    elseif which_name == "xpsdk/ceftest/destroy_second_window" then
        if g_second_window ~= nil then
            log_line("destroy second_window")
            XPLMDestroyWindow(g_second_window)
            g_second_window = nil
        end
    elseif which_name == "xpsdk/ceftest/destroy_mid_load" then
        if g_mid_load_window ~= nil then
            log_line("destroy mid_load_window (replacing)")
            XPLMDestroyWindow(g_mid_load_window)
            g_mid_load_window = nil
        end
        g_mid_load_window = create_browser_window(80, 80, 480, 480,
            "CEF Test #3 (Lua mid-load)", g_slow_url)
        g_mid_load_destroy_at = XPLMGetElapsedTime() + 0.05
    elseif which_name == "xpsdk/ceftest/log/clear" then
        log_inject(g_window,
            "var l = document.getElementById('log'); if (l) while (l.firstChild) l.removeChild(l.firstChild);")
    elseif which_name:sub(1, 18) == "xpsdk/ceftest/tab/" then
        -- Click the corresponding tab button in the SPA.
        local entry = g_cmd_lookup[which_name]
        local spec = g_cmd_specs[entry.spec_index]
        local tab_id = spec.tab_id
        if tab_id then
            log_inject(g_window,
                "(function(){var b=document.querySelector('.tab-button[data-tab=\""
                .. tab_id .. "\"]');if(b)b.click();})();")
        end
    end
    return 0
end

local function flight_loop_cb(elapsed_since_last, elapsed_since_last_loop, counter, refcon)
    if g_mid_load_window ~= nil and XPLMGetElapsedTime() >= g_mid_load_destroy_at then
        log_line("destroy mid_load_window (deferred from flight loop)")
        XPLMDestroyWindow(g_mid_load_window)
        g_mid_load_window = nil
    end
    return -1.0
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Plugin lifecycle
-- ─────────────────────────────────────────────────────────────────────────────
function XPluginStart()
    log_line("XPluginStart")

    local sys = XPLMGetSystemPath()
    g_index_url = make_file_url(sys, "Resources/test_plugins/CefTestPluginLua/web/index.html")
    g_page2_url = make_file_url(sys, "Resources/test_plugins/CefTestPluginLua/web/page2.html")
    g_slow_url  = make_file_url(sys, "Resources/test_plugins/CefTestPluginLua/web/slow.html")

    log_line("xsystem path: " .. sys)
    log_line("index_url:    " .. g_index_url)

    g_window = create_browser_window(40, 80, 1040, 760, "CEF Test Plugin (Lua)", g_index_url)
    if g_window == nil then return end

    return true
end

function XPluginEnable()
    log_line("XPluginEnable")

    g_cmd_specs = build_cmd_specs()
    for i, spec in ipairs(g_cmd_specs) do
        local ref = XPLMCreateCommand(spec[1], spec[2])
        XPLMRegisterCommandHandler(ref, cmd_handler, true, nil)
        g_cmd_refs[i] = ref
        g_cmd_lookup[spec[1]] = { spec_index = i, ref = ref }
    end

    g_flight_loop = XPLMCreateFlightLoop({
        phase        = XPLMFlightLoopPhaseType.xplm_FlightLoop_Phase_AfterFlightModel,
        callbackFunc = flight_loop_cb,
    })
    XPLMScheduleFlightLoop(g_flight_loop, -1.0, true)

    -- Plugins menu — escape hatches for when the SPA isn't on screen.
    local sub = XPLMAppendMenuItem(XPLMFindPluginsMenu(), "CEF Test Plugin (Lua)", nil, 1)
    g_menu = XPLMCreateMenu("CEF Test Plugin (Lua)", XPLMFindPluginsMenu(), sub, nil, nil)
    XPLMAppendMenuItemWithCommand(g_menu, "Reset window to SPA",
                                  XPLMFindCommand("xpsdk/ceftest/load/index"))
    XPLMAppendMenuSeparator(g_menu)
    XPLMAppendMenuItemWithCommand(g_menu, "Spawn 2nd window",
                                  XPLMFindCommand("xpsdk/ceftest/spawn_second_window"))
    XPLMAppendMenuItemWithCommand(g_menu, "Destroy 2nd window",
                                  XPLMFindCommand("xpsdk/ceftest/destroy_second_window"))

    return true
end

function XPluginDisable()
    log_line("XPluginDisable")

    if g_menu then XPLMDestroyMenu(g_menu) ; g_menu = nil end

    if g_flight_loop then
        XPLMDestroyFlightLoop(g_flight_loop)
        g_flight_loop = nil
    end

    for i, ref in ipairs(g_cmd_refs) do
        if ref then
            XPLMUnregisterCommandHandler(ref, cmd_handler, true, nil)
        end
    end
    g_cmd_refs = {}
    g_cmd_lookup = {}
end

function XPluginStop()
    log_line("XPluginStop")
    if g_window         then XPLMDestroyWindow(g_window)         ; g_window         = nil end
    if g_second_window  then XPLMDestroyWindow(g_second_window)  ; g_second_window  = nil end
    if g_mid_load_window then XPLMDestroyWindow(g_mid_load_window); g_mid_load_window = nil end
end

function XPluginReceiveMessage(from, msg, param)
end
