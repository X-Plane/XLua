--[[ XLua 2.0 ]]
-- PanelGraphicsTestPlugin.lua

require('XPLMPanelGraphics')

local PLUGIN_NAME        = "LuaPanelGraphicsTestPlugin"
local PLUGIN_SIGNATURE   = "xpsdk.examples.LuaPanelGraphicsTestPlugin"
local PLUGIN_DESCRIPTION = "A test of custom panel graphics drawing"

local c_screen_width = 1000.0
local c_screen_height = 500.0

local s_font = nil
local s_atlas = nil
local s_avionic = nil

local button_id = {
	lines = 1,
	linestrips = 2,
	lineloops = 3,
	polygons = 4,
	quadstrips = 5,
	fonts = 6,
	texture_atlas = 7,
	transforms = 8,
	scissors = 9,
	masks = 10,
	retained = 11,
	reload_plugin = 12
}

local s_current_tab = button_id.lines

local function draw_line(start_x, start_y, end_x, end_y, width, color)
	local verts = {
		{ x = start_x, y = start_y },
		{ x = end_x, y = end_y }
	}

	XPLMLinesWithWidth(color, width, verts, 2)
end

local function draw_button(x, y, text, id)
	local fontsize = 12
	local linewidth = 20
	local width = XPLMFontMeasureString(s_font, fontsize, text) + 10

	local z = {
		type = XPLMTouchZone.xplm_TouchZone_Identifier,
		identifier = id or -1,
		left = x,
		top = y + (linewidth / 2),
		right = x + width,
		bottom = y - (linewidth / 2)
	}

	local clicked = XPLMAccumulateTouchZone(z) == true
	local button_color
	if clicked then
		button_color = XPLMMakeColor(0.0, 1.0, 1.0, 1.0)
	else
		button_color = XPLMMakeColor(0.0, 0.0, 1.0, 0.5)
	end

	draw_line(x, y + 6, x + width, y + 6, linewidth, button_color)
	XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), fontsize, x + 5, y, text, XPLMJustification_t.xplm_JustLeft)

	return clicked
end

local function touch_event_cb(identifier, status, x, y, dx, dy, button, ref)
	if status ~= XPLMMouseStatus.xplm_MouseUp then
		return
	end

	if identifier > 0 then
		s_current_tab = identifier
	end

	if s_current_tab == button_id.reload_plugin then

		-- Assuming XPLMReloadThisPlugin exists in the environment or similar
		if XPLMReloadThisPlugin then
			XPLMReloadThisPlugin(false)
		end
	end
end

local function bezel_draw_cb(ambR, ambG, ambB, ref)
	local box = {
		{ x = 0.0,            y = 0.0,             color = XPLMMakeColor(0.0, 0.0, 0.0, 1.0)  },
		{ x = 0.0,            y = c_screen_height, color = XPLMMakeColor(0.0, 0.0, 0.0, 0.95) },
		{ x = c_screen_width, y = c_screen_height, color = XPLMMakeColor(0.0, 0.0, 0.0, 0.95) },
		{ x = c_screen_width, y = 0.0,             color = XPLMMakeColor(0.0, 0.0, 0.0, 1.0)  }
	}

	XPLMPolygonc(box, 4)
end

local function screen_draw_cb(ref)
	draw_line(0, c_screen_height / 2, c_screen_width, c_screen_height / 2, c_screen_width, XPLMMakeColor(0, 0, 0, 1))

	draw_button(25.0, c_screen_height - 25.0, "lines", button_id.lines)
	draw_button(25.0, c_screen_height - 50.0, "linestrips", button_id.linestrips)
	draw_button(25.0, c_screen_height - 75.0, "lineloops", button_id.lineloops)
	draw_button(25.0, c_screen_height - 100.0, "polygons", button_id.polygons)
	draw_button(25.0, c_screen_height - 100.0, "quadstrips", button_id.quadstrips)
	draw_button(25.0, c_screen_height - 125.0, "Fonts", button_id.fonts)
	draw_button(25.0, c_screen_height - 150.0, "Texture atlas", button_id.texture_atlas)
	draw_button(25.0, c_screen_height - 175.0, "Transforms", button_id.transforms)
	draw_button(25.0, c_screen_height - 200.0, "Scissors", button_id.scissors)
	draw_button(25.0, c_screen_height - 225.0, "Masks", button_id.masks)
	draw_button(25.0, c_screen_height - 250.0, "Retained drawing", button_id.retained)
	draw_button(25.0, c_screen_height - 275.0, "Reload this plugin!", button_id.reload_plugin)

	draw_line(175, 0, 175, c_screen_height, 5, XPLMMakeColor(1, 1, 1, 1))

	if s_current_tab == button_id.lines then
		local square = {
			{ x = 200.0, y = c_screen_height - 100.0 },
			{ x = 200.0, y = c_screen_height - 50.0 },
			{ x = 250.0, y = c_screen_height - 50.0 },
			{ x = 250.0, y = c_screen_height - 100.0 }
		}

		local font_y = c_screen_height - 25
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMLines small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMLines(XPLMMakeColor(1, 1, 0, 1), square, 4)

		font_y = font_y - 100.0
		for i=1,#square do square[i].y = square[i].y - 100.0 end
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMLinesWithWidth small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMLinesWithWidth(XPLMMakeColor(1, 1, 0, 1), 10.0, square, 4)

		font_y = font_y - 100.0
		local squareColor = {
			{ x = 200.0, y = square[1].y - 100, color = XPLMMakeColor(1, 0, 0, 1) },
			{ x = 200.0, y = square[2].y - 100, color = XPLMMakeColor(0, 1, 0, 1) },
			{ x = 250.0, y = square[3].y - 100, color = XPLMMakeColor(0, 0, 1, 1) },
			{ x = 250.0, y = square[4].y - 100, color = XPLMMakeColor(1, 1, 1, 1) }
		}
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMLinesc small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMLinesc(squareColor, 4)

		font_y = font_y - 100.0
		for i=1,#squareColor do squareColor[i].y = squareColor[i].y - 100.0 end
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMLinescWithWidth small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMLinescWithWidth(20.0, squareColor, 4)

		font_y = font_y - 100.0
		for i=1,#square do square[i].y = square[i].y - 100.0 end
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMLinesStipple small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMLinesStipple(XPLMMakeColor(1, 1, 0, 1), square, 4, 10.0, 5.0)

	elseif s_current_tab == button_id.lineloops then
		local square = {
			{ x = 200.0, y = c_screen_height - 100.0 },
			{ x = 200.0, y = c_screen_height - 50.0 },
			{ x = 250.0, y = c_screen_height - 50.0 },
			{ x = 250.0, y = c_screen_height - 100.0 }
		}

		local font_y = c_screen_height - 25
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMLineLoop small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMLineLoop(XPLMMakeColor(1, 1, 0, 1), square, 4)

		font_y = font_y - 100.0
		for i=1,#square do square[i].y = square[i].y - 100.0 end
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMLineLoopWithWidth small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMLineLoopWithWidth(XPLMMakeColor(1, 1, 0, 1), 10.0, square, 4)

		font_y = font_y - 100.0
		local squareColor = {
			{ x = 200.0, y = square[1].y - 100, color = XPLMMakeColor(1, 0, 0, 1) },
			{ x = 200.0, y = square[2].y - 100, color = XPLMMakeColor(0, 1, 0, 1) },
			{ x = 250.0, y = square[3].y - 100, color = XPLMMakeColor(0, 0, 1, 1) },
			{ x = 250.0, y = square[4].y - 100, color = XPLMMakeColor(1, 1, 1, 1) }
		}
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMLineLoopc small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMLineLoopc(squareColor, 4)

		font_y = font_y - 100.0
		for i=1,#squareColor do squareColor[i].y = squareColor[i].y - 100.0 end
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMLineLoopcWithWidth small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMLineLoopcWithWidth(20.0, squareColor, 4)

		font_y = font_y - 100.0
		for i=1,#square do square[i].y = square[i].y - 100.0 end
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMLineLoopStipple small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMLineLoopStipple(XPLMMakeColor(1, 1, 0, 1), square, 4, 10.0, 5.0)

	elseif s_current_tab == button_id.linestrips then
		local square = {
			{ x = 200.0, y = c_screen_height - 100.0 },
			{ x = 200.0, y = c_screen_height - 50.0 },
			{ x = 250.0, y = c_screen_height - 50.0 },
			{ x = 250.0, y = c_screen_height - 100.0 },
			{ x = 200.0, y = c_screen_height - 100.0 }
		}

		local font_y = c_screen_height - 25
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMLineStrip small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMLineStrip(XPLMMakeColor(1, 1, 0, 1), square, 5)

		font_y = font_y - 100.0
		for i=1,#square do square[i].y = square[i].y - 100.0 end
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMLineStripWithWidth small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMLineStripWithWidth(XPLMMakeColor(1, 1, 0, 1), 10.0, square, 5)

		font_y = font_y - 100.0
		local squareColor = {
			{ x = 200.0, y = square[1].y - 100, color = XPLMMakeColor(1, 0, 0, 1) },
			{ x = 200.0, y = square[2].y - 100, color = XPLMMakeColor(0, 1, 0, 1) },
			{ x = 250.0, y = square[3].y - 100, color = XPLMMakeColor(0, 0, 1, 1) },
			{ x = 250.0, y = square[4].y - 100, color = XPLMMakeColor(1, 1, 1, 1) },
			{ x = 200.0, y = square[5].y - 100, color = XPLMMakeColor(1, 0, 0, 1) }
		}
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMLineStripc small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMLineStripc(squareColor, 5)

		font_y = font_y - 100.0
		for i=1,#squareColor do squareColor[i].y = squareColor[i].y - 100.0 end
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMLineStripcWithWidth small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMLineStripcWithWidth(20.0, squareColor, 5)

		font_y = font_y - 100.0
		for i=1,#square do square[i].y = square[i].y - 100.0 end
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMLineStripWithWidth small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMLineStripStipple(XPLMMakeColor(1, 1, 0, 1), square, 5, 10.0, 5.0)

	elseif s_current_tab == button_id.polygons then
		local square = {
			{ x = 200.0, y = c_screen_height - 100.0 },
			{ x = 200.0, y = c_screen_height - 50.0 },
			{ x = 250.0, y = c_screen_height - 50.0 },
			{ x = 250.0, y = c_screen_height - 100.0 },
			{ x = 200.0, y = c_screen_height - 100.0 }
		}

		local font_y = c_screen_height - 25
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMPolygon small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMPolygon(XPLMMakeColor(1, 1, 0, 1), square, 5)

		font_y = font_y - 100.0
		for i=1,#square do square[i].y = square[i].y - 100.0 end
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMPolygonWithWidth small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMPolygonWithWidth(XPLMMakeColor(1, 1, 0, 1), 10.0, square, 5)

		font_y = font_y - 100.0
		local squareColor = {
			{ x = 200.0, y = square[1].y - 100, color = XPLMMakeColor(1, 0, 0, 1) },
			{ x = 200.0, y = square[2].y - 100, color = XPLMMakeColor(0, 1, 0, 1) },
			{ x = 250.0, y = square[3].y - 100, color = XPLMMakeColor(0, 0, 1, 1) },
			{ x = 250.0, y = square[4].y - 100, color = XPLMMakeColor(1, 1, 1, 1) },
			{ x = 200.0, y = square[5].y - 100, color = XPLMMakeColor(1, 0, 0, 1) }
		}
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMPolygonc small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMPolygonc(squareColor, 5)

		font_y = font_y - 100.0
		for i=1,#squareColor do squareColor[i].y = squareColor[i].y - 100.0 end
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMPolygoncWithWidth small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMPolygoncWithWidth(20.0, squareColor, 5)

	elseif s_current_tab == button_id.quadstrips then
		local square = {
			{ x = 200.0, y = c_screen_height - 100.0 },
			{ x = 200.0, y = c_screen_height - 50.0 },
			{ x = 250.0, y = c_screen_height - 50.0 },
			{ x = 250.0, y = c_screen_height - 100.0 }
		}

		local font_y = c_screen_height - 25
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMQuadstrip small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMQuadstrip(XPLMMakeColor(1, 1, 0, 1), square, 4)

		font_y = font_y - 100.0
		for i=1,#square do square[i].y = square[i].y - 100.0 end
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMQuadstripWithWidth small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMQuadstripWithWidth(XPLMMakeColor(1, 1, 0, 1), 10.0, square, 4)

		font_y = font_y - 100.0
		local squareColor = {
			{ x = 200.0, y = square[1].y - 100, color = XPLMMakeColor(1, 0, 0, 1) },
			{ x = 200.0, y = square[2].y - 100, color = XPLMMakeColor(0, 1, 0, 1) },
			{ x = 250.0, y = square[3].y - 100, color = XPLMMakeColor(0, 0, 1, 1) },
			{ x = 250.0, y = square[4].y - 100, color = XPLMMakeColor(1, 1, 1, 1) }
		}
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMQuadstripc small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMQuadstripc(squareColor, 4)

		font_y = font_y - 100.0
		for i=1,#squareColor do squareColor[i].y = squareColor[i].y - 100.0 end
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, "XPLMQuadstripcWithWidth small square:", XPLMJustification_t.xplm_JustLeft)
		XPLMQuadstripcWithWidth(20.0, squareColor, 4)

	elseif s_current_tab == button_id.fonts then
		local function create_box(x, y, width, height)
			return {
				{ x = x,         y = y + height  },
				{ x = x,         y = y },
				{ x = x + width, y = y },
				{ x = x + width, y = y + height  }
			}
		end

		local font_y = c_screen_height - 25

		local metrics = XPLMFontGetMetrics(s_font, 15)
		local s = string.format("XPLMFontGetMetrics() for fontsize 15. lineHeight: %.2f, lineAscent %.2f, lineDescent: %.2f", metrics.lineHeight, metrics.lineAscent, metrics.lineDescent)
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 12, 200, font_y, s, XPLMJustification_t.xplm_JustLeft)

		font_y = font_y - 30
		local test_string = "This string should fit exactly in this box"
		local width = XPLMFontMeasureString(s_font, 15, test_string)

		local fitting_box = create_box(200.0, font_y - metrics.lineDescent, width, metrics.lineHeight)
		XPLMLineLoop(XPLMMakeColor(1, 1, 1, 1), fitting_box, 4)
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 15, 200, font_y, test_string, XPLMJustification_t.xplm_JustLeft)

		font_y = font_y - 30
		local justified_box = create_box(200.0, font_y - metrics.lineDescent, width + 50.0, metrics.lineHeight)
		test_string = "This string should be left-justified in this box"
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 15, 200, font_y, test_string, XPLMJustification_t.xplm_JustLeft)
		XPLMLineLoop(XPLMMakeColor(1, 1, 1, 1), justified_box, 4)

		font_y = font_y - 30
		test_string = "This string should be right-justified in this box"
		width = XPLMFontMeasureString(s_font, 15, test_string)
		justified_box = create_box(200.0, font_y - metrics.lineDescent, width + 50.0, metrics.lineHeight)
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 15, justified_box[4].x, font_y, test_string, XPLMJustification_t.xplm_JustRight)
		XPLMLineLoop(XPLMMakeColor(1, 1, 1, 1), justified_box, 4)

		font_y = font_y - 30
		test_string = "This string should be center-justified in this box"
		width = XPLMFontMeasureString(s_font, 15, test_string)
		justified_box = create_box(200.0, font_y - metrics.lineDescent, width + 50.0, metrics.lineHeight)
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 15, (justified_box[1].x + justified_box[4].x) / 2, font_y, test_string, XPLMJustification_t.xplm_JustCenter)
		XPLMLineLoop(XPLMMakeColor(1, 1, 1, 1), justified_box, 4)

		font_y = font_y - 30
		test_string = "This string should be fixed-width and fit exactly in this box"
		width = #test_string * 10
		justified_box = create_box(200.0, font_y - metrics.lineDescent, width, metrics.lineHeight)
		XPLMFontDrawStringFixedSpacing(s_font, XPLMMakeColor(1, 0, 0, 1), 15, 200.0, font_y, test_string, 10.0, XPLMJustification_t.xplm_JustLeft)
		XPLMLineLoop(XPLMMakeColor(1, 1, 1, 1), justified_box, 4)

		font_y = font_y - 30
		test_string = "This string should be multi-line and fit exactly in this box"
		width = 200.0
		local lineCount = XPLMFontGetLineCount(s_font, 15.0, test_string, 200.0)
		justified_box = create_box(200.0, font_y + metrics.lineAscent - lineCount * metrics.lineHeight, width, metrics.lineHeight * lineCount)
		XPLMFontDrawStringWordWrapped(s_font, XPLMMakeColor(1, 0, 0, 1), 15, 200.0, font_y, test_string, 200.0, XPLMJustification_t.xplm_JustLeft)
		XPLMLineLoop(XPLMMakeColor(1, 1, 1, 1), justified_box, 4)

		font_y = font_y - 30
		test_string = "This string vertical!"
		width = XPLMFontMeasureString(s_font, 15, test_string)
		justified_box = create_box(c_screen_width - 50.0, font_y - metrics.lineDescent, metrics.lineHeight, width)
		XPLMFontDrawStringRotated(s_font, XPLMMakeColor(1, 0, 0, 1), 15, c_screen_width - 50.0 + metrics.lineDescent, font_y + width, test_string, 90.0, XPLMJustification_t.xplm_JustLeft)
		XPLMLineLoop(XPLMMakeColor(1, 1, 1, 1), justified_box, 4)

		font_y = font_y - 30
		test_string = "This string should be cut-off by the box"
		width = XPLMFontMeasureString(s_font, 15, test_string) - 50.0
		justified_box = create_box(200.0, font_y - metrics.lineDescent, width, metrics.lineHeight)
		local fit = XPLMFontFitForward(s_font, 15.0, test_string, width)
		local display_string = string.sub(test_string, 1, fit)
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 15, 200.0, font_y, display_string, XPLMJustification_t.xplm_JustLeft)
		XPLMLineLoop(XPLMMakeColor(1, 1, 1, 1), justified_box, 4)

		font_y = font_y - 30
		test_string = "This string should be cut-off by the box"
		width = XPLMFontMeasureString(s_font, 15, test_string) - 50.0
		justified_box = create_box(200.0, font_y - metrics.lineDescent, width, metrics.lineHeight)
		fit = XPLMFontFitReverse(s_font, 15.0, test_string, width)
		display_string = string.sub(test_string, fit + 1)
		XPLMFontDrawString(s_font, XPLMMakeColor(1, 0, 0, 1), 15, 200.0, font_y, display_string, XPLMJustification_t.xplm_JustLeft)
		XPLMLineLoop(XPLMMakeColor(1, 1, 1, 1), justified_box, 4)

	elseif s_current_tab == button_id.texture_atlas then
		if not framecounter then framecounter = 0 end
		framecounter = framecounter + 1

		local z = {
			type = xplm_TouchZone_Command,
			command = XPLMFindCommand("sim/operation/pause_toggle"),
			left = 400 - XPLMTextureAtlasGetImageWidth(s_atlas, 11) / 2,
			right = 400 + XPLMTextureAtlasGetImageWidth(s_atlas, 11) / 2,
			bottom = 300 - XPLMTextureAtlasGetImageHeight(s_atlas, 11) / 2,
			top = 300 + XPLMTextureAtlasGetImageHeight(s_atlas, 11) / 2
		}

		local clicked = XPLMAccumulateTouchZone(z) ~= 0

		XPLMTextureAtlasDrawScaled(s_atlas, 11, XPLMMakeColor(1, clicked and 0 or 1, 1, 1),
				400, 420,
				XPLMTextureAtlasGetImageWidth(s_atlas, 11) / 2,
				XPLMTextureAtlasGetImageHeight(s_atlas, 11) / 2,
				1.0, 1.0, 0.0)

		XPLMTextureAtlasDrawScaled(s_atlas, 12, XPLMMakeColor(1, 1, 1, 1),
				400, 420,
				XPLMTextureAtlasGetImageWidth(s_atlas, 12) / 2,
				XPLMTextureAtlasGetImageHeight(s_atlas, 12) / 2,
				1.0, 1.0, framecounter)

		XPLMTextureAtlasDrawStretched(s_atlas, 10, XPLMMakeColor(1, 1, 1, 1), 205, 300, 600, 10)

		local img = math.floor(framecounter / 30)
		if img > 8 then img = 8 end

		XPLMTextureAtlasDrawAt(s_atlas, img, XPLMMakeColor(1, 1, 0.3, 1), 250, 80)

		XPLMTextureAtlasDrawIn(s_atlas, 9, XPLMMakeColor(1, 1, 1, 1), 200, 100, 230, 20)

		if framecounter > 300 then
			framecounter = 0
		end

	elseif s_current_tab == button_id.transforms then
		if not x_offset then
			x_offset = 0
			y_offset = 0
			x_scale = 1.0
			y_scale = 1.0
		end

		if draw_button(225.0, c_screen_height - 25.0, "Move left") then     x_offset = x_offset - 1.0 end
		if draw_button(225.0, c_screen_height - 50.0, "Move right") then    x_offset = x_offset + 1.0 end
		if draw_button(225.0, c_screen_height - 75.0, "Move up") then       y_offset = y_offset + 1.0 end
		if draw_button(225.0, c_screen_height - 100.0, "Move down") then    y_offset = y_offset - 1.0 end
		if draw_button(225.0, c_screen_height - 125.0, "Scale x up") then   x_scale = x_scale + 0.001 end
		if draw_button(225.0, c_screen_height - 150.0, "Scale x down") then x_scale = x_scale - 0.001 end
		if draw_button(225.0, c_screen_height - 175.0, "Scale y up") then   y_scale = y_scale + 0.001 end
		if draw_button(225.0, c_screen_height - 200.0, "Scale y down") then y_scale = y_scale - 0.001 end

		local square = {
			{ x = c_screen_width / 2 + 50.0, y = c_screen_height / 2 + 50.0 },
			{ x = c_screen_width / 2 - 50.0, y = c_screen_height / 2 + 50.0 },
			{ x = c_screen_width / 2 - 50.0, y = c_screen_height / 2 - 50.0 },
			{ x = c_screen_width / 2 + 50.0, y = c_screen_height / 2 - 50.0 }
		}

		XPLMFontDrawString(s_font, XPLMMakeColor(1, 1, 1, 1), 15, c_screen_width / 2, c_screen_height / 2,  "Orig", XPLMJustification_t.xplm_JustCenter)
		XPLMLineLoop(XPLMMakeColor(1, 1, 1, 1), square, 4)

		XPLMTransformPush()

		if x_scale ~= 1.0 or y_scale ~= 1.0 then
			XPLMTransformScale(x_scale, y_scale)
		end

		XPLMFontDrawString(s_font, XPLMMakeColor(1, 1, 1, 1), 15,  c_screen_width / 2, c_screen_height / 2,  "Scaled only", XPLMJustification_t.xplm_JustCenter)
		XPLMLineLoop(XPLMMakeColor(1, 1, 1, 1), square, 4)

		XPLMTransformPush()
		if x_offset ~= 0.0 or y_offset ~= 0.0 then
			XPLMTransformTranslate(x_offset, y_offset)
		end

		XPLMFontDrawString(s_font, XPLMMakeColor(1, 1, 1, 1), 15,  c_screen_width / 2, c_screen_height / 2,  "Scaled and translated", XPLMJustification_t.xplm_JustCenter)
		XPLMLineLoop(XPLMMakeColor(1, 1, 1, 1), square, 4)

		XPLMTransformPop()
		XPLMTransformPop()

	elseif s_current_tab == button_id.scissors then
		if not scissor_top then
			scissor_top = c_screen_height
			scissor_left = 400.0
			scissor_bottom = 0.0
			scissor_right = c_screen_width
		end

		if draw_button(225.0, c_screen_height - 25.0, "Move left edge to the right") then     scissor_left   = scissor_left   + 1.0 end
		if draw_button(225.0, c_screen_height - 50.0, "Move left edge to the left") then      scissor_left   = scissor_left   - 1.0 end
		if draw_button(225.0, c_screen_height - 75.0, "Move right edge to the right") then    scissor_right  = scissor_right  + 1.0 end
		if draw_button(225.0, c_screen_height - 100.0, "Move right edge to the left") then    scissor_right  = scissor_right  - 1.0 end
		if draw_button(225.0, c_screen_height - 125.0, "Move top edge down") then             scissor_top    = scissor_top    - 1.0 end
		if draw_button(225.0, c_screen_height - 150.0, "Move top edge up") then               scissor_top    = scissor_top    + 1.0 end
		if draw_button(225.0, c_screen_height - 175.0, "Move bottom edge down") then          scissor_bottom = scissor_bottom - 1.0 end
		if draw_button(225.0, c_screen_height - 200.0, "Move bottom edge up") then            scissor_bottom = scissor_bottom + 1.0 end
		local shrink = draw_button(225.0, c_screen_height - 225.0, "Shrink by 50 pixels")

		local square = {
			{ x = scissor_left,  y = scissor_top    },
			{ x = scissor_right, y = scissor_top    },
			{ x = scissor_right, y = scissor_bottom },
			{ x = scissor_left,  y = scissor_bottom }
		}

		XPLMFontDrawString(s_font, XPLMMakeColor(1, 1, 1, 1), 15, c_screen_width / 2, c_screen_height / 2,  "Orig", XPLMJustification_t.xplm_JustCenter)
		XPLMLineLoopWithWidth(XPLMMakeColor(1, 0, 0, 1), 5.0,  square, 4)

		XPLMScissorPush()

		local line = {
			{ x = 400.0, y = c_screen_height / 2 },
			{ x = c_screen_width, y = c_screen_height / 2 }
		}

		XPLMScissorSet(scissor_top, scissor_left, scissor_bottom, scissor_right)

		if shrink then
			XPLMScissorShrink(scissor_top - 50.0, scissor_left + 50.0, scissor_bottom + 50.0, scissor_right - 50.0)
		end

		XPLMLinesWithWidth(XPLMMakeColor(1, 1, 1, 0.5), c_screen_height, line, 2)
		XPLMScissorPop()

	elseif s_current_tab == button_id.masks then
		XPLMBeginSetupStencilMask(1, 1)
		local diamond = {
			{ x = c_screen_width / 2 - 150, y = c_screen_height / 2 + 0 },
			{ x = c_screen_width / 2 + 0,   y = c_screen_height / 2 + 150 },
			{ x = c_screen_width / 2 + 150, y = c_screen_height / 2 - 0 },
			{ x = c_screen_width / 2 - 0,   y = c_screen_height / 2 - 150 }
		}

		XPLMPolygon(XPLMMakeColor(1, 0, 1, 1), diamond, 4)

		XPLMTextureAtlasDrawScaled(s_atlas, 11, XPLMMakeColor(1, 0, 1, 1),
			c_screen_width / 2 + 150, c_screen_height / 2,
			XPLMTextureAtlasGetImageWidth(s_atlas, 11) / 2,
			XPLMTextureAtlasGetImageHeight(s_atlas, 11) / 2,
			1.0, 1.0, 0.0)

		XPLMEndSetupStencilMask()

		XPLMUseStencilMask(1, 1)

		for i = -10, 10 do
			local line = {
				{ x = 200.0, y = c_screen_height / 2 + 15.0 * i },
				{ x = c_screen_width, y = c_screen_height / 2 + 15.0 * i }
			}
			XPLMLinesWithWidth(XPLMMakeColor(0, 0, 1, 1.0), 8.0, line, 2)
		end
		XPLMClearStencilMask()

	elseif s_current_tab == button_id.retained then
		XPLMBeginRetainedDrawing()
		local square = {
			{ x = c_screen_width / 2 - 50, y = c_screen_height / 2 + 50 },
			{ x = c_screen_width / 2 + 50, y = c_screen_height / 2 + 50 },
			{ x = c_screen_width / 2 + 50, y = c_screen_height / 2 - 50 },
			{ x = c_screen_width / 2 - 50, y = c_screen_height / 2 - 50 }
		}

		XPLMLineLoop(XPLMMakeColor(1, 1, 1, 1), square, 4)

		local drawing = XPLMEndRetainedDrawing()

		XPLMDrawRetained(drawing)

		XPLMTransformPush()
		XPLMTransformTranslate(150.0, 150.0)
		XPLMTransformRotate(c_screen_width / 2 + 150.0, c_screen_height / 2 + 150, 45.0)
		XPLMDrawRetained(drawing)
		XPLMTransformPop()

		XPLMDestroyRetainedDrawing(drawing)
	end
end

function print_table(t)
    for k, v in pairs(t) do
        print(k, v)
    end
end

-- Plugin Lifecycle
function XPluginStart()
	print("[Lua] XPluginStart")

	s_font = XPLMCreateFont(XPLMCharSet_t.xplm_CharSetUnicode)
	XPLMFontAddFace(s_font, "Resources/fonts/DejaVuSans.ttf")

	s_atlas = XPLMCreateTextureAtlas()
	XPLMTextureAtlasAddImageFile(s_atlas, "Resources/bitmaps/cockpit/generic/gen_handle.png")
	XPLMTextureAtlasAddImageFile(s_atlas, "Resources/bitmaps/cockpit/generic/gen_handle-1.png")
	XPLMTextureAtlasAddImageFileSet(s_atlas, "Resources/bitmaps/cockpit/generic/gen_rotary-1.png", 7, 1)

-- 	local grad = { 0,  0,   0,   255,
-- 	              255, 255, 255, 255,
-- 	              0,   15,  30,  255,
-- 	              255, 180, 150, 255 }
-- 	XPLMTextureAtlasAddImageSet(s_atlas, grad, 2, 2, 1, 1)

	XPLMTextureAtlasAddImageFile(s_atlas, "Resources/bitmaps/cockpit/ECAM/ECAM_carter.png")
	XPLMTextureAtlasAddImageFile(s_atlas, "Resources/bitmaps/cockpit/generic/gen_needle.png")
	XPLMTextureAtlasAddImageFile(s_atlas, "Resources/bitmaps/cockpit/generic/gen_needle-1.png")

	XPLMTextureAtlasBake(s_atlas)

	return true
end

function XPluginStop()
	print("[Lua] XPluginStop")
	if s_font then
		XPLMDestroyFont(s_font)
		s_font = nil
	end
	if s_atlas then
		XPLMDestroyTextureAtlas(s_atlas)
		s_atlas = nil
	end
end

function XPluginEnable()
	print("[Lua] XPluginEnable")
	local cavio = {
		screenWidth = math.floor(c_screen_width),
		screenHeight = math.floor(c_screen_height),
		bezelWidth = math.floor(c_screen_width),
		bezelHeight = math.floor(c_screen_height),
		bezelDrawCallback = bezel_draw_cb,
		drawCallback = screen_draw_cb,
		deviceID = "custom_avionic",
		deviceName = "Custom Avionic",
		native = 1
	}

	s_avionic = XPLMCreateAvionicsEx(cavio)
	XPLMSetAvionicsPopupVisible(s_avionic, true)
	XPLMSetTouchEventHandler(s_avionic, touch_event_cb)

	return true
end

function XPluginDisable()
	print("[Lua] XPluginDisable")
	if s_avionic then
		XPLMDestroyAvionics(s_avionic)
		s_avionic = nil
	end
end

function XPluginReceiveMessage(inFromWho, inMessage, inParam)
	print("[Lua] XPluginReceiveMessage")
end
