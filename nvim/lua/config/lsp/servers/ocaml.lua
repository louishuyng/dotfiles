vim.lsp.config('ocamllsp', {
  cmd = { 'ocamllsp' },
  filetypes = { 'ocaml', 'reason', 'dune', 'dune-project' },
  root_markers = { '*.opam', 'esy.json', 'package.json', 'dune-project', 'dune-workspace', '.git' },
})

vim.lsp.enable('ocamllsp')
