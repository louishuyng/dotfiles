require("codecompanion").setup({
  strategies = {
    -- CHAT STRATEGY ----------------------------------------------------------
    chat = {
      adapter = "copilot",
      roles = {
        llm = "  Copilot",
        user = "Louis",
      },
    },
    -- INLINE STRATEGY --------------------------------------------------------
    inline = {
      adapter = "copilot",
    },
    -- AGENT STRATEGY ---------------------------------------------------------
    agent = {
      adapter = "copilot",
    },
  },
})


vim.api.nvim_set_keymap("n", "<leader>a", ":CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<leader>a", ":CodeCompanion /buffer ", { noremap = true, silent = false })
vim.api.nvim_set_keymap("n", ",co", ":CodeCompanionToggle<cr>", { noremap = true, silent = true })
