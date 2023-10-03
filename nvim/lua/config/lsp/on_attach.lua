local group = require('functions.toggle_auto_format').group
local navic = require("nvim-navic")

return function(client, bufnr)
  local bufopts = {noremap = true, silent = true, buffer = bufnr}

  vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.declaration()<CR>', bufopts)
  vim.keymap.set('n', 'gf',
                 '<Cmd>lua require("telescope.builtin").lsp_definitions()<CR>',
                 bufopts)
  vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', bufopts)
  vim.keymap
      .set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', bufopts)

  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', bufopts)
  vim.keymap.set('n', '<leader>gi', '<cmd>lua vim.lsp.buf.implementation()<CR>',
                 bufopts)
  vim.keymap.set('n', ',rr', '<cmd>lua vim.lsp.buf.rename()<CR>', bufopts)
  vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>',
                 bufopts)

  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev,
                 {desc = "Go to previous diagnostic"})
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next,
                 {desc = "Go to next diagnostic"})

  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  vim.diagnostic.config({float = {border = "single"}})

  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end

  if client.server_capabilities.document_formatting then
    if vim.bo.filetype == 'org' then return end

    vim.api.nvim_create_autocmd("BufWritePre", {
      command = "lua vim.lsp.buf.format({ timeout_ms = 5000 })",
      group = vim.api.nvim_create_augroup("LSPFormat", {clear = true})
    })
  else
    vim.b.document_formatting = client.server_capabilities.document_formatting
  end
end
