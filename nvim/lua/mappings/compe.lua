local map = require('utils.map').map

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col(".") - 1
    if col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
        return true
    else
        return false
    end
end

_G.tab_complete = function()
    if vim.fn.pumvisible() == 1 then
        return t "<C-n>"
    elseif check_back_space() then
        return t "<Tab>"
    else
        return vim.fn["compe#complete"]()
    end
end

_G.s_tab_complete = function()
    if vim.fn.pumvisible() == 1 then
        return t "<C-p>"
    else
        return t "<S-Tab>"
    end
end

--  compe mappings
map("i", "<Tab>", "v:lua.tab_complete()", {expr = true}, {noremap = true, silent = true})
map("s", "<Tab>", "v:lua.tab_complete()", {expr = true}, {noremap = true, silent = true})
map("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true}, {noremap = true, silent = true})
map("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true}, {noremap = true, silent = true})

map("i", "<C-Space>", "compe#complete()", {expr = true}, {noremap = true, silent = true})
map("i", "<CR>", "compe#confirm('<CR>')", {expr = true}, {noremap = true, silent = true})
map("i", "<C-d>", "compe#close('<C-e>')", {expr = true}, {noremap = true, silent = true})
