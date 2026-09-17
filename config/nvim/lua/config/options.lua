-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Auto-reload files changed outside Neovim (e.g. by claudecode.nvim's terminal)
vim.opt.autoread = true

-- Don't auto-resize all windows to equal size when one is opened/closed
-- (e.g. toggling the explorer was shrinking the claudecode terminal pane)
vim.opt.equalalways = false

-- molten-nvim (Jupyter)用のpython3プロバイダ
-- pynvim/jupyter_clientが入った専用venv (~/.venvs/neovim) を使う
vim.g.python3_host_prog = vim.fn.expand("~/.venvs/neovim/bin/python3")
