local conditions = require("heirline.conditions")
local utils = require("heirline.utils")

local ViMode = {
  init = function(self)
    self.mode = vim.fn.mode(1)
    if not self.once then vim.cmd("au ModeChanged *:*o redrawstatus") end
    self.once = true
  end,
  static = {
    mode_names = { -- change the strings if you like it vvvvverbose!
      n = "N",
      no = "N?",
      nov = "N?",
      noV = "N?",
      ["no\22"] = "N?",
      niI = "Ni",
      niR = "Nr",
      niV = "Nv",
      nt = "Nt",
      v = "V",
      vs = "Vs",
      V = "V_",
      Vs = "Vs",
      ["\22"] = "^V",
      ["\22s"] = "^V",
      s = "S",
      S = "S_",
      ["\19"] = "^S",
      i = "I",
      ic = "Ic",
      ix = "Ix",
      R = "R",
      Rc = "Rc",
      Rx = "Rx",
      Rv = "Rv",
      Rvc = "Rv",
      Rvx = "Rv",
      c = "C",
      cv = "Ex",
      r = "...",
      rm = "M",
      ["r?"] = "?",
      ["!"] = "!",
      t = "T"
    }
  },
  provider = function(self) return "%2(" .. self.mode_names[self.mode] .. "%)" end,
  hl = function(self)
    local color = self:mode_color()
    return {fg = color, bold = true}
  end,
  update = {"ModeChanged"}
}

local Ruler = {
  -- %l = current line number
  -- %L = number of lines in the buffer
  -- %c = column number
  -- %P = percentage through file of displayed window
  provider = "%7(%l/%3L%):%2c %P"
}

local ScrollBar = {
  provider = function()
    local current_line = vim.fn.line(".")
    local total_lines = vim.fn.line("$")
    local chars = {"█", "▇", "▆", "▅", "▄", "▃", "▂", "▁"}
    local line_ratio = current_line / total_lines
    local index = math.ceil(line_ratio * #chars)
    return "  " .. chars[index]
  end
}

local FileType = {
  provider = function() return string.upper(vim.bo.filetype) end,
  hl = "Type"
}

local FileEncoding = {
  provider = function()
    local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc -- :h 'enc'
    return enc ~= "utf-8" and enc:upper()
  end
}

local LSPActive = {
  condition = conditions.lsp_attached,
  update = {"LspAttach", "LspDetach", "WinEnter"},

  provider = " [LSP]",

  -- Or complicate things a bit and get the servers names
  -- provider  = function(self)
  --     local names = {}
  --     for i, server in pairs(vim.lsp.buf_get_clients(0)) do
  --         table.insert(names, server.name)
  --     end
  --     return " [" .. table.concat(names, " ") .. "]"
  -- end,
  hl = {fg = "green", bold = true},
  on_click = {
    name = "heirline_LSP",
    callback = function() vim.schedule(function() vim.cmd("LspInfo") end) end
  }
}

local Navic = {
  condition = require("nvim-navic").is_available,
  static = {
    type_hl = {
      File = "Directory",
      Module = "Include",
      Namespace = "TSNamespace",
      Package = "Include",
      Class = "Struct",
      Method = "Method",
      Property = "TSProperty",
      Field = "TSField",
      Constructor = "TSConstructor",
      Enum = "TSField",
      Interface = "Type",
      Function = "Function",
      Variable = "TSVariable",
      Constant = "Constant",
      String = "String",
      Number = "Number",
      Boolean = "Boolean",
      Array = "TSField",
      Object = "Type",
      Key = "TSKeyword",
      Null = "Comment",
      EnumMember = "TSField",
      Struct = "Struct",
      Event = "Keyword",
      Operator = "Operator",
      TypeParameter = "Type"
    }
  },
  init = function(self)
    local data = require("nvim-navic").get_data() or {}
    local children = {}
    for i, d in ipairs(data) do
      local child = {
        {provider = d.icon .. " ", hl = {fg = "green"}}, {
          provider = d.name
          -- hl = self.type_hl[d.type],
        }
      }
      if #data > 1 and i < #data then
        table.insert(child, {provider = " > ", hl = {fg = "statement"}})
      end
      table.insert(children, child)
    end
    self[1] = self:new(children, 1)
  end,
  hl = {fg = "white"}
}

local Diagnostics = {

  condition = conditions.has_diagnostics,
  update = {"DiagnosticChanged", "BufEnter"},
  on_click = {
    callback = function()
      require("trouble").toggle({mode = "document_diagnostics"})
    end,
    name = "heirline_diagnostics"
  },

  static = {
    error_icon = vim.fn.sign_getdefined("DiagnosticSignError")[1].text,
    warn_icon = vim.fn.sign_getdefined("DiagnosticSignWarn")[1].text,
    info_icon = vim.fn.sign_getdefined("DiagnosticSignInfo")[1].text,
    hint_icon = vim.fn.sign_getdefined("DiagnosticSignHint")[1].text
  },

  init = function(self)
    self.errors = #vim.diagnostic.get(0, {
      severity = vim.diagnostic.severity.ERROR
    })
    self.warnings = #vim.diagnostic.get(0, {
      severity = vim.diagnostic.severity.WARN
    })
    self.hints = #vim.diagnostic.get(0,
                                     {severity = vim.diagnostic.severity.HINT})
    self.info = #vim.diagnostic
                    .get(0, {severity = vim.diagnostic.severity.INFO})
  end,

  {
    provider = function(self)
      return self.errors > 0 and (self.error_icon .. self.errors .. " ")
    end,
    hl = "DiagnosticError"
  },
  {
    provider = function(self)
      return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
    end,
    hl = "DiagnosticWarn"
  },
  {
    provider = function(self)
      return self.info > 0 and (self.info_icon .. self.info .. " ")
    end,
    hl = "DiagnosticInfo"
  },
  {
    provider = function(self)
      return self.hints > 0 and (self.hint_icon .. self.hints)
    end,
    hl = "DiagnosticHint"
  }
}

local Git = {
  condition = conditions.is_git_repo,

  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
    self.has_changes =
        self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or
            self.status_dict.changed ~= 0
  end,

  on_click = {
    callback = function(self, minwid, nclicks, button)
      vim.defer_fn(function() vim.cmd("Lazygit %:p:h") end, 100)
    end,
    name = "heirline_git",
    update = false
  },

  hl = {fg = "statement", bold = true},

  {
    provider = function(self) return " " .. self.status_dict.head end,
    hl = {bold = true}
  },
  {condition = function(self) return self.has_changes end, provider = "("},
  {
    provider = function(self)
      local count = self.status_dict.added or 0
      return count > 0 and ("+" .. count)
    end,
    hl = "diffAdded"
  },
  {
    provider = function(self)
      local count = self.status_dict.removed or 0
      return count > 0 and ("-" .. count)
    end,
    hl = "diffDeleted"
  },
  {
    provider = function(self)
      local count = self.status_dict.changed or 0
      return count > 0 and ("~" .. count)
    end,
    hl = "diffChanged"
  },
  {condition = function(self) return self.has_changes end, provider = ")"}
}

local DAPMessages = {
  condition = function()
    local session = require("dap").session()
    return session ~= nil
  end,
  provider = function() return " " .. require("dap").status() .. " " end,
  hl = "Debug",
  {
    provider = "",
    on_click = {
      callback = function() require("dap").step_into() end,
      name = "heirline_dap_step_into"
    }
  },
  {provider = " "},
  {
    provider = "",
    on_click = {
      callback = function() require("dap").step_out() end,
      name = "heirline_dap_step_out"
    }
  },
  {provider = " "},
  {
    provider = " ",
    on_click = {
      callback = function() require("dap").step_over() end,
      name = "heirline_dap_step_over"
    }
  },
  {provider = " "},
  {
    provider = "ﰇ",
    on_click = {
      callback = function() require("dap").restart() end,
      name = "heirline_dap_restart"
    }
  },
  {provider = " "},
  {
    provider = "",
    on_click = {
      callback = function()
        require("dap").terminate()
        require("dapui").close({})
      end,
      name = "heirline_dap_close"
    }
  },
  {provider = " "}
  --       ﰇ  
}

local WorkDir = {
  provider = function(self)
    self.icon = (vim.fn.haslocaldir(0) == 1 and "l" or "g") .. " " .. " "
    local cwd = vim.fn.getcwd(0)
    self.cwd = vim.fn.fnamemodify(cwd, ":t")
    if not conditions.width_percent_below(#self.cwd, 0.27) then
      self.cwd = vim.fn.pathshorten(self.cwd)
    end
  end,
  hl = {fg = "blue", bold = true},
  on_click = {
    callback = function() vim.cmd("NvimTreeToggle") end,
    name = "heirline_workdir"
  },
  {
    flexible = 1,
    {
      provider = function(self)
        local trail = self.cwd:sub(-1) == "/" and "" or "/"
        return self.icon .. self.cwd .. trail .. " "
      end
    },
    {
      provider = function(self)
        local cwd = vim.fn.pathshorten(self.cwd)
        local trail = self.cwd:sub(-1) == "/" and "" or "/"
        return self.icon .. cwd .. trail .. " "
      end
    },
    {provider = ""}
  }
}

local HelpFilename = {
  condition = function() return vim.bo.filetype == "help" end,
  provider = function()
    local filename = vim.api.nvim_buf_get_name(0)
    return vim.fn.fnamemodify(filename, ":t")
  end,
  hl = "Directory"
}

local Spell = {
  condition = function() return vim.wo.spell end,
  provider = "SPELL ",
  hl = {bold = true, fg = "white"}
}

ViMode = utils.surround({"", ""}, "bg", {ViMode})

local Align = {provider = "%="}
local Space = {provider = " "}

local NavicFlexible = {flexible = 3, Navic, {provider = ""}}

local SpaceFileFlexible = {flexible = 3, Space, FileEncoding, {provider = ""}}
local DefaultStatusline = {
  ViMode, Space, Spell, WorkDir, {provider = "%<"}, Space, Git, Space,
  Diagnostics, Align, NavicFlexible, Align, DAPMessages, LSPActive, Space, -- UltTest,
  Space, FileType, SpaceFileFlexible, Space, Ruler, Space, ScrollBar
  -- {
  --     provider = function()
  --         return vim.inspect(utils.get_highlight('StatusLine'))
  --     end
  -- }
}

local InactiveStatusline = {
  condition = conditions.is_not_active,
  {hl = {fg = "gray", force = true}, WorkDir},
  {provider = "%<"},
  Align
}

local SpecialStatusline = {
  condition = function()
    return conditions.buffer_matches({
      buftype = {"nofile", "prompt", "help", "quickfix"},
      filetype = {"^git.*", "fugitive"}
    })
  end,
  FileType,
  {provider = "%q"},
  Space,
  HelpFilename,
  Align
}

local GitStatusline = {
  condition = function()
    return conditions.buffer_matches({filetype = {"^git.*", "fugitive"}})
  end,
  FileType,
  Space,
  {provider = function() return vim.fn.FugitiveStatusline() end},
  Space,
  Align
}

local M = {}

M.StatusLines = {
  hl = {bg = "bg"},
  static = {
    mode_colors = {
      n = "red",
      i = "green",
      v = "special",
      V = "special",
      ["\22"] = "special", -- this is an actual ^V, type <C-v><C-v> in insert mode
      c = "constant",
      s = "statement",
      S = "statement",
      ["\19"] = "statement", -- this is an actual ^S, type <C-v><C-s> in insert mode
      R = "constant",
      r = "constant",
      ["!"] = "red",
      t = "green"
    },
    mode_color = function(self)
      local mode = conditions.is_active() and vim.fn.mode() or "n"
      return self.mode_colors[mode]
    end
  },

  -- init = utils.pick_child_on_condition,
  fallthrough = false,

  GitStatusline,
  SpecialStatusline,
  InactiveStatusline,
  DefaultStatusline
}

return M
