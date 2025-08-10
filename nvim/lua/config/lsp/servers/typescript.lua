local function organize_imports()
  local params = {
    command = '_typescript.organizeImports',
    arguments = { vim.api.nvim_buf_get_name(0) },
  }
  vim.lsp.buf.execute_command(params)
end

vim.lsp.config('ts_ls', {
  commands = {
    OrganizeImports = { organize_imports, description = 'Organize Imports' },
  },
  single_file_support = false,
  settings = {
    typescript = {
      updateImportsOnFileMove = { enabled = 'always' },
      suggest = {
        completeFunctionCalls = true,
      },
      inlayHints = {
        includeInlayParameterNameHints = 'literal',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = false,
        includeInlayVariableTypeHints = false,
        includeInlayPropertyDeclarationTypeHints = false,
        includeInlayFunctionLikeReturnTypeHints = false,
        includeInlayEnumMemberValueHints = false,
      },
    },
    javascript = {
      updateImportsOnFileMove = { enabled = 'always' },
      suggest = {
        completeFunctionCalls = true,
      },
      inlayHints = {
        includeInlayParameterNameHints = 'literal',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = false,
        includeInlayVariableTypeHints = false,
        includeInlayPropertyDeclarationTypeHints = false,
        includeInlayFunctionLikeReturnTypeHints = false,
        includeInlayEnumMemberValueHints = false,
      },
    },
  },
})

vim.lsp.config('eslint', {
  single_file_support = false,
})

vim.lsp.config('denols', {
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_dir = function(fname)
    return vim.fs.root(fname, { 'deno.json', 'deno.jsonc' })
  end,
})

-- vim.lsp.config('biome', {
--   cmd = { 'biome', 'lsp-proxy' },
--   filetypes = { 'javascript', 'javascriptreact', 'json', 'jsonc', 'typescript', 'typescript.tsx', 'typescriptreact' },
--   root_markers = { 'biome.json', '.git' },
-- })

vim.lsp.enable('ts_ls')
vim.lsp.enable('eslint')
vim.lsp.enable('denols')
-- vim.lsp.enable('biome')
