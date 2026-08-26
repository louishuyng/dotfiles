local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local saturation_graph = require("items.widgets.saturation_graph")

-- The interface is resolved every tick rather than cached, so a Wi-Fi ↔
-- Ethernet switch follows without a restart. Only the <Link#n> row carries the
-- byte counters; the per-address rows would double-count.
local SAMPLE_CMD = "iface=$(route -n get default 2>/dev/null | awk '/interface:/{print $2}'); "
	.. [[netstat -ib | awk -v i="$iface" '$1==i && $3 ~ /<Link/ {print $7, $10; exit}']]

-- netstat reports cumulative bytes, so the rate is a delta over the tick
-- interval. os.time() only has second resolution — too coarse to measure a 2s
-- window — so the nominal interval is used and the baseline is instead dropped
-- on wake, the one case where it would turn a sleep-long delta into a spike.
local prev_rx, prev_tx

-- The graph auto-scales against a decaying peak so it stays legible whether the
-- link is idling at 50 KB/s or saturated at 100 MB/s. The floor stops idle
-- noise from filling the graph.
local MIN_SCALE = 128 * 1024
local peak = MIN_SCALE

local UNITS = { { 1024 ^ 3, "G" }, { 1024 ^ 2, "M" }, { 1024, "K" } }

local function human(n)
	for _, unit in ipairs(UNITS) do
		local size, suffix = unit[1], unit[2]
		if n >= size then
			local v = n / size
			return (v < 10 and string.format("%.1f", v) or string.format("%d", v)) .. suffix
		end
	end
	return string.format("%dB", n)
end

-- Both lines are live and the same size here, so they need a wider split than
-- the caption-over-figure widgets get from the factory's defaults.
local function text(string, y_offset)
	return {
		string = string,
		family = settings.font.numbers,
		style = "Semibold",
		size = 9.0,
		color = colors.white,
		y_offset = y_offset,
	}
end

local w = saturation_graph.build({
	name = "widgets.network",
	color = colors.accent,
	top = text(icons.wifi.download .. "0B", 6),
	bottom = text(icons.wifi.upload .. "0B", -6),
})

w.graph:subscribe({ "routine", "system_woke", "forced" }, function(env)
	if env.SENDER == "system_woke" then
		prev_rx, prev_tx = nil, nil
	end

	sbar.exec(SAMPLE_CMD, function(out)
		local rx, tx = out:match("(%d+)%s+(%d+)")
		rx, tx = tonumber(rx), tonumber(tx)
		if not rx then
			return
		end

		local down, up = 0, 0
		-- A counter going backwards means the interface changed or reset; report
		-- nothing this tick rather than a garbage spike.
		if prev_rx and rx >= prev_rx and tx >= prev_tx then
			down = (rx - prev_rx) / saturation_graph.UPDATE_FREQ
			up = (tx - prev_tx) / saturation_graph.UPDATE_FREQ
		end
		prev_rx, prev_tx = rx, tx

		local total = down + up
		peak = math.max(total, peak * 0.98, MIN_SCALE)

		w.top:set({ label = { string = icons.wifi.download .. human(down) } })
		w.bottom:set({ label = { string = icons.wifi.upload .. human(up) } })
		w.graph:push({ total / peak })
	end)
end)
