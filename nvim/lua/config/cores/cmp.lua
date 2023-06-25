local present, cmp = pcall(require, "cmp")
local compare = require('cmp.config.compare')

if not present then return end

vim.opt.completeopt = "menuone,noselect"

local winhighlight = {
  winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel"
}

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and
             vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col)
                 :match("%s") == nil
end

local function t(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local source_names = {
  vsnip = "(Snippet)",
  nvim_lsp = "(LSP)",
  buffer = "(Buffer)",
  path = "(Path)"
}

cmp.setup {
  snippet = {
    expand = function(args) require("luasnip").lsp_expand(args.body) end
  },
  formatting = {
    format = function(entry, item)
      item.menu = source_names[entry.source.name] or
                      string.format("[%s]", entry.source.name)
      item.kind = string.format("%s %s",
                                require("config.libs.icons").kind[item.kind],
                                item.kind)

      return item
    end
  },
  mapping = {
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-d>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true
    },
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif require("luasnip").expand_or_jumpable() then
        vim.fn.feedkeys(t "<Plug>luasnip-expand-or-jump", "")
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, {"i", "s"}),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif require("luasnip").jumpable(-1) then
        vim.fn.feedkeys(t "<Plug>luasnip-jump-prev", "")
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, {"i", "s"})
  },
  sources = {
    {name = "nvim_lsp"}, {name = "luasnip"}, {name = "buffer"}, {name = "calc"},
    {name = 'orgmode'}
  }
}

-- `/` cmdline setup.
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {{name = 'buffer'}}
})

-- `:` cmdline setup.
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({{name = 'path'}}, {
    {name = 'cmdline', option = {ignore_cmds = {'Man', '!'}}}
  })
})
