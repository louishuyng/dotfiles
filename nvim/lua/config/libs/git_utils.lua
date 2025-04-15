M = {}

function M.pull()
  local command = vim.cmd(':Neogit pull')
  vim.cmd(command)
end

function M.push()
  local command = vim.cmd(':Neogit push')
  vim.cmd(command)
end

return M
