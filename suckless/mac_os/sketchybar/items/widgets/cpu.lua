local colors = require("colors")
local settings = require("settings")
local saturation_graph = require("items.widgets.saturation_graph")

-- CPU utilisation over the last second. macOS load average counts far more than
-- runnable threads -- it sits in the tens on an otherwise idle machine -- so it
-- is useless as a bar metric.
local w = saturation_graph.build({
	name = "widgets.cpu",
	color = colors.accent,
	top = {
		string = "CPU",
		style = "Semibold",
		size = 8.0,
		color = colors.with_alpha(colors.white, 0.6),
	},
	bottom = {
		string = "0%",
		family = settings.font.numbers,
		style = "Bold",
		size = 12.0,
		color = colors.white,
	},
})

w.graph:subscribe({ "routine", "system_woke", "forced" }, function()
	-- iostat's second sample averages over one second. Its leading disk columns
	-- vary with the number of disks attached, so idle is found from the end: the
	-- last three numbers are the load averages, and idle sits just before them.
	sbar.exec("iostat -c 2 | tail -1", function(out)
		local f = {}
		for n in out:gmatch("[%d%.]+") do
			f[#f + 1] = tonumber(n)
		end
		local idle = f[#f - 3]
		if not idle then
			return
		end
		local pct = 100 - idle
		local color = saturation_graph.threshold_color(pct)

		saturation_graph.recolor(w, color)
		w.bottom:set({ label = { string = math.floor(pct + 0.5) .. "%", color = color } })
		w.graph:push({ pct / 100.0 })
	end)
end)
