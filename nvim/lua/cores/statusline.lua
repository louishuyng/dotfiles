vim.cmd [[packadd nvim-web-devicons]]
local gl = require 'galaxyline'
local condition = require 'galaxyline.condition'
local diagnostic = require 'galaxyline.provider_diagnostic'

local utils = {}

function utils.is_buffer_empty()
  return vim.fn.empty(vim.fn.expand '%:t') == 1
end

function utils.has_width_gt(cols)
  return vim.fn.winwidth(0) / 2 > cols
end

local gls = gl.section
gl.short_line_list = { 'packer', 'NvimTree', 'Outline', 'LspTrouble' }

local colors = {
  bg = '#0000',
  fg = '#abb2bf',
  section_bg = '#0000',
  blue = '#61afef',
  green = '#98c379',
  purple = '#c678dd',
  orange = '#e5c07b',
  red = '#e06c75',
  yellow = '#e5c07b',
  darkgrey = '#2c323d',
  middlegrey = '#8791A5',
}

-- Local helper functions
local buffer_not_empty = function()
  return not utils.is_buffer_empty()
end

local checkwidth = function()
  return utils.has_width_gt(35) and buffer_not_empty()
end

local is_file = function()
  return vim.bo.buftype ~= 'nofile'
end

local function has_value(tab, val)
  for _, value in ipairs(tab) do
    if value[1] == val then
      return true
    end
  end
  return false
end

local mode_color = function()
  local mode_colors = {
    [110] = colors.green,
    [105] = colors.blue,
    [99] = colors.green,
    [116] = colors.blue,
    [118] = colors.purple,
    [22] = colors.purple,
    [86] = colors.purple,
    [82] = colors.red,
    [115] = colors.red,
    [83] = colors.red,
  }

  local color = mode_colors[vim.fn.mode():byte()]
  if color ~= nil then
    return color
  else
    return colors.purple
  end
end

local function file_readonly()
  if vim.bo.filetype == 'help' then
    return ''
  end
  if vim.bo.readonly == true then
    return '  '
  end
  return ''
end

local function get_current_file_name()
  local file = vim.fn.expand '%:t'
  if vim.fn.empty(file) == 1 then
    return ''
  end
  if string.len(file_readonly()) ~= 0 then
    return file .. file_readonly()
  end
  if vim.bo.modifiable then
    if vim.bo.modified then
      return file .. '  '
    end
  end
  return file .. ' '
end

local function split(str, sep)
  local res = {}
  local n = 1
  for w in str:gmatch('([^' .. sep .. ']*)') do
    res[n] = res[n] or w -- only set once (so the blank after a string is ignored)
    if w == '' then
        n = n + 1
    end -- step forwards on a blank but not a string
  end
  return res
end

local function get_basename(file)
  return file:match '^.+/(.+)$'
end

local GetGitRoot = function()
  local git_dir = require('galaxyline.provider_vcs').get_git_dir()
  if not git_dir then
    return ''
  end

  local git_root = git_dir:gsub('/.git/?$', '')
  return get_basename(git_root)
end

-- Left side
gls.left[1] = {
  ViMode = {
    provider = function()
      local mode = {
        n = {color = "String", icon = ""},
        i = {color = "Function", icon = ""},
        v = {color = "Conditional", icon = ""},
        V = {color = "Conditional", icon = ""},
        [""] = {color = "Conditional", icon = ""},
        c = {color = "Keyword", icon = ""},
        ['!'] = {color = "Keyword", icon = ""},
        R = {color = "Keyword", icon = "﯒"},
        r = {color = "Keyword", icon = "﯒"},
      }
      vim.api.nvim_command("hi link GalaxyViMode " .. mode[vim.fn.mode()].color)
      if mode[vim.fn.mode()].icon ~= nil then
        return "    " .. mode[vim.fn.mode()].icon
      end
    end,
    separator = " ",
    condition = condition.hide_in_width
  }
}
gls.left[2] = {
  FileIcon = {
    provider = { function()
        return '  '
    end, 'FileIcon' },
    condition = buffer_not_empty,
    highlight = {
        require('galaxyline.provider_fileinfo').get_file_icon,
        colors.section_bg,
    },
  },
}
gls.left[3] = {
  FileName = {
    provider = get_current_file_name,
    condition = buffer_not_empty,
    highlight = { colors.fg, colors.section_bg },
    separator = ' ',
    separator_highlight = { colors.section_bg, colors.bg },
  },
}
gls.left[4] = {
  ShowLspClient = {
    provider = 'GetLspClient',
    condition = function()
        local tbl = {['dashboard'] = true, [''] = true}
        if tbl[vim.bo.filetype] then return false end
        return true
    end,
    icon = '  ',
    highlight = {colors.middlegrey, colors.bg},
    separator = ' ',
    separator_highlight = {colors.section_bg, colors.bg}
  }
}
gls.left[5] = {
  DiagnosticError = {
    provider = { 'DiagnosticError' },
    icon = '  ',
    highlight = { colors.red, colors.bg },
    -- separator = ' ',
    -- separator_highlight = {colors.bg, colors.bg}
  },
}
gls.left[6] = {
  DiagnosticWarn = {
    provider = { 'DiagnosticWarn' },
    icon = '  ',
    highlight = { colors.orange, colors.bg },
    -- separator = ' ',
    -- separator_highlight = {colors.bg, colors.bg}
  },
}
gls.left[7] = {
  DiagnosticInfo = {
    provider = { 'DiagnosticInfo' },
    icon = '  ',
    highlight = { colors.blue, colors.bg },
    -- separator = ' ',
    -- separator_highlight = {colors.section_bg, colors.bg}
  },
}

-- Right side
gls.right[0] = {
  DiffAdd = {
    provider = 'DiffAdd',
    condition = checkwidth,
    icon = '+',
    highlight = { colors.green, colors.bg },
    separator = ' ',
    separator_highlight = { colors.section_bg, colors.bg },
  },
}
gls.right[1] = {
  DiffModified = {
    provider = 'DiffModified',
    condition = checkwidth,
    icon = '~',
    highlight = { colors.orange, colors.bg },
  },
}
gls.right[2] = {
  DiffRemove = {
    provider = 'DiffRemove',
    condition = checkwidth,
    icon = '-',
    highlight = { colors.red, colors.bg },
  },
}
gls.right[3] = {
  Space = {
    provider = function()
        return ' '
    end,
    highlight = { colors.section_bg, colors.bg },
  },
}
gls.right[4] = {
  Harpoon = {
    provider = function()
        return require('harpoon.mark').status()
    end,
    highlight = { colors.middlegrey, colors.bg },
  },
}
gls.right[5] = {
  GitBranch = {
    provider = {
        function()
            return '  '
        end,
        'GitBranch',
    },
    condition = condition.check_git_workspace,
    highlight = { colors.middlegrey, colors.bg },
  },
}
gls.right[6] = {
  GitRoot = {
    provider = { GetGitRoot },
    condition = function()
        return utils.has_width_gt(50) and condition.check_git_workspace
    end,
    icon = '  ',
    highlight = { colors.fg, colors.bg },
    separator_highlight = { colors.middlegrey, colors.bg },
    separator = '  ',
  },
}
gls.right[7] = {
  PerCent = {
    provider = 'LinePercent',
    separator = ' ',
    separator_highlight = { colors.blue, colors.bg },
    highlight = { colors.darkgrey, colors.blue },
  },
}

-- Short status line
gls.short_line_left[1] = {
  FileIcon = {
    provider = { function()
        return '  '
    end, 'FileIcon' },
    condition = function()
        return buffer_not_empty and has_value(
            gl.short_line_list,
            vim.bo.filetype
        )
    end,
    highlight = {
        require('galaxyline.provider_fileinfo').get_file_icon,
        colors.section_bg,
    },
  },
}
gls.short_line_left[2] = {
  FileName = {
    provider = get_current_file_name,
    condition = buffer_not_empty,
    highlight = { colors.fg, colors.section_bg },
    separator = '',
    separator_highlight = { colors.section_bg, colors.bg },
  },
}

gls.short_line_right[1] = {
  BufferIcon = {
    provider = 'BufferIcon',
    highlight = { colors.yellow, colors.section_bg },
    separator = '',
    separator_highlight = { colors.section_bg, colors.bg },
  },
}

-- Force manual load so that nvim boots with a status line
gl.load_galaxyline()
