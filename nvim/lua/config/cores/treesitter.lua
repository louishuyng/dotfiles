local present, ts_config = pcall(require, "nvim-treesitter.configs")
if not present then return end

ts_config.setup {
  ensure_installed = {
    "go", "graphql", "javascript", "jsdoc", "http", "json", "jsonc", "lua",
    "python", "ruby", "rust", "tsx", "typescript", "svelte", "kotlin", "yaml",
    "html", "toml", "vim", "norg", "fish", "bash", "markdown", "terraform",
    "org", "smithy", "regex"
  },
  matchup = {enable = true},
  highlight = {
    enable = true,
    disable = {'org'}, -- Remove this to use TS highlighter for some of the highlights (Experimental),
    additional_vim_regex_highlighting = {'org'} -- Required since TS highlighter doesn't support all syntax features (conceal)
  },
  autotag = {enable = true},
  indent = {enable = true},
  context_commentstring = {enable = true}
}

local present2, treesitter_context = pcall(require, "treesitter-context")
if not present2 then return end

treesitter_context.setup {
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
  min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  line_numbers = true,
  multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
  trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
  -- Separator between context and content. Should be a single character string, like '-'.
  -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
  separator = nil,
  zindex = 20, -- The Z-index of the context window
  on_attach = nil -- (fun(buf: integer): boolean) return false to disable attaching
}
