M = {}

function M.pull_newest()
  local branch = vim.cmd(":silent !git rev-parse --abbrev-ref HEAD")
  local command = string.format(":silent Git pull origin %s", branch)
  vim.cmd(command)

  require("notify")("Pull newest code successfully")
end

return M
