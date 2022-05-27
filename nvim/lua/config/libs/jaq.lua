local present, jaq = pcall(require, "jaq-nvim")

if not (present) then return end

jaq.setup({
  cmds = {
    default = "float",
    external = {
      typescript = "deno run %",
      javascript = "node %",
      markdown = "glow %",
      python = "python3 %",
      rust = "rustc % && ./$fileBase && rm $fileBase",
      cpp = "g++ % -o $fileBase && ./$fileBase",
      ruby = "ruby %",
      go = "go run %",
      sh = "sh %"
    },
    internal = {lua = "luafile %", vim = "source %"}
  },

  -- UI settings
  ui = {
    -- Start in insert mode
    startinsert = false,

    -- Switch back to current file
    -- after using Jaq
    wincmd = false,

    -- Floating Window / FTerm settings
    float = {
      -- Floating window border (see ':h nvim_open_win')
      border = "none",

      -- Num from `0 - 1` for measurements
      height = 0.8,
      width = 0.8,
      x = 0.5,
      y = 0.5,

      -- Highlight group for floating window/border (see ':h winhl')
      border_hl = "FloatBorder",
      float_hl = "Normal",

      -- Floating Window Transparency (see ':h winblend')
      blend = 0
    },

    terminal = {
      -- Position of terminal
      position = "bot",

      -- Open the terminal without line numbers
      line_no = false,

      -- Size of terminal
      size = 10
    },

    toggleterm = {
      -- Position of terminal, one of "vertical" | "horizontal" | "window" | "float"
      position = "horizontal",

      -- Size of terminal
      size = 10
    },

    quickfix = {
      -- Position of quickfix window
      position = "bot",

      -- Size of quickfix window
      size = 10
    }
  }
})
