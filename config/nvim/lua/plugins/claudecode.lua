return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    terminal_cmd = "claude",
    terminal = {
      split_side = "right",
      split_width_percentage = 0.4,
    },
  },
  keys = {
    { "<leader>a", nil, desc = "AI/Claude" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude (Split Right)" },
    {
      "<leader>aC",
      function()
        require("claudecode.terminal").simple_toggle({
          snacks_win_opts = {
            position = "float",
            height = 0.85,
            width = 0.85,
          },
        })
      end,
      desc = "Toggle Claude (Float)",
    },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
