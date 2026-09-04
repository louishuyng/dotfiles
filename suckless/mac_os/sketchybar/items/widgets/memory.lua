local colors = require("colors")
local settings = require("settings")
local saturation_graph = require("items.widgets.saturation_graph")

-- Activity Monitor's "Memory Used": anonymous pages, less the purgeable ones
-- macOS can drop, plus wired and compressed. Not `memory_pressure`, whose free
-- percentage is (total - wired - compressed) and so counts every byte of app
-- memory as free -- it reports ~90% free on a machine with 23GB in use.
local memsize = 1
do
	local handle = io.popen("sysctl -n hw.memsize")
	if handle then
		memsize = tonumber(handle:read("*a")) or 1
		handle:close()
	end
end

local CMD = (
	[[vm_stat | awk '/page size of/{s=$8} /Pages wired/{w=$4} /Pages purgeable/{p=$3} ]]
	.. [[/Anonymous pages/{a=$3} /occupied by compressor/{c=$5} END{printf "%%d", (a-p+w+c)*s/%d*100+0.5}']]
):format(memsize)

local w = saturation_graph.build({
	name = "widgets.memory",
	color = colors.accent,
	click_script = "killall 'Activity Monitor' >/dev/null 2>&1; defaults write com.apple.ActivityMonitor SelectedTab -int 1; open -a 'Activity Monitor'",
	top = {
		string = "MEM",
		style = "Semibold",
		size = 8.0,
		color = colors.with_alpha(colors.white, 0.6),
	},
	bottom = {
		string = "0%",
		family = settings.font.numbers,
		style = "Bold",
		size = 12.0,
		color = colors.white,
	},
})

saturation_graph.process_popup(
	w,
	[[top -l 1 -o mem -n 5 -stats pid,command,mem | awk '/^PID / {seen=1; next} seen && NF {pid=$1; mem=$NF; $1=$NF=""; sub(/^  */, ""); sub(/[ \t]+$/, ""); printf "%s\t%s\t#%s\n", substr($0,1,22), mem, pid}']]
)

w.graph:subscribe({ "routine", "system_woke", "forced" }, function()
	sbar.exec(CMD, function(out)
		local used = tonumber(out:match("%d+"))
		if not used then
			return
		end
		local color = saturation_graph.threshold_color(used)

		saturation_graph.recolor(w, color)
		w.bottom:set({ label = { string = used .. "%", color = color } })
		w.graph:push({ used / 100.0 })
	end)
end)
