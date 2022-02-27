return function(bufnr, mode, lhs, rhs, opts)
    opts = opts or {
      silent = true,
    }
    opts.buffer = bufnr

    vim.keymap.set(mode, lhs, rhs, opts)
end
