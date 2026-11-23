-- Adds VIMRUNTIME and each plugin a file requires to the lua_ls library, on demand.
local ok, lazydev = pcall(require, 'lazydev')
if ok then
  lazydev.setup({})
end

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      workspace = {
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
      completion = {
        callSnippet = 'Replace',
      },
      diagnostics = {
        disable = { 'missing-fields' },
      },
    },
  },
})

vim.lsp.enable('lua_ls')
