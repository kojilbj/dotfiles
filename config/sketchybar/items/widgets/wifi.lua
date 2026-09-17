local colors = require("colors")

local DEVICE = "en0"

-- Two-line stacked speed, matching the original reference image.
--
-- Lesson from an earlier attempt: a *bracket* wrapping two items that
-- overlap each other (via negative padding_left, to stack them into one
-- pill) loses its top/bottom border, leaving only the rounded end caps.
-- The fix: only ever put NON-overlapping items in a bracket. Here, "icon"
-- and "down" are bracketed together (they sit side by side, giving the
-- normal seamless icon+text pill every other widget has); "up" is a third,
-- backgroundless item pulled on top of "down" to form the second line, but
-- deliberately left out of the bracket.
--
-- Add order matters for where things land: on the right side, each new
-- item is inserted more centrally than the last, so the *last* one added
-- ends up leftmost. Adding "down", then "up", then "icon" last means their
-- untouched, natural layout is already [icon][up][down] left-to-right --
-- pulling "down" back by exactly one label-width onto "up" then leaves the
-- icon adjacent to the (now-merged) text, with nothing extra to undo.
local WIFI_TEXT_WIDTH = 98

local wifi_down = sbar.add("item", "widgets.wifi", {
	position = "right",
	update_freq = 2,
	icon = { drawing = false, padding_left = 0, padding_right = 0 },
	label = {
		string = "↓ ??? Bps",
		color = colors.cyan,
		font = { family = "Hack Nerd Font", style = "Bold", size = 10.0 },
		y_offset = -5,
		align = "right",
		width = WIFI_TEXT_WIDTH,
		padding_left = 2,
	},
	background = { drawing = false },
	padding_right = 0,
})

local wifi_up = sbar.add("item", "widgets.wifi.up", {
	position = "right",
	icon = { drawing = false, padding_left = 0, padding_right = 0 },
	label = {
		string = "↑ ??? Bps",
		color = colors.red,
		font = { family = "Hack Nerd Font", style = "Bold", size = 10.0 },
		y_offset = 5,
		align = "right",
		width = WIFI_TEXT_WIDTH,
		padding_left = 2,
	},
	background = { drawing = false },
	padding_left = 0,
	padding_right = 0,
})

local wifi_icon = sbar.add("item", "widgets.wifi.icon", {
	position = "right",
	icon = { string = "\u{f1eb}", color = colors.magenta, padding_left = 6, padding_right = 2 },
	label = { drawing = false },
	padding_left = 6,
	padding_right = 0,
})

-- Pull "down" back by one label-width so it overlaps "up" instead of
-- sitting to its right.
wifi_down:set({ padding_left = -WIFI_TEXT_WIDTH })

sbar.add("bracket", "widgets.wifi.bracket", { wifi_icon.name, wifi_down.name }, {
	background = { color = colors.black3 },
})

sbar.add("item", "widgets.wifi.gap", { position = "right", width = 6, background = { drawing = false } })

-- Always KB/s with a fixed-width, space-padded number, so the string length
-- (and therefore the pill's width) never changes as the digit count does.
local function human_bps(bytes_per_sec)
	return string.format("%6.1f KB/s", bytes_per_sec / 1024.0)
end

local prev_in, prev_out, prev_time = nil, nil, nil

local function poll_throughput()
	sbar.exec("netstat -ibn -I " .. DEVICE .. " | awk '$1==\"" .. DEVICE .. "\" {print $7, $10; exit}'", function(result)
		local ibytes, obytes = result:match("(%d+)%s+(%d+)")
		ibytes, obytes = tonumber(ibytes), tonumber(obytes)
		local now = os.time()

		if prev_in and ibytes and obytes and now > prev_time then
			local dt = now - prev_time
			wifi_up:set({ label = "↑ " .. human_bps((obytes - prev_out) / dt) })
			wifi_down:set({ label = "↓ " .. human_bps((ibytes - prev_in) / dt) })
		end

		prev_in, prev_out, prev_time = ibytes, obytes, now
	end)
end

wifi_icon:subscribe({ "routine", "forced" }, poll_throughput)

local function update_ssid()
	sbar.exec("ipconfig getsummary " .. DEVICE .. " | awk -F ' SSID : ' '/ SSID : / {print $2}'", function(ssid)
		ssid = ssid:gsub("%s+$", "")
		if ssid ~= "" then
			wifi_icon:set({ icon = { color = colors.magenta } })
		else
			wifi_icon:set({ icon = { color = colors.grey } })
		end
	end)
end

wifi_icon:subscribe({ "wifi_change", "system_woke", "forced" }, update_ssid)
