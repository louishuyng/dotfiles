local on_attach = require 'config/lsp/on_attach'

local lsp_config = require 'lspconfig'

lsp_config.svelte.setup({on_attach = on_attach})
