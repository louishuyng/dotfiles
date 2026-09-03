-- Adapter: scottmckendry/cyberdream.nvim -> semantic palette.

local M = {}

local colors = {
  dark = {
    bg = '#0b0f0d',
    bg_alt = '#111713',
    bg_highlight = '#263229',
    fg = '#e6edf3',
    grey = '#7f8f88',
    blue = '#82aaff',
    green = '#7ee787',
    cyan = '#67e8f9',
    red = '#ff6b6b',
    yellow = '#f9d66d',
    magenta = '#d783ff',
    pink = '#ff7ab2',
    orange = '#ffad66',
    purple = '#a78bfa',
  },
  light = {
    bg = '#f7f5e8',
    bg_alt = '#ebe8d7',
    bg_highlight = '#d5dac4',
    fg = '#27332d',
    grey = '#69776f',
    blue = '#245dcc',
    green = '#287a3d',
    cyan = '#007f91',
    red = '#c9363e',
    yellow = '#927000',
    magenta = '#9d35c9',
    pink = '#c83272',
    orange = '#b85c00',
    purple = '#6947c6',
  },
}

function M.setup()
  require('cyberdream').setup({
    variant = 'auto',
    transparent = false,
    colors = colors,
    overrides = function(c)
      return {
        Function = { fg = c.green },
        Keyword = { fg = c.pink },
        String = { fg = c.yellow },
        Type = { fg = c.cyan },
        ['@function'] = { fg = c.green },
        ['@function.call'] = { fg = c.green },
        ['@keyword'] = { fg = c.pink },
        ['@string'] = { fg = c.yellow },
        ['@type'] = { fg = c.cyan },
      }
    end,
  })
end

function M.apply(variant)
  vim.o.background = variant == 'light' and 'light' or 'dark'
  vim.cmd.colorscheme('cyberdream')
end

function M.resolve(variant)
  local p = variant == 'light' and colors.light or colors.dark

  return {
    bg = p.bg,
    bg_alt = p.bg_alt,
    bg_dim = p.bg_alt,
    surface = p.bg_highlight,
    surface_alt = p.bg_alt,
    overlay = p.bg_highlight,

    text = p.fg,
    subtle = p.grey,
    muted = p.grey,

    primary = p.green,
    secondary = p.cyan,
    tertiary = p.magenta,

    info = p.blue,
    warn = p.orange,
    error = p.red,
    success = p.green,
    attention = p.yellow,

    info_muted = p.blue,
    warn_muted = p.orange,
    error_muted = p.red,
    success_muted = p.green,

    bg_info = p.bg_alt,
    bg_warn = p.bg_alt,
    bg_error = p.bg_alt,
    bg_success = p.bg_alt,
  }
end

return M
