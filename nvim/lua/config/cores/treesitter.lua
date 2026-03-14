-- Enable treesitter highlighting for all filetypes
vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

-- Disable treesitter highlight for large files
vim.api.nvim_create_autocmd('BufReadPre', {
  callback = function(args)
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
    if ok and stats and stats.size > 100 * 1024 then
      vim.treesitter.stop(args.buf)
    end
  end,
})
