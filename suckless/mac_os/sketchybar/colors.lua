local themes = {
	catppuccin = {
		base = 0xff1e1e2e,
		surface = 0xff313244,
		overlay = 0xff45475a,
		muted = 0xff6c7086,
		subtle = 0xff9399b2,
		text = 0xffcdd6f4,
		love = 0xfff38ba8,
		gold = 0xfff9e2af,
		rose = 0xfff5e0dc,
		pine = 0xff94e2d5,
		foam = 0xff89dceb,
		iris = 0xffcba6f7,
		highlight_low = 0xff181825,
		highlight_med = 0xff11111b,
		highlight_high = 0xff313244,

		black = 0xff181926,
		white = 0xffcad3f5,
		red = 0xffed8796,
		green = 0xffa6da95,
		blue = 0xff8aadf4,
		yellow = 0xffeed49f,
		orange = 0xfff5a97f,
		magenta = 0xffc6a0f6,
		grey = 0xff939ab7,
		transparent = 0x00000000,
		accent = 0xffeed49f,

		bar = { bg = 0xff181926, border = 0xff45475a },
		popup = { bg = 0xf0181926, border = 0xff45475a },
		bg1 = 0x60000000,
		bg2 = 0x90000000,
		bg3 = 0xb0000000,
	},
	-- Retro-phosphor green, carried over from the previous bash config's
	-- colors.sh. Semantic names are mapped to matching hues rather than
	-- copied verbatim: colors.sh assigned GREEN to an orange, which would
	-- render a full battery orange here.
	phosphor = {
		base = 0xff000000,
		surface = 0xff061006,
		overlay = 0xff0b180b,
		muted = 0xff245224,
		subtle = 0xff4e6f4e,
		text = 0xffd8ffd8,
		love = 0xffc96d00,
		gold = 0xffffe07a,
		rose = 0xffffc94a,
		pine = 0xff00cc4f,
		foam = 0xff98ff98,
		iris = 0xff66ff99,
		highlight_low = 0xff061006,
		highlight_med = 0xff102210,
		highlight_high = 0xff183818,

		black = 0xff000000,
		white = 0xffd8ffd8,
		red = 0xffc96d00,
		green = 0xff00e65c,
		blue = 0xff66ff99,
		yellow = 0xffd98a00,
		orange = 0xffffc94a,
		magenta = 0xff66ff99,
		grey = 0xff4e6f4e,
		transparent = 0x00000000,
		accent = 0xff00e65c,

		bar = { bg = 0xff000000, border = 0xff0b180b },
		popup = { bg = 0xff000000, border = 0xff00e65c },
		bg1 = 0xff0b180b,
		bg2 = 0xff183818,
		bg3 = 0xff102210,
	},
}

-- Select the active theme here
local active_theme = "phosphor" -- options: "phosphor", "catppuccin"

local theme = themes[active_theme]

theme.with_alpha = function(color, alpha)
	if alpha > 1.0 or alpha < 0.0 then
		return color
	end
	return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
end

return theme
