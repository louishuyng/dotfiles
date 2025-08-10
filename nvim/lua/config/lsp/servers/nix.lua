vim.lsp.config('rnix', {
  cmd = { 'rnix-lsp' },
  filetypes = { 'nix' },
  root_markers = { 'flake.nix', 'shell.nix', 'default.nix', '.git' },
})

vim.lsp.enable('rnix')
