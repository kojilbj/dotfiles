return {
  {
    "folke/snacks.nvim",
    opts = {},
    keys = {
      {
        "<leader>ag",
        function()
          Snacks.terminal.toggle("agy", {
            win = {
              position = "right",
              width = 0.4,
            },
          })
        end,
        desc = "Toggle Antigravity (Split Right)",
      },
      {
        "<leader>aG",
        function()
          Snacks.terminal.toggle("agy", {
            win = {
              position = "float",
              height = 0.85,
              width = 0.85,
            },
          })
        end,
        desc = "Toggle Antigravity (Float)",
      },
    },
  },
}
