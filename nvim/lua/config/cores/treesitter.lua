-- Enable treesitter highlighting for all filetypes, except large files.
-- The size check must live here rather than on BufReadPre: BufReadPre fires
-- before FileType, so a stop() there would race against a start that hasn't
-- happened yet and always lose.
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
    if ok and stats and stats.size > 100 * 1024 then
      return
    end
    pcall(vim.treesitter.start, args.buf)
  end,
})
