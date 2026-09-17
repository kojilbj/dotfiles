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
