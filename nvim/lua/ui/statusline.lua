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

local colors = {
  fg = "#21252a",
  white = "#abb2bf",
  bg = "#2E323B",
  black = "#5c6370",
  blue = "#7AA2F7",
  cyan = "#56b6c2",
  green = "#98C379",
  magenta = "#c678dd",
  red = "#e06c75",
  yellow = "#e5c07b",
  dark_yellow = "#D7BA7D",
  insertgreen = "#6a9955",
  light_green = "#B5CEA8",
  string_orange = "#CE9178",
  orange = "#FF8800",
  purple = "#C586C0",
  grey = "#858585",
  vivid_blue = "#4FC1FF",
  light_blue = "#9CDCFE",
  error_red = "#F44747",
  info_yellow = "#FFCC66",
  statusline_bg = "#22262e",
  lightbg = "#21242B",
  git = "#FF8800",
  lightbg2 = "#24272F",
  violet = "#8A2BE2",
  darkblue = "#00008B",
  warnyelow = "#FFA500",
  newyellow = "#E5C07B",
  infoblue = "#56B6C2",
  sintaxviolet = "#BA99F6",
  newlighbg = "#5B6477",
  newpurple = "#C678DD",
  replacecolor = "#E06C75",
  status_text = "#4e545f",
  branch_name = "#5c6370",
  branch_cover = "#21252a",
  line = "#242634",
  none = "none",
}

local onedark_theme = {
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
    return "LouisDEV"
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
  path = 4
}

local diagnostics = {
  "diagnostics",
  sources = { "nvim_diagnostic" },
  sections = { "error", "warn" },
  symbols = { error = icons.ui.BigCircle, warn = icons.ui.BigCircle },
  colored = true,
  update_in_insert = false,
}

local filetype = {
  "filetype",
  icons_enabled = true,
  color = { bg = colors.line, fg = colors.branch_name },
}

local progress = {
  "progress",
  fmt = function()
    -- Porcentaje / No. Lineas
    return "%P"
  end,
  color = function()
    return { bg = colors.line, fg = colors.branch_name }
  end,
  separator = { left = " ", right = "" },
}

local spaces = {
  function()
    return "Spaces " .. vim.api.nvim_buf_get_option(0, "shiftwidth")
  end,
  color = { fg = colors.branch_name, bg = colors.line },
}

local location = {
  "location",
  color = function()
    return { fg = colors.line, bg = mode_color[vim.fn.mode()] }
  end,
}

local function get_attached_clients()
  local buf_clients = vim.lsp.get_active_clients({ bufnr = 0 })
  if #buf_clients == 0 then
    return "LSP Inactive"
  end

  local buf_ft = vim.bo.filetype
  local buf_client_names = {}

  -- add client
  for _, client in pairs(buf_clients) do
    if client.name ~= "copilot" and client.name ~= "null-ls" then
      table.insert(buf_client_names, client.name)
    end
  end

  -- Generally, you should use either null-ls or nvim-lint + formatter.nvim, not both.

  -- Add sources (from null-ls)
  -- null-ls registers each source as a separate attached client, so we need to filter for unique names down below.
  local null_ls_s, null_ls = pcall(require, "null-ls")
  if null_ls_s then
    local sources = null_ls.get_sources()
    for _, source in ipairs(sources) do
      if source._validated then
        for ft_name, ft_active in pairs(source.filetypes) do
          if ft_name == buf_ft and ft_active then
            table.insert(buf_client_names, source.name)
          end
        end
      end
    end
  end

  -- Add linters (from nvim-lint)
  local lint_s, lint = pcall(require, "lint")
  if lint_s then
    for ft_k, ft_v in pairs(lint.linters_by_ft) do
      if type(ft_v) == "table" then
        for _, linter in ipairs(ft_v) do
          if buf_ft == ft_k then
            table.insert(buf_client_names, linter)
          end
        end
      elseif type(ft_v) == "string" then
        if buf_ft == ft_k then
          table.insert(buf_client_names, ft_v)
        end
      end
    end
  end

  -- Add formatters (from formatter.nvim)
  local formatter_s, _ = pcall(require, "formatter")
  if formatter_s then
    local formatter_util = require("formatter.util")
    for _, formatter in ipairs(formatter_util.get_available_formatters_for_ft(buf_ft)) do
      if formatter then
        table.insert(buf_client_names, formatter)
      end
    end
  end

  -- This needs to be a string only table so we can use concat below
  local unique_client_names = {}
  for _, client_name_target in ipairs(buf_client_names) do
    local is_duplicate = false
    for _, client_name_compare in ipairs(unique_client_names) do
      if client_name_target == client_name_compare then
        is_duplicate = true
      end
    end
    if not is_duplicate then
      table.insert(unique_client_names, client_name_target)
    end
  end

  local client_names_str = table.concat(unique_client_names, ", ")
  local language_servers = string.format("[%s]", client_names_str)

  return language_servers
end

local attached_clients = {
  get_attached_clients,
  color = {
    fg = colors.branch_name,
    bg = colors.line,
  }
}

lualine.setup {
  options = {
    globalstatus = true,
    icons_enabled = true,
    theme = onedark_theme,
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = { "alpha", "dashboard", "NvimTree", "packer", "Outline", "toggleterm", "TelescopePrompt" },
    always_divide_middle = true,
  },
  sections = {
    lualine_a = { mode, path },
    lualine_b = { diagnostics },
    lualine_c = { { cond = hide_in_width } },
    lualine_x = { attached_clients, spaces, filetype },
    lualine_y = { progress },
    lualine_z = { location },
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
