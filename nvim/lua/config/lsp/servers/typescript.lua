local lsp_config = require 'lspconfig'
local on_attach = require 'config/lsp/on_attach'

local function organize_imports()
  local params = {
    command = '_typescript.organizeImports',
    arguments = { vim.api.nvim_buf_get_name(0) },
  }
  vim.lsp.buf.execute_command(params)
end

lsp_config.ts_ls.setup({
  commands = {
    OrganizeImports = { organize_imports, description = 'Organize Imports' },
  },
  on_attach = on_attach,
  root_dir = lsp_config.util.root_pattern('package.json'),
  single_file_support = false,
})

lsp_config.eslint.setup({
  on_attach = on_attach,
  single_file_support = false,
})

require('lspconfig').denols.setup({
  on_attach = on_attach,
  root_dir = lsp_config.util.root_pattern('deno.json', 'deno.jsonc'),
})

-- lsp_config.biome.setup({
--   on_attach = function(client, bufnr)
--     client.server_capabilities.document_formatting = true
--     on_attach(client, bufnr)
--   end
-- })
