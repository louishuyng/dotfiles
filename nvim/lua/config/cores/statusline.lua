require('lualine').setup {
  options = {component_separators = '', section_separators = ''},
  sections = {
    lualine_c = {},
    lualine_x = {
      {
        function()
          local msg = 'No Active Lsp'
          local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
          local clients = vim.lsp.get_active_clients()
          if next(clients) == nil then return msg end
          for _, client in ipairs(clients) do
            local filetypes = client.config.filetypes
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
              return client.name
            end
          end
          return msg
        end,
        icon = "",
        color = {fg = '#C6CDD8'}
      }, {
        require("noice").api.status.command.get,
        cond = require("noice").api.status.command.has,
        color = {fg = "#ff9e64"}
      }, {
        require("noice").api.status.mode.get,
        cond = require("noice").api.status.mode.has,
        color = {fg = "#ff9e64"}
      }
    }
  }
}
