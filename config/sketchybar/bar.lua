local colors = require("colors")

-- The bar itself is fully transparent; every item/bracket below draws its
-- own pill, so items float independently over the desktop.
sbar.bar({
	height = 38,
	color = colors.bar.bg,
	position = "top",
	padding_left = 8,
	padding_right = 8,
	blur_radius = 0,
})
