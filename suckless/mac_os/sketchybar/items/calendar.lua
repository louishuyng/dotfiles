local settings = require("settings")
local colors = require("colors")

-- Date right beside the time.
local date = sbar.add("item", "center.date", {
	position = "center",
	icon = {
		string = os.date("%b %d %a"),
		color = colors.white,
		padding_left = 0,
		padding_right = 0,
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = 12.0,
		},
	},
	label = { drawing = false },
	update_freq = 3600,
})

-- Time sits just right of the notch spacer.
local time = sbar.add("item", "center.time", {
	position = "center",
	icon = {
		string = os.date("%H:%M"),
		color = colors.accent,
		padding_left = 5,
		padding_right = 5,
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = 14.0,
		},
	},
	label = { drawing = false },
	update_freq = 30,
})

time:subscribe({ "forced", "routine", "system_woke" }, function(env)
	time:set({ icon = { string = os.date("%H:%M") } })
end)

date:subscribe({ "forced", "routine", "system_woke" }, function(env)
	date:set({ icon = { string = os.date("%b %d %a") } })
end)
