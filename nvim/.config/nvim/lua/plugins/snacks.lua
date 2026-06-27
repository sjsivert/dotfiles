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
                        nav_h = { "<C-h>", function() vim.cmd("TmuxNavigateLeft") end, desc = "Go to Left Window", mode = "t" },
                        nav_j = { "<C-j>", function() vim.cmd("TmuxNavigateDown") end, desc = "Go to Lower Window", mode = "t" },
                        nav_k = { "<C-k>", function() vim.cmd("TmuxNavigateUp") end, desc = "Go to Upper Window", mode = "t" },
                        nav_l = { "<C-l>", function() vim.cmd("TmuxNavigateRight") end, desc = "Go to Right Window", mode = "t" },
                    },
                },
            },
        },
    },
}
