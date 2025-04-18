local wezterm = require("wezterm")

local Theme = {}

function Theme.setup(config)
	local colors = {
		rosewater = "#fed1cb",
		flamingo = "#ff9185",
		pink = "#d699b6",
		mauve = "#cb7ec8",
		red = "#e06062",
		maroon = "#e67e80",
		peach = "#e69875",
		yellow = "#d3ad63",
		green = "#b0cc76",
		teal = "#6db57f",
		sky = "#8fbbb3",
		sapphire = "#60aaa0",
		blue = "#59a6c3",
		lavender = "#e0d3d4",
		text = "#98c379",
		subtext1 = "#e0d7c3",
		subtext0 = "#d3c6aa",
		overlay2 = "#9da9a0",
		overlay1 = "#859289",
		overlay0 = "#6d6649",
		surface2 = "#585c4a",
		surface1 = "#414b50",
		surface0 = "#374145",
		base = "#0F0F0F",
		mantle = "#1C1C20",
		crust = "#1e1e1e",
	}

	config.colors = {
		split = colors.surface0,
		foreground = colors.text,
		background = colors.base,
		cursor_border = colors.overlay2,
		cursor_fg = colors.base,
		selection_bg = colors.surface2,
		visual_bell = colors.surface0,
		indexed = { [16] = colors.peach, [17] = colors.rosewater },
		scrollbar_thumb = colors.surface2,
		compose_cursor = colors.flamingo,
		ansi = {
			colors.surface0,
			colors.red,
			colors.green,
			colors.yellow,
			colors.blue,
			colors.mauve,
			colors.teal,
			colors.subtext1,
		},
		brights = {
			colors.surface2,
			colors.red,
			colors.green,
			colors.yellow,
			colors.blue,
			colors.mauve,
			colors.teal,
			colors.subtext0,
		},
	}
end

return Theme
