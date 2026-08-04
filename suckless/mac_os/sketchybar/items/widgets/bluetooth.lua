local colors = require("colors")

-- sketchybar-app-font has only one bluetooth glyph (:bluetooth:); state is
-- conveyed via color rather than separate on/off/connected glyphs.
local bluetooth = sbar.add("item", "widgets.bluetooth", {
	position = "right",
	icon = {
		string = ":bluetooth:",
		font = {
			family = "sketchybar-app-font",
			style = "Regular",
			size = 14.0,
		},
		color = colors.grey,
		padding_left = 8,
		padding_right = 4,
	},
	label = { drawing = false },
	update_freq = 3,
	updates = true,
})

local function update()
	sbar.exec("system_profiler SPBluetoothDataType 2>/dev/null", function(out)
		local state = out:match("State:%s*(%w+)")
		local on = state == "On"

		local has_connected = false
		if on then
			local connected_block = out:match("Connected:(.-)Not Connected:") or out:match("Connected:(.-)$")
			if connected_block and connected_block:match("%S") then
				has_connected = connected_block:match("Address:") ~= nil
			end
		end

		local color
		if not on then
			color = colors.grey
		elseif has_connected then
			color = colors.gold
		else
			color = colors.white
		end

		bluetooth:set({ icon = { color = color } })
	end)
end

-- volume_change fires when the audio output route changes, which usually
-- coincides with a bluetooth audio device connecting/disconnecting — use it
-- as a near-instant trigger so we don't have to wait for the next routine tick.
bluetooth:subscribe({ "routine", "system_woke", "forced", "volume_change" }, update)
bluetooth:subscribe("mouse.clicked", update)
update()
