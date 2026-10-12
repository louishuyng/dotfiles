-- Run from the repo root: nvim --headless -u NONE -i NONE -n -l nvim/tests/mermaid.lua
package.loaded.snacks = { setup = function() end }
package.loaded['config.theme.palette'] = { on_change = function() end }

local chrome = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
local executable = vim.fn.executable
local original_path = vim.env.PUPPETEER_EXECUTABLE_PATH

for _, case in ipairs({
  { available = 1, expected = chrome },
  { available = 0 },
  { available = 1, override = '/custom/chrome', expected = '/custom/chrome' },
}) do
  vim.fn.executable = function(path)
    assert(path == chrome)
    return case.available
  end
  vim.env.PUPPETEER_EXECUTABLE_PATH = case.override
  dofile('nvim/lua/config/cores/snacks.lua')
  assert(vim.env.PUPPETEER_EXECUTABLE_PATH == case.expected, 'Chrome fallback or override failed')
end

vim.fn.executable = executable
vim.env.PUPPETEER_EXECUTABLE_PATH = original_path
dofile('nvim/lua/config/cores/snacks.lua')

local output = vim.fn.tempname() .. '.png'
local result = vim
  .system({ 'mmdc', '-i', '-', '-o', output, '-b', 'transparent', '-t', 'dark', '-s', '1.875' }, {
    stdin = 'flowchart LR\n  A[Start] --> B[Done]\n',
    text = true,
  })
  :wait(30000)
assert(result.code == 0, result.stderr)
assert(vim.fn.getfsize(output) > 0, 'Mermaid image was not generated')
vim.fn.delete(output)
print('Chrome fallback, override, and Mermaid conversion checks passed')
vim.cmd('qa!')
