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
    javascript = { 'eslint', 'prettier' },
    typescript = { 'eslint_d', 'prettier_d' },
    javascriptreact = { 'eslint_d', 'prettier_d' },
    typescriptreact = { 'eslint_d', 'prettier_d' },
  },
})

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function(args)
    require('conform').format({ bufnr = args.buf })
  end,
})

-- Kill eslint_d and prettier_d processes when exiting Neovim
vim.api.nvim_create_autocmd('VimLeavePre', {
  callback = function()
    vim.fn.system('eslint_d stop')
    vim.fn.system('prettier_d stop')
  end,
})
