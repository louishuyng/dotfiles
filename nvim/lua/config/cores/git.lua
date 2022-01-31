vim.g.gitgutter_sign_added = "▌"
vim.g.gitgutter_sign_modified = "▌"
vim.g.gitgutter_sign_removed = "▌"
vim.g.gitgutter_sign_removed_first_line = "▌"
vim.g.gitgutter_sign_removed_above_and_below = "▌"
vim.g.gitgutter_sign_modified_removed = "▌"

-- Git Messenger
vim.g.git_messenger_always_into_popup = true
vim.g.git_messenger_include_diff = "current"

-- Git Linker
local present, gitlinker = pcall(require, "gitlinker")
if not present then
  return
end

gitlinker.setup({})
