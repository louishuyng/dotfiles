return {
  {
    'akinsho/org-bullets.nvim',
    config = function()
      require('org-bullets').setup({
        concealcursor = false, -- If false then when the cursor is on a line underlying characters are visible
        symbols = {
          -- list symbol
          list = "•",
          -- headlines can be a list
          headlines = {"◉", "○", "✸", "✿"},
          -- or a function that receives the defaults and returns a list
          checkboxes = {done = {"✅", "OrgDone"}, todo = {"❌", "OrgTODO"}}
        }
      })
    end
  }, {'michaelb/sniprun', build = 'sh install.sh'}, {'nvim-orgmode/orgmode'}
}
