return {
  -- WezTerm(Kittyグラフィックスプロトコル対応)にセル出力の画像をインライン表示する
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      max_width_window_percentage = 100,
      max_height_window_percentage = 50,
    },
  },
  -- Jupyterカーネルに接続してセル単位で実行・出力表示する本体
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = true
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
    end,
    keys = {
      { "<leader>j", nil, desc = "Jupyter" },
      { "<leader>ji", "<cmd>MoltenInit<cr>", desc = "Init kernel" },
      {
        "<leader>jj",
        function()
          -- カーソル位置の```python ... ```フェンスを検出し、
          -- バッククォート行を含めずに中身のコードだけをMoltenEvaluateRangeへ渡す
          local bufnr = vim.api.nvim_get_current_buf()
          local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "markdown")
          if not ok or not parser then
            vim.notify("markdown treesitterパーサが見つかりません", vim.log.levels.ERROR)
            return
          end
          local row, col = unpack(vim.api.nvim_win_get_cursor(0))
          row = row - 1
          local tree = parser:parse()[1]
          local node = tree:root():named_descendant_for_range(row, col, row, col)
          while node and node:type() ~= "fenced_code_block" do
            node = node:parent()
          end
          if not node then
            vim.notify("カーソルがコードセル(```python)の中にありません", vim.log.levels.WARN)
            return
          end
          local content
          for child in node:iter_children() do
            if child:type() == "code_fence_content" then
              content = child
              break
            end
          end
          if not content then
            vim.notify("コードセルの中身が見つかりませんでした", vim.log.levels.WARN)
            return
          end
          local start_row, _, end_row, end_col = content:range()
          local last_row = (end_col == 0) and (end_row - 1) or end_row
          vim.fn.MoltenEvaluateRange(start_row + 1, last_row + 1)
        end,
        desc = "Run cell (fence-aware)",
      },
      { "<leader>jr", "<cmd>MoltenEvaluateOperator<cr>", desc = "Run operator" },
      { "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", desc = "Run line" },
      { "<leader>jc", "<cmd>MoltenReevaluateCell<cr>", desc = "Re-run cell" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>gv", mode = "v", desc = "Run selection" },
      { "<leader>jo", "<cmd>MoltenShowOutput<cr>", desc = "Show output" },
      { "<leader>je", "<cmd>noautocmd MoltenEnterOutput<cr>", desc = "Enter output (for copying)" },
      { "<leader>jh", "<cmd>MoltenHideOutput<cr>", desc = "Hide output" },
      { "<leader>jd", "<cmd>MoltenDelete<cr>", desc = "Delete cell output" },
      { "<leader>jx", "<cmd>MoltenInterrupt<cr>", desc = "Interrupt kernel" },
      {
        "<leader>jn",
        function()
          -- カーソル行の下に空のpythonコードセルを挿入し、中に入る
          local row = vim.api.nvim_win_get_cursor(0)[1]
          vim.api.nvim_buf_set_lines(0, row, row, false, { "", "```python", "", "```", "" })
          vim.api.nvim_win_set_cursor(0, { row + 3, 0 })
          vim.cmd("startinsert")
        end,
        desc = "New cell below",
      },
    },
  },
  -- .ipynbを直接開いて編集できるようにする(裏でjupytextコマンドを使って変換)
  {
    "GCBallesteros/jupytext.nvim",
    opts = {
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
    },
  },
}
