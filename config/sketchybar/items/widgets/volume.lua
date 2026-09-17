local colors = require("colors")

-- Text added before icon: with the right side's first-added-ends-up-
-- rightmost rule, this puts the icon to the LEFT of the text.
local volume = sbar.add("item", "widgets.volume", {
	position = "right",
	icon = { drawing = false },
	label = { string = "??%", color = colors.lime },
	padding_left = 0,
	background = { drawing = false },
})

local volume_icon = sbar.add("item", "widgets.volume.icon", {
	position = "right",
	icon = { string = "\u{f057e}", color = colors.lime },
	label = { drawing = false },
	padding_right = 0,
	background = { drawing = false },
})

sbar.add("bracket", "widgets.volume.bracket", { volume_icon.name, volume.name }, {
	background = { color = colors.black3 },
})

sbar.add("item", "widgets.volume.gap", { position = "right", width = 6, background = { drawing = false } })

local function set_volume(vol)
	vol = tonumber(vol)
	if vol == nil then
		return
	end
	local icon = "\u{f0581}"
	if vol > 60 then
		icon = "\u{f057e}"
	elseif vol > 30 then
		icon = "\u{f0580}"
	elseif vol > 0 then
		icon = "\u{f057f}"
	end
	volume_icon:set({ icon = { string = icon } })
	volume:set({ label = { string = vol .. "%" } })
end

volume:subscribe("volume_change", function(env)
	set_volume(env.INFO)
end)

volume:subscribe({ "forced", "system_woke" }, function()
	sbar.exec("osascript -e 'output volume of (get volume settings)'", function(result)
		set_volume(result)
	end)
end)
