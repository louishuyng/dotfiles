local cmd = vim.cmd

-- Define bg color
-- @param group Group
-- @param color Color
local M = {}

M.bg = function(group, col) cmd("hi " .. group .. " guibg=" .. col) end

-- Define fg color
-- @param group Group
-- @param color Color
M.fg = function(group, col) cmd("hi " .. group .. " guifg=" .. col) end

-- Define bg and fg color
-- @param group Group
-- @param fgcol Fg Color
-- @param bgcol Bg Color
M.fg_bg = function(group, fgcol, bgcol, gui)
  if gui ~= nil then
    cmd("hi " .. group .. " guifg=" .. fgcol .. " guibg=" .. bgcol .. " gui=" ..
            gui)
    return
  end

  cmd("hi " .. group .. " guifg=" .. fgcol .. " guibg=" .. bgcol)
end

return M
