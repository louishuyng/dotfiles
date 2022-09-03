local present, tint = pcall(require, "tint")

if not (present) then return end

tint.setup({
  bg = false, -- Tint background portions of highlight groups
  amt = -30, -- Darken colors, use a positive value to brighten
  ignore = {"WinSeparator", "Status.*"}, -- Highlight group patterns to ignore, see `string.find`
  ignorefunc = function(winid)
    local buf = vim.api.nvim_win_get_buf(winid)
    local buftype
    vim.api.nvim_buf_get_option(buf, "buftype")

    if buftype == "terminal" then
      -- Do not tint `terminal`-type buffers
      return true
    end

    -- Tint the window
    return false
  end
})
