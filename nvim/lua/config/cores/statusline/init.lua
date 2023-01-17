local vi_mode_utils = require('feline.providers.vi_mode')
local lsp = require('feline.providers.lsp')
local lazy = require("lazy.status")
local winbar_components = require('config.cores.statusline.winbar')
local themes = require('config.cores.statusline.themes')

local force_inactive = {
  filetypes = {
    '^NvimTree$', '^packer$', '^startify$', '^fugitive$', '^fugitiveblame$',
    '^qf$', '^help$', '^dbui$', '^lazy$', '^toggleterm$'
  },
  buftypes = {'^terminal$'},
  bufnames = {}
}

local disabled = {
  filetypes = {'^toggleterm$'},
  buftypes = {'^terminal$'},
  bufnames = {}
}

local components = {active = {{}, {}, {}}, inactive = {{}, {}, {}}}

local vi_mode_colors = {
  NORMAL = 'green',
  OP = 'green',
  INSERT = 'red',
  CONFIRM = 'red',
  VISUAL = 'skyblue',
  LINES = 'skyblue',
  BLOCK = 'skyblue',
  REPLACE = 'violet',
  ['V-REPLACE'] = 'violet',
  ENTER = 'cyan',
  MORE = 'cyan',
  SELECT = 'orange',
  COMMAND = 'green',
  SHELL = 'green',
  TERM = 'green',
  NONE = 'yellow'
}

local vi_mode_text = {
  NORMAL = '<|',
  OP = '<|',
  INSERT = '|>',
  VISUAL = '<>',
  LINES = '<>',
  BLOCK = '<>',
  REPLACE = '<>',
  ['V-REPLACE'] = '<>',
  ENTER = '<>',
  MORE = '<>',
  SELECT = '<>',
  COMMAND = '<|',
  SHELL = '<|',
  TERM = '<|',
  NONE = '<>',
  CONFIRM = '|>'
}

local default_seperator = {
  {str = ' ', hl = {bg = 'statusline'}, always_visible = true}
}

local function hl_icon_current_file()
  local val = {}
  local filename = vim.fn.expand('%:t')
  local extension = vim.fn.expand('%:e')
  local icon, name = require'nvim-material-icon'.get_icon(filename, extension)
  if icon ~= nil then
    val.fg = vim.fn.synIDattr(vim.fn.hlID(name), 'fg')
  else
    val.fg = 'white'
  end
  val.bg = 'statusline'
  val.style = 'bold'
  return val
end

-- STATUSLINE
-- LEFT

-- vi-mode
components.active[1][1] = {
  provider = 'LOUIS-DEV ',
  hl = function()
    local val = {}

    val.bg = vi_mode_utils.get_mode_color()
    val.fg = 'black'
    val.style = 'bold'

    return val
  end,
  right_sep = default_seperator
}
-- vi-symbol
components.active[1][2] = {
  provider = function() return vi_mode_text[vi_mode_utils.get_vim_mode()] end,
  hl = function()
    local val = {}
    val.fg = vi_mode_utils.get_mode_color()
    val.bg = 'statusline'
    val.style = 'bold'
    return val
  end,
  right_sep = default_seperator
}

-- File Name
components.active[1][3] = {
  provider = function() return vim.fn.expand('%:p:t') end,
  hl = {fg = 'fg', bg = 'statusline', style = 'bold'},
  right_sep = default_seperator
}

-- File Status
components.active[1][4] = {
  provider = function()
    if vim.bo.modified then
      return '●'
    else
      return ''
    end
  end,
  hl = {fg = 'red', bg = 'statusline', style = 'bold'},
  right_sep = default_seperator
}

-- gitBranch
components.active[1][5] = {
  provider = 'git_branch',
  hl = {fg = 'yellow', bg = 'statusline', style = 'bold'}
}
-- diffAdd
components.active[1][6] = {
  provider = 'git_diff_added',
  hl = {fg = 'green', bg = 'statusline', style = 'bold'}
}
-- diffModfified
components.active[1][7] = {
  provider = 'git_diff_changed',
  hl = {fg = 'orange', bg = 'statusline', style = 'bold'}
}
-- diffRemove
components.active[1][8] = {
  provider = 'git_diff_removed',
  hl = {fg = 'red', bg = 'statusline', style = 'bold'}
}

-- diagnosticErrors
components.active[1][9] = {
  provider = 'diagnostic_errors',
  enabled = function()
    return lsp.diagnostics_exist(vim.diagnostic.severity.ERROR)
  end,
  hl = {fg = 'red', style = 'bold', bg = 'statusline'}
}
-- diagnosticWarn
components.active[1][10] = {
  provider = 'diagnostic_warnings',
  enabled = function()
    return lsp.diagnostics_exist(vim.diagnostic.severity.WARN)
  end,
  hl = {fg = 'yellow', style = 'bold', bg = 'statusline'}
}
-- diagnosticHint
components.active[1][11] = {
  provider = 'diagnostic_hints',
  enabled = function()
    return lsp.diagnostics_exist(vim.diagnostic.severity.HINT)
  end,
  hl = {fg = 'cyan', style = 'bold', bg = 'statusline'}
}
-- diagnosticInfo
components.active[1][12] = {
  provider = 'diagnostic_info',
  enabled = function()
    return lsp.diagnostics_exist(vim.diagnostic.severity.INFO)
  end,
  hl = {fg = 'skyblue', style = 'bold', bg = 'statusline'}
}

-- RIGHT

-- LspName
components.active[3][1] = {
  provider = 'lsp_client_names',
  hl = {fg = 'yellow', style = 'bold', bg = 'statusline'}
}

-- fileIcon
components.active[3][2] = {
  provider = function()
    local filename = vim.fn.expand('%:t')
    local extension = vim.fn.expand('%:e')
    local icon = require'nvim-web-devicons'.get_icon(filename, extension)
    if icon == nil then icon = '' end
    return icon
  end,
  hl = hl_icon_current_file,
  right_sep = default_seperator,
  left_sep = default_seperator
}
-- fileType
components.active[3][3] = {
  provider = 'file_type',
  hl = function()
    local val = {}
    local filename = vim.fn.expand('%:t')
    local extension = vim.fn.expand('%:e')
    local icon, name = require'nvim-web-devicons'.get_icon(filename, extension)
    if icon ~= nil then
      val.fg = vim.fn.synIDattr(vim.fn.hlID(name), 'fg')
    else
      val.fg = 'white'
    end
    val.bg = 'statusline'
    val.style = 'bold'
    return val
  end,
  right_sep = default_seperator
}
-- fileSize
components.active[3][4] = {
  provider = 'file_size',
  enabled = function() return vim.fn.getfsize(vim.fn.expand('%:t')) > 0 end,
  hl = {fg = 'skyblue', bg = 'statusline', style = 'bold'},
  right_sep = default_seperator
}
-- fileFormat
components.active[3][5] = {
  provider = function() return '' .. vim.bo.fileformat:upper() .. '' end,
  hl = {fg = 'white', bg = 'statusline', style = 'bold'},
  right_sep = default_seperator
}
-- fileEncode
components.active[3][6] = {
  provider = 'file_encoding',
  hl = {fg = 'white', bg = 'statusline', style = 'bold'},
  right_sep = default_seperator
}
components.active[3][7] = {
  provider = 'position',
  hl = {fg = 'white', bg = 'statusline', style = 'bold'},
  right_sep = default_seperator
}
-- linePercent
components.active[3][8] = {
  provider = 'line_percentage',
  hl = {fg = 'white', bg = 'statusline', style = 'bold'},
  right_sep = default_seperator
}
-- Lazy.nvim
components.active[3][9] = {
  provider = function() return " ﮮ " end,
  enabled = lazy.has_updates,
  hl = {fg = 'black', bg = 'orange', style = 'bold'}
}
-- scrollBar
components.active[3][10] = {
  provider = 'scroll_bar',
  hl = {fg = 'yellow', bg = 'statusline'}
}

require('feline').setup({
  theme = themes.onedarkpro,
  vi_mode_colors = vi_mode_colors,
  components = components,
  force_inactive = force_inactive,
  disabled = disabled
})

require('feline').reset_highlights()

require('feline').winbar.setup({
  components = winbar_components,
  disabled = disabled
})
