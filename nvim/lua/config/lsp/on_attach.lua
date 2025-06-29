-- local navic = require('nvim-navic')

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    local bufopts = { noremap = true, silent = true, buffer = bufnr }

    -- if client.server_capabilities.documentSymbolProvider then
    --   navic.attach(client, bufnr)
    -- end

    -- If file is has . characters at beginning, don't format
    if vim.fn.match(vim.fn.expand('%:t'), '^[.]') ~= -1 then
      return
    end

    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' })
    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signatureHelp, { border = 'single' })

    vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.definition()<CR>', {
      desc = 'Go to definition',
    })
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', {
      desc = 'Document symbol',
    })
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', {
      desc = 'Go to implementation',
    })
    vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', {
      desc = 'Code action',
    })
    vim.keymap.set('n', ',rr', '<cmd>lua vim.lsp.buf.rename()<CR>', {
      desc = 'Rename',
    })
  end,
})
