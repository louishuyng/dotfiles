local M = {}

function M.toggle_current_line_blame()
  if vim.g.gitblame_display_virtual_text == 1 then
    vim.g.gitblame_display_virtual_text = 0
    vim.cmd("GitBlameDisable")
  else
    vim.g.gitblame_display_virtual_text = 1
    vim.cmd("GitBlameEnable")
  end
end

return M
