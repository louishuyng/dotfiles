vim.lsp.config('vtsls', {
  -- explicitly add default filetypes, so that we can extend
  -- them in related extras
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
  },
  settings = {
    complete_function_calls = true,
    vtsls = {
      enableMoveToFileCodeAction = true,
      autoUseWorkspaceTsdk = true,
      experimental = {
        maxInlayHintLength = 30,
        completion = {
          enableServerSideFuzzyMatch = true,
        },
      },
    },
    typescript = {
      updateImportsOnFileMove = { enabled = 'always' },
      suggest = {
        completeFunctionCalls = true,
      },
      inlayHints = {
        enumMemberValues = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        parameterNames = { enabled = 'literals' },
        parameterTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        variableTypes = { enabled = false },
      },
    },
  },
})

-- Organize imports
vim.keymap.set('n', '<leader>oi', function()
  local clients = vim.lsp.get_clients({ bufnr = 0, name = 'vtsls' })
  if #clients > 0 then
    -- Since we filtered by name='vtsls', clients[1] is guaranteed to be vtsls
    local client = clients[1]
    local params = {
      command = 'typescript.organizeImports',
      arguments = { vim.api.nvim_buf_get_name(0) },
    }
    client.request('workspace/executeCommand', params, nil, 0)
  else
    vim.notify('vtsls client not found', vim.log.levels.WARN)
  end
end, { desc = 'Organize Imports' })

vim.lsp.config('eslint', {
  single_file_support = true,
  settings = {
    packageManager = 'yarn', -- or 'npm'
  },
})

vim.lsp.enable('vtsls')
vim.lsp.enable('eslint')
