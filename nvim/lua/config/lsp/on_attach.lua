return function(client)
  vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.declaration()<CR>',
                          {noremap = true, silent = true})
  vim.api.nvim_set_keymap('n', 'gf', '<cmd>lua vim.lsp.buf.definition()<CR>',
                          {noremap = true, silent = true})
  vim.api.nvim_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>',
                          {noremap = true, silent = true})
  vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>',
                          {noremap = true, silent = true})
  vim.api.nvim_set_keymap('n', 'gi',
                          '<cmd>lua vim.lsp.buf.implementation()<CR>',
                          {noremap = true, silent = true})
  vim.api.nvim_set_keymap('n', ',rr', '<cmd>lua vim.lsp.buf.rename()<CR>',
                          {noremap = true, silent = true})
  vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>',
                          {noremap = true, silent = true})
  vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>',
                          {noremap = true, silent = true})
  vim.api.nvim_set_keymap('n', 'ac', '<cmd>lua vim.lsp.buf.code_action()<CR>',
                          {noremap = true, silent = true})

  vim.api.nvim_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  if client.server_capabilities.document_formatting then
    local group = vim.api.nvim_create_augroup("LSPFormat", {clear = true})

    vim.api.nvim_create_autocmd("BufWritePre", {
      command = "lua vim.lsp.buf.formatting_sync()",
      group = group
    })
  else
    vim.b.client_not_support_format = true
  end
end
