local M = {}

M.colorizer = function()
  local present, colorizer = pcall(require, "colorizer")
  if present then
    colorizer.setup()
    vim.cmd("ColorizerReloadAllBuffers")
  end
end

M.comment = function()
  local present, nvim_comment = pcall(require, "nvim_comment")
  if present then
    nvim_comment.setup()
  end
end

M.luasnip = function()
  local present, luasnip = pcall(require, "luasnip")
  if present then
    luasnip.config.set_config {
      history = true,
      updateevents = "TextChanged,TextChangedI",
    }
    require("luasnip/loaders/from_vscode").load { path = { '~/.config/nvim/my-snippets' } }
    end
end

return M
