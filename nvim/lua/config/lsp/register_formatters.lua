local conform = require('conform')

conform.setup({
  notify_on_error = true,
  format_on_save = function(bufnr)
    return {
      timeout_ms = 3000,
      lsp_fallback = true,
    }
  end,
  formatters_by_ft = {
    javascript = { 'oxfmt', 'prettier', 'eslint' },
    typescript = { 'oxfmt', 'prettier', 'eslint' },
    javascriptreact = { 'oxfmt', 'prettier', 'eslint' },
    typescriptreact = { 'oxfmt', 'prettier', 'eslint' },
    json = { 'prettier' },
    vue = { 'prettier', 'eslint' },
    lua = { 'stylua' },
    markdown = { 'markdownlint' },
    fish = { 'fish_indent' },
    sh = { 'shfmt' },
    go = { 'gofmt' },
    python = { 'ruff_organize_imports', 'ruff_fix', 'ruff_format', 'autopep8' },
  },
  formatters = {
    oxfmt = {
      command = 'oxfmt',
      stdin = true,
    },
    ruff_fix = {
      command = 'ruff',
      args = { 'fix', '--stdin-filename', '$FILENAME', '-' },
      stdin = true,
    },
    ruff_format = {
      command = 'ruff',
      args = { 'format', '--stdin-filename', '$FILENAME', '-' },
      stdin = true,
    },
    autopep8 = {
      command = 'autopep8',
      args = { '--aggressive', '--aggressive', '-' },
      stdin = true,
    },
  },
})
