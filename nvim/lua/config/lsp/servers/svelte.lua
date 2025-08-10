vim.lsp.config('svelte', {
  cmd = { 'svelteserver', '--stdio' },
  filetypes = { 'svelte' },
  root_markers = { 'package.json', '.git' },
})

vim.lsp.enable('svelte')
