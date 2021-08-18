local function map(mode, lhs, rhs, opts, options)
    options = options or {}

    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

local opt = {}

-- dont copy any deleted text , this is disabled by default so uncomment the below mappings if you want them
--[[ remove this line
map("n", "dd", [=[ "_dd ]=], opt)
map("v", "dd", [=[ "_dd ]=], opt)
map("v", "x", [=[ "_x ]=], opt)
 this line too ]]
--

-- General
map("n", ",h", ":<C-u>split<CR>", opt)
map("n", ",v", ":<C-u>vsplit<CR>", opt)

map("n", ",e", ":e <C-R>=expand(\"%:p:h\") . \"/\" <CR>", opt)

map("v", "<C-x>", ":!pbcopy<CR>", opt)
map("v", "<C-c>", ":w !pbcopy<CR><CR>", opt)

map("v", "/", "y/<C-R>\"<CR>", opt)
map("n", "<C-j>", "<C-w>j", opt)
map("n", "<C-k>", "<C-w>k", opt)
map("n", "<C-l>", "<C-w>l", opt)
map("n", "<C-h>", "<C-w>h", opt)

map("n", "<C-s>", ":w!<CR>", opt)
map("v", "<C-s>", "<C-C>:w!<CR>", opt)
map("i", "<C-s>", "<C-O>:w!<CR>", opt)
map("n", "<C-d>", ":q!<CR>", opt)
map("v", "<C-d>", "<ESC>:q!<CR>", opt)
map("i", "<C-d>", "<ESC>:q!<CR>", opt)

-- Macro Apply Visual
map("v", ",m", "normal @", opt)

-- HTML SUPPORT Close Tag
map("i", "><Tab>", "><Esc>?<[a-z]<CR>lyiwo</<C-r>\"><Esc>O", opt)

-- Move Block
vim.g.move_map_keys = 0
map("v", "<S-j>", "<Plug>MoveBlockDown", opt)
map("v", "<S-k>", "<Plug>MoveBlockUp", opt)
map("v", "<S-h>", "<Plug>MoveBlockLeft", opt)
map("v", "<S-l>", "<Plug>MoveBlockRight", opt)

-- compe stuff
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

-- dashboard stuff
map("n", "<space>sl", [[<Cmd> SessionLoad<CR>]], opt)
map("n", "<space>ss", [[<Cmd> SessionSave<CR>]], opt)

-- Truezen.nvim
map("n", "<C-w>o", ":TZFocus<CR>", opt)

-- Commenter Keybinding
map("n", "<space>/", ":CommentToggle<CR>", opt)
map("v", "<space>/", ":CommentToggle<CR>", opt)

-- anzu
map("n", "n", "<Plug>(anzu-n-with-echo)", opt)
map("n", "N", "<Plug>(anzu-N-with-echo)", opt)
map("n", "*", "<Plug>anzu-star-with-echo", opt)
map("n", "#", "<Plug>anzu-sharp-with-echo", opt)
map("n","<Esc><Esc>", "<Plug>anzu-clear-search-status", opt)

-- buffer
map("n", ",w", ":bnext<CR>", opt)
map("n", ",q", ":bprevious<CR>", opt)
map("n", ",bda", ":w <bar> %bd <bar> e# <bar> bd# <CR>", opt)
map("n", "<S-t>", ":tabnew<CR>", opt, {silent = true})
map("n", "1<Tab>", "1gt", opt, {silent = true})
map("n", "2<Tab>", "2gt", opt, {silent = true})
map("n", "3<Tab>", "3gt", opt, {silent = true})

-- fold
map("n", "zl", ":set foldlevel=", opt)

-- git
map("n", ",ga", ":Gwrite!<CR>", opt)
map("n", ",gc", ":Git commit<CR>", opt)
map("n", "<space>gp", ":Gpush", opt)
map("n", "<space>gf", ":Gpull", opt)
map("n", ",gs", ":Git<CR>:20wincmd_<CR>", opt, {silent = true})
map("n", "<space>gs", ":LazyGit<CR>", opt, {silent = true})
map("n", ",gb", ":Git blame<CR>", opt)
map("n", ",gd", ":Gvdiff!<CR>", opt)
map("n", "dh", ":diffget //2<CR>", opt)
map("n", "dl", ":diffget //3<CR>", opt)
map("n", ",go", ":.Gbrowse<CR>", opt)

-- lsp
map("n", "gff", ":vsplit<CR>gf", opt)
map("n", "gfh", ":split<CR>gf", opt)

-- lsp saga
map("n", "gr", ":Lspsaga lsp_finder<CR>", opt, {silent = true})
map("n", "gd", ":Lspsaga preview_definition<CR>", opt, {silent = true})
map("n", "ac", ":Lspsaga code_action<CR>", opt, {silent = true})
map("n", "K", ":Lspsaga hover_doc<CR>", opt, {silent = true})
map("n", ",rr", ":Lspsaga rename<CR>", opt, {silent = true})
map("n", "]d", ":Lspsaga diagnostic_jump_next<CR>", opt, {silent = true})
map("n", "[d", ":Lspsaga diagnostic_jump_prev<CR>", opt, {silent = true})

-- mundo
map("n", "<F5>", ":MundoToggle<CR>", opt)

-- rails
map("n", ",t", ":call RunCurrentSpecFile()<CR>", opt)
map("n", ",s", ":call RunNearestSpec()<CR>", opt)
map("n", ",l", ":call RunLastSpec()<CR>", opt)
map("n", ",a", ":call RunAllSpecs()<CR>", opt)

-- telescope
map("n", "<c-p>", "<cmd>Telescope git_files<cr>", opt, {silent = true})
map("n", "<space>f", "<cmd>Telescope live_grep<CR>", opt, {silent = true})
map("n", "<space>t", "<cmd>Telescope treesitter<CR>", opt, {silent = true})
map("n", "<space>b", "<cmd>Telescope buffers<CR>", opt, {silent = true})
map("n", "<space>h", "<cmd>Telescope oldfiles<CR>", opt, {silent = true})

-- vimux
map("n", ",vp", ":VimuxPromptCommand<CR>", opt)
map("n", ",vl", ":VimuxRunLastCommand<CR>", opt)
map("n", ",vz", ":VimuxZoomRunner<CR>", opt)
map("n", ",vi", ":VimuxInspectRunner<CR>", opt)
map("n", ",vc", ":VimuxInterruptRunner<CR>", opt)

-- nvimtree
map("n", ",ne", ":NvimTreeToggle<CR>", opt)
map("n", ",nf", ":NvimTreeFindFile<CR>", opt)

-- dashboard
map("n", "<space>fo", ":DashboardFindHistory<CR>", opt, {silent = true})
map("n", "<space>ff", ":DashboardFindFile<CR>", opt, {silent = true})
map("n", "<space>fw", ":DashboardFindWord<CR>", opt, {silent = true})
map("n", "<space>bm", ":DashboardJumpMark<CR>", opt, {silent = true})

-- prettier
map("n", ",p", ":Prettier<CR>", opt, {silent = true})

-- markdow
map("n", "<space>md", ":MarkdownPreview<CR>", opt, {silent = true})

-- wordmotion
map("n", "w", "<Plug>WordMotion_w", opt, {silent = true})
map("n", "e", "<Plug>WordMotion_b", opt, {silent = true})
map("n", "gE", "<Plug>WordMotion_gE", opt, {silent = true})
