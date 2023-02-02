local lsp_config = require 'lspconfig'

lsp_config.tsserver.setup({
  on_attach = function(client, bufnr)
    client.server_capabilities.document_formatting = true
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>fm",
                                "<cmd>lua vim.lsp.buf.formatting()<CR>", {})
  end
})
