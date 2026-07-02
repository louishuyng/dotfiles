-- Adapter: sainnhe/gruvbox-material → semantic palette.
--
-- Vimscript colorscheme configured via g:gruvbox_material_* globals. We
-- replicate its palette here since there's no Lua palette API. Defaults
-- pin background=medium and foreground=material — the latter matches the
-- "Cyberpunk Terminal" colors the user previously hand-coded as a
-- catppuccin override (#a9b665, #ea6962, #d8a657, ...).

local M = {}

-- "hard" background: bg0 is darker, giving better contrast against the
-- bg_alt panel layer. Hex values come from gruvbox_material#get_palette
-- with background='hard'.
local dark = {
  bg_dim           = '#141617',
  bg0              = '#1d2021',
  bg1              = '#282828',
  bg2              = '#282828',
  bg3              = '#3c3836',
  bg4              = '#3c3836',
  bg5              = '#504945',
  bg_visual_red    = '#442e2d',
  bg_visual_yellow = '#473c29',
  bg_visual_green  = '#333e34',
  bg_visual_blue   = '#2e3b3b',
  bg_visual_purple = '#3c333b',
  fg0              = '#d4be98',
  fg1              = '#ddc7a1',
  red              = '#ea6962',
  orange           = '#e78a4e',
  yellow           = '#d8a657',
  green            = '#a9b665',
  aqua             = '#89b482',
  blue             = '#7daea3',
  purple           = '#d3869b',
  grey0            = '#7c6f64',
  grey1            = '#928374',
  grey2            = '#a89984',
}

local light = {
  bg_dim           = '#f3eac7',
  bg0              = '#f9f5d7',
  bg1              = '#f5edca',
  bg2              = '#f3eac7',
  bg3              = '#f2e5bc',
  bg4              = '#eee0b7',
  bg5              = '#ebdbb2',
  bg_visual_red    = '#f0ddc3',
  bg_visual_yellow = '#f9eabf',
  bg_visual_green  = '#dde5c2',
  bg_visual_blue   = '#d9e1cc',
  bg_visual_purple = '#eee2d1',
  fg0              = '#654735',
  fg1              = '#4f3829',
  red              = '#c14a4a',
  orange           = '#c35e0a',
  yellow           = '#b47109',
  green            = '#6c782e',
  aqua             = '#4c7a5d',
  blue             = '#45707a',
  purple           = '#945e80',
  grey0            = '#a89984',
  grey1            = '#928374',
  grey2            = '#7c6f64',
}

function M.setup()
  vim.g.gruvbox_material_background = 'hard'
  vim.g.gruvbox_material_foreground = 'material'
  vim.g.gruvbox_material_better_performance = 1
end

function M.apply(variant)
  vim.o.background = variant == 'light' and 'light' or 'dark'
  vim.cmd.colorscheme('gruvbox-material')
end

function M.resolve(variant)
  local p = variant == 'light' and light or dark
  return {
    bg = p.bg0,
    bg_alt = p.bg1,
    bg_dim = p.bg_dim,
    -- gruvbox sets bg1 == bg2 (panel layer is one tone). To keep `surface`
    -- visibly distinct from `bg_alt` so things like NvimTreeCursorLine
    -- read as "active row", lift surface to bg3 and surface_alt to bg5.
    surface = p.bg3,
    surface_alt = p.bg5,
    overlay = p.bg4,

    text = p.fg1,
    subtle = p.fg0,
    muted = p.grey1,

    -- Brand accents: green leads, aqua supports, purple contrasts —
    -- matches the family pattern of the other adapters.
    primary = p.green,
    secondary = p.aqua,
    tertiary = p.purple,

    -- Diagnostic roles. Orange-as-warn (gruvbox has both yellow and orange,
    -- orange reads as more urgent without becoming an error).
    info = p.blue,
    warn = p.orange,
    error = p.red,
    success = p.green,
    attention = p.yellow,

    info_muted = p.blue,
    warn_muted = p.yellow,
    error_muted = p.red,
    success_muted = p.aqua,

    bg_info = p.bg_visual_blue,
    bg_warn = p.bg_visual_yellow,
    bg_error = p.bg_visual_red,
    bg_success = p.bg_visual_green,
  }
end

return M
