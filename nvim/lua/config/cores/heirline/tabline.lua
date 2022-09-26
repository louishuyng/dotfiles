local utils = require("heirline.utils")

local FileIcon = {
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ":e")
    self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(
                                     filename, extension, {default = true})
  end,
  provider = function(self) return self.icon and (self.icon .. " ") end,
  hl = function(self) return {fg = self.icon_color} end
}

local TablineBufnr = {
  provider = function(self) return tostring(self.bufnr) .. ". " end,
  hl = "Comment"
}

local TablineFileName = {
  provider = function(self)
    local filename = self.filename
    filename = filename == "" and "[No Name]" or
                   vim.fn.fnamemodify(filename, ":t")
    return filename
  end,
  hl = function(self)
    return {bold = self.is_active or self.is_visible, italic = true}
  end
}

local TablineFileFlags = {
  {
    condition = function(self)
      return vim.api.nvim_buf_get_option(self.bufnr, "modified")
    end,
    provider = "[+]",
    hl = {fg = "green"}
  }, {
    condition = function(self)
      return not vim.api.nvim_buf_get_option(self.bufnr, "modifiable") or
                 vim.api.nvim_buf_get_option(self.bufnr, "readonly")
    end,
    provider = function(self)
      if vim.api.nvim_buf_get_option(self.bufnr, "buftype") == "terminal" then
        return "  "
      else
        return ""
      end
    end,
    hl = {fg = "orange"}
  }
  -- {
  --     condition = function(self)
  --         return not vim.api.nvim_buf_is_loaded(self.bufnr)
  --     end,
  --     -- a downright arrow
  --     provider = "", -- 
  --     hl = { fg = "gray" },
  -- },
}

local TablineFileNameBlock = {
  init = function(self) self.filename = vim.api.nvim_buf_get_name(self.bufnr) end,
  hl = function(self)
    if self.is_active then
      return "TabLineSel"
    elseif not vim.api.nvim_buf_is_loaded(self.bufnr) then
      return {fg = "gray"}
    else
      return "TabLine"
    end
  end,
  on_click = {
    callback = function(_, minwid) vim.api.nvim_win_set_buf(0, minwid) end,
    minwid = function(self) return self.bufnr end,
    name = "heirline_tabline_buffer_callback"
  },
  TablineBufnr,
  FileIcon,
  TablineFileName,
  TablineFileFlags
}

local TablineCloseButton = {
  condition = function(self)
    -- return not vim.bo[self.bufnr].modified
    return not vim.api.nvim_buf_get_option(self.bufnr, "modified")
  end,
  {provider = " "},
  {
    provider = " ",
    hl = {fg = "gray"},
    on_click = {
      callback = function(_, minwid)
        vim.api.nvim_buf_delete(minwid, {force = false})
      end,
      minwid = function(self) return self.bufnr end,
      name = "heirline_tabline_close_buffer_callback"
    }
  }
}

local TablineBufferBlock = utils.surround({" ", " "}, function(self)
  if self.is_active then
    return utils.get_highlight("TabLineSel").bg
  else
    return utils.get_highlight("TabLine").bg
  end
end, {TablineFileNameBlock, TablineCloseButton})

local BufferLine = utils.make_buflist(TablineBufferBlock,
                                      {provider = "", hl = {fg = "gray"}},
                                      {provider = "", hl = {fg = "gray"}})

local Tabpage = {
  provider = function(self)
    return "%" .. self.tabnr .. "T " .. self.tabnr .. " %T"
  end,
  hl = function(self)
    if not self.is_active then
      return "TabLine"
    else
      return "TabLineSel"
    end
  end
}

local TabpageClose = {provider = "%999X  %X", hl = "TabLine"}

local TabPages = {
  condition = function() return #vim.api.nvim_list_tabpages() >= 2 end,
  {provider = "%="},
  utils.make_tablist(Tabpage),
  TabpageClose
}

local TabLineOffset = {
  condition = function(self)
    local win = vim.api.nvim_tabpage_list_wins(0)[1]
    local bufnr = vim.api.nvim_win_get_buf(win)
    self.winid = win

    if vim.api.nvim_buf_get_option(bufnr, "filetype") == "NvimTree" then
      self.title = "NvimTree"
      return true
    end
  end,

  provider = function(self)
    local title = self.title
    local width = vim.api.nvim_win_get_width(self.winid)
    local pad = math.ceil((width - #title) / 2)
    return string.rep(" ", pad) .. title .. string.rep(" ", pad)
  end,

  hl = function(self)
    if vim.api.nvim_get_current_win() == self.winid then
      return "TablineSel"
    else
      return "Tabline"
    end
  end
}

local M = {}

M.TabLine = {
  -- update = {
  --     "BufNew",
  --     "BufDelete",
  --     "WinEnter",
  --     "BufEnter",
  --     "BufModifiedSet",
  --     callback = function()
  --         -- print("callback")
  --     end,
  -- },
  TabLineOffset, BufferLine, TabPages
}

return M
