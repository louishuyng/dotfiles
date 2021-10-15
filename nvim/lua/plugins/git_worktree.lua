M = {}

function M.pull()
  local command = vim.cmd(":Git pull")
  vim.cmd(command)

  require("notify")("You just command to pull code", "trace")
end

function M.push()
  local command = vim.cmd(":Git push")
  vim.cmd(command)

  require("notify")("You just command to push code", "trace")
end

return M
