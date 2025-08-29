require('conform').setup({
  lsp_format = 'prefer',
  notify_on_error = false,
  format_on_save = {
    lsp_fallback = true,
    async = false,
    timeout_ms = 500,
  },
  formatters_by_ft = {
    javascript = { 'prettierd', 'eslint_d' },
    typescript = { 'prettierd', 'eslint_d' },
    javascriptreact = { 'prettierd', 'eslint_d' },
    typescriptreact = { 'prettierd', 'eslint_d' },
    json = { 'prettierd' },
    vue = { 'prettierd', 'eslint_d' },
    lua = { 'stylua' },
    markdown = { 'markdownlint' },
    fish = { 'fish_indent' },
    sh = { 'shfmt' },
    yaml = { 'yamlfmt' },
    go = { 'gofmt' },
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
