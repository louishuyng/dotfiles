return {
  {
    'github/copilot.vim',
    lazy = false,
    config = function()
      vim.api.nvim_set_keymap('i', '<Bslash><Bslash>', 'copilot#Accept("<CR>")', { expr = true, silent = true })
      vim.g.copilot_no_tab_map = true
    end,
  },
}
