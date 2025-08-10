vim.lsp.config('ltex', {
  cmd = { 'ltex-ls' },
  filetypes = { 'bib', 'gitcommit', 'markdown', 'org', 'plaintex', 'rst', 'rnoweb', 'tex' },
  root_markers = { '.git' },
})

vim.lsp.enable('ltex')
