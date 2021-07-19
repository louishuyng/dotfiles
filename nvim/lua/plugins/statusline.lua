-- if not package.loaded['galaxyline'] then
--   return
-- end
local status_ok, gl = pcall(require, "galaxyline")
if not status_ok then
  return
end

local colors = {
  fg = "#c8c9d1",
  bg = "#212121",
  alt_bg = "#2a2a2a",
  accent = "#383d45",
  white = "#c8c9d1",
  gray = "#858585",
  light_gray = "#c8c9c1",
  blue = "#5486c0",
  gray_blue = "#66899d",
  cyan = "#65a7c5",
  red = "#b04b57",
  green = "#87b379",
  light_green = "#b2d77c",
  yellow = "#eeba5a",
  orange = "#c6735a",
  purple = "#bf83c1",
  pale_purple = "#7199ee",
  magenta = "#D16D9E",
  cursor_fg = "#515052",
  cursor_bg = "#AEAFAD",
  sign_add = "#587c0c",
  sign_change = "#0c7d9d",
  sign_delete = "#94151b",
  error_red = "#F44747",
  warning_orange = "#ff8800",
  info_yellow = "#FFCC66",
  hint_blue = "#4FC1FF",
  purple_test = "#ff00ff",
  cyan_test = "#00ffff",
}

local condition = require "galaxyline.condition"
local gls = gl.section
gl.short_line_list = { "NvimTree", "vista", "dbui", "packer" }

table.insert(gls.left, {
  ViMode = {
    provider = function()
      -- auto change color according the vim mode
      local mode_color = {
        n = colors.blue,
        i = colors.green,
        v = colors.purple,
        [""] = colors.purple,
        V = colors.purple,
        c = colors.magenta,
        no = colors.blue,
        s = colors.orange,
        S = colors.orange,
        [""] = colors.orange,
        ic = colors.yellow,
        R = colors.red,
        Rv = colors.red,
        cv = colors.blue,
        ce = colors.blue,
        r = colors.cyan,
        rm = colors.cyan,
        ["r?"] = colors.cyan,
        ["!"] = colors.blue,
        t = colors.blue,
      }
      vim.api.nvim_command("hi GalaxyViMode guifg=" .. mode_color[vim.fn.mode()])
      return "  Losuis "
    end,
    separator_highlight = { "NONE", colors.alt_bg },
    highlight = { "NONE", colors.alt_bg },
  },
})
-- print(vim.fn.getbufvar(0, 'ts'))
vim.fn.getbufvar(0, "ts")

table.insert(gls.left, {
  GitIcon = {
    provider = function()
      return "  "
    end,
    condition = condition.check_git_workspace,
    separator = " ",
    separator_highlight = { "NONE", colors.alt_bg },
    highlight = { colors.orange, colors.alt_bg },
  },
})

table.insert(gls.left, {
  GitBranch = {
    provider = "GitBranch",
    condition = condition.check_git_workspace,
    separator = " ",
    separator_highlight = { "NONE", colors.alt_bg },
    highlight = { colors.grey, colors.alt_bg },
  },
})

table.insert(gls.left, {
  DiffAdd = {
    provider = "DiffAdd",
    condition = condition.hide_in_width,
    icon = "  ",
    highlight = { colors.green, colors.alt_bg },
  },
})

table.insert(gls.left, {
  DiffModified = {
    provider = "DiffModified",
    condition = condition.hide_in_width,
    icon = " 柳",
    highlight = { colors.blue, colors.alt_bg },
  },
})

table.insert(gls.left, {
  DiffRemove = {
    provider = "DiffRemove",
    condition = condition.hide_in_width,
    icon = "  ",
    highlight = { colors.red, colors.alt_bg },
  },
})

table.insert(gls.left, {
  Filler = {
    provider = function()
      return " "
    end,
    highlight = { colors.grey, colors.alt_bg },
  },
})
-- get output from shell command
function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, "r"))
  local s = assert(f:read "*a")
  f:close()
  if raw then
    return s
  end
  s = string.gsub(s, "^%s+", "")
  s = string.gsub(s, "%s+$", "")
  s = string.gsub(s, "[\n\r]+", " ")
  return s
end
-- cleanup virtual env
local function env_cleanup(venv)
  if string.find(venv, "/") then
    local final_venv = venv
    for w in venv:gmatch "([^/]+)" do
      final_venv = w
    end
    venv = final_venv
  end
  return venv
end
local PythonEnv = function()
  if vim.bo.filetype == "python" then
    local venv = os.getenv "CONDA_DEFAULT_ENV"
    if venv ~= nil then
      return "  (" .. env_cleanup(venv) .. ")"
    end
    venv = os.getenv "VIRTUAL_ENV"
    if venv ~= nil then
      return "  (" .. env_cleanup(venv) .. ")"
    end
    return ""
  end
  return ""
end
table.insert(gls.left, {
  VirtualEnv = {
    provider = PythonEnv,
    event = "BufEnter",
    highlight = { colors.green, colors.alt_bg },
  },
})

table.insert(gls.right, {
  DiagnosticError = {
    provider = "DiagnosticError",
    icon = "  ",
    highlight = { colors.red, colors.alt_bg },
  },
})
table.insert(gls.right, {
  DiagnosticWarn = {
    provider = "DiagnosticWarn",
    icon = "  ",
    highlight = { colors.orange, colors.alt_bg },
  },
})

table.insert(gls.right, {
  DiagnosticInfo = {
    provider = "DiagnosticInfo",
    icon = "  ",
    highlight = { colors.yellow, colors.alt_bg },
  },
})

table.insert(gls.right, {
  DiagnosticHint = {
    provider = "DiagnosticHint",
    icon = "  ",
    highlight = { colors.blue, colors.alt_bg },
  },
})

table.insert(gls.right, {
  TreesitterIcon = {
    provider = function()
      if next(vim.treesitter.highlighter.active) ~= nil then
        return "  "
      end
      return ""
    end,
    separator = " ",
    separator_highlight = { "NONE", colors.alt_bg },
    highlight = { colors.green, colors.alt_bg },
  },
})

local get_lsp_client = function(msg)
  msg = msg or "LSP"
  local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
  local clients = vim.lsp.get_active_clients()
  if next(clients) == nil then
    return msg
  end
  local lsps = ""
  for _, client in ipairs(clients) do
    local filetypes = client.config.filetypes
    if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
      -- print(client.name)
      if lsps == "" then
        -- print("first", lsps)
        lsps = client.name
      else
        if not string.find(lsps, client.name) then
          lsps = lsps .. ", " .. client.name
        end
        -- print("more", lsps)
      end
    end
  end
  if lsps == "" then
    return msg
  else
    return lsps
  end
end

table.insert(gls.right, {
  ShowLspClient = {
    provider = get_lsp_client,
    condition = function()
      local tbl = { ["dashboard"] = true, [" "] = true }
      if tbl[vim.bo.filetype] then
        return false
      end
      return true
    end,
    icon = "  ",
    highlight = { colors.grey, colors.alt_bg },
  },
})

table.insert(gls.right, {
  LineInfo = {
    provider = "LineColumn",
    separator = "  ",
    separator_highlight = { "NONE", colors.alt_bg },
    highlight = { colors.grey, colors.alt_bg },
  },
})

table.insert(gls.right, {
  PerCent = {
    provider = "LinePercent",
    separator = " ",
    separator_highlight = { "NONE", colors.alt_bg },
    highlight = { colors.grey, colors.alt_bg },
  },
})

table.insert(gls.right, {
  Tabstop = {
    provider = function()
      return "Spaces: " .. vim.api.nvim_buf_get_option(0, "shiftwidth") .. " "
    end,
    condition = condition.hide_in_width,
    separator = " ",
    separator_highlight = { "NONE", colors.alt_bg },
    highlight = { colors.grey, colors.alt_bg },
  },
})

table.insert(gls.right, {
  BufferType = {
    provider = "FileTypeName",
    condition = condition.hide_in_width,
    separator = " ",
    separator_highlight = { "NONE", colors.alt_bg },
    highlight = { colors.alt_bg, colors.alt_bg },
  },
})

table.insert(gls.right, {
  FileEncode = {
    provider = "FileEncode",
    condition = condition.hide_in_width,
    separator = " ",
    separator_highlight = { "NONE", colors.alt_bg },
    highlight = { colors.grey, colors.alt_bg },
  },
})

table.insert(gls.right, {
  Space = {
    provider = function()
      return " "
    end,
    separator = " ",
    separator_highlight = { "NONE", colors.alt_bg },
    highlight = { colors.grey, colors.alt_bg },
  },
})

table.insert(gls.short_line_left, {
  BufferType = {
    provider = "FileTypeName",
    separator = " ",
    separator_highlight = { "NONE", colors.alt_bg },
    highlight = { colors.alt_bg, colors.alt_bg },
  },
})

table.insert(gls.short_line_left, {
  SFileName = {
    provider = "SFileName",
    condition = condition.buffer_not_empty,
    highlight = { colors.alt_bg, colors.alt_bg },
  },
})

--table.insert(gls.short_line_right[1] = {BufferIcon = {provider = 'BufferIcon', highlight = {colors.grey, colors.alt_bg}}})
