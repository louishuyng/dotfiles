local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
  return
end

local icons = {
  ui = {
    BigCircle = " ",
    BigUnfilledCircle = " ",
  }
}

local colors = require("leaf.colors").setup()

local theme = {
  normal = {
    a = { fg = colors.none, bg = colors.line },
    b = { fg = colors.none, bg = colors.line },
    c = { fg = colors.none, bg = colors.line },
  },
}

vim.api.nvim_set_hl(0, "SLGitIcon", { fg = colors.git, bg = colors.bg })
vim.api.nvim_set_hl(0, "SLBranchName", { fg = colors.branch_name, bg = colors.bg, bold = false })
vim.api.nvim_set_hl(0, "SLSeparator", { fg = colors.line, bg = colors.bg, bold = false })
vim.api.nvim_set_hl(0, "SLProgress", { fg = colors.blue, bg = colors.none })

local mode_color = {
  n = colors.blue,
  i = colors.green,
  v = colors.magenta,
  -- [""] = "#c586c0",
  V = colors.magenta,
  ["\22"] = "#c586c0",
  -- c = '#B5CEA8',
  -- c = '#D7BA7D',
  c = colors.yellow,
  no = colors.red,
  s = colors.orange,
  [""] = colors.orange,
  S = colors.orange,
  ic = colors.yellow,
  R = colors.red,
  Rv = colors.red,
  cv = colors.blue,
  ce = colors.red,
  r = colors.cyan,
  rm = colors.cyan,
  ["r?"] = colors.cyan,
  ["!"] = colors.red,
  t = colors.red,
}

local mode = {
  function()
    return "  " .. vim.fn.mode():upper() .. " "
  end,
  color = function()
    return { fg = colors.fg, bg = mode_color[vim.fn.mode()], gui = 'bold' }
  end,
  padding = 1,
}

local hide_in_width = function()
  return vim.fn.winwidth(0) > 80
end

local path = {
  'filename',
  path = 1
}

local diagnostics = {
  "diagnostics",
  sources = { "nvim_diagnostic" },
  sections = { "error", "warn" },
  symbols = { error = icons.ui.BigCircle, warn = icons.ui.BigCircle },
  colored = true,
  update_in_insert = false,
}

local progress = {
  "progress",
  fmt = function()
    return "%P / %L"
  end,
  color = function()
    return { bg = colors.line, fg = colors.branch_name }
  end,
  separator = { left = " ", right = "" },
}

lualine.setup {
  options = {
    globalstatus = true,
    icons_enabled = true,
    theme = theme,
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = { "alpha", "dashboard", "NvimTree", "packer", "Outline", "toggleterm", "TelescopePrompt" },
    always_divide_middle = true,
  },
  sections = {
    lualine_a = { mode, path, filetype },
    lualine_b = { diagnostics },
    lualine_c = { { cond = hide_in_width } },
    lualine_x = {},
    lualine_y = { progress },
    lualine_z = {},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = {},
}
-- Inserts a component in lualine_c at left section
-- local function ins_left(component)
--   table.insert(config.sections.lualine_c, component)
-- end
