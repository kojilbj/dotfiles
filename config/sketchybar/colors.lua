-- Tokyo Night palette, matching the reference config
-- (github.com/SoichiroYamane/dotfiles/tree/main/sketchybar).
return {
	transparent = 0x00000000,
	foreground = 0xe0fbf1c7,

	black3 = 0xff24283b,
	black4 = 0xff1a1b26,

	blue = 0xff7aa2f7,
	cyan = 0xff2ac3de,
	green = 0xff9ece6a,
	lime = 0xffc3e88d,
	orange = 0xffff9e64,
	magenta = 0xffbb9af7,
	red = 0xfff7768e,
	grey = 0xff7f8490,

	pure_green = 0xff3bb143,

	bar = {
		bg = 0x00000000,
	},

	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
	end,
}
