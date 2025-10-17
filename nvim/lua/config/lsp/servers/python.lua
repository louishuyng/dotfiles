vim.lsp.config('ruff', {
  cmd = { 'ruff-lsp' },
  filetypes = { 'python' },
  settings = {
    organizeImports = true,
    fixAll = true,
  },
})

vim.lsp.config('pyright', {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  settings = {
    pyright = {
      -- Using Ruff's import organizer
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        -- Ignore all files for analysis to exclusively use Ruff for linting
        ignore = { '*' },
      },
    },
  },
})

vim.lsp.enable('ruff')
vim.lsp.enable('pyright')
