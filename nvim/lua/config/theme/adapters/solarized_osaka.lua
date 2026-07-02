-- Adapter: craftzdog/solarized-osaka.nvim → semantic palette.
--
-- Unlike the other adapters, we don't replicate the palette table here.
-- solarized-osaka computes its colors via HSL at load time and exposes the
-- resolved tables as M.default (dark) / M.light (light) on the colors
-- module. We require it at resolve() time.

local M = {}

function M.setup()
  local ok, so = pcall(require, 'solarized-osaka')
  if ok then
    so.setup({
      transparent = false,
    })
  end
end

function M.apply(variant)
  vim.o.background = variant == 'light' and 'light' or 'dark'
  vim.cmd.colorscheme(variant == 'light' and 'solarized-osaka-day' or 'solarized-osaka')
end

function M.resolve(variant)
  local ok, colors = pcall(require, 'solarized-osaka.colors')
  if not ok then
    return nil
  end
  local p = variant == 'light' and colors.light or colors.default
  if not p then
    return nil
  end

  return {
    -- Backgrounds (deep → shallow, semantics flip with variant)
    bg = p.bg or p.base04,
    bg_alt = p.base03 or p.base04,
    bg_dim = p.bg_highlight or p.base03,
    surface = p.base02,
    surface_alt = p.base01,
    overlay = p.base00,

    -- Foregrounds
    text = p.fg or p.base0,
    subtle = p.base1,
    muted = p.base00,

    -- Brand accents (green leads, cyan supports, violet contrasts —
    -- matches the family pattern of the other adapters).
    primary = p.green,
    secondary = p.cyan,
    tertiary = p.violet,

    -- Status / diagnostic roles
    info = p.blue,
    warn = p.orange,
    error = p.red,
    success = p.green,
    attention = p.yellow,

    info_muted = p.blue700 or p.blue,
    warn_muted = p.orange700 or p.orange,
    error_muted = p.red700 or p.red,
    success_muted = p.green700 or p.green,

    -- Dim backgrounds for badges / diff regions (solarized-osaka has
    -- ready-made 950 shades — perfect for this).
    bg_info = p.blue950 or p.base02,
    bg_warn = p.orange950 or p.base02,
    bg_error = p.red950 or p.base02,
    bg_success = p.green950 or p.base02,
  }
end

return M
