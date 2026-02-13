local wezterm = require("wezterm")

local Theme = {}

Theme.palettes = {
	mocha = {
		base = "#000000",
		mantle = "#33353f",
		crust = "#202023",
		text = "#c5cdd9",
		subtext1 = "#bcc5d1",
		subtext0 = "#9da9a0",
		overlay2 = "#7f8490",
		overlay1 = "#6b7089",
		overlay0 = "#535965",
		surface2 = "#414550",
		surface1 = "#3b3e48",
		surface0 = "#363944",
		rosewater = "#deb974",
		flamingo = "#deb974",
		pink = "#d38aea",
		mauve = "#d38aea",
		red = "#ec7279",
		maroon = "#ec7279",
		peach = "#deb974",
		yellow = "#deb974",
		green = "#a0c980",
		teal = "#5dbbc1",
		sky = "#5dbbc1",
		sapphire = "#6cb6eb",
		blue = "#6cb6eb",
		lavender = "#d38aea",
	},
	latte = {
		rosewater = "#dc8a78",
		flamingo = "#dd7878",
		pink = "#ea76cb",
		mauve = "#8839ef",
		red = "#d20f39",
		maroon = "#e64553",
		peach = "#fe640b",
		yellow = "#df8e1d",
		green = "#40a02b",
		teal = "#179299",
		sky = "#04a5e5",
		sapphire = "#209fb5",
		blue = "#1e66f5",
		lavender = "#7287fd",
		text = "#4c4f69",
		subtext1 = "#5c5f77",
		subtext0 = "#6c6f85",
		overlay2 = "#7c7f93",
		overlay1 = "#8c8fa1",
		overlay0 = "#9ca0b0",
		surface2 = "#acb0be",
		surface1 = "#bcc0cc",
		surface0 = "#ccd0da",
		base = "#eff1f5",
		mantle = "#e6e9ef",
		crust = "#dce0e8",
	},
}

function Theme.is_dark()
	if wezterm.gui then
		return wezterm.gui.get_appearance():find("Dark") ~= nil
	end
	return true
end

function Theme.get_palette()
	return Theme.palettes.mocha
end

function Theme.apply_colors(config, c)
	local is_latte = c.base == Theme.palettes.latte.base

	config.colors = {
		split = c.overlay0,
		foreground = c.text,
		background = c.base,
		cursor_border = c.rosewater,
		cursor_fg = is_latte and c.base or c.crust,
		cursor_bg = c.rosewater,
		selection_fg = c.text,
		selection_bg = c.surface2,
		visual_bell = c.surface0,
		indexed = { [16] = c.peach, [17] = c.rosewater },
		scrollbar_thumb = c.surface2,
		compose_cursor = c.flamingo,
		ansi = {
			is_latte and c.subtext1 or c.surface1,
			c.red,
			c.green,
			c.yellow,
			c.blue,
			c.pink,
			c.teal,
			is_latte and c.surface2 or c.subtext1,
		},
		brights = {
			is_latte and c.subtext0 or c.surface2,
			c.red,
			c.green,
			c.yellow,
			c.blue,
			c.pink,
			c.teal,
			is_latte and c.surface1 or c.subtext0,
		},
	}

	config.command_palette_bg_color = c.crust
	config.command_palette_fg_color = c.text
end

function Theme.setup(config)
	local c = Theme.get_palette()
	Theme.apply_colors(config, c)

	wezterm.on("window-config-reloaded", function(window, _pane)
		local c = Theme.get_palette()
		local overrides = window:get_config_overrides() or {}
		Theme.apply_colors(overrides, c)
	end)
end

return Theme
