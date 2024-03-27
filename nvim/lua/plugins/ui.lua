return {
  { 'goolord/alpha-nvim' },
  { 'nvim-tree/nvim-web-devicons' },
  { 'rebelot/heirline.nvim' },
  {
    "b0o/incline.nvim",
    event = "BufReadPre",
    priority = 1200,
    config = function()
      require("incline").setup({
        window = {
          margin = { vertical = 0, horizontal = 1 },
        },
        render = function(props)
          local function get_diagnostic_label()
            local icons = { Error = "E", Warn = "W", Hint = "H", Info = "I" }
            local label = {}

            for severity, icon in pairs(icons) do
              local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
              if n > 0 then
                table.insert(label, { icon .. n .. ' ', group = 'DiagnosticSign' .. severity })
              end
            end
            if #label > 0 then
              table.insert(label, { '┊ ' })
            end
            return label
          end

          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if vim.bo[props.buf].modified then
            filename = "[+] " .. filename
          end

          return {
            { get_diagnostic_label() },
            { filename } }
        end
      })
    end,
  },
}
