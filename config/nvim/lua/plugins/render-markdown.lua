return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  ft = { "markdown", "quarto" },
  opts = {
    code = {
      -- コードブロック(セル)の背景色を敷いて境界を分かりやすくする
      -- 囲み枠(border)はMolten出力が枠内に巻き込まれて見えるためoffにする
      style = "full",
      border = "none",
      width = "full",
      left_pad = 1,
      right_pad = 1,
      -- 言語アイコン/名前の見出しは不要なので非表示
      language = false,
    },
  },
  config = function(_, opts)
    require("render-markdown").setup(opts)
    -- CursorLine等はtransparent.nvimに背景を消されるため、直接控えめな色を指定する
    local function set_code_hl()
      vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "#20222e" })
    end
    set_code_hl()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_code_hl })
  end,
}
