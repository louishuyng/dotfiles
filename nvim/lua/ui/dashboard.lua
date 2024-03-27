local present, alpha = pcall(require, "alpha")

if not present then return end

local theme = require("alpha.themes.theta")
local dashboard = require("alpha.themes.dashboard")

-- HEADER SECTION
local ascii = {
  [[0   ______   ______   ______   ______   ]],
  [[x  /\  == \ /\  __ \ /\  __ \ /\__  _\  ]],
  [[5  \ \  __< \ \ \/\ \\ \ \/\ \\/_/\ \/  ]],
  [[8   \ \_\ \_\\ \_____\\ \_____\  \ \_\  ]],
  [[4    \/_/ /_/ \/_____/ \/_____/   \/_/  ]], [[]]
}

local header = {
  type = 'text',
  val = ascii,
  opts = { position = "center", hl_shortcut = 'AlphaHeader', hl = 'AlphaHeader' }
}

-- INFO SECTION
local function get_info()
  local lazy_stats = require("lazy").stats()
  local total_plugins = lazy_stats.loaded .. "/" .. lazy_stats.count .. " packages"
  local version = vim.version()
  local nvim_version_info = "ⓥ " .. version.major .. "." .. version.minor ..
      "." .. version.patch

  local info_string = total_plugins .. "  |  " .. nvim_version_info

  return {
    type = "text",
    val = info_string,
    opts = { hl = "Delimiter", position = "center" }
  }
end

-- LINK SECTION
local links = {
  type = "group",
  val = {
    {
      type = "text",
      val = "Tools",
      opts = { hl = "SpecialComment", position = "center" }
    }, dashboard.button("l", "💤 Lazy", "<cmd>Lazy<CR>"),
    dashboard.button("m", "🧱 Mason", "<cmd>Mason<CR>")
  },
  position = "center"
}

-- RECENT FILES SECTION
local mru = {
  type = 'group',
  val = {
    {
      type = 'text',
      val = 'Recent files',
      opts = { hl = 'SpecialComment', position = 'center' }
    }, { type = 'padding', val = 1 }, {
    type = 'group',
    val = function() return { theme.mru(1, vim.fn.getcwd(), 10) } end
  }
  }
}
theme.config.layout = {
  { type = "padding", val = 12 }, header, { type = "padding", val = 2 }, get_info(),
  { type = "padding", val = 2 }, links, { type = "padding", val = 2 }, mru,
  { type = "padding", val = 2 }
}

alpha.setup(theme.config)

-- autocommands to turn off bars
local alpha_group = vim.api.nvim_create_augroup("alpha", { clear = true })
vim.api.nvim_create_autocmd("User", {
  group = alpha_group,
  pattern = "AlphaReady",
  command = "set laststatus=0 | set showtabline=0"
})

vim.api.nvim_create_autocmd("User", {
  group = alpha_group,
  pattern = "AlphaClosed",
  command = "set laststatus=3 | set showtabline=1"
})
