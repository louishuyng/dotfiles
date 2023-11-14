local nvim_notify = require("notify")

nvim_notify.setup({
  timeout = 5000,
  background_colour = "#1E1E1E",
  render = "minimal"
})

vim.notify = nvim_notify
