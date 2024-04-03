local present, harpoon = pcall(require, "harpoon")

if not (present) then return end

harpoon:setup()

vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "m{", function() harpoon:list():prev() end)
vim.keymap.set("n", "m}", function() harpoon:list():next() end)


harpoon:extend({
  UI_CREATE = function(cx)
    vim.keymap.set("n", "v",
      function() harpoon.ui:select_menu_item({ vsplit = true }) end,
      { buffer = cx.bufnr })

    vim.keymap.set("n", "s",
      function() harpoon.ui:select_menu_item({ split = true }) end,
      { buffer = cx.bufnr })

    vim.keymap.set("n", "<C-t>", function()
      harpoon.ui:select_menu_item({ tabedit = true })
    end, { buffer = cx.bufnr })

    vim.keymap.set("n", "<C-j>", function()
      harpoon.ui:move(1)
    end, { buffer = cx.bufnr })

    vim.keymap.set("n", "<C-k>", function()
      harpoon.ui:move(-1)
    end, { buffer = cx.bufnr })
  end
})
