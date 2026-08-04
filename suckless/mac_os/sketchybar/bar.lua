LAYOUT_FULL = true

sbar.bar({
	topmost = "window",
	height = 32,
	color = LAYOUT_FULL and 0xff000000 or 0x00000000,
	border_width = 0,
	shadow = LAYOUT_FULL,
	position = "top",
	sticky = true,
	padding_right = 0,
	padding_left = 0,
	y_offset = LAYOUT_FULL and 8 or 6,
	margin = 128,
	blur_radius = 0,
	corner_radius = LAYOUT_FULL and 8 or 0,
})
