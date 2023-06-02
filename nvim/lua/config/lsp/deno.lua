local on_attach = require 'config/lsp/on_attach'

require('lspconfig').denols.setup({on_attach = on_attach})
