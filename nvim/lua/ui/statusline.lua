local heirline = require("heirline")
local conditions = require("heirline.conditions")
local utils = require("heirline.utils")

local colors = require("catppuccin.palettes").get_palette()

conditions.buffer_not_empty = function()
  return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
end

conditions.hide_in_width = function(size)
  return vim.api.nvim_get_option("columns") > (size or 140)
end

local Align = { provider = "%=", hl = { bg = colors.crust } }
local Space = { provider = " " }

local ViMode = {
  {
    init = function(self)
      self.mode = vim.api.nvim_get_mode().mode
      if not self.once then
        vim.api.nvim_create_autocmd("ModeChanged", {
          pattern = "*:*o",
          command = "redrawstatus"
        })
        self.once = true
      end
    end,
    static = {
      MODE_NAMES = {
        ["!"] = "SHELL",
        ["R"] = "REPLACE",
        ["Rc"] = "REPLACE",
        ["Rv"] = "V-REPLACE",
        ["Rvc"] = "V-REPLACE",
        ["Rvx"] = "V-REPLACE",
        ["Rx"] = "REPLACE",
        ["S"] = "S-LINE",
        ["V"] = "V-LINE",
        ["Vs"] = "V-LINE",
        ["\19"] = "S-BLOCK",
        ["\22"] = "V-BLOCK",
        ["\22s"] = "V-BLOCK",
        ["c"] = "COMMAND",
        ["ce"] = "EX",
        ["cv"] = "EX",
        ["i"] = "INSERT",
        ["ic"] = "INSERT",
        ["ix"] = "INSERT",
        ["n"] = "NORMAL",
        ["niI"] = "NORMAL",
        ["niR"] = "NORMAL",
        ["niV"] = "NORMAL",
        ["no"] = "O-PENDING",
        ["noV"] = "O-PENDING",
        ["no\22"] = "O-PENDING",
        ["nov"] = "O-PENDING",
        ["nt"] = "NORMAL",
        ["ntT"] = "NORMAL",
        ["r"] = "REPLACE",
        ["r?"] = "CONFIRM",
        ["rm"] = "MORE",
        ["s"] = "SELECT",
        ["t"] = "TERMINAL",
        ["v"] = "VISUAL",
        ["vs"] = "VISUAL"
      },
      MODE_COLORS = {
        [""] = colors.yellow,
        [""] = colors.yellow,
        ["s"] = colors.yellow,
        ["!"] = colors.maroon,
        ["R"] = colors.flamingo,
        ["Rc"] = colors.flamingo,
        ["Rv"] = colors.rosewater,
        ["Rx"] = colors.flamingo,
        ["S"] = colors.teal,
        ["V"] = colors.lavender,
        ["Vs"] = colors.lavender,
        ["c"] = colors.peach,
        ["ce"] = colors.peach,
        ["cv"] = colors.peach,
        ["i"] = colors.green,
        ["ic"] = colors.green,
        ["ix"] = colors.green,
        ["n"] = colors.blue,
        ["niI"] = colors.blue,
        ["niR"] = colors.blue,
        ["niV"] = colors.blue,
        ["no"] = colors.pink,
        ["no"] = colors.pink,
        ["noV"] = colors.pink,
        ["nov"] = colors.pink,
        ["nt"] = colors.red,
        ["null"] = colors.pink,
        ["r"] = colors.teal,
        ["r?"] = colors.maroon,
        ["rm"] = colors.sky,
        ["s"] = colors.teal,
        ["t"] = colors.red,
        ["v"] = colors.mauve,
        ["vs"] = colors.mauve
      }
    },
    provider = function(self)
      local mode = self.mode:sub(1, 1)
      return string.format("▌ %s ", self.MODE_NAMES[mode])
    end,
    hl = function(self)
      local mode = self.mode:sub(1, 1)
      return { fg = self.MODE_COLORS[mode], bg = colors.mantle, bold = true }
    end,
    update = { "ModeChanged" }
  }, { provider = "", hl = { bg = colors.crust, fg = colors.mantle } }
}

local FileIcon = {
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ":e")
    self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(
      vim.fn.fnamemodify(filename, ":t"),
      extension, { default = true })
  end,
  provider = function(self) return self.icon and (" %s "):format(self.icon) end,
  hl = function(self) return { fg = self.icon_color } end
}

local FileFlags = {
  {
    condition = function() return vim.bo.modified end,
    provider = " ● ",
    hl = { fg = colors.lavender }
  }, {
  condition = function() return not vim.bo.modifiable or vim.bo.readonly end,
  provider = "",
  hl = { fg = colors.red }
}
}

local FileNameModifer = {
  hl = function()
    if vim.bo.modified then
      return { fg = colors.text, bold = true, force = true }
    end
  end
}

local FileType = {
  provider = function() return (" %s "):format(vim.bo.filetype:upper()) end,
  hl = { bg = colors.crust, fg = colors.surface2 },
  condition = function()
    return conditions.buffer_not_empty() and conditions.hide_in_width()
  end
}

local FileSize = {
  provider = function()
    local suffix = { "b", "k", "M", "G", "T", "P", "E" }
    local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
    fsize = (fsize < 0 and 0) or fsize
    if fsize < 1024 then return " " .. fsize .. suffix[1] .. " " end
    local i = math.floor((math.log(fsize) / math.log(1024)))
    return (" %.2g%s "):format(fsize / math.pow(1024, i), suffix[i + 1])
  end,
  condition = function()
    return conditions.buffer_not_empty() and conditions.hide_in_width()
  end,
  hl = { bg = colors.crust, fg = colors.surface2 }
}

local Ruler = {
  provider = " %7(%l/%3L%):%2c %P ",
  condition = function()
    return conditions.buffer_not_empty() and conditions.hide_in_width()
  end,
  hl = { bg = colors.crust, fg = colors.surface2 }
}

local function table_contains(tbl, x)
  local found = false
  for _, v in pairs(tbl) do if v == x then found = true end end
  return found
end

local RestEnv = {
  provider = function()
    local icon = ""
    local env = _G._rest_nvim.env_file

    return (" %s %s "):format(icon, env)
  end,
  hl = { fg = "#428890", bg = colors.crust, bold = true },
  condition = function()
    return vim.bo.filetype == "http"
  end
}


local LSPActive = {
  condition = function()
    return conditions.hide_in_width(120) and conditions.lsp_attached()
  end,
  update = { "LspAttach", "LspDetach" },
  on_click = {
    callback = function()
      vim.defer_fn(function() vim.cmd("LspInfo") end, 100)
    end,
    name = "heirline_LSP"
  },
  provider = function()
    local names = {}
    for _, server in pairs(vim.lsp.get_active_clients()) do
      if server.name ~= "null-ls" and not table_contains(names, server.name) then
        table.insert(names, server.name)
      end
    end

    if #names == 0 then return "" end

    return (vim.g.emoji and " 🛰 %s " or "  %s "):format((table.concat(
      names, " ")))
  end,
  hl = { bg = colors.crust, fg = colors.subtext1, bold = true, italic = false }
}


local Git = {
  condition = conditions.is_git_repo,
  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
    self.has_changes =
        self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or
        self.status_dict.changed ~= 0
  end,
  hl = { bg = colors.mantle },
  { provider = "", hl = { bg = colors.crust, fg = colors.mantle } },
  {
    provider = function(self)
      return ("  %s "):format(self.status_dict.head == "" and "~" or
        self.status_dict.head)
    end,
    hl = { fg = colors.mauve }
  },
  {
    provider = function(self)
      local count = self.status_dict.added or 0
      return count > 0 and ("  %s"):format(count)
    end,
    hl = { fg = colors.green },
    condition = function()
      return conditions.buffer_not_empty() and conditions.hide_in_width()
    end
  },
  {
    provider = function(self)
      local count = self.status_dict.removed or 0
      return count > 0 and ("  %s"):format(count)
    end,
    hl = { fg = colors.red },
    condition = function()
      return conditions.buffer_not_empty() and conditions.hide_in_width()
    end
  },
  {
    provider = function(self)
      local count = self.status_dict.changed or 0
      return count > 0 and ("  %s"):format(count)
    end,
    hl = { fg = colors.peach },
    condition = function()
      return conditions.buffer_not_empty() and conditions.hide_in_width()
    end
  },
  Space
}

local FileFormat = {
  provider = function()
    local fmt = vim.bo.fileformat
    if fmt == "unix" then
      return " LF "
    elseif fmt == "mac" then
      return " CR "
    else
      return " CRLF "
    end
  end,
  hl = { bg = colors.crust, fg = colors.surface2 },
  condition = function()
    return conditions.buffer_not_empty() and conditions.hide_in_width()
  end
}

local FileEncoding = {
  provider = function()
    local enc = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc
    return (" %s "):format(enc:upper())
  end,
  condition = function()
    return conditions.buffer_not_empty() and conditions.hide_in_width()
  end,
  hl = { bg = colors.crust, fg = colors.surface2 }
}

local IndentSizes = {
  provider = function()
    local indent_type =
        vim.api.nvim_buf_get_option(0, "expandtab") and "Spaces" or "Tab Size"
    local indent_size = vim.api.nvim_buf_get_option(0, "tabstop")
    return (" %s: %s"):format(indent_type, indent_size)
  end,
  hl = { bg = colors.crust, fg = colors.surface2 },
  condition = function()
    return conditions.buffer_not_empty() and conditions.hide_in_width()
  end
}

heirline.setup({
  statusline = {
    ViMode, Git, Align, RestEnv, LSPActive, Ruler, FileType, FileSize,
    FileFormat, FileEncoding, IndentSizes
  }
})
