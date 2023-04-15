local status_ok, navic = pcall(require, "nvim-navic")
local icons = require('config.libs.icons')
local utils = require('config.cores.breadcrumb.utils')

if not status_ok then return end

local options = {
  icons = {
    Array = icons.kind.Array .. " ",
    Boolean = icons.kind.Boolean,
    Class = icons.kind.Class .. " ",
    Color = icons.kind.Color .. " ",
    Constant = icons.kind.Constant .. " ",
    Constructor = icons.kind.Constructor .. " ",
    Enum = icons.kind.Enum .. " ",
    EnumMember = icons.kind.EnumMember .. " ",
    Event = icons.kind.Event .. " ",
    Field = icons.kind.Field .. " ",
    File = icons.kind.File .. " ",
    Folder = icons.kind.Folder .. " ",
    Function = icons.kind.Function .. " ",
    Interface = icons.kind.Interface .. " ",
    Key = icons.kind.Key .. " ",
    Keyword = icons.kind.Keyword .. " ",
    Method = icons.kind.Method .. " ",
    Module = icons.kind.Module .. " ",
    Namespace = icons.kind.Namespace .. " ",
    Null = icons.kind.Null .. " ",
    Number = icons.kind.Number .. " ",
    Object = icons.kind.Object .. " ",
    Operator = icons.kind.Operator .. " ",
    Package = icons.kind.Package .. " ",
    Property = icons.kind.Property .. " ",
    Reference = icons.kind.Reference .. " ",
    Snippet = icons.kind.Snippet .. " ",
    String = icons.kind.String .. " ",
    Struct = icons.kind.Struct .. " ",
    Text = icons.kind.Text .. " ",
    TypeParameter = icons.kind.TypeParameter .. " ",
    Unit = icons.kind.Unit .. " ",
    Value = icons.kind.Value .. " ",
    Variable = icons.kind.Variable .. " "
  },
  highlight = true,
  separator = " " .. icons.ui.ChevronRight .. " ",
  depth_limit = 0,
  depth_limit_indicator = ".."
}

navic.setup(options)

local get_winbar = function()
  if utils.excludes() then return end

  local value = utils.get_filename()

  local gps_added = false
  if not utils.isempty(value) then
    local gps_value = utils.get_gps()
    value = value .. " " .. gps_value
    if not utils.isempty(gps_value) then gps_added = true end
  end

  if not utils.isempty(value) and utils.get_buf_option "mod" then
    local mod = "%#LspCodeLens#" .. icons.ui.Circle .. "%*"
    if gps_added then
      value = value .. " " .. mod
    else
      value = value .. mod
    end
  end

  local num_tabs = #vim.api.nvim_list_tabpages()

  if num_tabs > 1 and not utils.isempty(value) then
    local tabpage_number = tostring(vim.api.nvim_tabpage_get_number(0))
    value = value .. "%=" .. tabpage_number .. "/" .. tostring(num_tabs)
  end

  local status_ok, _ = pcall(vim.api.nvim_set_option_value, "winbar", value,
                             {scope = "local"})
  if not status_ok then return end
end

vim.api.nvim_create_augroup("_winbar", {})
vim.api.nvim_create_autocmd({
  "CursorHoldI", "CursorHold", "BufWinEnter", "BufFilePost", "InsertEnter",
  "BufWritePost", "TabClosed", "TabEnter"
}, {
  group = "_winbar",
  callback = function()
    local status_ok, _ = pcall(vim.api.nvim_buf_get_var, 0,
                               "lsp_floating_window")
    if not status_ok then get_winbar() end
  end
})
