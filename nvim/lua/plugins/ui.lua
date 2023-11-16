return {
  {'sainnhe/edge'},
  {'nvim-tree/nvim-web-devicons'},
  {'goolord/alpha-nvim'},
  {'nvim-lualine/lualine.nvim'}, 
  {'rcarriga/nvim-notify'},
  {
    'b0o/incline.nvim',
    event = "BufReadPre",
    priority = 1200,
    opts = {},
    config = function()
      require("incline").setup({
        highlight = {
          groups = {
            InclineNormal = {guibg = "#1E1E1E", guifg = "#A8C888"},
            InclineNormalNC = {guibg = "#1E1E1E"}
          }
        },
        window = {margin = {vertical = 0, horizontal = 1}},
        hide = {cursorline = true},
        render = function(props)
          local filename = vim.fn.fnamemodify(
                               vim.api.nvim_buf_get_name(props.buf), ":t")
          if vim.bo[props.buf].modified then
            filename = "[+] " .. filename
          end

          local icon, color = require("nvim-web-devicons").get_icon_color(
                                  filename)
          return {{icon, guifg = color}, {" "}, {filename}}
        end
      })
    end
  }
}
