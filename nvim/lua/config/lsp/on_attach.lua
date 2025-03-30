local dropdown_theme = require("config.cores.telescope.theme").dropdown_theme

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

  require("better-diagnostic-virtual-text.api").setup_buf(bufnr, {})

  vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.definition()<CR>', bufopts)
  vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', bufopts)
  vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', bufopts)
  vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', bufopts)
  vim.keymap.set('n', ',rr', '<cmd>lua vim.lsp.buf.rename()<CR>', bufopts)

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
