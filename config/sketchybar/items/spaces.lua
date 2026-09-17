local colors = require("colors")
local app_icons = require("helpers.icon_map")

-- AeroSpace has no native sketchybar integration (that exists for yabai),
-- so workspaces and the current workspace's window list are rebuilt by
-- shelling out to the `aerospace` CLI, triggered by a custom event that
-- AeroSpace's exec-on-workspace-change fires on every workspace switch.
sbar.add("event", "aerospace_workspace_change")

local SPACES_BRACKET = "spaces.bracket"
local APPS_BRACKET = "spaces.apps.bracket"
local APPS_ITEM = "spaces.apps"

sbar.add("item", APPS_ITEM, {
	position = "left",
	icon = { drawing = false },
	label = {
		string = "—",
		font = { family = "sketchybar-app-font", style = "Regular", size = 16.0 },
	},
	background = { drawing = false },
})

sbar.add("bracket", APPS_BRACKET, { APPS_ITEM }, {
	background = {
		color = colors.black3,
		border_width = 0,
	},
})

local function refresh_apps()
	sbar.exec("aerospace list-windows --workspace focused --json", function(windows)
		if type(windows) ~= "table" or #windows == 0 then
			sbar.set(APPS_ITEM, { label = "—" })
			return
		end
		local icon_line = ""
		for _, win in ipairs(windows) do
			local app = win["app-name"]
			local icon = app_icons[app] or app_icons["default"]
			icon_line = icon_line .. icon .. " "
		end
		sbar.set(APPS_ITEM, { label = icon_line })
	end)
end

-- Chain each newly (re)added workspace item into place, immediately before
-- APPS_BRACKET, since sbar.add always appends to the end of its side
-- otherwise. There is no sbar.move, so this shells out to the sketchybar
-- CLI directly (same running instance, so it's a valid way to reach calls
-- SbarLua doesn't wrap).
local function refresh_spaces()
	sbar.exec("aerospace list-workspaces --focused", function(focused_raw)
		local focused = focused_raw:gsub("%s+$", "")
		sbar.exec("aerospace list-workspaces --monitor focused --empty no", function(nonempty_raw)
			local set = { [focused] = true }
			for ws in nonempty_raw:gmatch("[^\r\n]+") do
				set[ws] = true
			end
			local sorted = {}
			for ws in pairs(set) do
				table.insert(sorted, ws)
			end
			table.sort(sorted)

			sbar.remove("/^space\\..*/")
			sbar.remove(SPACES_BRACKET)

			local names = {}
			local prev = nil
			for _, ws in ipairs(sorted) do
				local color = (ws == focused) and colors.blue or colors.grey
				local item = sbar.add("item", "space." .. ws, {
					position = "left",
					icon = { drawing = false },
					label = { string = ws, color = color },
					background = { drawing = false },
					click_script = "aerospace workspace " .. ws,
				})
				table.insert(names, item.name)
				if prev == nil then
					sbar.exec("sketchybar --move " .. item.name .. " before " .. APPS_ITEM)
				else
					sbar.exec("sketchybar --move " .. item.name .. " after " .. prev)
				end
				prev = item.name
			end

			sbar.add("bracket", SPACES_BRACKET, names, {
				background = {
					color = colors.black3,
					border_color = colors.blue,
					border_width = 2,
				},
			})
		end)
	end)

	refresh_apps()
end

refresh_spaces()

sbar.add("item", "spaces.event_proxy", { drawing = false }):subscribe("aerospace_workspace_change", refresh_spaces)
