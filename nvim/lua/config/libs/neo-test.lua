vim.g['test#strategy'] = "vimux"

local present, neotest = pcall(require, "neotest")

if not (present) then return end

neotest.setup({
  log_level = vim.log.levels.WARN,
  -- discovery = {
  --   filter_dir = function(_, rel_path)
  --     return vim.startswith(rel_path, "tests")
  --   end,
  -- },
  --
  status = {virtual_text = true, signs = false},
  adapters = {require("neotest-rspec")},
  icons = {
    child_indent = "│",
    child_prefix = "├",
    collapsed = "─",
    expanded = "╮",
    failed = "✖",
    final_child_indent = " ",
    final_child_prefix = "╰",
    non_collapsible = "─",
    passed = "✔",
    running = "◐",
    running_animated = {"/", "|", "\\", "-", "/", "|", "\\", "-"},
    skipped = "ﰸ",
    unknown = "?"
  }
})

local mappings = {["<leader>np"] = neotest.summary.toggle}

for keys, mapping in pairs(mappings) do
  vim.api.nvim_set_keymap("n", keys, "", {callback = mapping, noremap = true})
end
