-- vim-test configuration
-- Custom strategies for different terminals
local wezterm_pane_id = nil

vim.g['test#custom_strategies'] = {
  -- WezTerm strategy - opens test in a pane below, reuses existing pane
  wezterm = function(cmd)
    -- Check if existing pane is still valid
    if wezterm_pane_id then
      local check = vim.fn.system('wezterm cli list --format json')
      local ok, panes = pcall(vim.json.decode, check)
      local pane_exists = false
      if ok and panes then
        for _, pane in ipairs(panes) do
          if pane.pane_id == wezterm_pane_id then
            pane_exists = true
            break
          end
        end
      end
      if not pane_exists then
        wezterm_pane_id = nil
      end
    end

    if wezterm_pane_id then
      -- Reuse existing pane: send Ctrl-C to stop any running process, clear, then run command
      vim.fn.system('wezterm cli send-text --pane-id ' .. wezterm_pane_id .. " --no-paste $'\\x03'")
      vim.fn.system(
        'wezterm cli send-text --pane-id '
          .. wezterm_pane_id
          .. ' --no-paste "clear && '
          .. cmd:gsub('"', '\\"')
          .. '\n"'
      )
    else
      -- Create new pane and capture its ID
      local result = vim.fn.system('wezterm cli split-pane --bottom --percent 30')
      wezterm_pane_id = tonumber(result:match('%d+'))
      if wezterm_pane_id then
        vim.fn.system(
          'wezterm cli send-text --pane-id ' .. wezterm_pane_id .. ' --no-paste "' .. cmd:gsub('"', '\\"') .. '\n"'
        )
      end
    end
  end,
}

-- Auto-detect terminal and set strategy
local function get_strategy()
  if os.getenv('WEZTERM_PANE') then
    return 'wezterm'
  end

  return 'vimux' -- Default to vimux if not WezTerm
end

vim.g['test#strategy'] = get_strategy()

-- Vimux settings
vim.g['VimuxHeight'] = '15'

-- Optional: Customize test commands for different languages
-- For Go tests
vim.g['test#go#gotest#options'] = '-v -race -count=1 -timeout=60s'

-- Ensure Jest is enabled for JavaScript/TypeScript files
vim.g['test#javascript#runner'] = 'jest'
vim.g['test#typescript#runner'] = 'jest'
