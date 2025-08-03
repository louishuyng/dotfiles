local lsp_config = require 'lspconfig'

lsp_config.lua_ls.setup({
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
        },
      },
      telemetry = {
        enable = false,
      },
      completion = {
        callSnippet = "Replace",
      },
      diagnostics = {
        disable = { "missing-fields" },
      },
    },
  },
})
