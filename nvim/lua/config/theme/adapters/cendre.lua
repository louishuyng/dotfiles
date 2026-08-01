-- Adapter: Aejkatappaja/cendre → semantic palette.
--
-- Dark-only theme: it hardcodes `background = "dark"` in its load(), so
-- assigning it to the light slot yields a dark editor. Its "variants" are
-- three ground depths (hard/medium/soft) picked in setup() or at runtime via
-- :CendreBackground — the pigments don't move between them, only the grounds.
--
-- Palette shape (cendre.palette):
--   grounds  = { bg_deep, bg0 .. bg5 }        -- seven finely spaced depths
--   ink      = { fg, fg_dim, comment, gutter }
--   pigments = { brass, ember, sap, cinder, frost }
--   semantic = { error, warn, ok, hint, info }  -- higher chroma than pigments
--   tints    = { vis, add, del, mod }           -- tinted grounds for diff/visual

local M = {}

function M.setup()
  local ok, cendre = pcall(require, 'cendre')
  if ok then
    cendre.setup({
      background = 'hard',
      transparent = false,
      italic = false,
      italic_comments = true,
    })
  end
end

function M.apply(_)
  vim.o.background = 'dark'
  vim.cmd.colorscheme('cendre')
end

function M.resolve(_)
  local ok, cendre = pcall(require, 'cendre')
  if not ok then
    return nil
  end
  -- cendre.colors is the table the active depth actually loaded (post
  -- on_colors); fall back to the configured depth if load() hasn't run yet.
  local c = cendre.colors
  if not c then
    local ok_p, palette = pcall(require, 'cendre.palette')
    if not ok_p then
      return nil
    end
    c = palette.get(cendre.config.background)
  end

  return {
    bg = c.bg0,
    bg_alt = c.bg_deep,
    bg_dim = c.bg1,
    surface = c.bg2,
    surface_alt = c.bg3,
    overlay = c.bg4,

    text = c.fg,
    subtle = c.fg_dim,
    muted = c.comment,

    -- Brand accents: green leads, a cool tone supports, warm contrasts —
    -- matches the family pattern of the other adapters.
    primary = c.sap,
    secondary = c.frost,
    tertiary = c.brass,

    info = c.info,
    warn = c.warn,
    error = c.error,
    success = c.ok,
    -- warn is already amber; brass keeps attention distinguishable from it.
    attention = c.brass,

    -- The pigments are the low-chroma counterparts of the diagnostic family
    -- (cinder/red, ember/amber, sap/green, frost/blue) — exactly what the
    -- muted roles want.
    info_muted = c.frost,
    warn_muted = c.ember,
    error_muted = c.cinder,
    success_muted = c.sap,

    -- Tinted grounds, sized to lift off the editor by a fixed amount.
    -- No warn tint exists; vis is the warm one.
    bg_info = c.mod,
    bg_warn = c.vis,
    bg_error = c.del,
    bg_success = c.add,
  }
end

return M
