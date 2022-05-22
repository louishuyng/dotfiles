local M = {}

local group = vim.api.nvim_create_augroup("LSPFormat", { clear = true })

function M.toggle_auto_format()
  if vim.g.auto_format then
    vim.g.auto_format = false
  else
    vim.g.auto_format = true
    M.get_auto_format()
  end

  if not vim.g.auto_format then
    vim.api.nvim_clear_autocmds({ group = group })
  end
end

function M.get_auto_format()
  vim.api.nvim_create_autocmd("BufWritePre", {
    command = "lua vim.lsp.buf.formatting_sync(nil, 1000)",
    group = group
  })
end

return M
