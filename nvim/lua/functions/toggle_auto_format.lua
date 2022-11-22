local M = {}

function M.toggle_auto_format()
  if vim.g.auto_format then
    vim.g.auto_format = false
    vim.api.nvim_clear_autocmds({group = "LSPFormat"})
  else
    vim.g.auto_format = true
    M.get_auto_format()
  end
end

function M.get_auto_format()
  vim.api.nvim_create_autocmd("BufWritePre", {
    command = "lua vim.lsp.buf.format()",
    group = vim.api.nvim_create_augroup("LSPFormat", {clear = true})
  })
end

return M
