return {
  {
    'catppuccin/nvim',
    priority = 1000,
    lazy = false,
    config = function()
      vim.cmd.colorscheme 'catppuccin-frappe'

      local green_bg = '#364234'
      local dark_green_bg = '#1f2d1e'
      local gray_bg = '#282828'
      local dark_gray_bg = '#212121'
      local red = '#D5553A'
      local yellow = '#e7c664'
      local green = '#89d287'

      -- highlight telescope
      vim.api.nvim_set_hl(0, 'TelescopeBorder', { bg = green_bg })
      vim.api.nvim_set_hl(0, 'TelescopeNormal', { bg = green_bg })
      vim.api.nvim_set_hl(0, 'TelescopePromptNormal', { bg = green_bg })
      vim.api.nvim_set_hl(0, 'TelescopePromptBorder', { bg = green_bg })
      vim.api.nvim_set_hl(0, 'TelescopePromptTitle', { bg = green_bg })
      vim.api.nvim_set_hl(0, 'TelescopeTitle', { bg = green_bg })
      vim.api.nvim_set_hl(0, 'TelescopeSelection', { bg = dark_green_bg })

      -- highlight NeoTree
      vim.api.nvim_set_hl(0, 'NeoTreeNormal', { bg = gray_bg })
      vim.api.nvim_set_hl(0, 'NeoTreeNormalNC', { bg = gray_bg })
      vim.api.nvim_set_hl(0, 'NeoTreeCursorLine', { bg = dark_gray_bg })
      vim.api.nvim_set_hl(0, 'NeoTreeRootName', { fg = green, bg = 'NONE', italic = false })
      vim.api.nvim_set_hl(0, 'NeoTreeWinSeparator', { fg = 'NONE', bg = 'NONE' })

      -- highlight Alpha
      vim.api.nvim_set_hl(0, 'AlphaHeader', { fg = yellow, bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'AlphaFooter', { fg = green, bg = 'NONE' })

      -- highlight statusline
      vim.api.nvim_set_hl(0, 'StatusLine', { bg = dark_gray_bg })

      -- highlight general
      vim.api.nvim_set_hl(0, 'WinSeparator', { fg = red, bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'CursorLine', { bg = dark_green_bg })
      vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'NeoTreeEndOfBuffer', { bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'WinBar', { bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'WinBarNC', { bg = 'NONE' })

      vim.api.nvim_set_hl(0, 'LineNr', { bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'NONE' })
    end,
  },
}
