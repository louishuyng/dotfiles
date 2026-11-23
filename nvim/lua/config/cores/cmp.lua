local present, blink = pcall(require, 'blink.cmp')
if not present then
  return
end

blink.setup {
  enabled = function()
    return vim.bo.buftype ~= 'prompt' and vim.b.completion ~= false
  end,
  snippets = { preset = 'luasnip' },
  keymap = {
    -- No preset: <Tab> stays with copilot.vim.
    preset = 'none',
    ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
    ['<CR>'] = { 'accept', 'fallback' },
    ['<C-e>'] = { 'cancel', 'fallback' },
    ['<C-j>'] = { 'select_next', 'fallback' },
    ['<C-k>'] = { 'select_prev', 'fallback' },
    ['<C-n>'] = { 'select_next', 'fallback' },
    ['<C-p>'] = { 'select_prev', 'fallback' },
    ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
  },
  completion = {
    -- Nothing selected until asked, so <CR> stays a newline.
    list = { selection = { preselect = false, auto_insert = false } },
    menu = {
      draw = {
        columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 }, { 'kind' } },
      },
    },
    documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = 'rounded' } },
  },
  signature = { enabled = true, window = { border = 'rounded' } },
  cmdline = {
    completion = { menu = { auto_show = true } },
  },
}
