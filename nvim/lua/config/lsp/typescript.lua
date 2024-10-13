local lsp_config = require 'lspconfig'
local on_attach = require 'config/lsp/on_attach'

local function organize_imports()
  local params = {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(0) }
  }
  vim.lsp.buf.execute_command(params)
end

lsp_config.ts_ls.setup({
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
  on_attach = function(client, bufnr)
    -- Some project need to enable document formatting on tsserver
    local paths = { "perx-dashboard-v4", "usvc-request", "usvc-migrations", "lsp-from-scratch" }

    if vim.tbl_contains(paths, vim.fn.fnamemodify(vim.fn.getcwd(), ":t")) then
      client.server_capabilities.document_formatting = true
    else
      client.server_capabilities.document_formatting = false
    end

    on_attach(client, bufnr)
  end,
  commands = {
    OrganizeImports = { organize_imports, description = "Organize Imports" }
  },
  root_dir = lsp_config.util.root_pattern("package.json"),
  single_file_support = false
})

lsp_config.eslint.setup({
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre",
      { buffer = bufnr, command = "EslintFixAll" })
  end,
  root_dir = lsp_config.util.root_pattern(".eslintrc.js", ".eslintrc.json", ".eslintrc", ".eslintrc.yml"),
  single_file_support = false
})

require('lspconfig').denols.setup({
  on_attach = function(client, bufnr)
    client.server_capabilities.document_formatting = true

    on_attach(client, bufnr)
  end,
  root_dir = lsp_config.util.root_pattern("deno.json", "deno.jsonc"),
})

-- lsp_config.biome.setup({
--   on_attach = function(client, bufnr)
--     client.server_capabilities.document_formatting = true
--     on_attach(client, bufnr)
--   end
-- })
