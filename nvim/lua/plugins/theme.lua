return {
  {
    'sainnhe/gruvbox-material',
    priority = 1000,
    lazy = false,
    config = function()
      vim.cmd.colorscheme 'gruvbox-material'

      local bg = '#364234'
      local selection_bg = '#1f2d1e'
      local red = '#D5553A'
      local yellow = '#e7c664'
      local green = '#89d287'

      -- highlight telescope
      vim.api.nvim_set_hl(0, 'TelescopeBorder', { bg = bg })
      vim.api.nvim_set_hl(0, 'TelescopeNormal', { bg = bg })
      vim.api.nvim_set_hl(0, 'TelescopePromptNormal', { bg = bg })
      vim.api.nvim_set_hl(0, 'TelescopePromptBorder', { bg = bg })
      vim.api.nvim_set_hl(0, 'TelescopePromptTitle', { bg = bg })
      vim.api.nvim_set_hl(0, 'TelescopeTitle', { bg = bg })
      vim.api.nvim_set_hl(0, 'TelescopeSelection', { bg = selection_bg })

      -- highlight NeoTree
      vim.api.nvim_set_hl(0, 'NeoTreeNormal', { bg = bg })
      vim.api.nvim_set_hl(0, 'NeoTreeNormalNC', { bg = bg })
      vim.api.nvim_set_hl(0, 'NeoTreeCursorLine', { bg = selection_bg })

      -- highlight Alpha
      vim.api.nvim_set_hl(0, 'AlphaHeader', { fg = yellow, bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'AlphaFooter', { fg = green, bg = 'NONE' })

      -- highlight general
      vim.api.nvim_set_hl(0, 'WinSeparator', { fg = red, bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'CursorLine', { bg = selection_bg })
      vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'NeoTreeEndOfBuffer', { bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'WinBar', { bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'WinBarNC', { bg = 'NONE' })
    end,
  },
}
