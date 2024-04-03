return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      background = {
        dark = "mocha",
      },
      transparent_background = false,
      color_overrides = {
        mocha = {
          -- custom everforest dark hard port
          rosewater = "#fed1cb",
          flamingo  = "#ff9185",
          pink      = "#d699b6",
          mauve     = "#cb7ec8",
          red       = "#e06062",
          maroon    = "#e67e80",
          peach     = "#e69875",
          yellow    = "#d3ad63",
          green     = "#b0cc76",
          teal      = "#6db57f",
          sky       = "#8fbbb3",
          sapphire  = "#60aaa0",
          blue      = "#59a6c3",
          lavender  = "#e0d3d4",
          text      = "#e8e1bf",
          subtext1  = "#e0d7c3",
          subtext0  = "#d3c6aa",
          overlay2  = "#9da9a0",
          overlay1  = "#859289",
          overlay0  = "#6d6649",
          surface2  = "#585c4a",
          surface1  = "#414b50",
          surface0  = "#374145",
          base      = "#000000",
          mantle    = "#161b1d",
          crust     = "#14181a",
        },
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
      },
    })

    vim.api.nvim_command("colorscheme catppuccin")
  end,
}
