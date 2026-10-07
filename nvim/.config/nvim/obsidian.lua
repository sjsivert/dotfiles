-- Vim Motions config (mirrors LazyVim keymaps from ~/.config/nvim)
-- Window nav (<C-w>, <C-h/j/k/l>) stays in the Leader Hotkeys plugin so it works outside the editor.

vim.g.mapleader = " "

local leader = {
  -- top level
  { "e", "yazi-explorer:open", desc = "Explorer (yazi)" },
  { "/", "global-search:open", desc = "Grep" },
  { ",", "app:show-tab-switcher", desc = "Switch buffer" },
  { " ", "yazi-explorer:search-file", desc = "Find file (yazi)" },
  { ":", "command-palette:open", desc = "Commands" },
  { "-", "workspace:split-horizontal", desc = "Split below" },
  { "|", "workspace:split-vertical", desc = "Split right" },

  -- file / find
  { "ff", "switcher:open", desc = "Find file" },
  { "fr", "yazi-explorer:open-recent", desc = "Recent" },
  { "fz", "yazi-explorer:open-frecency", desc = "Most visited" },
  { "fb", "app:show-tab-switcher", desc = "Buffers" },
  { "fn", "file-explorer:new-file", desc = "New file" },
  { "fd", "file-explorer:new-folder", desc = "New folder" },
  { "fy", "workspace:copy-path", desc = "Copy path" },
  { "fc", "app:open-settings", desc = "Config" },

  -- search
  { "sg", "global-search:open", desc = "Grep" },
  { "sw", "global-search:open", desc = "Word" },
  { "sb", "editor:open-search", desc = "Buffer" },
  { "sr", "editor:open-search-replace", desc = "Replace" },
  { "ss", "yazi-explorer:open-outline", desc = "Symbols" },
  { "sd", "yazi-explorer:search-dir", desc = "Folders" },
  { "sc", "command-palette:open", desc = "Commands" },
  { "sk", "app:open-settings", desc = "Keymaps" },
  { "sh", "app:open-help", desc = "Help" },
  { "sm", "yazi-explorer:open-bookmarks", desc = "Bookmarks" },
  { "st", "tag-pane:open", desc = "Tags" },

  -- buffers
  { "bd", "workspace:close", desc = "Delete buffer" },
  { "bo", "workspace:close-others", desc = "Delete others" },
  { "bb", "workspace:goto-last-tab", desc = "Other buffer" },
  { "bn", "workspace:next-tab", desc = "Next buffer" },
  { "bp", "workspace:previous-tab", desc = "Previous buffer" },
  { "bt", "workspace:toggle-pin", desc = "Toggle pin" },
  { "bu", "workspace:undo-close-pane", desc = "Undo close" },

  -- windows
  { "wv", "workspace:split-vertical", desc = "Split right" },
  { "ws", "workspace:split-horizontal", desc = "Split below" },
  { "wd", "workspace:close", desc = "Delete window" },
  { "wo", "workspace:close-others", desc = "Only this window" },
  { "wh", "editor:focus-left", desc = "Go left" },
  { "wj", "editor:focus-bottom", desc = "Go down" },
  { "wk", "editor:focus-top", desc = "Go up" },
  { "wl", "editor:focus-right", desc = "Go right" },

  -- ui toggles
  { "ue", "app:toggle-left-sidebar", desc = "Sidebar" },
  { "ul", "editor:toggle-line-numbers", desc = "Line numbers" },
  { "us", "editor:toggle-spellcheck", desc = "Spelling" },
  { "uw", "editor:toggle-readable-line-length", desc = "Readable width" },
  { "ur", "markdown:toggle-preview", desc = "Reading view" },
  { "um", "editor:toggle-source", desc = "Source mode" },

  -- obsidian extras
  { "og", "graph:open", desc = "Graph" },
  { "ol", "graph:open-local", desc = "Local graph" },
  { "ob", "backlink:open", desc = "Backlinks" },
  { "or", "yazi-explorer:open-relations", desc = "Relations (yazi)" },
  { "oo", "outgoing-link:open", desc = "Outgoing links" },
  { "op", "properties:open", desc = "Properties" },
  { "oc", "canvas:new-file", desc = "New canvas" },
  { "od", "daily-notes", desc = "Daily note" },
  { "ot", "templates:insert-template", desc = "Insert template" },
  { "om", "bookmarks:bookmark-current-view", desc = "Bookmark view" },
}

vim.obsidian.leader.add(leader)

vim.obsidian.whichkey.add({
  { "<leader>f", group = "file/find" },
  { "<leader>s", group = "search" },
  { "<leader>b", group = "buffer" },
  { "<leader>w", group = "windows" },
  { "<leader>u", group = "ui" },
  { "<leader>o", group = "obsidian" },
})
