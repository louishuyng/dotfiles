local lsp_config = require 'lspconfig'
local on_attach = require 'config/lsp/on_attach'

lsp_config.tsserver.setup({
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
  on_attach = function(client, bufnr)
    client.server_capabilities.document_formatting = false
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>fm",
                                "<cmd>lua vim.lsp.buf.formatting()<CR>", {})
    on_attach(client, bufnr)
  end
})

lsp_config.eslint.setup({
  on_attach = function(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre",
                                {buffer = bufnr, command = "EslintFixAll"})
  end
})
