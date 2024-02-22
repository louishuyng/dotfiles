vim.api.nvim_set_keymap("n", "<Leader>cs",
                        [[<cmd>lua require("neoscopes").select()<CR>]],
                        {noremap = true})
