-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
local function apply_custom_highlights()
  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
  vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
  -- デフォルトのLineNr/LineNrAbove/LineNrBelow(#3b4261)は透過背景だと暗すぎてほぼ見えないので、
  -- TokyoNightのブルー系に変えて視認性を上げる
  -- (relativenumber有効時、現在行以外はLineNrAbove/Belowが使われ、LineNrとは別定義なので両方指定が必要)
  vim.api.nvim_set_hl(0, "LineNr", { fg = "#7aa2f7" })
  vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#7aa2f7" })
  vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#7aa2f7" })
  -- Claude Codeのターミナルウィンドウ用winbarの色(WezTermのタブ色と揃えている)
  vim.api.nvim_set_hl(0, "ClaudeCodeWinbar", { bg = "#ff9e64", fg = "#1a1b26", bold = true })
  -- Stopフックで応答完了・入力待ちになった時用(WezTermの緑タブと揃えている)
  vim.api.nvim_set_hl(0, "ClaudeCodeWinbarWaiting", { bg = "#9ece6a", fg = "#1a1b26", bold = true })
end

apply_custom_highlights()

vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = apply_custom_highlights,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = apply_custom_highlights,
})

-- Check for external file changes (e.g. Claude editing in its terminal) whenever
-- focus returns to Neovim or the terminal/buffer is entered, so the buffer reloads
-- without needing autoread's own polling.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "TermLeave", "TermClose" }, {
  pattern = "*",
  command = "checktime",
})

-- claudecode.nvimのターミナルウィンドウにwinbarを付けて状態を分かりやすくする
-- (WezTerm側のタブ色付けと同じ狙い。本文の読みやすさに影響しないようwinbarのみ着色)
--
-- 状態はStopフック/UserPromptSubmitフック(set-tab-status.sh)がRPC経由
-- (v:lua.ClaudeCodeSetStatus)で伝えてくる。フックがまだ一度も呼ばれていない
-- (＝現在推論中、またはClaude Code起動直後)状態を"running"とみなしてオレンジにする。
_G.ClaudeCodeStatus = _G.ClaudeCodeStatus or "running"

local function claude_winbar_group(status)
  return status == "waiting" and "ClaudeCodeWinbarWaiting" or "ClaudeCodeWinbar"
end

-- claudecode.nvimはトグルのたびに別ウィンドウでターミナルバッファを開き直すことがあるため、
-- TermOpen発火時だけでなく、そのバッファが(再)表示されるたびに現在の状態色を塗り直す。
--
-- 「このバッファがclaudeのターミナルか」はTermOpen時に一度だけterm_titleで判定し、
-- バッファローカル変数に記憶しておく。term_titleはClaude Code自身が推論中に
-- スピナー付きの動的な文字列("claude"を含まない)で上書きしてしまうため、
-- 塗り直しのたびに毎回title文字列を見て判定すると推論中に判定漏れしてオレンジに
-- 戻せなくなる(Stop直後の"waiting"は判定できるが次のUserPromptSubmitでの
-- "running"への復帰が効かない、という不具合が実際に起きていた)。
local function paint_claude_winbar(win)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  local buf = vim.api.nvim_win_get_buf(win)
  if not vim.b[buf].is_claude_terminal then
    return
  end
  vim.wo[win].winbar = ("%%#%s# Claude Code %%*"):format(claude_winbar_group(_G.ClaudeCodeStatus))
end

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(ev)
    local win = vim.api.nvim_get_current_win()
    -- TermOpen発火時点ではterm_titleにコマンド名がまだ反映されていないことがあるため、
    -- 次のイベントループで再チェックする
    vim.schedule(function()
      if not vim.api.nvim_win_is_valid(win) then
        return
      end
      local title = vim.b[ev.buf].term_title or ""
      if title:match("claude") then
        vim.b[ev.buf].is_claude_terminal = true
        paint_claude_winbar(win)
      end
    end)
  end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
  callback = function()
    paint_claude_winbar(vim.api.nvim_get_current_win())
  end,
})

-- Claude Codeのフック(set-tab-status.sh)がRPC経由(v:lua.ClaudeCodeSetStatus)で呼ぶ。
-- claudecode.nvimの:terminal内で動いている場合、Neovimが自動でセットする$NVIM経由で
-- 到達できる。全ウィンドウのうち、claudeのターミナルバッファを持つものだけ塗り替える。
_G.ClaudeCodeSetStatus = function(status)
  _G.ClaudeCodeStatus = status
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    paint_claude_winbar(win)
  end
  return ""
end

-- Moltenの出力ウィンドウをEscで閉じられるようにする
vim.api.nvim_create_autocmd("FileType", {
  pattern = "molten_output",
  callback = function(ev)
    vim.keymap.set("n", "<Esc>", "<cmd>q<cr>", { buffer = ev.buf, silent = true })
  end,
})

-- エクスプローラー(左サイドバー)を閉じた時、空いた幅が隣の1つのウィンドウに丸ごと入って
-- 分割比率が崩れるため、横に並んだ通常のファイルウィンドウだけ幅を均等に戻す。
-- (equalalways=falseにしてあるので自動では揃わない。claudecodeのターミナルpane等は
--  buftypeが空でないので対象外にして、幅が変わらないようにしている)
local function equalize_file_windows()
  local groups = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local cfg = vim.api.nvim_win_get_config(win)
    local buf = vim.api.nvim_win_get_buf(win)
    if cfg.relative == "" and vim.bo[buf].buftype == "" and not vim.wo[win].winfixwidth then
      local row = vim.api.nvim_win_get_position(win)[1]
      -- 同じ高さ・同じ行から始まるウィンドウ = 横に並んでいるもの
      local key = row .. ":" .. vim.api.nvim_win_get_height(win)
      groups[key] = groups[key] or {}
      table.insert(groups[key], win)
    end
  end

  for _, wins in pairs(groups) do
    local n = #wins
    if n > 1 then
      table.sort(wins, function(a, b)
        return vim.api.nvim_win_get_position(a)[2] < vim.api.nvim_win_get_position(b)[2]
      end)
      local total = n - 1 -- 区切り線の分
      for _, win in ipairs(wins) do
        total = total + vim.api.nvim_win_get_width(win)
      end
      local each = math.floor((total - (n - 1)) / n)
      for i = 1, n - 1 do
        vim.api.nvim_win_set_width(wins[i], each)
      end
    end
  end
end

vim.api.nvim_create_autocmd("WinClosed", {
  group = vim.api.nvim_create_augroup("equalize_after_explorer", { clear = true }),
  callback = function(ev)
    local win = tonumber(ev.match)
    if not (win and vim.api.nvim_win_is_valid(win)) then
      return
    end
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype ~= "snacks_picker_list" then
      return
    end
    -- ウィンドウが実際に閉じ終わってから揃える
    vim.schedule(equalize_file_windows)
  end,
})

-- ウィンドウ(pane)・バッファを離れた時と、Neovim自体のフォーカスが外れた時に自動保存する
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave", "FocusLost" }, {
  group = vim.api.nvim_create_augroup("autosave", { clear = true }),
  callback = function(ev)
    local buf = ev.buf
    -- WinLeave/BufLeaveの最中に書き込むとBufWritePre(LSP整形)が正しく効かないため、
    -- イベント処理が終わってから対象バッファで保存する
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      local b = vim.bo[buf]
      if b.modified and b.buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
        vim.api.nvim_buf_call(buf, function()
          vim.cmd("silent! update")
        end)
      end
    end)
  end,
})
