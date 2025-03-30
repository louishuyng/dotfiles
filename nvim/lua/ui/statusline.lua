local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
  return
end

local lualine_require = require("lualine_require")
lualine_require.require = require

local icons = require("config.libs.icons")

local Util = require("lazyvim.util")

vim.o.laststatus = vim.g.lualine_laststatus

local colors = {}

if vim.g.theme == "paper" then
  colors = {
    bg0 = "#1E1B1F",
    bg1 = "#2E2C2F",
    bg2 = "#3E3D3F",
    fg0 = "#D1D3CC",
    fg1 = "#E1E4DC",
    fg2 = "#F1F5EC",
    red0 = "#C45C64",
    red1 = "#BA5860",
    yellow0 = "#D8B573",
    yellow1 = "#CCAA6C",
    green0 = "#7AA682",
    green1 = "#729B79",
    blue1 = "#5292C6",
    purple0 = "#9571B3",
    purple1 = "#8C6AA8",
  }
end

if vim.g.theme == "night" then
  colors = {
    bg0     = "#1E2031",
    bg1     = "#232136",
    bg2     = "#2d2a45",
    fg0     = "#eae8ff",
    fg1     = "#e0def4",
    fg2     = "#cdcbe0",
    red0    = "#ed8796",
    red1    = "#ed8796",
    yellow0 = "#eed49f",
    yellow1 = "#eed49f",
    green0  = "#a6da95",
    green1  = "#a6da95",
    blue1   = "#8aadf4",
    purple0 = "#b7bdf8",
    purple1 = "#b7bdf8",
  }
end

if vim.g.theme == "light" then
  colors = {
    bg0     = "#F7F1DC",
    bg1     = "#f6f2ee",
    bg2     = "#dbd1dd",
    fg0     = "#302b5d",
    fg1     = "#3d2b5a",
    fg2     = "#643f61",
    red0    = "#a5222f",
    red1    = "#a5222f",
    green0  = "#396847",
    green1  = "#396847",
    yellow0 = "#AC5402",
    yellow1 = "#AC5402",
    blue1   = "#2848a9",
    purple0 = "#6e33ce",
    purple1 = "#6e33ce",
  }
end


local theme = {
  normal = {
    a = { bg = colors.bg0, fg = colors.purple0 },
    b = { bg = colors.bg0, fg = colors.yellow0 },
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
    a = { bg = colors.bg0, fg = colors.blue1 },
    b = { bg = colors.bg0, fg = colors.blue1 },
  },
  replace = {
    a = { bg = colors.bg0, fg = colors.red0 },
    b = { bg = colors.bg0, fg = colors.red1 },
  },
  inactive = {
    a = { bg = colors.bg0, fg = colors.blue1 },
    b = { bg = colors.bg0, fg = colors.bg0 },
    c = { bg = colors.bg0, fg = colors.bg1 },
  }
}

local marlin = require("marlin")

local marlin_component = function()
  local indexes = marlin.num_indexes()
  if indexes == 0 then
    return ""
  end
  local cur_index = marlin.cur_index()

  return " " .. cur_index .. "/" .. indexes
end

lualine.setup {
  options = {
    theme = theme,
    globalstatus = true,
    disabled_filetypes = { statusline = { "dashboard", "alpha", "intro" } },
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = {
      {
        "mode",
        fmt = function(mode)
          -- Vertical bar symbol
          return "▐"
        end,
        padding = { left = 0, right = 0 },
      },
      {
        "filesize",
        color = { fg = colors.fg2 }
      },
      {
        'filename',
        file_status = true,   -- Displays file status (readonly status, modified status)
        newfile_status = false,
        path = 4,             -- 0: Just the filename

        shorting_target = 40, -- Shortens path to leave 40 spaces in the window
        symbols = {
          modified = '[+]',
          readonly = '[-]',
          unnamed = '[No Name]',
          newfile = '[New]',
        },
        color = { fg = colors.yellow1 }
      },
      {
        "location",
        color = { fg = colors.fg2 },
      }
    },
    lualine_b = {
      {
        "marlin",
        fmt = marlin_component,
        color = { fg = colors.purple0 },
      }
    },

    lualine_c = {
      Util.lualine.root_dir(),
      {
        "diff",
        symbols = {
          added = "+",
          modified = "~",
          removed = "-",
        },
        source = function()
          local gitsigns = vim.b.gitsigns_status_dict
          if gitsigns then
            return {
              added = gitsigns.added,
              modified = gitsigns.changed,
              removed = gitsigns.removed,
            }
          end
        end,
      },
      {
        "diagnostics",
        symbols = {
          error = icons.diagnostics.error,
          warn = icons.diagnostics.warn,
          info = icons.diagnostics.info,
          hint = icons.diagnostics.hint,
        },
      },
    },
    lualine_x = {
      -- stylua: ignore
      {
        function() return require("noice").api.status.mode.get() end,
        cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
        color = { fg = Snacks.util.color("Constant") }
      },
      {
        "encoding",
      },
      {
        "branch",
        icon = "",
        color = { fg = colors.green0 }
      },
      {
        function() return "  " .. require("dap").status() end,
        cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
        color = { fg = Snacks.util.color("Debug") }
      },
    },
    lualine_y = {},
    lualine_z = {}
  },
}
