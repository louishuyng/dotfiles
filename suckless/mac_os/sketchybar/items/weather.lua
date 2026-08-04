local settings = require("settings")
local colors = require("colors")

local WTTR_URL = "https://wttr.in/?format=%t&m"

local weather = sbar.add("item", "center.weather", {
	position = "center",
	icon = {
		string = "􀆭",
		color = colors.accent,
		padding_left = 5,
		padding_right = 2,
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = 13.0,
		},
	},
	label = {
		string = "--°",
		color = colors.white,
		padding_left = 2,
		padding_right = 6,
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = 12.0,
		},
	},
	update_freq = 1800,
})

local function update()
	sbar.exec("curl -s --max-time 5 '" .. WTTR_URL .. "'", function(out)
		local temp = out and out:gsub("^%s*(.-)%s*$", "%1") or ""
		if temp ~= "" and not temp:lower():find("unknown") then
			weather:set({ label = { string = temp } })
		end
	end)
end

weather:subscribe({ "routine", "system_woke", "forced" }, update)

update()
