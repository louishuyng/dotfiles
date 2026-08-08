local colors = require("colors")

-- ──────────────────────────── LEFT ────────────────────────────
require("items.apple")
require("items.spaces")
require("items.media")

-- ─────────────────────────── CENTER ───────────────────────────
require("items.weather")
require("items.calendar")

-- ─────────────────────────── RIGHT ────────────────────────────
require("items.widgets.battery")
require("items.widgets.volume")
-- require("items.widgets.cpu")
require("items.widgets.wifi")
require("items.widgets.bluetooth")

-- ══════════════════════════════════════════════════════════════
-- BRACKETS — drawn after all items are created
-- ══════════════════════════════════════════════════════════════

CORNER_RADIUS = 16

-- Left pill: Apple logo + Aerospace workspaces
sbar.add("bracket", "bracket.left", { "apple.logo", "/space\\..*/", "spaces.right_pad" }, {
	background = {
		color = colors.transparent,
		corner_radius = CORNER_RADIUS,
		height = 28,
		border_width = 0,
	},
})

-- Media pill: playpause + artwork + title, right of the workspaces
sbar.add("bracket", "bracket.media", { "/^left\\.media.*/" }, {
	background = {
		color = colors.transparent,
		corner_radius = CORNER_RADIUS,
		height = 28,
		border_width = 0,
	},
})

-- Center pill: weather + time + date
sbar.add("bracket", "bracket.center", {
	"center.weather",
	"center.time",
	"center.date",
}, {
	background = {
		color = colors.transparent,
		corner_radius = 4,
		height = 24,
		border_width = 0,
	},
})

-- Right pill: WiFi + Bluetooth + Volume + Battery
sbar.add("bracket", "bracket.right", {
	"widgets.wifi",
	"widgets.bluetooth",
	-- "widgets.cpu",
	-- "widgets.cpu.percent",
	-- "widgets.cpu.caption",
	"widgets.volume",
	"widgets.battery",
}, {
	background = {
		color = colors.transparent,
		corner_radius = CORNER_RADIUS,
		height = 28,
		border_width = 0,
	},
})
