local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
  return
end

local lualine_require = require("lualine_require")
lualine_require.require = require

local icons = require("lazyvim.config").icons
local Util = require("lazyvim.util")

vim.o.laststatus = vim.g.lualine_laststatus

local colors = {
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

if vim.g.theme == "frappe" then
  colors = {
    bg0 = "#232232",
    bg1 = "#2F2E3E",
    bg2 = "#474655",
    fg0 = "#E7EBF1",
    fg1 = "#D1D3CC",
    fg2 = "#BCC0CB",
    red0 = "#9D4B53",
    red1 = "#BA5860",
    yellow0 = "#A78A58",
    yellow1 = "#CCAA6C",
    green0 = "#ABE9B4",
    green1 = "#ABE9B4",
    blue1 = "#5292C6",
    purple0 = "#CBA6F7",
    purple1 = "#CBA6F7",
  }
end

if vim.g.theme == "latte" then
  colors = {
    bg0 = "#F6EDE3",
    bg1 = "#E5DFD4",
    bg2 = "#D0C6BC",
    fg0 = "#1E1B1F",
    fg1 = "#2E2C2F",
    fg2 = "#3E3D3F",
    red0 = "#9D4B53",
    red1 = "#BA5860",
    yellow0 = "#A78A58",
    yellow1 = "#CCAA6C",
    green0 = "#3EA57B",
    green1 = "#3EA57B",
    blue1 = "#5292C6",
    purple0 = "#AC78BD",
    purple1 = "#AC78BD",
  }
end

if vim.g.theme == 'solarized' then
  colors = {
    bg0 = "#002B36",
    bg1 = "#073642",
    bg2 = "#586E75",
    fg0 = "#839496",
    fg1 = "#93A1A1",
    fg2 = "#EEE8D5",
    red0 = "#DC322F",
    red1 = "#CB4B16",
    yellow0 = "#B58900",
    yellow1 = "#657B83",
    green0 = "#859900",
    green1 = "#2AA198",
    blue1 = "#268BD2",
    purple0 = "#6C71C4",
    purple1 = "#D33682",
  }
end

local theme = {
  normal = {
    a = { bg = colors.bg0, fg = colors.purple0 },
    b = { bg = colors.bg0, fg = colors.yellow0 },
    c = { bg = colors.bg0, fg = colors.fg2 },
  },
  insert = {
    a = { bg = colors.green0, fg = colors.bg0 },
    b = { bg = colors.bg0, fg = colors.green1 },
  },
  command = {
    a = { bg = colors.yellow0, fg = colors.bg0 },
    b = { bg = colors.bg0, fg = colors.yellow1 },
  },
  visual = {
    a = { bg = colors.blue1, fg = colors.bg0 },
    b = { bg = colors.bg0, fg = colors.blue1 },
  },
  replace = {
    a = { bg = colors.red0, fg = colors.bg0 },
    b = { bg = colors.bg0, fg = colors.red1 },
  },
  inactive = {
    a = { bg = colors.bg0, fg = colors.blue1 },
    b = { bg = colors.bg0, fg = colors.bg0 },
    c = { bg = colors.bg0, fg = colors.bg1 },
  }
}

lualine.setup {
  options = {
    theme = vim.g.theme == 'frappe' and 'auto' or theme,
    globalstatus = true,
    disabled_filetypes = { statusline = { "dashboard", "alpha", "intro" } },
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "" },

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
      { "filetype",                icon_only = true, separator = "", padding = { left = 1, right = 0 } },
      { Util.lualine.pretty_path() },
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
