require('conform').setup({
  lsp_format = 'prefer',
  notify_on_error = false,
  format_on_save = {
    lsp_fallback = true,
    async = false,
    timeout_ms = 500,
  },
  formatters_by_ft = {
    javascript = { 'prettier', 'eslint' },
    typescript = { 'prettier', 'eslint' },
    javascriptreact = { 'prettier', 'eslint' },
    typescriptreact = { 'prettier', 'eslint' },
    json = { 'prettierd' },
    vue = { 'prettierd', 'eslint_d' },
    lua = { 'stylua' },
    markdown = { 'markdownlint' },
    fish = { 'fish_indent' },
    sh = { 'shfmt' },
    go = { 'gofmt' },
  },
})

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function(args)
    require('conform').format({ bufnr = args.buf })
  end,
})
