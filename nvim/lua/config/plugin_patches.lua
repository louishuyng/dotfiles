local M = {}

function M.apply(plugin)
  local patch = vim.fn.stdpath('config') .. '/patches/' .. plugin.spec.name .. '.patch'
  if vim.fn.filereadable(patch) == 0 then
    return
  end

  local lines = vim.fn.readfile(patch)
  local sources = { table.concat(lines, '\n') }
  for _, line in ipairs(lines) do
    local file = line:match('^%+%+%+ b/(.+)$')
    if file then
      local path = plugin.path .. '/' .. file
      if vim.fn.filereadable(path) == 0 then
        vim.notify('Plugin patch needs review: ' .. patch, vim.log.levels.WARN)
        return
      end
      sources[#sources + 1] = table.concat(vim.fn.readfile(path), '\n')
    end
  end

  local stamp = vim.fn.stdpath('state') .. '/plugin_patches/' .. plugin.spec.name
  local signature = vim.fn.sha256(table.concat(sources, '\0'))
  if vim.fn.filereadable(stamp) == 1 and vim.fn.readfile(stamp)[1] == signature then
    return
  end

  local function apply(...)
    local command = { 'git', '-C', plugin.path, 'apply' }
    vim.list_extend(command, { ... })
    command[#command + 1] = patch
    return vim.system(command, { text = true }):wait().code == 0
  end
  if apply('--check') then
    if not apply() then
      error('Could not apply plugin patch: ' .. patch)
    end
    return M.apply(plugin)
  end
  if not apply('--reverse', '--check') then
    vim.notify('Plugin patch needs review: ' .. patch, vim.log.levels.WARN)
    return
  end
  vim.fn.mkdir(vim.fs.dirname(stamp), 'p')
  vim.fn.writefile({ signature }, stamp)
end

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(args)
    if args.data.kind ~= 'delete' then
      M.apply(args.data)
    end
  end,
})

return M
