return {
  {
    "folke/snacks.nvim",
    opts = {},
    keys = {
      {
        "<leader>ax",
        function()
          Snacks.terminal.toggle("codex", {
            win = {
              position = "right",
              width = 0.4,
            },
          })
        end,
        desc = "Toggle Codex (Split Right)",
      },
      {
        "<leader>aX",
        function()
          Snacks.terminal.toggle("codex", {
            win = {
              position = "float",
              height = 0.85,
              width = 0.85,
            },
          })
        end,
        desc = "Toggle Codex (Float)",
      },
    },
  },
}
