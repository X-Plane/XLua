--[[ XLua 2.0 ]]

require("XPLMCamera")
require("XPLMDataAccess")
require("XPLMDisplay")			-- Partially excluded.
require("XPLMGraphics")			-- Partially excluded. Use ImGui.
require("XPLMInstance")
require("XPLMMap")
require("XPLMMenus")
require("XPLMNavigation")
require("XPLMPlanes")
require("XPLMPlugin")
require("XPLMProcessing")
require("XPLMScenery")
--require("XPLMSound")
require("XPLMUtilities")
require("XPLMWeather")
-- require("XPLMUIGraphics")	Excluded entirely.

g_custom_accessor_store = 5
g_pre_fl_handle = nil
g_post_fl_handle = nil
custom_cmnd = nil
g_flagpolePath = nil

g_num_tcas_acf = 5
haveTCASAircraft = false
drModeS = XPLMFindDataRef("sim/cockpit2/tcas/targets/modeS_id")
drPitch = XPLMFindDataRef("sim/cockpit2/tcas/targets/position/the")
drBank = XPLMFindDataRef("sim/cockpit2/tcas/targets/position/phi")
drHeading = XPLMFindDataRef("sim/cockpit2/tcas/targets/position/psi")
drRelAlt = XPLMFindDataRef("sim/cockpit2/tcas/indicators/relative_altitude_mtrs")
drRelBrg = XPLMFindDataRef("sim/cockpit2/tcas/indicators/relative_bearing_degs")
drRelDis = XPLMFindDataRef("sim/cockpit2/tcas/indicators/relative_distance_mtrs")
drTCASLat = XPLMFindDataRef("sim/cockpit2/tcas/targets/position/lat")
drTCASLon = XPLMFindDataRef("sim/cockpit2/tcas/targets/position/lon")
drTCASAlt = XPLMFindDataRef("sim/cockpit2/tcas/targets/position/ele")
drUserHdg = XPLMFindDataRef("sim/flightmodel/position/psi")
drUserLat = XPLMFindDataRef("sim/flightmodel/position/latitude")
drUserLon = XPLMFindDataRef("sim/flightmodel/position/longitude")
instanceRefs = {}

XLuaReloadOnFlightChange()

function print_banner(title)
	title = "*     " .. title .. "     *"
	local b = string.gsub(title, ".", "*")

	print() print()
	print(b)
	print(title)
	print(b)
end

function secondPreFlightLoop(inElapsedSinceLastCall, inElapsedTimeSinceLastFlightLoop, inCounter, inRefcon)
	print("  PRE-FL: Sim elapsed time: " .. XPLMGetElapsedTime() .. ", cycle #" .. XPLMGetCycleNumber())

	if XPLMGetElapsedTime() > 100 then
		print("  PRE-FL: Elapsed time > 100, killing the flight loop.")
		XPLMDestroyFlightLoop(g_pre_fl_handle)
		g_pre_fl_handle = nil
	end

	return 10
end

local hotkey_count = 0
local hotkey_ref = nil
function hotkey_callback(userref)
	print("Hotkey pressed! Userref = " .. userref)

	hotkey_count = hotkey_count + 1
	if hotkey_count == 5 then
		print("Hotkey '" .. tostring(hotkey_ref) .. "' says that's enough.")

		XPLMUnregisterHotKey(hotkey_ref)
		hotkey_ref = nil
	end
end

function PostFlightLoop()
--	print("  POST-FL: Sim elapsed time: " .. XPLMGetElapsedTime() .. ", cycle #" .. XPLMGetCycleNumber())

	----------------------------------------------------
	--[[      XPLMGraphics/X-PLANE TEXT tests       ]]--
	----------------------------------------------------
	-- FAIL: Doesn't draw anything.
--	print("After physics")
	XPLMDrawString({1.0, 0.2, 0.2}, 50, 50, "XPLMDrawString says hi!", nil, XPLMFontID.xplmFont_Proportional)
	XPLMDrawNumber({1.0, 0.2, 0.2}, 50, 50, XPLMGetElapsedTime(), 10, 3, true, XPLMFontID.xplmFont_Proportional)

	if haveTCASAircraft then
		local curBrg = {}
		local brgCount = XPLMGetDatavf(drRelBrg, curBrg, 0, g_num_tcas_acf)
		for i = 1, #curBrg do
			curBrg[i] = curBrg[i] + 0.125
			if curBrg[i] >= 360 then curBrg[i] = curBrg[i] - 360 end
		end

		XPLMSetDatavf(drRelBrg, curBrg, 0, #curBrg)

		for i = 1, #curBrg do
			curBrg[i] = curBrg[i] + 90 + XPLMGetDataf(drUserHdg)
			if curBrg[i] >= 360 then curBrg[i] = curBrg[i] - 360 end
		end
		XPLMSetDatavf(drHeading, curBrg, 0, #curBrg)

		local tcasLats, tcasLons, tcasAlts = {}, {}, {}
		XPLMGetDatavf(drTCASLat, tcasLats, 0, g_num_tcas_acf)
		XPLMGetDatavf(drTCASLon, tcasLons, 0, g_num_tcas_acf)
		XPLMGetDatavf(drTCASAlt, tcasAlts, 0, g_num_tcas_acf)
		for i = 2, g_num_tcas_acf do
			if instanceRefs[i] ~= nil then
				local wp = XPLMWorldToLocal(tcasLats[i], tcasLons[i], tcasAlts[i])

				XPLMInstanceSetPosition(instanceRefs[i],
				{
					["x"] = wp.outX,
					["y"] = wp.outY,
					["z"] = wp.outZ,
					["pitch"] = 0,
					["heading"] = curBrg[i],
					["roll"] = 5
				},
				{ nil })
			end
		end
	end

	return -1
end

function FlightStarted()
	--------------------------------------
	--[[      XPLMPlugin tests       ]]--
	--------------------------------------
	print_banner("XPLMPlugin")

	XPLMEnumerateFeatures(function(inFeature, inRef)
		print("InRef: " .. inRef)
		print("Feature: " .. inFeature)
	end, 1234)

	-- XPLMGetMyID() and XPLMIsPluginEnabled()
	local pid = XPLMGetMyID()
	print("Type of pid == " .. type(pid))
	print("I am " .. (XPLMIsPluginEnabled(pid) and "Enabled" or "Disabled"))

	-- XPLMCountPlugins(), XPLMGetNthPlugin() and XPLMGetPluginInfo()
	local numplugins = XPLMCountPlugins()
	print("  and one of " .. numplugins .. " plugins.")
	for i = 0,numplugins-1 do
		pinfo = XPLMGetPluginInfo(XPLMGetNthPlugin(i))
		print("  " .. i .. ": " .. pinfo.outName .. " (" .. pinfo.outDescription .. ")")
	end

	-- XPLMFindPluginByPath()
	local missing_plugin = XPLMFindPluginByPath("/some/path/that/doesnt/exist.xpl")

	-- Lua 5.2 would support automatic __tostring if used directly but not with concatenation...
	print("Missing plugin ID should be XPLM_NO_PLUGIN_ID: " .. (missing_plugin == XPLM_NO_PLUGIN_ID and "Yes" or ("No (" .. tostring(missing_plugin) .. ")")))

	local existing_plugin = XPLMFindPluginBySignature("xpsdk.examples.pluginadmin")
	print("Existing plugin ID should be >= 1: " .. tostring(existing_plugin))	-- As above, implement the tostring properly.

	--------------------------------------
	--[[      XPLMUtilities tests       ]]--
	--------------------------------------
	print_banner("XPLMUtilities")

	print("System path: " .. XPLMGetSystemPath())
	print("Prefs path : " .. XPLMGetPrefsPath())
	print("Directory Separator: " .. XPLMGetDirectorySeparator())
	-- XPLMExtractFileAndPath currently excluded because it's 'modify string in place' with a null terminator. Not relevant to lua, and also there are existing path native manipulation commands.
	-- XPLMGetDirectoryContents currently excluded because it returns a 0-separated single string rather than a table of strings

	-- This causes problems but they appear to be sim-side...?
--	local loaded_sit = XPLMLoadDataFile(XPLMDataFileType.xplm_DataFile_Situation, "Output/situations/test_set1.sit")
--	print("Load situation: " .. (loaded_sit and "OK" or "FAILED"))

	local saved_sit = XPLMSaveDataFile(XPLMDataFileType.xplm_DataFile_Situation, "Output/situations/test_lua.sit")
	print("Save situation: " .. (saved_sit and "OK" or "FAILED"))

	local versions = XPLMGetVersions()
	print("Host " .. versions.outHostID .. " has version " .. versions.outXPlaneVersion .. ", XPLM version " .. versions.outXPLMVersion)

	print("Language: " .. XPLMGetLanguage())
	-- XPLMFindSymbol excluded because lua _always_ uses the latest version of the SDK
	XPLMDebugString("Testing Lua's direct log write, although print() does the same job")
	XPLMSpeakString("Testing Lua's ability to use speech synthesis")
	print("Virtual key code XPLM_VK_G -> " .. XPLMGetVirtualKeyDescription(string.char(0x47)))

	local base_cmnd = XPLMFindCommand("sim/view/tower")
	print("Type of base command: " .. type(base_cmnd))
	XPLMCommandOnce(base_cmnd)

	print("Type of custom command: " .. type(custom_cmnd))
	XPLMRegisterCommandHandler(custom_cmnd,
		function(inCommand, inPhase, userref)
			if inCommand == custom_cmnd then
				print("Custom Command phase " .. inPhase)
				return false
			end

			return true
		end,
		true,
	0)
	XPLMCommandBegin(custom_cmnd)
	XPLMCommandEnd(custom_cmnd)

	--------------------------------------
	--[[        XPLMMenu tests        ]]--
	--------------------------------------
	print_banner("XPLMMenu")

	item = XPLMAppendMenuItem(XPLMFindPluginsMenu(), "Lua's First Menu", nil, 0);
	menu = XPLMCreateMenu("Lua's First Menu", XPLMFindPluginsMenu(), item,
					function(menuRef, itemRef)
						print("Menu item called with item ref type '" .. type(itemRef) .. "' (should be string)")
						print("                  and menu ref type '" .. type(menuRef) .. "' (should be number)")

						if type(menuRef) == "number" then
							print("- Menu Ref: " .. menuRef)
						end

						if type(itemRef) == "string" then
							print("- Item Ref: " .. itemRef)
						end

						-- Er... how are you supposed to get the index of the selected menu and item??!?
						-- XPLMCheckMenuItem(menu, 2, XPLMMenuCheck.xplm_Menu_Checked)
					end, 12345)
	item = XPLMAppendMenuItem(menu, "Boop!", "Item 'boop'", 0);
	item2 = XPLMAppendMenuItem(menu, "Beep!", "Item 'beep'", 0);
	XPLMAppendMenuSeparator(menu)
	item3 = XPLMAppendMenuItem(menu, "Nope!", "Item 'nope'", 0);
	XPLMEnableMenuItem(menu, item3, false)
	XPLMCheckMenuItem(menu, item2, XPLMMenuCheck.xplm_Menu_Checked)

	-----------------------------------------
	--[[        XPLMWeather tests        ]]--
	-----------------------------------------
	print_banner("XPLMWeather")

	local success, wxr = XPLMGetWeatherAtLocation(51.5, 0.25, 100)
	if success then
		print("Local temperature is " .. wxr.temperature_alt .. ", pressure = " .. wxr.pressure_alt)

		for idx, val in ipairs(wxr.temp_layers) do
			print("  L" .. idx .. ": " .. val)
		end
		
		print("Winds (" .. #wxr.wind_layers .. " layers)")
		for idx, val in ipairs(wxr.wind_layers) do
			print("  L" .. idx .. ": " .. math.floor(val.alt_msl) .. "m MSL, " .. string.format("%.2f", val.speed) .. "m/s, " .. string.format("%.2f", val.direction) .. " degT")
		end
	else
		print("Failed to read weather...?")
	end

	print("METAR for EGLL:" .. XPLMGetMETARForAirport("EGLL").buffer)

	-----------------------------------------------------------------------
	--[[        XPLMNavigation/NAVIGATION DATABASE ACCESS tests        ]]--
	-----------------------------------------------------------------------
	print_banner("XPLMNavigation/NAVIGATION DATABASE ACCESS")

	function print_navaid(navaid)
		if navaid == nil then
			print("  Undefined!")
			return
		end

		local nd = XPLMGetNavAidInfo(navaid)
		--print("  (Type of nd = " .. type(nd) .. ")")
		print("  Type: " .. nd.outType)
		print("  Pos : " .. nd.outLatitude .. ", " .. nd.outLongitude .. ", " .. nd.outHeight)
		print("  ID  : " .. nd.outID)
		print("  Freq: " .. nd.outFrequency)
		print("  Name: " .. nd.outName)
	end

	local first_navaid = XPLMGetFirstNavAid()
	if first_navaid == XPLM_NAV_NOT_FOUND then
		print("!!! First navaid not found??!?")
	else
		print("First navaid is:")
		print_navaid(first_navaid)

		first_navaid = XPLMGetNextNavAid(first_navaid)
		print("Second navaid is:")
		print_navaid(first_navaid)
	end

	first_navaid = XPLMFindFirstNavAidOfType(XPLMNavType.xplm_Nav_Airport)
	print("First airport is:")
	print_navaid(first_navaid)

	first_navaid = XPLMFindLastNavAidOfType(XPLMNavType.xplm_Nav_Airport)
	print("Last airport is:")
	print_navaid(first_navaid)

	print("Search for EGLL:")
	first_navaid = XPLMFindNavAid(nil, "EGLL", 55.0, -3.0, nil, XPLMNavType.xplm_Nav_Airport)
	print_navaid(first_navaid)

	-----------------------------------------------------------------------
	--[[        XPLMNavigation/FLIGHT MANAGEMENT COMPUTER tests        ]]--
	-----------------------------------------------------------------------
	print_banner("XPLMNavigation/FLIGHT MANAGEMENT COMPUTER - FMS")

	local function print_fms_entry(fms_entry)
		if fms_entry == nil then
			print("  (None)")
		elseif type(fms_entry) ~= "table" then
			print("  (Type " .. type(fms_entry) .. ")")
		else
			print("  Type = " .. fms_entry.outType)
			print("  ID   = " .. fms_entry.outID)
			print("  Ref  = " .. type(fms_entry.outRef))
			print("  Alt  = " .. fms_entry.outAltitude)
			print("  Lat  = " .. fms_entry.outLat)
			print("  Lon  = " .. fms_entry.outLon)
		end
	end

	print("We have " .. XPLMCountFMSEntries() .. " FMS entries.")
	print("Current displayed entry: " .. XPLMGetDisplayedFMSEntry())
	print("Destination entry: " .. XPLMGetDestinationFMSEntry())

	XPLMSetFMSEntryLatLon(0, 51.2, -2.0, 2000)
	print("After adding one, we have " .. XPLMCountFMSEntries() .. " FMS entries.")
	XPLMSetFMSEntryInfo(1, first_navaid, 1500)
	print("After adding two, we have " .. XPLMCountFMSEntries() .. " FMS entries.")
	XPLMSetDisplayedFMSEntry(1)
	XPLMSetDestinationFMSEntry(0)

	local fms_entry = XPLMGetFMSEntryInfo(1)
	print("FMS Entry 1:")
	print_fms_entry(fms_entry)

	XPLMClearFMSEntry(0)
	fms_entry = XPLMGetFMSEntryInfo(1)
	print("FMS Entry 0 (Should be the same as above):")
	print_fms_entry(fms_entry)

	-----------------------------------------------------------------------
	--[[        XPLMNavigation/FLIGHT MANAGEMENT COMPUTER tests        ]]--
	-----------------------------------------------------------------------
	print_banner("XPLMNavigation/FLIGHT MANAGEMENT COMPUTER - FlightPlans")

	local fplan = [[I
1100 Version
CYCLE 2103
ADEP EGLL
ADES EDDM
NUMENR 24
1 EGLL ADEP 83.000000 51.477500 -0.461389
3 DET DRCT 3000.000000 51.304003 0.597275
3 DVR L6 3000.000000 51.162622 1.359089
11 KONAN UL9 3000.000000 51.130764 2.000000
3 KOK UL607 3000.000000 51.094722 2.651667
11 FERDI UL607 3000.000000 50.912639 3.636972
11 BUPAL UL607 3000.000000 50.723056 4.601111
11 REMBA UL607 3000.000000 50.662222 4.914028
3 SPI UL607 3000.000000 50.514722 5.623611
11 PELIX UL607 3000.000000 50.496944 5.762500
11 MATUG UL607 3000.000000 50.416667 6.369722
28 FIX01 DRCT 3000.000000 50.000000 7.000000
11 MOVUM DRCT 3000.000000 49.950000 8.526111
11 HAREM T109 3000.000000 49.618333 9.414444
11 ELMOX T104 3000.000000 49.383611 9.824722
11 PIGAB T104 3000.000000 49.198333 10.143333
3 DKB T104 3000.000000 49.142753 10.238306
11 LEVBU T104 3000.000000 49.006944 10.456667
11 ANORA T104 3000.000000 48.949444 10.548333
11 XERUM T104 3000.000000 48.811111 10.767778
11 BURAM T104 3000.000000 48.695497 10.949003
3 WLD T104 3000.000000 48.579419 11.129386
11 ROKIL T104 3000.000000 48.513314 11.196725
1 EDDM ADES 4000.000000 48.353783 11.786086
]]

	print("Loading a flightplan...")
	XPLMLoadFMSFlightPlan(0, fplan, fplan:len())

	local FPL_P_Pri = XPLMNavFlightPlan.xplm_Fpl_Pilot_Primary
	print("  Loaded " .. XPLMCountFMSFlightPlanEntries(FPL_P_Pri) .. " entries.")
	print("Displaying entry #" .. XPLMGetDisplayedFMSFlightPlanEntry(FPL_P_Pri))
	print("Display entry 5...")
	XPLMSetDisplayedFMSFlightPlanEntry(FPL_P_Pri, 5)
	print("  Now displaying entry #" .. XPLMGetDisplayedFMSFlightPlanEntry(FPL_P_Pri))

	print("Destination entry #" .. XPLMGetDestinationFMSFlightPlanEntry(FPL_P_Pri))
	print("Set direct-to #6...")
	XPLMSetDirectToFMSFlightPlanEntry(FPL_P_Pri, 6)
	print("  Now destination entry #" .. XPLMGetDestinationFMSFlightPlanEntry(FPL_P_Pri))
	fms_entry = XPLMGetFMSFlightPlanEntryInfo(FPL_P_Pri, XPLMGetDestinationFMSFlightPlanEntry(FPL_P_Pri))
	print_fms_entry(fms_entry)

	---------------------------------------------------------
	--[[        XPLMNavigation/GPS RECEIVER tests        ]]--
	---------------------------------------------------------
	print_banner("XPLMNavigation/GPS RECEIVER")
	
	print("GPS destination type: " .. XPLMGetGPSDestinationType())
	local gps_dest = XPLMGetGPSDestination()
	print("Actual GPS destination:")
	print_navaid(gps_dest)

	--------------------------------------------
	--[[        XPLMDataAccess tests        ]]--
	--------------------------------------------
	print_banner("XPLMDataAccess")

	print(XPLMCountDataRefs() .. " datarefs exist in total")

	-- Read datarefs 0 through 9
	local ten_datarefs = {}
	print("")
	print("Datarefs 0 through 9")
	local offset = 0
	XPLMGetDataRefsByIndex(offset, 10, ten_datarefs)
	print("Requested 10 datarefs, got " .. #ten_datarefs)
	for i = 1, 10 do
		local dri = XPLMGetDataRefInfo(ten_datarefs[i])
		print("dataref[" .. (offset + i) .. "] = " .. (dri.name or "(none)"))
	end

	-- Read datarefs 10 through 19
	print("")
	print("Datarefs 5 through 12")
	offset = 5
	XPLMGetDataRefsByIndex(offset, 8, ten_datarefs)
	print("Requested 8 datarefs, got " .. #ten_datarefs)
	for i = 1, 10 do
		local dri = XPLMGetDataRefInfo(ten_datarefs[i])
		print("dataref[" .. (offset + i) .. "] = " .. (dri.name or "(none)"))
	end

	local drTest = XPLMFindDataRef("sim/cockpit2/ice/ice_inlet_heat_on")
	if drTest ~= nil then
		dri = XPLMGetDataRefInfo(drTest)
		print("sim/cockpit2/ice/ice_inlet_heat_on is type #" .. dri.type)
	else
		print("sim/cockpit2/ice/ice_inlet_heat_on does not exist??!?")
	end

	drTest = XPLMFindDataRef("sim/cockpit2/ice/this_does_not_exist")
	if drTest ~= nil then
		dri = XPLMGetDataRefInfo(drTest)
		print("sim/cockpit2/ice/this_does_not_exist is a " .. dri.type)
		print("... and is " .. (XPLMCanWriteDataRef(drTest) and "" or "not ") .. "writeable")
		print("... and is " .. (XPLMIsDataRefGood(drTest) and "" or "not ") .. "valid")
		print("...  using " .. XPLMGetDataRefTypes(drTest) .. " datatype bitmask")
	else
		print("sim/cockpit2/ice/this_does_not_exist does not exist.")
	end

	drTest = XPLMFindDataRef("sim/cockpit2/radios/actuators/audio_selection_com2")
	local com2_on = XPLMGetDatai(drTest)
	print("COM2 is " .. (com2_on ~= 0 and "" or "not ") .. "selected")
	XPLMSetDatai(drTest, com2_on ~= 0 and 0 or 1)
	print("COM2 is " .. (XPLMGetDatai(drTest) ~= 0 and "" or "not ") .. "selected after being enabled")

	drTest = XPLMFindDataRef("sim/cockpit/radios/nav_type")

	print("Max size of 'sim/cockpit/radios/nav_type' array = " .. XPLMGetDatavi(drTest, nil, 0, 5))

	-- Lua will accept a different size of the output array because it resizes.
	local cnt = XPLMGetDatavi(drTest, ten_datarefs, 0, 5)
	print("Requested 5 items, got " .. cnt .. " with array size now " .. #ten_datarefs)
	for i, v in ipairs(ten_datarefs) do
		print("  " .. i .. ": " .. v)
	end

	cnt = XPLMGetDatavi(drTest, ten_datarefs, 3, 5)
	print("Requested 5 items from offset 3, got " .. cnt .. " with array size now " .. #ten_datarefs)
	for i, v in ipairs(ten_datarefs) do
		print("  " .. i .. ": " .. v)
	end

	drTest = XPLMFindDataRef("sim/cockpit2/switches/custom_slider_on")
	ten_datarefs = { 0, 1, 2, 3, 4 }
	XPLMSetDatavi(drTest, ten_datarefs, 0, 5)
	print("Results of setting 5 elements of an array at index 0:")
	cnt = XPLMGetDatavi(drTest, ten_datarefs, 0, 10)
	for i, v in ipairs(ten_datarefs) do
		print("  " .. i .. ": " .. v)
	end

	ten_datarefs = { 0, 1, 2, 3, 4 }
	XPLMSetDatavi(drTest, ten_datarefs, 3, 5)
	print("Results of setting 5 elements of an array at index 3:")
	cnt = XPLMGetDatavi(drTest, ten_datarefs, 0, 10)
	for i, v in ipairs(ten_datarefs) do
		print("  " .. i .. ": " .. v)
	end

	function TestGetArrayOfInts(refcon, outvalues, offset, max)
		if outvalues == nil then
			return 17
		end

		for i = 1, max do
			outvalues[i] = offset + i
		end

		return max
	end

	-- Custom datarefs
	drTest = XPLMRegisterDataAccessor("xlua/test/custom_accessors", XPLMDataTypeID.xplmType_Int, true,
		function(userRef) return g_custom_accessor_store end, function(userRef, val) print("Updating custom accessor to " .. val) g_custom_accessor_store = val end,
		nil, nil,						-- [GS]etDataf
		nil, nil,						-- [GS]etDatad
		TestGetArrayOfInts, nil,		-- [GS]etDatavi
		nil, nil,						-- [GS]etDatavf
		nil, nil,						-- [GS]etDatab
		"UD_read", "UD_write"
	)

	-- XPLM-method read:
	print("Custom dataref can provide up to " .. XPLMGetDatavi(drTest, nil, 0, 0) .. " items as an array.")

	print("Read custom dataref using XPLM: " .. XPLMGetDatai(drTest) .. " (should be 5)")

	XPLMSetDatai(drTest, 6)
	print("Read updated custom dataref using XPLM: " .. XPLMGetDatai(drTest) .. " (should be 6)")

	XPLMUnregisterDataAccessor(drTest)

	print("Read deleted custom dataref using XPLM: " .. XPLMGetDatai(drTest) .. " (should be 0, unreadable)")

--[[ Not implemented due to dependency issue.

	-- Shared data
	local function sharedDataCallback(userRef)
		print("Shared data " .. userRef .. " was written")
	end

	drShared = XPLMShareData("xlua/test/shared_data", XPLMDataTypeID.xplmType_Int, sharedDataCallback, 12345)
	drTest = XPLMFindDataRef("xlua/test/shared_data")
	XPLMSetDatai(drTest, 1)

	XPLMUnshareData("xlua/test/shared_data", XPLMDataTypeID.xplmType_Int, sharedDataCallback, 12345)

	drTest = XPLMFindDataRef("xlua/test/shared_data")
	if drTest ~= nil then
		print("xlua/test/shared_data was unshared, but still findable. Check that the callback does NOT fire:")
		XPLMSetDatai(drTest, 1)
		print("  Callback check should NOT have fired.")
	end
]]

	-----------------------------------------
	--[[      XPLMProcessing tests       ]]--
	-----------------------------------------
	print_banner("XPLMProcessing")

	if g_pre_fl_handle == nil then
		g_pre_fl_handle = XPLMCreateFlightLoop({
			["phase"] = XPLMFlightLoopPhaseType.xplm_FlightLoop_Phase_BeforeFlightModel,
			["callbackFunc"] = secondPreFlightLoop,
			["refcon"] = 0
		})
		XPLMScheduleFlightLoop(g_pre_fl_handle, 10, true)
	end

	if g_post_fl_handle == nil then
		g_post_fl_handle = XPLMCreateFlightLoop({
			["phase"] = XPLMFlightLoopPhaseType.xplm_FlightLoop_Phase_AfterFlightModel,
			["callbackFunc"] = PostFlightLoop,
			["refcon"] = 0
		})
		XPLMScheduleFlightLoop(g_post_fl_handle, -1, false)
	end

	-- Old-style flightloop registration is not supported.
	-- XPLMRegisterFlightLoopCallback

	
	--------------------------------------------
	--[[      XPLMDisplay/AVIONICS API      ]]--
	--------------------------------------------
	print_banner("XPLMDisplay/AVIONICS API")
	local avionicsHd = XPLMGetAvionicsHandle(XPLMDeviceID.xplm_device_G1000_PFD_1)
	if avionicsHd ~= nil then
		if XPLMIsAvionicsBound(avionicsHd) then
			print("Pilot has G1000")

			XPLMSetAvionicsBrightnessRheo(avionicsHd, 0.5)
			print("  Has " .. (100 * XPLMGetAvionicsBusVoltsRatio(avionicsHd)) .. "% voltage")
			
			local cursorOver, cursorCoords = XPLMIsCursorOverAvionics(avionicsHd)
			if cursorOver then
				print("Cursor is over G1000 at " .. cursorCoords.outX .. ", " .. cursorCoords.outY)
			end

			XPLMSetAvionicsPopupVisible(avionicsHd, true)
			local popupGeom = XPLMGetAvionicsGeometry(avionicsHd)
			print("Popup window is " .. popupGeom.outLeft .. ", " .. popupGeom.outLeft .. ", " .. popupGeom.outLeft .. ", " .. popupGeom.outLeft)
		else
			print("Pilot does not have G1000")
		end
	else
		print("No avionics handle for pilot's size G1000!")
	end

	local myAvionicsHd = XPLMRegisterAvionicsCallbacksEx({
			["deviceId"] = XPLMDeviceID.xplm_device_G1000_PFD_1,
			["drawCallbackAfter"] = function(inDeviceID, inIsBefore, userref)
										XPLMDrawString({1.0, 0.2, 0.2}, 50, 50, "XPLMDrawString says hi in Avionics!", nil, XPLMFontID.xplmFont_Proportional)
										XPLMDrawNumber({1.0, 0.2, 0.2}, 50, 35, XPLMGetElapsedTime(), 10, 3, true, XPLMFontID.xplmFont_Proportional)

										local cursorOver, cursorCoords = XPLMIsCursorOverAvionics(avionicsHd)
										if cursorOver then
											XPLMDrawString({1.0, 0.2, 0.2}, 50, 80, "Cursor is over G1000 at " .. cursorCoords.outX .. ", " .. cursorCoords.outY, nil, XPLMFontID.xplmFont_Proportional)
										end

										return true
									end,
			["userref"] = "abc"
	})
	---------------------------------------------------
	--[[      XPLMDisplay/WINDOW API excluded      ]]--
	---------------------------------------------------
	

	-----------------------------------------------------
	--[[      XPLMDisplay/KEY SNIFFERS excluded      ]]--
	-----------------------------------------------------
	-- Incompatible with composite key of function + refcon


	-----------------------------------------------
	--[[      XPLMDisplay/HOT KEYS tests       ]]--
	-----------------------------------------------
	print_banner("XPLMDisplay/HOT KEYS")

	print("There are " .. XPLMCountHotKeys() .. " hotkeys registered.")
	hotkey_ref = XPLMRegisterHotKey("A", XPLMKeyFlags.xplm_ControlFlag + XPLMKeyFlags.xplm_DownFlag, "A Lua-generated Hotkey", hotkey_callback, "Hotkey Refdata")
	print("There are " .. XPLMCountHotKeys() .. " hotkeys registered after adding a new one.")
	print("****************************************************")
	print("*** New hotkey registered to Ctrl+A! Try it out! ***")
	print("****************************************************")

	local hk_info = XPLMGetHotKeyInfo(XPLMGetNthHotKey(0))
	print("The first hotkey is '" .. hk_info.outDescription .. "'")
	local hk_info = XPLMGetHotKeyInfo(XPLMGetNthHotKey(9))				-- 0-based indexing.
	print("The tenth hotkey is '" .. hk_info.outDescription .. "'")

	--------------------------------------------------------
	--[[      XPLMScenery/Terrain Y-Testing tests       ]]--
	--[[      XPLMGraphics/X-PLANE COORDINATES tests    ]]--
	--------------------------------------------------------
	print_banner("XPLMScenery/Terrain Y-Testing")

	local userLat = XPLMGetDataf(drUserLat)
	local userLon = XPLMGetDataf(drUserLon)

	local probe = XPLMCreateProbe(XPLMProbeType.xplm_ProbeY)
	local localCoords = XPLMWorldToLocal(userLat, userLon, 0)
	print("Local coords are " .. localCoords.outX .. ", " .. localCoords.outZ .. ", " .. localCoords.outZ)

	local probeRes, probeDetails = XPLMProbeTerrainXYZ(probe, localCoords.outX, localCoords.outY, localCoords.outZ, {})
	print("Probe result: " .. probeRes)
	print("Terrain altitude at P0's location = " .. probeDetails.locationY)
	XPLMDestroyProbe(probe)

	---------------------------------------------------------
	--[[      XPLMScenery/Magnetic Variation tests       ]]--
	---------------------------------------------------------
	print_banner("XPLMScenery/Magnetic Variation")

	print("Magnetic variation at " .. userLat .. ", " .. userLon .. " is " .. XPLMGetMagneticVariation(userLat, userLon))
	print("30 degrees true at the user's location is " .. XPLMDegTrueToDegMagnetic(30) .. " degrees magnetic")
	print("30 degrees magnetic at the user's location is " .. XPLMDegMagneticToDegTrue(30) .. " degrees true")


	-----------------------------------------------------
	--[[      XPLMScenery/Library Access tests       ]]--
	-----------------------------------------------------
	print_banner("XPLMScenery/Library Access")

	print("Request flagpoles from the object library:")
	XPLMLookupObjects("lib/airport/Common_Elements/Miscellaneous/Flagpole.obj", userLat, userLon,
				function(filePath, userref)
					print(" - " .. filePath)
					g_flagpolePath = filePath
				end,
				555)
	print(" - Done.")

	-----------------------------------------------------
	--[[      XPLMScenery/Object Drawing tests       ]]--
	-----------------------------------------------------
	print_banner("XPLMScenery/Object Drawing")

	print("Requesting async load of a flagpole (" .. g_flagpolePath .. ")")
	XPLMLoadObjectAsync(g_flagpolePath,
						function(objRef, userref)
							if objRef ~= nil then
								print("  Flagpole loaded - userref " .. userref)
								XPLMUnloadObject(objRef)
							else
								print("  Flagpole NOT FOUND - userref " .. userref)
							end
						end,
						666)

	-----------------------------------------------------
	--[[      XPLMGraphics/X-PLANE GRAPHICS tests    ]]--
	-----------------------------------------------------
	-- Excluded.

	----------------------------------------------------
	--[[      XPLMGraphics/X-PLANE TEXT tests       ]]--
	----------------------------------------------------
	print_banner("XPLMGraphics/X-PLANE TEXT")
	local font_dims = XPLMGetFontDimensions(XPLMFontID.xplmFont_Proportional)
	print("Proportional font: W:" .. font_dims.outCharWidth .. ", H:" .. font_dims.outCharHeight .. ", Digits only: " .. (font_dims.outDigitsOnly and "true" or "false"))
	print("Pixel width of 'Hello World' = " .. XPLMMeasureString(XPLMFontID.xplmFont_Proportional, "Hello World", string.len("Hello World")))

	-------------------------------------
	--[[      XPLMCamera tests       ]]--
	-------------------------------------
	print_banner("XPLMCamera")
	print("Camera is" .. (XPLMIsCameraBeingControlled() and "" or " not") .. " being controlled.")

	local camPos = XPLMReadCameraPosition()
	print("Camera position is " .. camPos.x .. ", " .. camPos.y .. ", " .. camPos.z .. " on heading " .. camPos.heading)

	XPLMControlCamera(XPLMCameraControlDuration.xplm_ControlCameraUntilViewChanges,
					  function(cameraPos, isLosingControl, userref)
						if not isLosingControl then
							cameraPos.y = cameraPos.y + 0.05
						end

						return true
					  end,
					  777)

	---------------------------------------------------------------------
	--[[      XPLMMap/MAP LAYER CREATION AND DESTRUCTION tests       ]]--
	---------------------------------------------------------------------
	print_banner("XPLMGraphics/MAP LAYER CREATION AND DESTRUCTION")
--	local map_layer_def = XPLMCreateMapLayer_t()
--	map_layer_def.mapToCreateLayerIn = "XPLM_MAP_USER_INTERFACE"
--	map_layer_def.layerType = ...
--  These calls work as well as an ad-hoc table

	function cb_MapCreationCallback(userref)
		if XPLMMapExists("XPLM_MAP_USER_INTERFACE") and not XPLMMapExists("Lua Map Layer") then
			print("Creating new map layer!")

			local userLat = XPLMGetDataf(drUserLat)
			local userLon = XPLMGetDataf(drUserLon)

			XPLMCreateMapLayer({
				mapToCreateLayerIn	= "XPLM_MAP_USER_INTERFACE",
				layerType			= XPLMMapLayerType.xplm_MapLayer_Markings,
				showUiToggle		= true,
				layerName			= "Lua Map Layer",
				refcon				= "Map Layer Userref",
				-- Out of sequence, check it's still called/translated.
				iconCallback		= function(inLayer, inMapBoundsLeftTopRightBottom, zoomRatio, mapUnitsPerUserInterfaceUnit, mapStyle, projection, inRefcon)
											local proj = XPLMMapProject(projection, userLat + 0.05, userLon)
											XPLMDrawMapIconFromSheet(inLayer, "Resources/bitmaps/interface11/map.png", 0, 0, 8, 8, proj.outX, proj.outY, XPLMMapOrientation.xplm_MapOrientation_Map, 5, 48 * mapUnitsPerUserInterfaceUnit)
										end,
				labelCallback		= function(inLayer, inMapBoundsLeftTopRightBottom, zoomRatio, mapUnitsPerUserInterfaceUnit, mapStyle, projection, inRefcon)
											local proj = XPLMMapProject(projection, userLat + 0.05, userLon)
											XPLMDrawMapLabel(inLayer, "Lua-generated Map Label", proj.outX, proj.outY, XPLMMapOrientation.xplm_MapOrientation_Map, 5)
										end,
			})
		end
	end

	XPLMRegisterMapCreationHook(cb_MapCreationCallback, "map creation callback")
	if XPLMMapExists("XPLM_MAP_USER_INTERFACE") then
		cb_MapCreationCallback("already existed")
	end

	----------------------------------------------
	--[[      XPLMMap/MAP DRAWING tests       ]]--
	----------------------------------------------
	-- Done in the lambda above.


	----------------------------------------------------------
	--[[      XPLMPlanes/USER AIRCRAFT ACCESS tests       ]]--
	----------------------------------------------------------
	-- XPLMInitFlight()
	-- XPLMUpdateFlight()
	-- XPLMSetUsersAircraft
	-- XPLMPlaceUserAtAirport
	-- XPLMPlaceUserAtLocation

	------------------------------------------------------------
	--[[      XPLMPlanes/GLOBAL AIRCRAFT ACCESS tests       ]]--
	------------------------------------------------------------
	print_banner("XPLMGraphics/GLOBAL AIRCRAFT ACCESS")

	local acount = XPLMCountAircraft()
	print("There are " .. acount.outTotalAircraft .. " aircraft in total and " .. acount.outActiveAircraft .. " active.")

	local amodel = XPLMGetNthAircraftModel(0)
	print("Model 0 (user's aircraft) is " .. amodel.outFileName .. " at " .. amodel.outPath)


	---------------------------------------------------------------
	--[[      XPLMPlanes/EXCLUSIVE AIRCRAFT ACCESS tests       ]]--
	---------------------------------------------------------------
	print_banner("XPLMGraphics/EXCLUSIVE AIRCRAFT ACCESS")

	local function setup_planes()
		print("Setting up TCAS aircraft")
		XPLMSetActiveAircraftCount(g_num_tcas_acf + 1)
		haveTCASAircraft = true

		local drTCAS = XPLMFindDataRef("sim/operation/override/override_TCAS")
		XPLMSetDatai(drTCAS, 1)

		local modeS, p, b, h, rb, rd, ra = {}, {}, {}, {}, {}, {}, {}
		for i = 1, g_num_tcas_acf do
			modeS[i] = math.random(65536, 16777215)
			p[i] = math.random(-10.0, 10.0)
			b[i] = math.random(-10.0, 10.0)
			h[i] = 0
			rb[i] = math.random(0, 359)
			rd[i] = math.random(3000, 50000)
			ra[i] = 1000 + math.random(-500, 2000)
		end

		XPLMSetDatavi(drModeS,	 modeS, 0, g_num_tcas_acf)
		XPLMSetDatavf(drPitch,	 p, 0, g_num_tcas_acf)
		XPLMSetDatavf(drBank,	 b, 0, g_num_tcas_acf)
		XPLMSetDatavf(drHeading, h, 0, g_num_tcas_acf)

		XPLMSetDatavf(drRelBrg,	 rb, 0, g_num_tcas_acf)
		XPLMSetDatavf(drRelDis,	 rd, 0, g_num_tcas_acf)
		XPLMSetDatavf(drRelAlt,	 ra, 0, g_num_tcas_acf)
	end

	if XPLMAcquirePlanes(
		{
		  "Aircraft/Laminar Research/Beechcraft Baron 58/Baron_58.acf",
		  "Aircraft/Laminar Research/Cirrus SR22/Cirrus SR22.acf",
		  "Aircraft/Laminar Research/Lancair Evolution/N844X.acf"
		},
		setup_planes,
		54321)
	then
		setup_planes()
	end

	-------------------------------------------------------------------------
	--[[      XPLMInstance/Instance Creation and Destruction tests       ]]--
	-------------------------------------------------------------------------
	print_banner("XPLMInstance/Instance Creation and Destruction")

	g_AcfObjectPath = nil
	XPLMLookupObjects("lib/airport/aircraft/cargo/heavy_d.obj", userLat, userLon,
				function(filePath, userref)
					print(" - " .. filePath)
					g_AcfObjectPath = filePath
				end,
				555)
	XPLMLoadObjectAsync(g_AcfObjectPath,
						function(objRef, userref)
							if objRef ~= nil then
								for i = 1, g_num_tcas_acf do
									instanceRefs[i] = XPLMCreateInstance(objRef, { nil })
									XPLMUnloadObject(objRef)
								end
							else
								print("  Aircraft model NOT FOUND - userref " .. userref)
							end
						end,
						666)

	-------------------------------------------------------------------------
	--[[      XPLMInstance/Instance Manipulation tests       ]]--
	-------------------------------------------------------------------------
	-- Done above.

	------------------------------------------------
	--[[      XPLMSound/FMOD ACCESS tests       ]]--
	------------------------------------------------
	--[[
	local fmod_studio = XPLMGetFMODStudio()
	if fmod_studio ~= nil then
		local fmod_pilotradio = XPLMGetFMODChannelGroup(XPLMAudioBus.xplm_AudioRadioPilot)
		print("Pilot radio FMOD channel = " .. (fmod_pilotradio == nil and "nil" or fmod_pilotradio.to_string()))

		local buf = nil
		local pcm_chan = XPLMPlayPCMOnBus(buf, 0, 2, 
											16000, 1, false, XPLMAudioBus.xplm_AudioRadioPilot, 
											function(userref, fmod_result) end,
											"UsErReF"
										 )
	else
		print("FMOD Studio not available??!?")
	end
	]]

	return -1
end

function XPluginStart()
	-- One-off setup stuff here. You _can_ do setup globally, but this is more like a compiled plugin will do
	-- and keeps all your init in one place. Return false to say the script can't continue.
	print_banner("XPluginStart")

	custom_cmnd = XPLMCreateCommand("test/lua/commands", "Test creating a command from Lua")

	return true
end

function XPluginStop()
	-- One-off teardown stuff here. Called right before the script is unloaded.
	print_banner("XPluginStop")

	if g_pre_fl_handle ~= nil then
		XPLMDestroyFlightLoop(g_pre_fl_handle)
		g_pre_fl_handle = nil
	end

	if g_post_fl_handle ~= nil then
		XPLMDestroyFlightLoop(g_post_fl_handle)
		g_post_fl_handle = nil
	end
end

function XPluginEnable()
	-- One-off enable stuff here. This is normally called right after XPluginStart, the difference being that a
	-- script might be enabled and disabled during a flight. Do any setup here that you want to be able to undo
	-- if the user requests that this script is disabled.
	print_banner("XPluginEnable")

	return true
end

function XPluginDisable()
	-- One-off disable stuff here. Normally called right before XPluginStop, but can also be called at the user's request
	-- during a flight. Stop or reset any stuff that your script may have modified that the user might expect to stop happening.
	print("XPluginDisable")

	hotkey_count = 0
	g_flagpolePath = nil

	if haveTCASAircraft then
		XPLMReleasePlanes()
		XPLMSetActiveAircraftCount(1)

		haveTCASAircraft = false
		g_AcfObjectPath = nil
		instanceRefs = {}
	end
end

function XPluginReceiveMessage(inFromWho, inMessage, param)
	-- X-Plane will send you messages at key points, identified by "inMessage". Please see the XPLMPlugin header for details.
	local pi = XPLMGetPluginInfo(inFromWho)

	if type(param) ~= "nil" then
		print("Received message " .. inMessage .. " from '" .. tostring(inFromWho) .. "' with param " .. tostring(param))
	else
		print("Received message " .. inMessage .. " from '" .. tostring(inFromWho) .. "'")
	end

	if inFromWho == XPLM_PLUGIN_XPLANE then
		if inMessage == XPLM_MSG_AIRPORT_LOADED then
			FlightStarted()
		end
	end
end
