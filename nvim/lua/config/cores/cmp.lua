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

local tabnine = require('cmp_tabnine.config')

tabnine:setup({
  max_lines = 1000,
  max_num_results = 5,
  sort = true,
  run_on_every_keystroke = true,
  snippet_placeholder = '..',
  -- ignored_file_types = {lua = true},
  show_prediction_strength = true
})

cmp.setup {
  window = {
    completion = cmp.config.window.bordered(winhighlight),
    documentation = cmp.config.window.bordered(winhighlight)
  },
  snippet = {
    expand = function(args) require("luasnip").lsp_expand(args.body) end
  },
  formatting = {
    fields = {"kind", "abbr", "menu"},
    format = function(entry, vim_item)
      vim_item.kind = string.format("%s",
                                    require("config.libs.lspkind_icons").icons[vim_item.kind])
      if entry.source.name == 'cmp_tabnine' then vim_item.kind = '' end
      return vim_item
    end
  },
  mapping = {
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
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
    {name = "cmp_tabnine"}, {name = "nvim_lsp"}, {name = "luasnip"},
    {name = "buffer"}, {name = "calc"}, {name = 'orgmode'}
  },
  sorting = {
    priority_weight = 2,
    comparators = {
      require('cmp_tabnine.compare'), compare.offset, compare.exact,
      compare.score, compare.recently_used, compare.kind, compare.sort_text,
      compare.length, compare.order
    }
  }
}
