local icons = require('config.libs.icons')
local status_ok, lualine = pcall(require, 'lualine')
if not status_ok then
  return
end

local C = require('catppuccin.palettes').get_palette(flavour)

local colors = {
  bg0 = C.mantle,
  bg1 = C.base,
  bg2 = C.surface0,
  fg0 = C.text,
  fg1 = C.subtext0,
  fg2 = C.subtext1,
  red0 = C.red,
  red1 = C.red,
  yellow0 = C.yellow,
  yellow1 = C.yellow,
  green0 = C.green,
  green1 = C.green,
  blue1 = C.blue,
  purple0 = C.mauve,
  purple1 = C.mauve,
}

local theme = {
  normal = {
    a = { bg = colors.bg0, fg = colors.blue1 },
    b = { bg = colors.bg0, fg = colors.blue1 },
    c = { bg = colors.bg0, fg = colors.fg2 },
  },
  insert = {
    a = { bg = colors.bg0, fg = colors.green0 },
    b = { bg = colors.bg0, fg = colors.green1 },
  },
  command = {
    a = { bg = colors.bg0, fg = colors.yellow0 },
    b = { bg = colors.bg0, fg = colors.yellow1 },
  },
  visual = {
    a = { bg = colors.bg0, fg = colors.purple0 },
    b = { bg = colors.bg0, fg = colors.purple1 },
  },
  replace = {
    a = { bg = colors.bg0, fg = colors.red0 },
    b = { bg = colors.bg0, fg = colors.red1 },
  },
  inactive = {
    a = { bg = colors.bg0, fg = colors.blue1 },
    b = { bg = colors.bg0, fg = colors.bg0 },
    c = { bg = colors.bg0, fg = colors.bg1 },
  },
}

local marlin = require('marlin')
local marlin_component = function()
  local indexes = marlin.num_indexes()
  if indexes == 0 then
    return ''
  end
  local cur_index = marlin.cur_index()

  return ' ' .. cur_index .. '/' .. indexes
end

lualine.setup {
  options = {
    theme = theme,
    globalstatus = true,
    disabled_filetypes = { statusline = { 'dashboard', 'alpha', 'intro' } },
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    },
  },
  sections = {
    lualine_a = {
      {
        function()
          local mode = vim.fn.mode()
          return '▌'
        end,
        padding = { left = 0 },
      },
    },
    lualine_b = {
      {
        'active',
        fmt = function()
          return ''
        end,
        color = function()
          local mode = vim.fn.mode()
          local mode_color = {
            n = colors.blue1,
            i = colors.green1,
            v = colors.purple1,
            V = colors.purple1,
            ['\22'] = colors.purple1,
            c = colors.yellow1,
            s = colors.purple1,
            S = colors.purple1,
            ['\19'] = colors.purple1,
            R = colors.red1,
            r = colors.red1,
            ['!'] = colors.yellow1,
            t = colors.green1,
          }
          return { fg = mode_color[mode] or colors.blue1 }
        end,
      },
      require('opencode').statusline,
    },
    lualine_c = {
      {
        'filesize',
        color = function()
          return {
            fg = colors.fg2,
          }
        end,
      },
      -- {
      --   'filename',
      --   file_status = true,
      --   newfile_status = true,
      --   path = 4,
      --   symbols = {
      --     modified = '*',
      --     readonly = 'RO',
      --     unnamed = 'scratch',
      --     newfile = 'new',
      --   },
      --   color = function()
      --     return { fg = colors.fg2 }
      --   end,
      -- },
      { 'location' },
      {
        'diff',
        symbols = {
          added = '+',
          modified = '~',
          removed = '-',
        },
      },
      {
        'diagnostics',
        symbols = {
          error = icons.diagnostics.Error,
          warn = icons.diagnostics.Warn,
          info = icons.diagnostics.Info,
          hint = icons.diagnostics.Hint,
        },
      },
      {
        'marlin',
        fmt = marlin_component,
        color = function()
          return { fg = colors.purple0 }
        end,
      },
    },
    lualine_x = {
      {
        -- Recording Macro
        function()
          local reg = vim.fn.reg_recording()
          return reg ~= '' and '[' .. reg .. ']' or ''
        end,
        color = {
          fg = colors.red0,
          gui = 'bold',
        },
        cond = function()
          return vim.fn.reg_recording() ~= ''
        end,
      },
      -- Show file format (LF, CRLF, CR)
      {
        'fileformat',
        symbols = {
          unix = 'LF', -- Show 'LF' for Unix line endings
          dos = 'CRLF', -- Show 'CRLF' for Windows line endings
          mac = 'CR', -- Show 'CR' for old Mac line endings
        },
      },
      {
        'encoding',
        fmt = function(str)
          return str:upper() -- Display as uppercase (UTF-8 instead of utf-8)
        end,
      },
      {
        'lsp_status',
        icon = '',
        color = function()
          return { fg = colors.yellow0 }
        end,
      },
      {
        'branch',
        icon = '',
        color = function()
          return { fg = colors.green0 }
        end,
      },
    },
    lualine_y = {},
    lualine_z = {},
  },
}
