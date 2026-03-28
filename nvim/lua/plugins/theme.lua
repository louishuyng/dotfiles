return {
  {
    'echasnovski/mini.base16',
    priority = 1000,
    lazy = false,
    config = function()
      local highlights = require('utils.highlights')
      require('mini.base16').setup { palette = highlights.palette }
      highlights.apply()
    end,
  },
}
