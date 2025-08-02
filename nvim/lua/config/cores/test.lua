local neotest_ns = vim.api.nvim_create_namespace('neotest')

local opts = {
  status = { virtual_text = true },
  output = {
    enabled = true,
    open_on_run = false,
  },
}

vim.api.nvim_create_autocmd('User', {
  pattern = 'NeotestResult',
  callback = function(args)
    local results = args.data
    if results then
      -- Check if any tests failed
      local has_failures = false
      for _, result in pairs(results) do
        if result.status == 'failed' then
          has_failures = true
          break
        end
      end

      -- Open output panel if there are failures
      if has_failures then
        require('neotest').output_panel.open()
      end
    end
  end,
})

vim.diagnostic.config({
  virtual_text = {
    format = function(diagnostic)
      -- Replace newline and tab characters with space for more compact diagnostics
      local message = diagnostic.message:gsub('\n', ' '):gsub('\t', ' '):gsub('%s+', ' '):gsub('^%s+', '')
      return message
    end,
  },
}, neotest_ns)

opts.adapters = {
  ['neotest-golang'] = {
    go_test_args = { '-v', '-race', '-count=1', '-timeout=60s' },
    dap_go_enabled = true,
  },
  ['neotest-jest'] = {
    jestCommand = 'yarn test --',
    jestConfigFile = 'jest.config.ts',
    env = { CI = true },
    cwd = function(path)
      return vim.fn.getcwd()
    end,
  },
}

if opts.adapters then
  local adapters = {}
  for name, config in pairs(opts.adapters or {}) do
    if type(name) == 'number' then
      if type(config) == 'string' then
        config = require(config)
      end
      adapters[#adapters + 1] = config
    elseif config ~= false then
      local adapter = require(name)
      if type(config) == 'table' and not vim.tbl_isempty(config) then
        local meta = getmetatable(adapter)
        if adapter.setup then
          adapter.setup(config)
        elseif adapter.adapter then
          adapter.adapter(config)
          adapter = adapter.adapter
        elseif meta and meta.__call then
          adapter = adapter(config)
        else
          error('Adapter ' .. name .. ' does not support setup')
        end
      end
      adapters[#adapters + 1] = adapter
    end
  end
  opts.adapters = adapters
end

require('neotest').setup(opts)
