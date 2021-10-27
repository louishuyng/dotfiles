local lsp_config = require 'lspconfig'
local on_attach = require 'lsp/on_attach'

local system_name
if vim.fn.has("mac") == 1 then
  system_name = "macOS"
elseif vim.fn.has("unix") == 1 then
  system_name = "Linux"
elseif vim.fn.has('win32') == 1 then
  system_name = "Windows"
else
  print("Unsupported system for sumneko")
end

local sumneko_root_path = vim.fn.stdpath('config')..'/lua-language-server/bin/'
local sumneko_binary = sumneko_root_path..system_name.."/lua-language-server"

local main_sumneko_root_path = vim.fn.stdpath('config')..'/lua-language-server/main.lua'

lsp_config.sumneko_lua.setup({
  on_attach = on_attach,
  cmd = {sumneko_binary, "-E", main_sumneko_root_path};
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        enable = true,
        globals = {
          "vim",
          "describe",
          "it",
          "before_each",
          "after_each"
        }
      },
      workspace = {
        maxPreload=10000,
        preloadFileSize=1000,
        checkThirdParty=false,
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true
        },
      },
    }
  }
})
