local typescript_on_save_augroup = vim.api.nvim_create_augroup('FormatOnSave', {})

local function on_attach(client, bufnr)
  vim.api.nvim_clear_autocmds({ group = typescript_on_save_augroup, buffer = bufnr })
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = typescript_on_save_augroup,
    buffer = bufnr,
    callback = function(event)
      vim.cmd('TSToolsRemoveUnused')
      vim.cmd('TSToolsOrganizeImports')
    end,
  })
end

require('typescript-tools').setup({
  on_attach = on_attach,
})

vim.lsp.config('eslint', {
  single_file_support = true,
  settings = {
    packageManager = 'yarn', -- or 'npm'
  },
})

vim.lsp.enable('eslint')
