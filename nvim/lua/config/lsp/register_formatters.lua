local conform = require('conform')

-- Walk up from `start` looking for a project-relative path (e.g. a node_modules binary).
local function find_upwards(start, rel)
  local dir = start
  while dir do
    local candidate = dir .. '/' .. rel
    if vim.uv.fs_stat(candidate) then
      return candidate
    end
    local parent = vim.fs.dirname(dir)
    if parent == dir then
      return nil
    end
    dir = parent
  end
end

conform.setup({
  notify_on_error = true,
  format_on_save = function(bufnr)
    return {
      timeout_ms = 3000,
      lsp_fallback = true,
    }
  end,
  formatters_by_ft = {
    javascript = { 'oxfmt', 'prettier', stop_after_first = true },
    typescript = { 'oxfmt', 'prettier', stop_after_first = true },
    javascriptreact = { 'oxfmt', 'prettier', stop_after_first = true },
    typescriptreact = { 'oxfmt', 'prettier', stop_after_first = true },
    json = { 'prettier' },
    vue = { 'prettier', 'eslint' },
    lua = { 'stylua' },
    markdown = { 'markdownlint' },
    fish = { 'fish_indent' },
    sh = { 'shfmt' },
    go = { 'gofmt' },
    python = { 'ruff_organize_imports', 'ruff_fix', 'ruff_format', 'autopep8' },
    zig = { 'zigfmt' },
  },
  formatters = {
    oxfmt = {
      -- oxfmt ships as a project-local binary; fall back to a global one if present.
      command = function(_, ctx)
        return find_upwards(ctx.dirname, 'node_modules/.bin/oxfmt') or 'oxfmt'
      end,
      stdin = true,
      args = function(_, ctx)
        local args = { '--stdin-filepath', ctx.filename }
        -- Match `pnpm format`, which points oxfmt at the shared config in node_modules.
        local cfg = find_upwards(ctx.dirname, 'node_modules/@regask/standard-oxfmt-service/.oxfmtrc.json')
        if cfg then
          vim.list_extend(args, { '--config', cfg })
        end
        return args
      end,
      -- Only run when the project actually has oxfmt installed.
      condition = function(_, ctx)
        return find_upwards(ctx.dirname, 'node_modules/.bin/oxfmt') ~= nil
      end,
    },
    zigfmt = {
      command = 'zig',
      args = { 'fmt', '--stdin' },
      stdin = true,
    },
    ruff_fix = {
      command = 'ruff',
      args = { 'fix', '--stdin-filename', '$FILENAME', '-' },
      stdin = true,
    },
    ruff_format = {
      command = 'ruff',
      args = { 'format', '--stdin-filename', '$FILENAME', '-' },
      stdin = true,
    },
    autopep8 = {
      command = 'autopep8',
      args = { '--aggressive', '--aggressive', '-' },
      stdin = true,
    },
  },
})
