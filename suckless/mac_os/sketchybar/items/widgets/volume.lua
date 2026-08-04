local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local volume = sbar.add("item", "widgets.volume", {
	position = "right",
	icon = {
		string = icons.volume._100,
		font = {
			style = settings.font.style_map["Bold"],
			size = 14.0,
		},
		color = colors.green,
		padding_left = 8,
		padding_right = 4,
	},
	label = {
		string = "--%",
		font = {
			family = settings.font.numbers,
			style = settings.font.style_map["Bold"],
			size = 12.0,
		},
		color = colors.white,
		padding_right = 0,
	},
	updates = true,
})

local function pick_icon(volume_pct)
	if volume_pct > 60 then
		return icons.volume._100
	elseif volume_pct > 30 then
		return icons.volume._66
	elseif volume_pct > 10 then
		return icons.volume._33
	elseif volume_pct > 0 then
		return icons.volume._10
	end
	return icons.volume._0
end

local function apply(volume_pct)
	local lead = volume_pct < 10 and "0" or ""
	volume:set({
		icon = { string = pick_icon(volume_pct) },
		label = { string = lead .. volume_pct .. "%" },
	})
end

volume:subscribe("volume_change", function(env)
	apply(tonumber(env.INFO))
end)

-- Pull the initial value on load (volume_change only fires on change).
sbar.exec("osascript -e 'output volume of (get volume settings)'", function(out)
	local v = tonumber(out)
	if v then
		apply(v)
	end
end)

volume:subscribe("mouse.scrolled", function(env)
	local delta = env.SCROLL_DELTA
	sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end)
