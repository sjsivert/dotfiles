return {
    {
        "folke/snacks.nvim",
        opts = {
            picker = {
                sources = {
                    explorer = {
                        hidden = true,
                        ignored = true,
                    },
                    files = {
                        hidden = true,
                        ignored = true,
                    },
                },
                win = {
                    list = {
                        keys = {
                            -- free up C-j/C-k for window navigation (j/k already navigate the list)
                            ["<c-j>"] = false,
                            ["<c-k>"] = false,
                        },
                    },
                },
            },
            terminal = {
                win = {
                    keys = {
                        -- LazyVim default uses plain wincmd with no tmux awareness.
                        -- Replace with TmuxNavigate so terminal-mode nav reaches tmux.
                        -- expr = false: opts are deep-merged, so LazyVim's expr = true would
                        -- otherwise stick. In an expr mapping wincmd fails (textlock), the
                        -- navigator swallows the error and jumps straight to the tmux pane.
                        nav_h = { "<C-h>", function() vim.cmd("TmuxNavigateLeft") end, desc = "Go to Left Window", expr = false, mode = "t" },
                        nav_j = { "<C-j>", function() vim.cmd("TmuxNavigateDown") end, desc = "Go to Lower Window", expr = false, mode = "t" },
                        nav_k = { "<C-k>", function() vim.cmd("TmuxNavigateUp") end, desc = "Go to Upper Window", expr = false, mode = "t" },
                        nav_l = { "<C-l>", function() vim.cmd("TmuxNavigateRight") end, desc = "Go to Right Window", expr = false, mode = "t" },
                    },
                },
            },
        },
    },
}
