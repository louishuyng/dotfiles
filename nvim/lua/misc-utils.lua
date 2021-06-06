local scopes = {o = vim.o, b = vim.bo, w = vim.wo}

local function opt(scope, key, value)
    scopes[scope][key] = value
    if scope ~= "o" then
        scopes["o"][key] = value
    end
end

opt("o", "gcr", "a:blinkon0")
opt("o", "cursorline", true)
opt("o", "autoread", true)
opt("o", "showcmd", true)
opt("o", "spell", true)

opt("o", "hidden", true)
opt("o", "ignorecase", true)
opt("o", "incsearch", true)
opt("o", "smartcase", true)
opt("o", "hlsearch", true)
opt("o", "termguicolors", true)
opt('w', 'relativenumber', true)  -- Numbers starting at cursor line
opt('w', 'number', true)    
opt("o", "numberwidth", 2)
opt("w", "cul", true)

opt("o", "mouse", "a")

opt("w", "signcolumn", "yes")
opt("o", "cmdheight", 1)

opt("o", "updatetime", 250) -- update interval for gitsigns
opt("o", "clipboard", "unnamedplus")
opt("o", "timeoutlen", 500)

-- for indenline
opt("b", "expandtab", true)
opt("b", "shiftwidth", 2)

-- for scroll
opt("o", "scrolloff", 3)
opt("o", "sidescrolloff", 15)
opt("o", "sidescroll", 1)

-- for clipboard
opt("o", "clipboard", 'unnamed')

local M = {}

function M.is_buffer_empty()
    -- Check whether the current buffer is empty
    return vim.fn.empty(vim.fn.expand("%:t")) == 1
end

function M.has_width_gt(cols)
    -- Check if the windows width is greater than a given number of columns
    return vim.fn.winwidth(0) / 2 > cols
end
-- file extension specific tabbing
vim.cmd([[autocmd Filetype ruby setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2]])
return M
