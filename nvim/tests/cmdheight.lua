-- Run from the repo root: nvim -u nvim/tests/cmdheight.lua -i NONE -n
-- UI2 requires an attached terminal UI; do not use --headless.
local ui = require('vim._core.ui2')
ui.enable({})
dofile('nvim/lua/options/init.lua')

vim.schedule(function()
  local ok, err = pcall(function()
    local function assert_hidden()
      assert(
        vim.wait(1000, function()
          return vim.o.cmdheight == 0 and ui.cmdheight == 0
        end),
        'cmdheight and UI2 must both return to zero'
      )
      assert(vim.api.nvim_win_get_config(ui.wins.cmd).hide, 'UI2 command bar must be hidden')
    end

    assert_hidden()
    vim.o.cmdheight = 1
    assert_hidden()
    vim.cmd('set cmdheight=3')
    assert_hidden()

    vim.cmd('tabnew')
    vim.cmd('noautocmd set cmdheight=1')
    vim.cmd('tabprevious')
    vim.cmd('tabnext')
    assert_hidden()

    vim.cmd('noautocmd set cmdheight=1')
    vim.api.nvim_exec_autocmds('VimResized', {})
    assert_hidden()
  end)
  if not ok then
    io.stderr:write(tostring(err) .. '\n')
    vim.cmd('cquit')
  end
  io.stdout:write('cmdheight checks passed\n')
  vim.cmd('qa!')
end)
