-- vim-test configuration
-- Custom strategies for different terminals
vim.g['test#custom_strategies'] = {
  -- Snacks terminal strategy (for non-WezTerm)
  snacks = function(cmd)
    require('snacks').terminal.toggle(cmd, {
      win = { position = 'bottom', height = 0.3 },
    })
  end,
  -- WezTerm strategy - opens test in a pane below (async)
  wezterm = function(cmd)
    local handle
    handle = vim.uv.spawn('wezterm', {
      args = { 'cli', 'split-pane', '--bottom', '--percent', '30', '--', 'sh', '-c', cmd },
      detached = true,
    }, function()
      if handle then
        handle:close()
      end
    end)
  end,
}

-- Auto-detect terminal and set strategy
local function get_strategy()
  if os.getenv('WEZTERM_PANE') then
    return 'wezterm'
  end
  return 'snacks'
end

vim.g['test#strategy'] = get_strategy()

-- Optional: Customize test commands for different languages
-- For Go tests
vim.g['test#go#gotest#options'] = '-v -race -count=1 -timeout=60s'

-- Ensure Jest is enabled for JavaScript/TypeScript files
vim.g['test#javascript#runner'] = 'jest'
vim.g['test#typescript#runner'] = 'jest'
