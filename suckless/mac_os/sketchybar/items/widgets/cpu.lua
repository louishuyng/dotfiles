local colors = require("colors")
local settings = require("settings")

-- Live CPU graph with a stacked text readout to its right, à la FelixKratz:
-- a tiny "CPU" caption (raised) sitting on top of the live percentage (lowered).
-- The two pieces are separate items with opposite y_offsets; the caption has
-- width 0 so it overlaps the percentage instead of reserving its own column.
--
-- A single graph plots total CPU usage (user + system) over time, with a
-- translucent fill for an area-chart look.
--
-- NOTE: the FelixKratz config stacks two *graphs* by giving the `sys` graph
-- width 0 so it overlaps the `user` graph. On sketchybar v2.24 a zero-width
-- graph allocates a zero-length sample buffer and segfaults in graph_draw, so
-- we use one positively-sized graph instead. (A zero-width *item*, like the
-- caption below, is fine — only graphs crash.)
local GRAPH_WIDTH = 35

-- Clicking anywhere on the widget opens Activity Monitor.
local CLICK_SCRIPT = "open -a 'Activity Monitor'"

-- Added first so they land to the *right* of the graph in the right region.
-- caption: the small "CPU" word, raised and overlapping the percentage.
local cpu_caption = sbar.add("item", "widgets.cpu.caption", {
	position = "right",
	width = 0,
	click_script = CLICK_SCRIPT,
	icon = { drawing = false },
	label = {
		string = "CPU",
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Semibold"],
			size = 8.0,
		},
		color = colors.with_alpha(colors.white, 0.6),
		y_offset = 6,
	},
})

-- percent: the live figure, lowered to sit under the caption.
local cpu_percent = sbar.add("item", "widgets.cpu.percent", {
	position = "right",
	click_script = CLICK_SCRIPT,
	icon = { drawing = false },
	label = {
		string = "0%",
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Bold"],
			size = 12.0,
		},
		color = colors.white,
		y_offset = -4,
	},
})

local cpu = sbar.add("graph", "widgets.cpu", GRAPH_WIDTH, {
	position = "right",
	click_script = CLICK_SCRIPT,
	graph = {
		color = colors.blue,
		fill_color = colors.with_alpha(colors.blue, 0.30),
		line_width = 1.5,
	},
	background = { height = 24, drawing = true, color = colors.transparent },
	icon = { drawing = false },
	label = { drawing = false },
	update_freq = 2,
})

cpu:subscribe({ "routine", "system_woke", "forced" }, function()
	-- top -l 2 samples twice so the second reading reflects a real interval
	-- delta rather than an instantaneous (and misleading) snapshot.
	sbar.exec([[top -l 2 -n 0 | grep -E "^CPU usage" | tail -1]], function(out)
		local user = tonumber(out:match("([%d%.]+)%% user")) or 0
		local sys = tonumber(out:match("([%d%.]+)%% sys")) or 0
		local used = user + sys
		local pct = math.floor(used + 0.5)

		-- Recolour the graph + percentage by load, like the battery widget does.
		local color
		if used >= 80 then
			color = colors.love
		elseif used >= 50 then
			color = colors.orange
		elseif used >= 25 then
			color = colors.gold
		else
			color = colors.blue
		end

		cpu:set({
			graph = { color = color, fill_color = colors.with_alpha(color, 0.30) },
		})
		cpu_percent:set({ label = { string = pct .. "%", color = color } })
		-- Graphs expect normalised values in the 0..1 range.
		cpu:push({ used / 100.0 })
	end)
end)
