local present, cmp = pcall(require, "cmp")
local neogen = require 'neogen'

if not present then
   return
end

vim.opt.completeopt = "menuone,noselect"

-- nvim-cmp setup
cmp.setup {
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  formatting = {
    format = function(entry, vim_item)
      vim_item.kind = string.format(
        "%s %s",
        require("plugins.lspkind_icons").icons[vim_item.kind],
        vim_item.kind
      )

      vim_item.menu = ({
        nvim_lsp = "[LSP]",
        nvim_lua = "[Lua]",
        buffer = "[BUF]",
      })[entry.source.name]

      return vim_item
    end,
  },
  mapping = {
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-d>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping.confirm {
       behavior = cmp.ConfirmBehavior.Replace,
       select = true,
    },
    ["<Tab>"] = function(fallback)
       if cmp.visible() then
          cmp.select_next_item()
       elseif neogen.jumpable() then
          vim.fn.feedkeys(t("<cmd>lua require('neogen').jump_next()<CR>"), "")
       elseif require("luasnip").expand_or_jumpable() then
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
       else
          fallback()
       end
    end,
    ["<S-Tab>"] = function(fallback)
       if cmp.visible() then
          cmp.select_prev_item()
       elseif require("luasnip").jumpable(-1) then
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
       else
          fallback()
       end
    end,
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "nvim_lua" },
  },
}
