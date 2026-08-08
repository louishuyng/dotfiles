require("utils")
local colors = require("colors")
local icons = require("icons")

sbar.add("item", "tatical.logo", {
	position = "left",
	background = {
		image = {
			string = os.getenv("HOME") .. "/.config/sketchybar/assets/tatical.png",
			scale = 0.08,
		},
	},
	-- icon = {
	-- 	y_offset = 1,
	-- 	font = { size = 18.0 },
	-- 	color = colors.white,
	-- 	string = icons.apple,
	-- },
	label = { drawing = false },
	padding_left = 20,
	padding_right = 10,
})

sbar.add("item", "go.logo", {
	position = "left",
	background = {
		image = {
			string = os.getenv("HOME") .. "/.config/sketchybar/assets/golang.png",
			scale = 0.075,
		},
	},
	-- icon = {
	-- 	y_offset = 1,
	-- 	font = { size = 18.0 },
	-- 	color = colors.white,
	-- 	string = icons.apple,
	-- },
	label = { drawing = false },
	padding_left = 0,
	padding_right = 13,
})

sbar.add("item", "claude.logo", {
	position = "left",
	background = {
		image = {
			string = os.getenv("HOME") .. "/.config/sketchybar/assets/claude.png",
			scale = 0.069,
		},
	},
	-- icon = {
	-- 	y_offset = 1,
	-- 	font = { size = 18.0 },
	-- 	color = colors.white,
	-- 	string = icons.apple,
	-- },
	label = { drawing = false },
	padding_left = 0,
	padding_right = 7,
})

sbar.add("item", "gpt.logo", {
	position = "left",
	background = {
		image = {
			string = os.getenv("HOME") .. "/.config/sketchybar/assets/chatgpt.png",
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
	padding_left = 0,
	padding_right = 7,
})

sbar.add("item", "hack.logo", {
	position = "left",
	background = {
		image = {
			string = os.getenv("HOME") .. "/.config/sketchybar/assets/hack.png",
			scale = 0.067,
		},
	},
	-- icon = {
	-- 	y_offset = 1,
	-- 	font = { size = 18.0 },
	-- 	color = colors.white,
	-- 	string = icons.apple,
	-- },
	label = { drawing = false },
	padding_left = 0,
	padding_right = 5,
})

sbar.add("item", {
	position = "left",
	width = 10,
	icon = {
		string = "",
		font = { size = 16.0 },
		y_offset = 1,
		color = colors.with_alpha(colors.white, 0.3),
	},
})
