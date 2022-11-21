local M = {}

M.group = vim.api.nvim_create_augroup("LSPFormat", {clear = true})

function M.toggle_auto_format()
  if vim.g.auto_format then
    vim.g.auto_format = false
    vim.api.nvim_clear_autocmds({group = M.group})
  else
    vim.g.auto_format = true
    M.get_auto_format()
  end
end

function M.get_auto_format()
  vim.api.nvim_create_autocmd("BufWritePre", {
    command = "lua vim.lsp.buf.format()",
    group = M.group
  })
end

return M
