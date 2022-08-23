local colors = require 'ui.main_colors'

return {
  provider = function()
    local Lsp = vim.lsp.util.get_progress_messages()[1]

    if Lsp then
      local msg = Lsp.message or ""
      local percentage = Lsp.percentage or 0
      local title = Lsp.title or ""
      local spinners = {"", "", ""}

      local success_icon = {"", "", ""}

      local ms = vim.loop.hrtime() / 1000000
      local frame = math.floor(ms / 120) % #spinners

      if percentage >= 70 then
        return string.format(" %%<%s %s %s (%s%%%%) ", success_icon[frame + 1],
                             title, msg, percentage)
      end

      return string.format(" %%<%s %s %s (%s%%%%) ", spinners[frame + 1], title,
                           msg, percentage)
    end

    return ""
  end,
  hl = {fg = colors.status_line_fg}
}
