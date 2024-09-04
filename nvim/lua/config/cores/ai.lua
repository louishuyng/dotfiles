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


vim.keymap.set("n", "<LocalLeader>ct", ":CodeCompanionToggle<CR>", { desc = "Toggle Code Companion" })
