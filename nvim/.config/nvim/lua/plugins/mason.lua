-- Ensure tools are installed via Mason
return {
  "mason-org/mason.nvim",
  opts = {
    ensure_installed = {
      "prettier", -- JavaScript/TypeScript formatter
      "stylua", -- Lua formatter
    },
  },
}
