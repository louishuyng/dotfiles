require("gitsigns").setup {
    numhl = false,
    keymaps = {
        -- Default keymap options
        noremap = true,
        buffer = true,
        ["n ]h"] = {expr = true, '&diff ? \']c\' : \'<cmd>lua require"gitsigns".next_hunk()<CR>\''},
        ["n [h"] = {expr = true, '&diff ? \'[c\' : \'<cmd>lua require"gitsigns".prev_hunk()<CR>\''},
        ["n ga"] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
        ["n gA"] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
        ["n gu"] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
        ["n gp"] ='<cmd>lua require"gitsigns".preview_hunk()<CR>',
        ["n gb"] = '<cmd>lua require"gitsigns".blame_line()<CR>'
    },
    watch_index = {
        interval = 100
    },
    sign_priority = 5,
    status_formatter = nil -- Use default
}
