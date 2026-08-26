local settings = require("settings")
local colors = require("colors")

-- On the right side of the bar, earlier-added items render further RIGHT, so
-- time is added before date to read "date time" left-to-right.
local time = sbar.add("item", "right.time", {
	position = "right",
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

local date = sbar.add("item", "right.date", {
	position = "right",
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

time:subscribe({ "forced", "routine", "system_woke" }, function(env)
	time:set({ icon = { string = os.date("%H:%M") } })
end)

date:subscribe({ "forced", "routine", "system_woke" }, function(env)
	date:set({ icon = { string = os.date("%b %d %a") } })
end)
