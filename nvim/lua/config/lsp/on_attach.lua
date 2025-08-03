-- local navic = require('nvim-navic')

local augroup = vim.api.nvim_create_augroup('UserLspConfig', { clear = true })

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' })
vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signatureHelp, { border = 'single' })

vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup,
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    if not client then return end

    -- If file has . characters at beginning, don't format
    if vim.fn.match(vim.fn.expand('%:t'), '^[.]') ~= -1 then
      return
    end

    -- Disable semantic tokens for better performance
    client.server_capabilities.semanticTokensProvider = nil

    local opts = { buffer = bufnr, silent = true, noremap = true }

    vim.keymap.set('n', 'gf', vim.lsp.buf.definition, vim.tbl_extend('force', opts, { desc = 'Go to definition' }))
    vim.keymap.set('n', 'gs', vim.lsp.buf.document_symbol, vim.tbl_extend('force', opts, { desc = 'Document symbol' }))
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, vim.tbl_extend('force', opts, { desc = 'Go to implementation' }))
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, vim.tbl_extend('force', opts, { desc = 'Code action' }))
    vim.keymap.set('n', ',rr', vim.lsp.buf.rename, vim.tbl_extend('force', opts, { desc = 'Rename' }))
  end,
})
