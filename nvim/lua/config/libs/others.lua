local M = {}

M.colorizer = function()
  local present, colorizer = pcall(require, "colorizer")
  if present then
    colorizer.setup()
    vim.cmd("ColorizerReloadAllBuffers")
  end
end

M.luasnip = function()
  local present, luasnip = pcall(require, "luasnip")
  if present then
    luasnip.config.set_config {
      history = true,
      updateevents = "TextChanged,TextChangedI",
    }
    require("luasnip.loaders.from_vscode").lazy_load { }
    end
end

return M
