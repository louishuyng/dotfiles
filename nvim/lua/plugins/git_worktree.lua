M = {}

function M.pull_newest()
  local command = vim.cmd(":silent Git pull")
  vim.cmd(command)

  require("notify")("Pull newest code successfully")
end

return M
