-- pantran.nvim を使った翻訳設定
--
-- vim-translatorはGoogle翻訳の無料APIのうち`translate.googleapis.com`(gtx)しか
-- 使わず、フォールバックが無いためネットワークによってはブロックされ動かない
-- (このマシンではHTTP 429で常にブロックされることを確認済み)。
-- pantranのgoogleエンジンは`clients5.google.com`への自動フォールバックを持ち、
-- 同じネットワークから実際に翻訳成功することを確認したため、
-- ポップアップ/置換系のキーマップもpantranのエンジンを直接呼び出して実装する。
--
-- gtxは常にブロックされておりcurlのリトライ(--retry 3)を毎回消化してから
-- clients5にフォールバックするため1回の翻訳に約8.5秒かかっていた。
-- gtxへのリトライを完全に省いてclients5だけを叩くよう固定したところ約60msまで
-- 短縮できたため、最初から動く方だけを使う。
-- 参考: https://zenn.dev/mozumasu/articles/mozumasu-translate-in-vim

local WORKING_GOOGLE_URL = "https://clients5.google.com/translate_a/t?client=dict-chrome-ex"

local function get_engine()
  local engine = require("pantran.engines.google")
  engine.urls = { WORKING_GOOGLE_URL }
  engine.setup()
  return engine
end

local function get_visual_selection()
  local s = vim.fn.getpos("'<")
  local e = vim.fn.getpos("'>")
  local lines = vim.fn.getline(s[2], e[2])
  if #lines == 0 then
    return "", nil
  end
  if #lines == 1 then
    lines[1] = lines[1]:sub(s[3], e[3])
  else
    lines[1] = lines[1]:sub(s[3])
    lines[#lines] = lines[#lines]:sub(1, e[3])
  end
  local range = { start_line = s[2], end_line = e[2], start_col = s[3], end_col = e[3] }
  return table.concat(lines, "\n"), range
end

local function show_popup(text)
  vim.lsp.util.open_floating_preview(vim.split(text, "\n", { plain = true }), "markdown", {
    border = "rounded",
    focus = false,
    close_events = { "CursorMoved", "CursorMovedI", "InsertEnter" },
  })
end

-- 置換は単一行のみ対応(元記事のvim-translatorも「複数行ある場合はうまく動きません」
-- という同様の制限があったため、それに準じてシンプルに保つ)
local function replace_text(word, range, translation)
  if range then
    if range.start_line ~= range.end_line then
      vim.notify("複数行の置換には対応していません", vim.log.levels.WARN, { title = "Translate" })
      return
    end
    local line = vim.fn.getline(range.start_line)
    local new_line = line:sub(1, range.start_col - 1) .. translation .. line:sub(range.end_col + 1)
    vim.fn.setline(range.start_line, new_line)
  else
    local lnum = vim.fn.line(".")
    local line = vim.fn.getline(lnum)
    local new_line = vim.fn.substitute(line, "\\V" .. vim.fn.escape(word, "\\"), vim.fn.escape(translation, "\\&"), "")
    vim.fn.setline(lnum, new_line)
  end
end

---@param target "ja"|"en"
---@param opts { replace: boolean, visual: boolean }
local function translate(target, opts)
  local text, range
  if opts.visual then
    text, range = get_visual_selection()
  else
    text = vim.fn.expand("<cword>")
  end
  if text == "" then
    return
  end

  local engine = get_engine()
  require("pantran.async").run(function()
    local ok, result = pcall(engine.translate, text, "auto", target)
    if not ok then
      vim.notify("翻訳に失敗しました: " .. tostring(result), vim.log.levels.ERROR, { title = "Translate" })
      return
    end
    if opts.replace then
      replace_text(text, range, result.text)
    else
      show_popup(result.text)
    end
  end)
end

return {
  "potamides/pantran.nvim",
  cmd = "Pantran",
  keys = {
    {
      "<leader>tj",
      function()
        translate("ja", { replace = false, visual = false })
      end,
      mode = "n",
      desc = "日本語に翻訳 (ポップアップ)",
    },
    {
      "<leader>tj",
      function()
        translate("ja", { replace = false, visual = true })
      end,
      mode = "v",
      desc = "日本語に翻訳 (ポップアップ)",
    },
    {
      "<leader>te",
      function()
        translate("en", { replace = false, visual = false })
      end,
      mode = "n",
      desc = "英語に翻訳 (ポップアップ)",
    },
    {
      "<leader>te",
      function()
        translate("en", { replace = false, visual = true })
      end,
      mode = "v",
      desc = "英語に翻訳 (ポップアップ)",
    },
    {
      "<leader>trj",
      function()
        translate("ja", { replace = true, visual = false })
      end,
      mode = "n",
      desc = "日本語に置換",
    },
    {
      "<leader>trj",
      function()
        translate("ja", { replace = true, visual = true })
      end,
      mode = "v",
      desc = "日本語に置換",
    },
    {
      "<leader>tre",
      function()
        translate("en", { replace = true, visual = false })
      end,
      mode = "n",
      desc = "英語に置換",
    },
    {
      "<leader>tre",
      function()
        translate("en", { replace = true, visual = true })
      end,
      mode = "v",
      desc = "英語に置換",
    },
    { "<leader>tw", "<Cmd>Pantran<CR>", mode = "n", desc = "翻訳ウィンドウを表示" },
    { "<leader>tw", ":Pantran<CR>", mode = "v", desc = "選択範囲を翻訳ウィンドウで表示" },
  },
  opts = {
    default_engine = "google",
    engines = {
      google = {
        default_source = "auto",
        default_target = "ja",
      },
    },
  },
  config = function(_, opts)
    require("pantran").setup(opts)
    -- <leader>tw (:Pantran) もこのgoogleエンジンを使うため、そちらでも
    -- gtxへのリトライが起きないよう起動時に一度だけ固定しておく
    require("pantran.engines.google").urls = { WORKING_GOOGLE_URL }
  end,
}
