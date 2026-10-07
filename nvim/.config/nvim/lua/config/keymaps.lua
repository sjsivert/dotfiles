-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local g = vim.g
-- Smart tmux-aware window navigation.
-- Problem: snacks picker and explorer open floating windows on top of a real
-- split (snacks_layout_box). When wincmd lands on that container, winnr()
-- changes so vim-tmux-navigator never forwards to tmux. Fix: detect landing
-- on known snacks non-editor windows and call TmuxNavigate from there.
local snacks_skip = {
  snacks_layout_box = true,
  snacks_picker_preview = true,
}

local function tmux_nav(dir)
  local cmd = { h = "TmuxNavigateLeft", j = "TmuxNavigateDown", k = "TmuxNavigateUp", l = "TmuxNavigateRight" }
  return function()
    local cur = vim.api.nvim_get_current_win()
    vim.cmd("wincmd " .. dir)
    local ft = vim.bo.filetype
    if vim.api.nvim_get_current_win() == cur or snacks_skip[ft] then
      vim.cmd(cmd[dir])
    end
  end
end

vim.keymap.set("n", "<C-h>", tmux_nav("h"), { silent = true })
vim.keymap.set("n", "<C-j>", tmux_nav("j"), { silent = true })
vim.keymap.set("n", "<C-k>", tmux_nav("k"), { silent = true })
vim.keymap.set("n", "<C-l>", tmux_nav("l"), { silent = true })
