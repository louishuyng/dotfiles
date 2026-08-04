local colors = require("colors")

function menubar_section(items)
	local _ = sbar.add("bracket", items, {
		background = {
			color = colors.bar.bg,
			corner_radius = 16,
			height = 28,
			border_width = 1,
			border_color = colors.bar.border,
		},
	})
end
