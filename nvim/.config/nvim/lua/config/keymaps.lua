-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local g = vim.g
local set = vim.api.nvim_set_keymap
local ns = { noremap = true, silent = true }

set("i", "jk", "<Esc>", ns)
set("i", "kj", "<Esc>", ns)
