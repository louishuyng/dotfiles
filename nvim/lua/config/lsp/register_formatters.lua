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

-- fmtkit (brew cask, https://github.com/oullin/fmtkit) owns TS/Vue/Markdown
-- formatting in repos whose Makefile drives it. It has no config file, so the
-- only way to match it is to call it; unconfigured prettier rewrites those
-- files wholesale (tabs -> 2 spaces, single -> double quotes).
local fmtkit_extensions = { ts = true, tsx = true, mts = true, cts = true, js = true, jsx = true, vue = true, html = true, md = true }

local function is_fmtkit_project(dir)
  if vim.fn.executable('fmtkit') ~= 1 then
    return false
  end
  -- Package Makefiles shadow the root one, so check every Makefile up to /.
  for _, makefile in ipairs(vim.fs.find('Makefile', { upward = true, path = dir, limit = math.huge })) do
    if table.concat(vim.fn.readfile(makefile), '\n'):find('fmtkit', 1, true) then
      return true
    end
  end
  return false
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
    javascript = { 'oxfmt', 'fmtkit', 'prettier', stop_after_first = true },
    typescript = { 'oxfmt', 'fmtkit', 'prettier', stop_after_first = true },
    javascriptreact = { 'oxfmt', 'fmtkit', 'prettier', stop_after_first = true },
    typescriptreact = { 'oxfmt', 'fmtkit', 'prettier', stop_after_first = true },
    json = { 'prettier' },
    vue = { 'fmtkit', 'prettier', 'eslint' },
    lua = { 'stylua' },
    markdown = { 'fmtkit', 'prettier' },
    fish = { 'fish_indent' },
    sh = { 'shfmt' },
    go = { 'fmtkit_go', 'gofmt', stop_after_first = true },
    python = { 'ruff_organize_imports', 'ruff_fix', 'ruff_format', 'autopep8' },
    zig = { 'zigfmt' },
  },
  formatters = {
    fmtkit = {
      command = 'fmtkit',
      args = { 'ts', '$FILENAME' },
      stdin = false,
      condition = function(_, ctx)
        return is_fmtkit_project(ctx.dirname)
      end,
    },
    fmtkit_go = {
      command = 'fmtkit',
      args = { 'go', 'format', '$FILENAME' },
      stdin = false,
      condition = function(_, ctx)
        return is_fmtkit_project(ctx.dirname)
      end,
    },
    prettier = {
      -- Stay out of the way where fmtkit owns the file.
      condition = function(_, ctx)
        local ext = vim.fn.fnamemodify(ctx.filename, ':e')
        return not (fmtkit_extensions[ext] and is_fmtkit_project(ctx.dirname))
      end,
    },
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
