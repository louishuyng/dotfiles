local M = {}

function M.setup()
  local opts = { silent = true, noremap = true }
  vim.api.nvim_set_keymap(
    'n',
    '<space>h',
    '<cmd>lua require"harpoon.ui".toggle_quick_menu()<CR>',
    opts
  )
  vim.cmd [[ autocmd FileType harpoon nnoremap <buffer> q :q<cr> ]]
end

function M.config()
  require('harpoon').setup {}
end

return M
