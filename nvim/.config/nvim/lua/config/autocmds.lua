-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Claude Code's transcript (ctrl+o then v, or C-a Esc in tmux): start at the
-- end of the conversation, and on quit send q to the Claude pane so it leaves
-- its transcript view and goes back to the prompt
local claude_transcript = vim.api.nvim_create_augroup("claude_transcript", { clear = true })
vim.api.nvim_create_autocmd("BufReadPost", {
  group = claude_transcript,
  pattern = "cc-transcript-*.txt",
  callback = function()
    vim.cmd("normal! G")
    local pane = vim.env.TMUX_PANE
    if not pane then
      return
    end
    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = claude_transcript,
      once = true,
      callback = function()
        -- wait for Claude to take the terminal back before the q arrives
        vim.fn.jobstart({ "sh", "-c", 'sleep 0.3; tmux send-keys -t "$1" q', "sh", pane }, { detach = true })
      end,
    })
  end,
})
