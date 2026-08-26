local colors = require("colors")
local settings = require("settings")

-- Shared construct for the saturation widgets: a live graph with two stacked
-- text lines to its right.
--
-- The top line has width 0 so it overlaps the bottom one instead of reserving
-- its own column; opposite y_offsets pull them apart vertically. Right-region
-- items draw right-aligned, so the zero-width line has to be added BEFORE the
-- sized one — its text then extends leftward across it. Added after, it lands
-- beside the sized line instead. (A left-to-right region needs the same order
-- for the opposite reason: there the zero-width box reserves no advance, so the
-- sized line starts at the same origin.) The graph is added last to end up
-- left of both.
--
-- NOTE: a zero-width *graph* allocates a zero-length sample buffer and
-- segfaults in graph_draw, so the graph is always positively sized. A
-- zero-width *item*, like the top line, is fine.

local M = {}

local POSITION = "right"
local GRAPH_WIDTH = 35

-- Every tick redraws each graph, which is real GPU work in the compositor.
-- network.lua derives its rates from this, so the one knob stays consistent.
M.UPDATE_FREQ = 5

-- Clicking anywhere on any of the widgets opens Activity Monitor.
local CLICK_SCRIPT = "open -a 'Activity Monitor'"

local function text_item(name, spec, y_offset, width)
	return sbar.add("item", name, {
		position = POSITION,
		width = width,
		click_script = CLICK_SCRIPT,
		icon = { drawing = false },
		label = {
			string = spec.string,
			font = {
				family = spec.family or settings.font.text,
				style = settings.font.style_map[spec.style],
				size = spec.size,
			},
			color = spec.color,
			y_offset = y_offset,
		},
	})
end

-- The stacked label pair on its own, for widgets that show a value without a
-- graph. `padding_left` is the gap to the widget on its left, which the graph
-- otherwise provides.
function M.text_pair(opts)
	local top = text_item(opts.name .. ".top", opts.top, opts.top.y_offset or 6, 0)
	local bottom = text_item(opts.name .. ".bottom", opts.bottom, opts.bottom.y_offset or -4)
	return { top = top, bottom = bottom }
end

function M.build(opts)
	local w = M.text_pair(opts)
	local top, bottom = w.top, w.bottom

	local graph = sbar.add("graph", opts.name, GRAPH_WIDTH, {
		position = POSITION,
		click_script = CLICK_SCRIPT,
		graph = {
			color = opts.color,
			fill_color = colors.with_alpha(opts.color, 0.30),
			line_width = 1.5,
		},
		background = { height = 24, drawing = true, color = colors.transparent },
		icon = { drawing = false },
		label = { drawing = false },
		-- Gap to the previous widget, and the pill's left inset on the first one.
		padding_left = 4,
		update_freq = M.UPDATE_FREQ,
	})

	return { graph = graph, top = top, bottom = bottom }
end

function M.recolor(w, color)
	w.graph:set({ graph = { color = color, fill_color = colors.with_alpha(color, 0.30) } })
end

-- Same ladder the battery widget uses, on a 0..100 scale.
function M.threshold_color(pct)
	if pct >= 80 then
		return colors.love
	elseif pct >= 50 then
		return colors.orange
	elseif pct >= 25 then
		return colors.gold
	end
	return colors.accent
end

return M
