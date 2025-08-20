vim.lsp.config('ts_ls', {
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

vim.lsp.config('denols', {
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_dir = function(fname)
    return vim.fs.root(fname, { 'deno.json', 'deno.jsonc' })
  end,
})

-- vim.lsp.config('biome', {
--   cmd = { 'biome', 'lsp-proxy' },
--   filetypes = { 'javascript', 'javascriptreact', 'json', 'jsonc', 'typescript', 'typescript.tsx', 'typescriptreact' },
--   -- root_markers = { 'biome.json', '.git' },
-- })

vim.lsp.enable('ts_ls')
vim.lsp.enable('denols')
-- vim.lsp.enable('biome')
