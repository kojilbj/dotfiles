local colors = require("colors")

-- Text only -- every icon glyph tried here (fa-calendar, fa-calendar-alt,
-- oct-calendar) either had its frame clipped at small sizes or resolved to
-- the wrong glyph, so the pill is just the border + date/time text.
local clock = sbar.add("item", "widgets.clock", {
	position = "right",
	icon = { drawing = false },
	label = {
		color = colors.magenta,
		font = { family = "Hack Nerd Font", style = "Bold", size = 11.0 },
		align = "right",
	},
	background = {
		color = colors.black3,
		border_color = colors.magenta,
		border_width = 2,
	},
})

clock:subscribe({ "forced", "routine", "system_woke" }, function()
	clock:set({ label = os.date("%a %b %d %H:%M") })
end)
