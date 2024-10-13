return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
   lazy = false,
   priority = 1000,
   config = function()
     require("catppuccin").setup({
       background = {
         dark = "mocha",
         light = "latte",
        },
        highlight_overrides = {
          all = function(colors)
            return {
              NormalFloat = { bg = colors.base },
              Pmenu = { bg = colors.mantle, fg = "" },
              PmenuSel = { bg = colors.surface0, fg = "" },
              CursorLineNr = { fg = colors.text },
              LineNr = { fg = colors.surface1 },
              FloatBorder = { bg = colors.base, fg = colors.surface0 },
              VertSplit = { bg = colors.base, fg = colors.surface0 },
              WinSeparator = { bg = colors.base, fg = colors.surface0 },
              LspInfoBorder = { link = "FloatBorder" },
              YankHighlight = { bg = colors.surface2 },

              CmpItemMenu = { fg = colors.surface2 },

              GitSignsChange = { fg = colors.peach },

              NeoTreeDirectoryIcon = { fg = colors.subtext1 },
              NeoTreeDirectoryName = { fg = colors.subtext1 },
              NeoTreeFloatBorder = { link = "TelescopeResultsBorder" },
              NeoTreeGitConflict = { fg = colors.red },
              NeoTreeGitDeleted = { fg = colors.red },
              NeoTreeGitIgnored = { fg = colors.overlay0 },
              NeoTreeGitModified = { fg = colors.peach },
              NeoTreeGitStaged = { fg = colors.green },
              NeoTreeGitUnstaged = { fg = colors.red },
              NeoTreeGitUntracked = { fg = colors.green },
              NeoTreeIndent = { link = "IblIndent" },
              NeoTreeNormal = { bg = colors.mantle },
              NeoTreeNormalNC = { bg = colors.mantle },
              NeoTreeRootName = { fg = colors.subtext1, style = { "bold" } },
              NeoTreeTabActive = { fg = colors.text, bg = colors.mantle },
              NeoTreeTabInactive = { fg = colors.surface2, bg = colors.crust },
              NeoTreeTabSeparatorActive = { fg = colors.mantle, bg = colors.mantle },
              NeoTreeTabSeparatorInactive = { fg = colors.crust, bg = colors.crust },
              NeoTreeWinSeparator = { fg = colors.base, bg = colors.base },

              TelescopePreviewBorder = { bg = colors.crust, fg = colors.crust },
              TelescopePreviewNormal = { bg = colors.crust },
              TelescopePreviewTitle = { fg = colors.crust, bg = colors.crust },
              TelescopePromptBorder = { bg = colors.surface0, fg = colors.surface0 },
              TelescopePromptCounter = { fg = colors.mauve, style = { "bold" } },
              TelescopePromptNormal = { bg = colors.surface0 },
              TelescopePromptPrefix = { bg = colors.surface0 },
              TelescopePromptTitle = { fg = colors.surface0, bg = colors.surface0 },
              TelescopeResultsBorder = { bg = colors.mantle, fg = colors.mantle },
              TelescopeResultsNormal = { bg = colors.mantle },
              TelescopeResultsTitle = { fg = colors.mantle, bg = colors.mantle },
              TelescopeSelection = { bg = colors.surface0 },

              WhichKeyFloat = { bg = colors.mantle },

              IblIndent = { fg = colors.surface0 },
              IblScope = { fg = colors.overlay0 },

              MasonNormal = { bg = colors.mantle },
              MasonMutedBlock = { link = "CursorLine" },

              LazyNormal = { bg = colors.mantle },
            }
          end,
          latte = function(colors)
            return {
              LineNr = { fg = colors.surface1 },

              IblIndent = { fg = colors.mantle },
              IblScope = { fg = colors.surface1 },
            }
          end,
        }
      })
    end,
  },
  { "scottmckendry/cyberdream.nvim", },
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {}
  },
}
