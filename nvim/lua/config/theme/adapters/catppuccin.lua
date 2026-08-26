-- Adapter: catppuccin/nvim → semantic palette.
--
-- Preserves the "Cyberpunk Terminal" palette overrides:
--   - mocha (dark)  : gruvbox-material colors with phosphor-green lead
--   - latte (light) : solarized-leaning colors
--
-- mocha and latte are the two flavors actually used; macchiato/frappe are
-- intentionally not selected here so the color_overrides below always apply.

local M = {}

local opts = {
  transparent_background = false,
  background = {
    light = 'latte',
    dark = 'macchiato',
  },
  color_overrides = {
    mocha = {
      base = '#11111B',
    },
    macchiato = {
      -- base = '#000000',
    },
    latte = {
      rosewater = '#fdf7e8',
      flamingo = '#cb4b16',
      pink = '#d33682',
      mauve = '#6c71c4',
      red = '#dc322f',
      maroon = '#c03260',
      peach = '#cb4b1f',
      yellow = '#b58900',
      green = '#859900',
      teal = '#2aa198',
      sky = '#2398d2',
      sapphire = '#0077b3',
      blue = '#268bd2',
      lavender = '#7b88d3',
      text = '#657b83',
      subtext1 = '#586e75',
      subtext0 = '#073642',
      overlay2 = '#002b36',
      overlay1 = '#839496',
      overlay0 = '#93a1a1',
      base = '#fdf6e3',
      mantle = '#f7f1dc',
      crust = '#f5ecd7',
    },
  },
  highlight_overrides = {
    all = function(colors)
      return {
        TelescopeSelection = { fg = 'None', bg = colors.surface0 },
        WinSeparator = { bg = 'None', fg = colors.overlay0 },
        -- Normal = { bg = 'None' },
        -- NormalNC = { bg = 'None' },
        -- NvimTreeWinSeparator = { bg = colors.mantle, fg = colors.mantle },
      }
    end,
  },
}

function M.setup()
  require('catppuccin').setup(opts)
end

function M.apply(variant)
  vim.o.background = variant == 'light' and 'light' or 'dark'
  vim.cmd.colorscheme('catppuccin')
end

function M.resolve(variant)
  local flavor = variant == 'light' and 'latte' or 'macchiato'
  local ok, palettes = pcall(require, 'catppuccin.palettes')
  if not ok then
    return nil
  end
  local c = palettes.get_palette(flavor)
  if not c then
    return nil
  end
  return {
    bg = c.base,
    bg_alt = c.crust,
    bg_dim = c.mantle,
    surface = c.surface0,
    surface_alt = c.surface1,
    overlay = c.overlay0,

    text = c.text,
    subtle = c.subtext0,
    muted = c.overlay1,

    primary = c.green,
    secondary = c.teal,
    tertiary = c.mauve,

    info = c.blue,
    warn = c.peach,
    error = c.red,
    success = c.green,
    attention = c.yellow,

    info_muted = c.sapphire,
    warn_muted = c.peach,
    error_muted = c.maroon,
    success_muted = c.teal,

    -- Catppuccin lacks dim accent backgrounds; surface_alt is the closest
    -- reasonable fallback for badge/diff backgrounds.
    bg_info = c.surface1,
    bg_warn = c.surface1,
    bg_error = c.surface1,
    bg_success = c.surface1,
  }
end

return M
