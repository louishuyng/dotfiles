local present, neoscroll = pcall(require, "neoscroll")
if not present then
    return
end

neoscroll.setup({
  mappings = {'<C-f>', '<C-b>'},
})

local t = {}

t['<C-f>'] = {'scroll', {'-vim.wo.scroll', 'true', '150'}}
t['<C-b>'] = {'scroll', { 'vim.wo.scroll', 'true', '150'}}

require('neoscroll.config').set_mappings(t)
