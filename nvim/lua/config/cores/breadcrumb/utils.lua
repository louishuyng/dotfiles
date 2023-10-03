local icons = require('config.libs.icons')

local M = {}

M.get_gps = function()
  local status_gps_ok, gps = pcall(require, "nvim-navic")
  if not status_gps_ok then return "" end

  local status_ok, gps_location = pcall(gps.get_location, {})
  if not status_ok then return "" end

  if not gps.is_available() or gps_location == "error" then return "" end

  if not M.isempty(gps_location) then
    return "%#NavicSeparator#" .. icons.ui.ChevronRight .. "%* " .. gps_location
  else
    return ""
  end
end

M.isempty = function(s) return s == nil or s == "" end

M.get_buf_option = function(opt)
  local status_ok, buf_option = pcall(vim.api.nvim_buf_get_option, 0, opt)
  if not status_ok then
    return nil
  else
    return buf_option
  end
end

M.get_filename = function()
  local filename = vim.fn.expand "%:t"
  local extension = vim.fn.expand "%:e"

  if not M.isempty(filename) then
    local file_icon, hl_group
    local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
    file_icon, hl_group = devicons.get_icon(filename, extension,
      { default = true })

    if M.isempty(file_icon) then file_icon = icons.File end

    local buf_ft = vim.bo.filetype

    if buf_ft == "dapui_breakpoints" then file_icon = icons.ui.Bug end

    if buf_ft == "dapui_stacks" then file_icon = icons.ui.Stacks end

    if buf_ft == "dapui_scopes" then file_icon = icons.ui.Scopes end

    if buf_ft == "dapui_watches" then file_icon = icons.ui.Watches end

    -- if buf_ft == "dapui_console" then
    --   file_icon = lvim.icons.ui.DebugConsole
    -- end

    local navic_text = vim.api.nvim_get_hl_by_name("Normal", true)
    vim.api.nvim_set_hl(0, "Winbar", { fg = navic_text.foreground })

    return " " .. "%#" .. hl_group .. "#" .. file_icon .. "%*" .. " " ..
        "%#Winbar#" .. filename .. "%*"
  end
end

M.excludes = function() return vim.tbl_contains({}, vim.bo.filetype) end

return M
