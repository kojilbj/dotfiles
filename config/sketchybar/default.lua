local settings = require("settings")
local colors = require("colors")

-- Equivalent to the --default domain. Every item is a small dark pill by
-- default (no border); specific widgets override background.border_color
-- and border_width to pick themselves out, matching the reference's style.
sbar.default({
	update_freq = 1,
	icon = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = 16.0,
		},
		color = colors.foreground,
		padding_left = 6,
		padding_right = 2,
	},
	label = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Semibold"],
			size = 13.0,
		},
		color = colors.foreground,
		padding_left = settings.paddings,
		padding_right = settings.paddings,
	},
	background = {
		color = colors.black3,
		height = 34,
		corner_radius = 10,
		border_width = 0,
	},
	padding_left = 6,
	padding_right = 6,
})
