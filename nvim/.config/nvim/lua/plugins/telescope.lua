return {
  "nvim-telescope/telescope.nvim",
  keys = {
    {
      "<leader>fA",
      function()
        require("telescope.builtin").find_files({ no_ignore = true, hidden = true })
      end,
      desc = "Find All Files (incl. gitignored)",
    },
  },
  opts = {
    defaults = {
      file_ignore_patterns = { "%.git/" }, -- hide .git folder, but not all dotfiles
    },
    pickers = {
      find_files = {
        hidden = true,
        no_ignore = true, -- don't respect .gitignore
        no_ignore_parent = true, -- don't respect .gitignore in parent dirs
      },
    },
  },
  {
    "christoomey/vim-tmux-navigator",
    init = function()
      -- Disable plugin's own mappings; keymaps.lua provides smart wincmd+tmux nav
      vim.g.tmux_navigator_no_mappings = 1
    end,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-h>", "<cmd>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>" },
    },
  },
}
