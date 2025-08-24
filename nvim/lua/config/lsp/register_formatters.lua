local get_lsp_format_opt = function()
  local bufnr = vim.fn.bufnr()

  local disable_filetypes = {
    javascript = true,
    typescript = true,
    javascriptreact = true,
    typescriptreact = true,
  }

  local lsp_format_opt
  if disable_filetypes[vim.bo[bufnr].filetype] then
    lsp_format_opt = 'never'
  else
    lsp_format_opt = 'fallback'
  end

  return lsp_format_opt
end

require('conform').setup({
  lsp_format = 'prefer',
  notify_on_error = false,
  format_on_save = function()
    return {
      timeout_ms = 500,
      lsp_format = get_lsp_format_opt(),
    }
  end,
  formatters_by_ft = {
    lua = { 'stylua' },
    javascript = { 'eslint_d', 'prettier_d', 'prettier' },
    typescript = { 'eslint_d', 'prettier_d', 'prettier' },
    javascriptreact = { 'eslint_d', 'prettier_d', 'prettier' },
    typescriptreact = { 'eslint_d', 'prettier_d', 'prettier' },
  },
})

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function(args)
    require('conform').format({ bufnr = args.buf })
  end,
})
