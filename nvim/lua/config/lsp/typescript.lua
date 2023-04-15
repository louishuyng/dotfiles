local lsp_config = require 'lspconfig'
local on_attach = require 'config/lsp/on_attach'

lsp_config.tsserver.setup({
  on_attach = function(client, bufnr)
    client.server_capabilities.document_formatting = false
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>fm",
                                "<cmd>lua vim.lsp.buf.formatting()<CR>", {})
    on_attach(client, bufnr)
  end
})
