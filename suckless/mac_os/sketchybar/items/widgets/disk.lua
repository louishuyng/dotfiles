local colors = require("colors")
local settings = require("settings")
local saturation_graph = require("items.widgets.saturation_graph")

-- Free space, not a graph: disk fills over weeks, so the history says nothing
-- and the number that matters is how much room is left.
--
-- Data volume, not `/`: on APFS the root is a sealed system snapshot that always
-- reads ~9% full.
local w = saturation_graph.text_pair({
	name = "widgets.disk",
	top = {
		string = "DSK",
		style = "Semibold",
		size = 8.0,
		color = colors.with_alpha(colors.white, 0.6),
	},
	bottom = {
		string = "--",
		family = settings.font.numbers,
		style = "Bold",
		size = 12.0,
		color = colors.white,
	},
})

w.bottom:set({ padding_left = 8, update_freq = 60 })

w.bottom:subscribe({ "routine", "system_woke", "forced" }, function()
	sbar.exec("df -k /System/Volumes/Data | tail -1", function(out)
		local avail, used = out:match("%d+%s+%d+%s+(%d+)%s+(%d+)%%")
		if not avail then
			return
		end
		local gb = tonumber(avail) / 1024 / 1024
		local color = saturation_graph.threshold_color(tonumber(used))

		w.bottom:set({
			label = {
				string = gb >= 100 and math.floor(gb + 0.5) .. "G" or string.format("%.1fG", gb),
				color = color,
			},
		})
	end)
end)
