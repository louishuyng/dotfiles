-- Filetype plugins can start Treesitter before this callback, so stop it for large files.
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
    if ok and stats and stats.size > 100 * 1024 then
      vim.treesitter.stop(args.buf)
      return
    end
    pcall(vim.treesitter.start, args.buf)
  end,
})
