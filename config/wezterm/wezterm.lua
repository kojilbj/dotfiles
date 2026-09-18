local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "Solarized Dark Higher Contrast"
config.automatically_reload_config = true
config.font_size = 12.0
config.use_ime = true
config.window_background_opacity = 0.85
config.macos_window_background_blur = 20
-- ウィンドウサイズを文字セルの整数倍にスナップし、リサイズ時のテキスト崩れを軽減
config.use_resize_increments = true

----------------------------------------------------
-- Tab
----------------------------------------------------
-- タイトルバーを非表示
config.window_decorations = "RESIZE"
-- タブバーの表示
config.show_tabs_in_tab_bar = true
-- タブが一つの時は非表示
config.hide_tab_bar_if_only_one_tab = true
-- falseにするとタブバーの透過が効かなくなる
-- config.use_fancy_tab_bar = false

-- タブバーの透過
config.window_frame = {
	inactive_titlebar_bg = "none",
	active_titlebar_bg = "none",
}

-- window_background_gradientはOSC11での動的な背景色変更(Claude Code実行時のオレンジ化など)を
-- ブロックしてしまうため削除。タブバーの見た目に差が出たら別の方法を検討する

-- タブの追加ボタンを非表示
config.show_new_tab_button_in_tab_bar = false
-- nightlyのみ使用可能
-- タブの閉じるボタンを非表示
config.show_close_tab_button_in_tabs = false

-- タブ同士の境界線を非表示 / カーソル色をSolarizedの明るい色に変更(デフォルトのオレンジは視認性が低いため)
config.colors = {
	tab_bar = {
		inactive_tab_edge = "none",
	},
	cursor_bg = "#38bdf8",
	cursor_border = "#38bdf8",
	cursor_fg = "#002b36",
}

-- タブの形をカスタマイズ(ピル型)
-- タブの左側の装飾
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_left_half_circle_thick
-- タブの右側の装飾
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_right_half_circle_thick

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local proc = tab.active_pane.foreground_process_name or ""
	local is_claude = proc:find("claude") ~= nil
	local is_antigravity = proc:find("agy") ~= nil or proc:find("antigravity") ~= nil or (tab.active_pane.title or ""):find("agy") ~= nil
	local is_codex = proc:find("codex") ~= nil or (tab.active_pane.title or ""):lower():find("codex") ~= nil
	-- Stopフック(set-tab-status.sh)がセットするユーザー変数。応答完了・入力待ちの間だけ緑にする。
	-- is_claudeには依存しない: claudecode.nvim経由でnvim内にネストして動いている場合、
	-- WezTermからのforeground_process_nameは"nvim"に見えてis_claudeがfalseになるため。
	local is_waiting = tab.active_pane.user_vars.claude_status == "waiting"
		or tab.active_pane.user_vars.agy_status == "waiting"
		or tab.active_pane.user_vars.antigravity_status == "waiting"
		or tab.active_pane.user_vars.codex_status == "waiting"

	local background = "#5c6d74"
	local foreground = "#FFFFFF"
	local edge_background = "none"
	if is_claude then
		-- Claude Codeが動いているタブはオレンジにする
		background = "#ff9e64"
		foreground = "#1a1b26"
	elseif is_antigravity then
		-- Antigravityが動いているタブはパープルにする
		background = "#bb9af7"
		foreground = "#1a1b26"
	elseif is_codex then
		-- Codexが動いているタブはOpenAIグリーン/ティールにする
		background = "#10a37f"
		foreground = "#1a1b26"
	end
	if is_waiting then
		background = "#9ece6a"
		foreground = "#1a1b26"
	end
	if tab.is_active then
		if is_waiting then
			background = "#c3e88d"
		elseif is_claude then
			background = "#ffb380"
		elseif is_antigravity then
			background = "#caa6f7"
		elseif is_codex then
			background = "#2dd4bf"
		else
			background = "#38bdf8"
		end
		foreground = (is_claude or is_antigravity or is_codex or is_waiting) and "#1a1b26" or "#FFFFFF"
	end
	local edge_foreground = background
	local full_title = tab.active_pane.title
	if is_claude then
		-- 先頭のスピナー部分だけ残して、それ以外の文字列は"Claude Code"に固定する
		local spinner = full_title:match("^(%S+)")
		full_title = spinner and (spinner .. " Claude Code") or "Claude Code"
	elseif is_antigravity then
		full_title = "Antigravity"
	elseif is_codex then
		full_title = "Codex"
	end
	local truncated = wezterm.truncate_right(full_title, max_width - 1)
	if truncated ~= full_title then
		-- 省略されている場合は末尾を"…"に置き換えて分かるようにする
		truncated = wezterm.truncate_right(truncated, #truncated - 1) .. "…"
	end
	local title = "   " .. truncated .. "   "
	return {
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_LEFT_ARROW },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_RIGHT_ARROW },
	}
end)

----------------------------------------------------
-- mouse bindings
----------------------------------------------------
-- タブが1つの時はタブバーが非表示になりウィンドウをドラッグする場所がなくなるため、
-- Cmd + 左クリックドラッグでどこからでもウィンドウを移動できるようにする
config.mouse_bindings = {
	{
		event = { Drag = { streak = 1, button = "Left" } },
		mods = "SUPER",
		action = wezterm.action.StartWindowDrag,
	},
}

----------------------------------------------------
-- keybinds
----------------------------------------------------
config.disable_default_key_bindings = true
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables
config.leader = { key = "j", mods = "CTRL", timeout_milliseconds = 2000 }

return config
