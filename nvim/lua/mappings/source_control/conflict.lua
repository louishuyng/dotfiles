local opts = { silent = true }

-- Choose current changes
vim.keymap.set("n", "<leader>ch", ":diffget //2<CR>", opts)

-- Choose incoming changes
vim.keymap.set("n", "<leader>ci", ":diffget //3<CR>", opts)

-- Opening merge tool
-- Notes: When open merge tool, we need to stop LSP
local open_merge_tool = function()
  vim.cmd("Gvdiffsplit!")
  vim.cmd("LspStop")
end
vim.keymap.set("n", "gmo", open_merge_tool, opts)

-- Focus on current file
local focus_on_current_file = function()
  vim.cmd("silent! only!")
  vim.cmd("LspStart")
end
vim.keymap.set("n", "gmf", focus_on_current_file, opts)

-- Completed Merge and stage a file
-- Notes: When finish merge, we need to reactive LSP
local completed_merge = function()
  vim.cmd("silent! only!")
  vim.cmd("silent! Gitsigns stage_buffer")
  vim.cmd("LspStart")
end

vim.keymap.set("n", "gmc", completed_merge, opts)

-- Navigate to next/previous conflict
local jump_to_next_conflict = function() vim.cmd("/<<<<<<<") end
vim.keymap.set("n", "]x", jump_to_next_conflict, opts)

local jump_to_previous_conflict = function() vim.cmd("silent! ?<<<<<<<") end
vim.keymap.set("n", "[x", jump_to_previous_conflict, opts)
