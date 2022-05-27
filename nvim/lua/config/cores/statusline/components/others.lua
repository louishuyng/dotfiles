local colors = require 'ui.main_colors'
local separator_style = require 'ui.statusline_seperator_style'

local M = {}

local mode_colors = {
  ["n"] = {"NORMAL", colors.red},
  ["no"] = {"N-PENDING", colors.red},
  ["i"] = {"INSERT", colors.dark_purple},
  ["ic"] = {"INSERT", colors.dark_purple},
  ["t"] = {"TERMINAL", colors.green},
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
  ["!"] = {"SHELL", colors.green}
}

local chad_mode_hl = function()
  return {fg = mode_colors[vim.fn.mode()][2], bg = colors.one_bg2}
end

M.main_icon = {
  provider = separator_style.main_icon,

  hl = {fg = colors.statusline_bg, bg = colors.nord_blue},

  right_sep = {
    str = separator_style.right,
    hl = {fg = colors.nord_blue, bg = colors.lightbg}
  }
}

M.empty_space = {
  provider = " " .. separator_style.left,
  hl = {fg = colors.statusline_bg, bg = colors.statusline_bg}
}

-- this matches the vi mode color
M.empty_spaceColored = {
  provider = separator_style.left,
  hl = function()
    return {fg = mode_colors[vim.fn.mode()][2], bg = colors.statusline_bg}
  end
}

M.mode_icon = {
  provider = separator_style.vi_mode_icon,
  hl = function()
    return {fg = colors.statusline_bg, bg = mode_colors[vim.fn.mode()][2]}
  end
}

M.empty_space2 = {
  provider = function() return " " .. mode_colors[vim.fn.mode()][1] .. " " end,
  hl = chad_mode_hl
}

M.separator_right = {
  provider = separator_style.left,
  hl = {fg = colors.one_bg2, bg = colors.one_bg2}
}

M.separator_right2 = {
  provider = separator_style.left,
  hl = {fg = colors.green, bg = colors.one_bg2}
}

M.position_icon = {
  provider = separator_style.position_icon,
  hl = {fg = colors.black, bg = colors.green}
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

  hl = {fg = colors.green, bg = colors.one_bg2}
}

return M
