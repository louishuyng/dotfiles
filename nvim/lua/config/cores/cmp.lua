local present, cmp = pcall(require, 'cmp')
local compare = require('cmp.config.compare')
local defaults = require('cmp.config.default')()
local luasnip = require('luasnip')

-- for conciseness
local opt = vim.opt -- vim options

-- set options
opt.completeopt = 'menu,menuone,noselect'
if not present then
  return
end

local COMPLETION_KIND = {
  Text = true,
  Method = true,
  Function = true,
  Constructor = true,
  Field = true,
  Variable = true,
  Class = true,
  Interface = true,
  Module = true,
  Property = true,
  Unit = true,
  Value = true,
  Enum = true,
  Keyword = true,
  Snippet = true,
  Color = true,
  File = true,
  Reference = true,
  Folder = true,
  EnumMember = true,
  Constant = true,
  Struct = true,
  Event = true,
  Operator = true,
  TypeParameter = true,
}

cmp.setup {
  preselect = cmp.PreselectMode.Item,
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  formatting = {
    fields = { 'kind', 'abbr', 'menu' },
    format = function(entry, item)
      local icons = require('config.libs.icons').kinds
      local kind = item.kind
      local kind_hl_group = ('CmpItemKind%s'):format(kind)

      item.kind = (' %s '):format(icons[kind])

      local source = entry.source.name
      item.menu = kind

      if source == 'buffer' then
        item.menu_hl_group = nil
        item.menu = nil
      end

      local half_win_width = math.floor(vim.api.nvim_win_get_width(0) * 0.5)
      if vim.api.nvim_strwidth(item.abbr) > half_win_width then
        item.abbr = ('%s…'):format(item.abbr:sub(1, half_win_width))
      end

      if item.menu then -- Add exta space to visually differentiate `abbr` and `menu`
        item.abbr = ('%s '):format(item.abbr)
      end

      return item
    end,
  },
  mapping = {
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = false,
    }),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<C-j>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),

    ['<C-k>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-n>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-p>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
  },
  sources = cmp.config.sources({
    { name = 'lazydev' },
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  }, {
    { name = 'buffer' },
  }),
  sorting = defaults.sorting,
}

-- `/` cmdline setup with borders
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' },
  },
  window = {
    completion = {
      border = 'rounded',
      winhighlight = 'Normal:Pmenu,FloatBorder:PmenuBorder,CursorLine:PmenuSel,Search:None',
    },
  },
})

-- `:` cmdline setup.
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({ { name = 'path' } }, {
    { name = 'cmdline', option = { ignore_cmds = { 'Man', '!' } } },
  }),
  window = {
    completion = {
      border = 'rounded',
      winhighlight = 'Normal:Pmenu,FloatBorder:PmenuBorder,CursorLine:PmenuSel,Search:None',
    },
  },
})
