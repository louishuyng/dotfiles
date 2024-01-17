M = {}

function M.pull()
  local command = vim.cmd(":Git pull --rebase")
  vim.cmd(command)
end

function M.push()
  local command = vim.cmd(":Git push -u origin")
  vim.cmd(command)
end

function M.push_force()
  local command = vim.cmd(":Git push -u origin --force-with-lease")
  vim.cmd(command)
end

return M
