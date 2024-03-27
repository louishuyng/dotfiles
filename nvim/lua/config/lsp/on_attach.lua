-- if you want to set up formatting on save, you can use this as a callback
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local lsp_formatting = function(bufnr)
  vim.lsp.buf.format({
    filter = function(client)
      return client.server_capabilities.document_formatting
    end,
    bufnr = bufnr
  })
end

return function(client, bufnr)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }

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

  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function() lsp_formatting(bufnr) end
    })
  end
end
