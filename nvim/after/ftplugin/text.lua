vim.lsp.start({
  name = "LSP From Scratch",
  cmd = {
    "npx", "ts-node",
    vim.fn.expand(
      "~/Dev/repository/github.com/louishuyng/awesome-tech/backend/scratch/lsp-from-scratch/server/src/server.ts")
  },
  capabilities = vim.lsp.protocol.make_client_capabilities(),
})
