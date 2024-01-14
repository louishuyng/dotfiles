local group = require('functions.toggle_auto_format').group

return function(client, bufnr)
  local bufopts = {noremap = true, silent = true, buffer = bufnr}

  vim.keymap.set('n', 'gd', ':Lspsaga goto_type_definition<CR>', bufopts)
  vim.keymap.set('n', 'gf', ':Lspsaga goto_definition<CR>', bufopts)
  vim.keymap.set('n', 'gF', ':Lspsaga peek_definition<CR>', bufopts)
  vim.keymap.set('n', 'gr', ':Lspsaga finder<CR>', bufopts)
  vim.keymap.set('n', 'K', ':Lspsaga hover_doc<CR>', bufopts)
  vim.keymap.set('n', '<leader>ca', ':Lspsaga code_action<CR>', bufopts)
  vim.keymap.set('n', ',rr', '<cmd>lua vim.lsp.buf.rename()<CR>', bufopts)

  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- If file is has . characters at beginning, don't format
  if vim.fn.match(vim.fn.expand('%:t'), '^[.]') ~= -1 then return end

  if client.server_capabilities.document_formatting then
    vim.api.nvim_create_autocmd("BufWritePre", {
      command = "lua vim.lsp.buf.format({ timeout_ms = 5000 })",
      group = vim.api.nvim_create_augroup("LSPFormat", {clear = true})
    })
  else
    vim.b.document_formatting = client.server_capabilities.document_formatting
  end
end
