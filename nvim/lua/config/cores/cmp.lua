local present, cmp = pcall(require, 'cmp')
local compare = require('cmp.config.compare')

local icons = require('config.libs.icons')

if not present then
  return
end

local LspKind = {}

LspKind.Completion = {
  Text = { text = 'Text', icon = '' },
  Method = { text = 'Method', icon = '' },
  Function = { text = 'Function', icon = '' },
  Constructor = { text = 'Constructor', icon = '' },
  Field = { text = 'Field', icon = '' },
  Variable = { text = 'Variable', icon = '' },
  Class = { text = 'Class', icon = '' },
  Interface = { text = 'Interface', icon = '' },
  Module = { text = 'Module', icon = '' },
  Property = { text = 'Property', icon = '' },
  Unit = { text = 'Unit', icon = 'ﱦ' },
  Value = { text = 'Value', icon = '' },
  Enum = { text = 'Enum', icon = '' },
  Keyword = { text = 'Keyword', icon = '' },
  Snippet = { text = 'Snippet', icon = '' },
  Color = { text = 'Color', icon = '' },
  File = { text = 'File', icon = '' },
  Reference = { text = 'Reference', icon = '' },
  Folder = { text = 'Folder', icon = '' },
  EnumMember = { text = 'EnumMember', icon = '' },
  Constant = { text = 'Constant', icon = '' },
  Struct = { text = 'Struct', icon = '' },
  Event = { text = 'Event', icon = 'ﯓ' },
  Operator = { text = 'Operator', icon = '' },
  TypeParameter = { text = 'TypeParameter', icon = '' },
}

vim.opt.completeopt = 'menuone,noselect'

cmp.setup {
  window = {
    completion = {
      winhighlight = 'Normal:Pmenu,CursorLine:PmenuSel,Search:None',
      border = { '┏', '━', '┓', '┃', '┛', '━', '┗', '┃' },
    },
    documentation = {
      border = { '┏', '━', '┓', '┃', '┛', '━', '┗', '┃' },
      winhighlight = 'Normal:Pmenu,CursorLine:PmenuSel,Search:None',
    },
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  formatting = {
    fields = { 'kind', 'abbr', 'menu' },
    format = function(entry, item)
      local kind = item.kind
      local kind_hl_group = ('CmpItemKind%s'):format(kind)

      item.kind_hl_group = ('%sIcon'):format(kind_hl_group)
      item.kind = (' %s '):format(LspKind.Completion[kind].icon)

      local source = entry.source.name
      if source == 'nvim_lsp' or source == 'path' then
        item.menu_hl_group = kind_hl_group
      else
        item.menu_hl_group = 'Comment'
      end
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
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),

    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'nvim_lua' },
    { name = 'async_path' },
  },
}

-- `/` cmdline setup.
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' },
  },
})

-- `:` cmdline setup.
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({ { name = 'path' } }, {
    { name = 'cmdline', option = { ignore_cmds = { 'Man', '!' } } },
  }),
})
