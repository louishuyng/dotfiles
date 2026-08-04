require("utils")
local colors = require("colors")
local icons = require("icons")

sbar.add("item", "apple.logo", {
	position = "left",
	background = {
		image = {
			string = os.getenv("HOME") .. "/.config/sketchybar/assets/diamondRed.png",
			scale = 0.04,
		},
	},
	-- icon = {
	-- 	y_offset = 1,
	-- 	font = { size = 18.0 },
	-- 	color = colors.white,
	-- 	string = icons.apple,
	-- },
	label = { drawing = false },
	padding_left = 10,
	padding_right = 5,
	click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0",
})

sbar.add("item", {
	position = "left",
	width = 10,
	icon = {
		string = "|",
		font = { size = 16.0 },
		y_offset = 1,
		color = colors.with_alpha(colors.white, 0.3),
	},
})
