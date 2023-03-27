local fn = vim.fn

local M = {}

local function color(highlight_group, content)
  return string.format('%%#%s#%s%%*', highlight_group, content)
end

M.modes = {
  ["n"] = {"NORMAL", "St_NormalMode"},
  ["niI"] = {"NORMAL i", "St_NormalMode"},
  ["niR"] = {"NORMAL r", "St_NormalMode"},
  ["niV"] = {"NORMAL v", "St_NormalMode"},
  ["no"] = {"N-PENDING", "St_NormalMode"},
  ["i"] = {"INSERT", "St_InsertMode"},
  ["ic"] = {"INSERT (completion)", "St_InsertMode"},
  ["ix"] = {"INSERT completion", "St_InsertMode"},
  ["t"] = {"TERMINAL", "St_TerminalMode"},
  ["v"] = {"VISUAL", "St_VisualMode"},
  ["V"] = {"V-LINE", "St_VisualMode"},
  ["Vs"] = {"V-LINE (Ctrl O)", "St_VisualMode"},
  [""] = {"V-BLOCK", "St_VisualMode"},
  ["R"] = {"REPLACE", "St_ReplaceMode"},
  ["Rv"] = {"V-REPLACE", "St_ReplaceMode"},
  ["s"] = {"SELECT", "St_SelectMode"},
  ["S"] = {"S-LINE", "St_SelectMode"},
  [""] = {"S-BLOCK", "St_SelectMode"},
  ["c"] = {"COMMAND", "St_CommandMode"},
  ["cv"] = {"COMMAND", "St_CommandMode"},
  ["ce"] = {"COMMAND", "St_CommandMode"},
  ["r"] = {"PROMPT", "St_ConfirmMode"},
  ["rm"] = {"MORE", "St_ConfirmMode"},
  ["r?"] = {"CONFIRM", "St_ConfirmMode"},
  ["x"] = {"CONFIRM", "St_ConfirmMode"},
  ["!"] = {"SHELL", "St_TerminalMode"}
}

M.mode = function()
  local m = vim.api.nvim_get_mode().mode
  return "%#" .. M.modes[m][2] .. "#" .. "▎"
end

local function icon()
  local file_name = vim.fn.expand '%:p:t'
  local extension = vim.fn.expand '%:e'

  local the_icon, highlight = require('nvim-web-devicons').get_icon(file_name,
                                                                    extension)

  if not the_icon and #file_name == 0 then
    -- Is in a folder
    the_icon = ""
    highlight = 'Accent'
  end

  return color(string.format('Statusline%s', highlight or 'Accent'),
               the_icon or '●')
end

M.fileInfo = function()
  local filename = (fn.expand "%" == "" and "Empty ") or fn.expand "%:t"

  return "%#StText# " .. icon() .. " " .. filename .. " "
end

M.gitchanges = function()
  if not vim.b.gitsigns_head or vim.b.gitsigns_git_status or vim.o.columns < 120 then
    return ""
  end

  local git_status = vim.b.gitsigns_status_dict

  local added = (git_status.added and git_status.added ~= 0) and
                    ("%#St_lspInfo#  " .. git_status.added .. "") or ""
  local changed = (git_status.changed and git_status.changed ~= 0) and
                      ("%#St_lspWarning#  " .. git_status.changed .. "") or
                      ""
  local removed = (git_status.removed and git_status.removed ~= 0) and
                      ("%#St_lspError#  " .. git_status.removed .. "") or ""

  return
      (added .. changed .. removed) ~= "" and (added .. changed .. removed) or
          ""
end

-- LSP STUFF
M.LSP_progress = function()
  if not rawget(vim, "lsp") then return "" end

  local Lsp = vim.lsp.util.get_progress_messages()[1]

  if vim.o.columns < 120 or not Lsp then return "" end

  local msg = Lsp.message or ""
  local percentage = Lsp.percentage or 0
  local title = Lsp.title or ""
  local spinners = {
    "", "󰪞", "󰪟", "󰪠", "󰪢", "󰪣", "󰪤", "󰪥"
  }
  local ms = vim.loop.hrtime() / 1000000
  local frame = math.floor(ms / 120) % #spinners
  local content = string.format(" %%<%s %s %s (%s%%%%) ", spinners[frame + 1],
                                title, msg, percentage)

  return ("%#St_LspProgress#" .. content) or ""
end

M.LSP_Diagnostics = function()
  if not rawget(vim, "lsp") then
    return "%#St_lspError#  0 %#St_lspWarning# 0"
  end

  local errors = #vim.diagnostic.get(0,
                                     {severity = vim.diagnostic.severity.ERROR})
  local warnings = #vim.diagnostic.get(0, {
    severity = vim.diagnostic.severity.WARN
  })
  local hints = #vim.diagnostic
                    .get(0, {severity = vim.diagnostic.severity.HINT})
  local info = #vim.diagnostic.get(0, {severity = vim.diagnostic.severity.INFO})

  errors =
      (errors and errors > 0) and ("%#St_lspError# " .. errors .. " ") or
          "%#St_lspError# 0 "
  warnings = (warnings and warnings > 0) and
                 ("%#St_lspWarning# " .. warnings .. " ") or
                 "%#St_lspWarning# 0 "
  hints = (hints and hints > 0) and ("%#St_lspHints#ﯧ " .. hints .. " ") or ""
  info = (info and info > 0) and ("%#St_lspInfo# " .. info .. " ") or ""

  return vim.o.columns > 140 and errors .. warnings .. hints .. info or ""
end

M.filetype = function()
  return vim.bo.ft == "" and "%#St_ft# {} plain text  " or "%#St_ft#{} " ..
             vim.bo.ft .. " "
end

M.LSP_status = function()
  if rawget(vim, "lsp") then
    for _, client in ipairs(vim.lsp.get_active_clients()) do
      if client.attached_buffers[vim.api.nvim_get_current_buf()] then
        return
            (vim.o.columns > 100 and "%#St_LspStatus#   " .. client.name ..
                "  ") or "   LSP  "
      end
    end
  end
end

M.cwd = function()
  local dir_name = "%#St_cwd#  " .. fn.fnamemodify(fn.getcwd(), ":t") .. " "
  return (vim.o.columns > 85 and dir_name) or ""
end

M.run = function()
  local modules = require "config.cores.statusline"

  return table.concat {
    modules.mode(), modules.fileInfo(), modules.gitchanges(), "%=",
    modules.LSP_progress(), "%=", modules.LSP_Diagnostics(),
    vim.o.columns > 140 and "%#StText# Ln %l, Col %c  " or "",
    string.upper(vim.bo.fileencoding) == "" and "" or "%#St_encode#" ..
        string.upper(vim.bo.fileencoding) .. "  ", modules.filetype(),
    modules.LSP_status() or "", modules.cwd()
  }
end

vim.opt.statusline = "%!v:lua.require('config.cores.statusline').run()"

return M