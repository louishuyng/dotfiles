local roots = {}

vim.api.nvim_create_autocmd('BufEnter', {
  pattern = '*.py',
  callback = function(args)
    local root = roots[args.buf]
    if root == nil then
      root = vim.fs.root(args.buf, '.git') or false
      roots[args.buf] = root
    end
    if not root then
      return
    end
    vim.env.PYTHONPATH = vim.fs.joinpath(root, 'src')
  end,
})
