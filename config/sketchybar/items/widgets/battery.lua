local colors = require("colors")

-- Added in this order (text first) so that, with the right side's
-- first-added-ends-up-rightmost rule, the icon lands to the LEFT of the
-- text -- the usual icon-then-text reading order.
local battery = sbar.add("item", "widgets.battery", {
	position = "right",
	update_freq = 120,
	icon = { drawing = false },
	label = { string = "??%", color = colors.orange },
	padding_left = 0,
	background = { drawing = false },
})

local battery_icon = sbar.add("item", "widgets.battery.icon", {
	position = "right",
	icon = { string = "\u{f240}", color = colors.orange },
	label = { drawing = false },
	padding_right = 0,
	background = { drawing = false },
})

sbar.add("bracket", "widgets.battery.bracket", { battery_icon.name, battery.name }, {
	background = {
		color = colors.black3,
		border_color = colors.orange,
		border_width = 2,
	},
})

sbar.add("item", "widgets.battery.gap", { position = "right", width = 6, background = { drawing = false } })

local function update_battery()
	sbar.exec("pmset -g batt", function(batt_info)
		local charge = tonumber(batt_info:match("(%d+)%%"))
		local charging = batt_info:find("AC Power") ~= nil

		local icon = "!"
		local color = colors.orange
		if charging then
			icon = "\u{f0e7}"
		elseif charge then
			if charge > 80 then
				icon = "\u{f240}"
			elseif charge > 60 then
				icon = "\u{f241}"
			elseif charge > 40 then
				icon = "\u{f242}"
			elseif charge > 20 then
				icon = "\u{f243}"
			else
				icon = "\u{f244}"
				color = colors.red
			end
		end

		battery_icon:set({ icon = { string = icon, color = color } })
		battery:set({ label = { string = (charge or "?") .. "%", color = color } })
	end)
end

battery:subscribe({ "routine", "power_source_change", "system_woke", "forced" }, update_battery)
