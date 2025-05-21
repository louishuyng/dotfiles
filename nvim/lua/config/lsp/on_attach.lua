return function(client, bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }

  -- If file is has . characters at beginning, don't format
  if vim.fn.match(vim.fn.expand('%:t'), '^[.]') ~= -1 then
    return
  end

  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'single' })
  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signatureHelp, { border = 'single' })

  vim.keymap.set('n', '<leader>A', function()
    local current_status = vim.fn.execute('Copilot status')

    if current_status:find('Offline') then
      vim.cmd('Copilot enable')
    else
      vim.cmd('Copilot disable')
    end
  end, { desc = 'Toggle Copilot' })

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
end
