local colors = require("colors")

-- ──────────────────────────── LEFT ────────────────────────────
require("items.apple")
require("items.spaces")
require("items.media")

-- ─────────────────────────── RIGHT ────────────────────────────
-- Center is intentionally empty. On the right, earlier-added items render
-- further RIGHT: the clock is required first to sit at the bar's edge, and the
-- saturation graphs last so they lead the cluster from the left.
require("items.calendar")
require("items.weather")
require("items.widgets.battery")
require("items.widgets.volume")
require("items.widgets.wifi")
require("items.widgets.bluetooth")
require("items.widgets.network")
require("items.widgets.disk")
require("items.widgets.memory")
require("items.widgets.cpu")

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

-- Clock pill: weather + date + time
sbar.add("bracket", "bracket.clock", {
	"right.weather",
	"right.date",
	"right.time",
}, {
	background = {
		color = colors.transparent,
		corner_radius = 4,
		height = 24,
		border_width = 0,
	},
})

-- Metrics pill: CPU + memory + disk saturation, network throughput. Its own bracket,
-- tinted with the accent hue rather than a neutral bgN — the bgN shades are too
-- close to each other to tell the two pills apart at bar size.
-- Members are listed out rather than matched: sketchybar's bracket matcher does
-- not handle regex alternation, and a bracket that matches nothing is silently
-- never created.
sbar.add("bracket", "bracket.metrics", {
	"widgets.cpu",
	"widgets.cpu.top",
	"widgets.cpu.bottom",
	"widgets.memory",
	"widgets.memory.top",
	"widgets.memory.bottom",
	"widgets.disk.top",
	"widgets.disk.bottom",
	"widgets.network",
	"widgets.network.top",
	"widgets.network.bottom",
}, {
	background = {
		color = colors.transparent,
		corner_radius = 0,
		height = 37,
		border_width = 1,
		border_color = "0xffCA9EE6",
	},
})

-- Right pill: WiFi + Bluetooth + Volume + Battery
sbar.add("bracket", "bracket.right", {
	"widgets.wifi",
	"widgets.bluetooth",
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
