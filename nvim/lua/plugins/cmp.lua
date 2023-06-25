return {
  {"rafamadriz/friendly-snippets", event = "InsertEnter"}, {
    "hrsh7th/nvim-cmp",
    dependencies = {"friendly-snippets"},
    config = function() require "config.cores.cmp" end
  }, {
    "L3MON4D3/LuaSnip",
    dependencies = {"nvim-cmp", "friendly-snippets"},
    config = function() require("config.libs.others").luasnip() end
  }, {"saadparwaiz1/cmp_luasnip", dependencies = {"LuaSnip"}},
  {"hrsh7th/cmp-calc", dependencies = {"nvim-cmp"}}, {"hrsh7th/cmp-nvim-lsp"},
  {"hrsh7th/cmp-buffer", dependencies = {"nvim-cmp"}}, {
    "github/copilot.vim",
    event = "VeryLazy",
    build = "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash",
    config = function()
      vim.g.copilot_filetypes = {
        ["chatgpt"] = false,
        ["python"] = true,
        ["lua"] = true,
        ["rust"] = true,
        ["clojure"] = true,
        ["R"] = true,
        ["nu"] = true,
        ["ruby"] = true,
        ["javascript"] = true,
        ["typescript"] = true,
        ["go"] = true,
        ["markdown"] = true,
        ["*"] = false
      }
    end
  }, {"hrsh7th/cmp-cmdline", dependencies = {'nvim-cmp'}}
}
