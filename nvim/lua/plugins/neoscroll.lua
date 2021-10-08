local present, neoscroll = pcall(require, "neoscroll")
if not present then
    return
end

neoscroll.setup({
  mappings = {'zj', 'zk'},
})

local t = {}

t['zk'] = {'scroll', {'-vim.wo.scroll', 'true', '150'}}
t['zj'] = {'scroll', { 'vim.wo.scroll', 'true', '150'}}

require('neoscroll.config').set_mappings(t)
