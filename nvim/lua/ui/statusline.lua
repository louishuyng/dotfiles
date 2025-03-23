local Shade = require("nightfox.lib.shade")

local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
  return
end

local lualine_require = require("lualine_require")
lualine_require.require = require

local icons = require("lazyvim.config").icons
local Util = require("lazyvim.util")

vim.o.laststatus = vim.g.lualine_laststatus

local colors = {}

if vim.g.theme == "paper" then
  colors = {
    bg0 = "#262626",
    bg1 = "#303232",
    bg2 = "#4A4A4A",
    fg0 = "#D1D3CC",
    fg1 = "#E1E4DC",
    fg2 = "#F1F5EC",
    red0 = "#9D4B53",
    red1 = "#BA5860",
    yellow0 = "#E2C697",
    yellow1 = "#E2C697",
    green0 = "#ABE9B4",
    green1 = "#ABE9B4",
    blue1 = "#89B4FA",
    purple0 = "#CBA6F7",
    purple1 = "#CBA6F7",
  }
end

if vim.g.theme == "night" then
  colors = {
    bg0     = "#191726",
    bg1     = "#232136",
    bg2     = "#2d2a45",
    fg0     = "#eae8ff",
    fg1     = "#e0def4",
    fg2     = "#cdcbe0",
    red0    = "#eb6f92",
    red1    = "#f083a2",
    yellow0 = "#f6c177",
    yellow1 = "#f9cb8c",
    green0  = "#a3be8c",
    green1  = "#b1d196",
    blue1   = "#569fba",
    purple0 = "#ccb1ed",
    purple1 = "#c4a7e7",
  }
end

if vim.g.theme == "light" then
  colors = {
    bg0     = "#e4dcd4",
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
    lualine_a = { "mode" },
    lualine_b = { marlin_component },

    lualine_c = {
      Util.lualine.root_dir(),
      {
        "diagnostics",
        symbols = {
          error = "E",
          warn = "W",
          info = "I",
          hint = "H"
        },
      },
      {
        require("package-info").get_status,
      },
      {
        function()
          return require("nvim-navic").get_location()
        end,
        cond = function()
          return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
        end,
      },
    },
    lualine_x = {
      -- stylua: ignore
      {
        function() return require("noice").api.status.command.get() end,
        cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
        color = { fg = Snacks.util.color("Statement") }
      },
      -- stylua: ignore
      {
        function() return require("noice").api.status.mode.get() end,
        cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
        color = { fg = Snacks.util.color("Constant") }
      },
      -- stylua: ignore
      {
        function() return "  " .. require("dap").status() end,
        cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
        color = { fg = Snacks.util.color("Debug") }
      },
      {
        require("lazy.status").updates,
        cond = require("lazy.status").has_updates,
        color = { fg = Snacks.util.color("Special") }
      },
      {
        "diff",
        symbols = {
          added = icons.git.added,
          modified = icons.git.modified,
          removed = icons.git.removed,
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
    },
  },
}
