-- snipai — AI snippets backed by Claude Code.
-- Snippets: ~/.config/snipai/snippets.json (symlinked -> ~/.dotfiles/snipai)

local ok_setup, err_setup = pcall(function()
  require('snipai').setup()
end)
if not ok_setup then
  vim.notify('snipai: setup failed — ' .. tostring(err_setup), vim.log.levels.ERROR)
  return
end

-- Register the nvim-cmp source. Safe to call even before cmp is loaded;
-- the internal pcall short-circuits and returns false when cmp is absent.
require('snipai.sources.cmp').register()
