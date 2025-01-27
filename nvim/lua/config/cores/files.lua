require('mini.files').setup({
  mappings = {
    close = "q",
    -- Use this if you want to open several files
    go_in = "l",
    -- This opens the file, but quits out of mini.files (default L)
    go_in_plus = "L",
    -- I swapped the following 2 (default go_out: h)
    -- go_out_plus: when you go out, it shows you only 1 item to the right
    -- go_out: shows you all the items to the right
    go_out = "H",
    go_out_plus = "h",
    -- Default <BS>
    reset = "<BS>",
    -- Default @
    reveal_cwd = ".",
    show_help = "g?",
    -- Default =
    synchronize = "s",
    trim_left = "<",
    trim_right = ">",
    -- Below I created an autocmd with the "," keymap to open the highlighted
    -- directory in a tmux pane on the right
  },
  windows = {
    preview = true,
    width_focus = 30,
    width_preview = 80,
  },
  options = {
    use_as_default_explorer = true,
    permanent_delete = false,
  }
})

vim.keymap.set("n", "<leader>e", function()
  local buf_name = vim.api.nvim_buf_get_name(0)
  local dir_name = vim.fn.fnamemodify(buf_name, ":p:h")
  if vim.fn.filereadable(buf_name) == 1 then
    -- Pass the full file path to highlight the file
    require("mini.files").open(buf_name, true)
  elseif vim.fn.isdirectory(dir_name) == 1 then
    -- If the directory exists but the file doesn't, open the directory
    require("mini.files").open(dir_name, true)
  else
    -- If neither exists, fallback to the current working directory
    require("mini.files").open(vim.uv.cwd(), true)
  end
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>E", function()
  require("mini.files").open(vim.uv.cwd(), true)
end, { noremap = true, silent = true })
