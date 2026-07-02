-- Adapter: savq/melange-nvim → semantic palette.
--
-- Single colorscheme with both dark and light backgrounds, selected via
-- vim.o.background. Palette tables live at melange.palettes.{dark,light}
-- with the shape:
--   a = { bg, overbg, sel, faded, com, fg }  -- structure tones
--   b = bright accents (red/yellow/green/teal/blue/magenta)
--   c = mid accents
--   d = muted accents
--   e = darkest accents (good for dim badge/diff backgrounds)

local M = {}

function M.setup()
  -- melange has no setup() — config is via vim.g.melange_enable_*
  -- and the colorscheme variant key is just vim.o.background.
end

function M.apply(variant)
  vim.o.background = variant == 'light' and 'light' or 'dark'
  vim.cmd.colorscheme('melange')
end

function M.resolve(variant)
  local mod = variant == 'light' and 'melange.palettes.light' or 'melange.palettes.dark'
  local ok, p = pcall(require, mod)
  if not ok or type(p) ~= 'table' then
    return nil
  end
  local a, b, c, e = p.a, p.b, p.c, p.e
  return {
    bg = a.bg,
    bg_alt = a.overbg,
    bg_dim = a.overbg,
    surface = a.sel,
    surface_alt = a.overbg,
    overlay = a.sel,

    text = a.fg,
    subtle = a.faded,
    muted = a.com,

    -- Brand accents: green leads, teal supports, magenta contrasts —
    -- matches the family pattern of the other adapters.
    primary = b.green,
    secondary = b.teal,
    tertiary = b.magenta,

    info = b.blue,
    warn = b.yellow,
    error = b.red,
    success = b.green,
    attention = c and c.yellow or b.yellow,

    info_muted = c and c.blue or b.blue,
    warn_muted = c and c.yellow or b.yellow,
    error_muted = c and c.red or b.red,
    success_muted = c and c.green or b.green,

    -- e.* are melange's darkest shades — ideal for badge/diff surfaces.
    bg_info = (e and e.blue) or a.overbg,
    bg_warn = (e and e.yellow) or a.overbg,
    bg_error = (e and e.red) or a.overbg,
    bg_success = (e and e.green) or a.overbg,
  }
end

return M
