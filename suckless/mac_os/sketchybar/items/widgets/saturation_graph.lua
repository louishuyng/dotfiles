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
local PROCESS_ROWS = 5
local active_process_popup

local function process_click_script(pid, fallback)
	local id = pid:match("^#(%d+)$")
	if not id then
		return fallback
	end
	return "path=$(ps -p "
		.. id
		.. ' -o comm=); case "$path" in *.app/*) open "${path%%.app/*}.app" ;; *) '
		.. fallback
		.. " ;; esac"
end

local function text_item(name, spec, y_offset, width, click_script)
	return sbar.add("item", name, {
		position = POSITION,
		width = width,
		click_script = click_script,
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
	local click_script = opts.click_script or CLICK_SCRIPT
	local top = text_item(opts.name .. ".top", opts.top, opts.top.y_offset or 6, 0, click_script)
	local bottom = text_item(opts.name .. ".bottom", opts.bottom, opts.bottom.y_offset or -4, nil, click_script)
	return { top = top, bottom = bottom }
end

function M.build(opts)
	local w = M.text_pair(opts)
	local top, bottom = w.top, w.bottom
	local click_script = opts.click_script or CLICK_SCRIPT

	local graph = sbar.add("graph", opts.name, GRAPH_WIDTH, {
		position = POSITION,
		click_script = click_script,
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

	w.graph = graph
	w.click_script = click_script
	return w
end

function M.process_popup(w, command)
	local rows = {}
	local hover_version = 0
	for i = 1, PROCESS_ROWS do
		rows[i] = sbar.add("item", "popup." .. w.graph.name .. ".process." .. i, {
			position = "popup." .. w.graph.name,
			click_script = w.click_script,
			scroll_texts = false,
			icon = {
				width = 135,
				align = "left",
				font = { family = settings.font.text, style = settings.font.style_map["Semibold"], size = 11.0 },
				padding_left = 10,
				padding_right = 5,
			},
			label = {
				width = 80,
				align = "right",
				font = { family = settings.font.numbers, style = settings.font.style_map["Bold"], size = 11.0 },
				padding_left = 5,
				padding_right = 10,
			},
		})
	end

	local function show()
		hover_version = hover_version + 1
		if active_process_popup and active_process_popup ~= w.graph then
			active_process_popup:set({ popup = { drawing = false } })
		end
		active_process_popup = w.graph

		sbar.exec(command, function(out)
			if active_process_popup ~= w.graph then
				return
			end
			local i = 1
			for line in out:gmatch("[^\r\n]+") do
				if i > PROCESS_ROWS then
					break
				end
				local name, usage, pid = line:match("^(.-)\t(.-)\t(.+)$")
				if name then
					rows[i]:set({
						drawing = true,
						click_script = process_click_script(pid, w.click_script),
						icon = { string = name },
						label = { string = usage .. "  " .. pid },
					})
					i = i + 1
				end
			end
			for hidden = i, PROCESS_ROWS do
				rows[hidden]:set({ drawing = false })
			end
			w.graph:set({ popup = { drawing = true } })
		end)
	end

	w.graph:subscribe("mouse.entered", show)
	w.top:subscribe("mouse.entered", show)
	w.bottom:subscribe("mouse.entered", show)

	local function close()
		if active_process_popup == w.graph then
			w.graph:set({ popup = { drawing = false } })
			active_process_popup = nil
		end
	end

	local function schedule_close()
		hover_version = hover_version + 1
		local version = hover_version
		sbar.exec("sleep 0.15", function()
			if hover_version == version then
				close()
			end
		end)
	end

	for _, item in ipairs(rows) do
		item:subscribe("mouse.entered", function()
			hover_version = hover_version + 1
		end)
		item:subscribe("mouse.exited", schedule_close)
	end

	w.graph:subscribe("mouse.exited", schedule_close)
	w.top:subscribe("mouse.exited", schedule_close)
	w.bottom:subscribe("mouse.exited", schedule_close)
	w.graph:subscribe("mouse.exited.global", close)
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
