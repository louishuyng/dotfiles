local present, harpoon = pcall(require, "harpoon")

if not (present) then return end

harpoon:setup()

vim.keymap.set("n", ",mf", function() harpoon:list():append() end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "m{", function() harpoon:list():prev() end)
vim.keymap.set("n", "m}", function() harpoon:list():next() end)

harpoon:extend({
  UI_CREATE = function(cx)
    vim.keymap.set("n", "<C-v>",
                   function() harpoon.ui:select_menu_item({vsplit = true}) end,
                   {buffer = cx.bufnr})

    vim.keymap.set("n", "<C-s>",
                   function() harpoon.ui:select_menu_item({split = true}) end,
                   {buffer = cx.bufnr})

    vim.keymap.set("n", "<C-t>", function()
      harpoon.ui:select_menu_item({tabedit = true})
    end, {buffer = cx.bufnr})
  end
})
