local uv = vim.loop
local async

local M = {}

M.toggle_delay = function(delay, first_command, second_command)
  async = uv.new_async(function()
    vim.api.nvim_command(second_command)
    async:close()
  end)

  vim.api.nvim_command(first_command)
  async:send()
end

return M
