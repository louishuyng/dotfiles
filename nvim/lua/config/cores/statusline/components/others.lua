local colors = require 'ui.main_colors'
local separator_style = require 'ui.statusline_seperator_style'

local M = {}

local mode_colors = {
  ["n"] = {"NORMAL", colors.status_line_red},
  ["no"] = {"N-PENDING", colors.status_line_red},
  ["i"] = {"INSERT", colors.status_line_purple},
  ["ic"] = {"INSERT", colors.status_line_purple},
  ["t"] = {"TERMINAL", colors.status_line_green},
  ["v"] = {"VISUAL", colors.cyan},
  ["V"] = {"V-LINE", colors.cyan},
  [""] = {"V-BLOCK", colors.cyan},
  ["R"] = {"REPLACE", colors.orange},
  ["Rv"] = {"V-REPLACE", colors.orange},
  ["s"] = {"SELECT", colors.nord_blue},
  ["S"] = {"S-LINE", colors.nord_blue},
  [""] = {"S-BLOCK", colors.nord_blue},
  ["c"] = {"COMMAND", colors.pink},
  ["cv"] = {"COMMAND", colors.pink},
  ["ce"] = {"COMMAND", colors.pink},
  ["r"] = {"PROMPT", colors.teal},
  ["rm"] = {"MORE", colors.teal},
  ["r?"] = {"CONFIRM", colors.teal},
  ["!"] = {"SHELL", colors.status_line_green}
}

local chad_mode_hl = function()
  return {fg = mode_colors[vim.fn.mode()][2], bg = colors.status_line}
end

M.main_icon = {
  provider = separator_style.main_icon,

  hl = {fg = colors.status_line_fg, bg = colors.status_line},

  right_sep = {
    str = separator_style.right,
    hl = {fg = colors.status_line_fg, bg = colors.status_line}
  }
}

M.empty_space = {
  provider = " " .. separator_style.left,
  hl = {fg = colors.statusline_bg, bg = colors.status_line}
}

-- this matches the vi mode color
M.empty_spaceColored = {
  provider = separator_style.left,
  hl = function()
    return {fg = mode_colors[vim.fn.mode()][2], bg = colors.status_line}
  end
}

M.mode_icon = {
  provider = separator_style.vi_mode_icon,
  hl = function() return {fg = colors.status_line_fg, bg = colors.status_line} end
}

M.empty_space2 = {
  provider = function() return " " .. mode_colors[vim.fn.mode()][1] .. " " end,
  hl = chad_mode_hl
}

M.separator_right = {
  provider = separator_style.left,
  hl = {fg = colors.status_line_fg, bg = colors.status_line}
}

M.separator_right2 = {
  provider = separator_style.left,
  hl = {fg = colors.status_line_fg, bg = colors.status_line}
}

M.position_icon = {
  provider = separator_style.position_icon,
  hl = {fg = colors.status_line_fg, bg = colors.status_line}
}

M.current_line = {
  provider = function()
    local current_line = vim.fn.line "."
    local total_line = vim.fn.line "$"

    if current_line == 1 then
      return " Top "
    elseif current_line == vim.fn.line "$" then
      return " Bot "
    end
    local result, _ = math.modf((current_line / total_line) * 100)
    return " " .. result .. "%% "
  end,

  hl = {fg = colors.status_line_fg, bg = colors.status_line}
}

return M
