local colors = require("colors")

local cpu_graph = sbar.add("graph", "widgets.cpu.graph", 32, {
	position = "right",
	graph = { color = colors.cyan, line_width = 1.0 },
	background = { drawing = false },
	y_offset = 2,
	padding_right = 2,
})

local cpu = sbar.add("item", "widgets.cpu", {
	position = "right",
	update_freq = 2,
	icon = { string = "\u{f2db}", color = colors.cyan },
	label = { string = "??%", color = colors.cyan },
	background = { drawing = false },
	padding_left = 0,
})

sbar.add("bracket", "widgets.cpu.bracket", { cpu_graph.name, cpu.name }, {
	background = { color = colors.black3 },
})

sbar.add("item", "widgets.cpu.gap", { position = "right", width = 6, background = { drawing = false } })

cpu:subscribe({ "routine", "forced" }, function()
	sbar.exec(
		"top -l 1 -n 0 | awk -F', ' '/CPU usage/{print $3}' | sed 's/%.*//'",
		function(idle_str)
			local idle = tonumber(idle_str)
			if idle == nil then
				return
			end
			local load = math.floor(100 - idle)

			local color = colors.cyan
			if load > 80 then
				color = colors.red
			elseif load > 50 then
				color = colors.orange
			end

			cpu_graph:push({ load / 100.0 })
			cpu_graph:set({ graph = { color = color } })
			cpu:set({ label = string.format("%d%%", load), icon = { color = color } })
		end
	)
end)
