require("nebulous").setup {
  variant = "twilight",
  custom_colors = { -- this table can hold any group of colors with their respective values
    Normal = { fg = "ABB2BF", bg = "#000000", style = "NONE" },
    TelescopePreviewBorder = { fg = "#48e566" },
    LspDiagnosticsDefaultError = { bg = "#E11313" },
    TSTagDelimiter = { style = "bold,italic" },
  }
}
