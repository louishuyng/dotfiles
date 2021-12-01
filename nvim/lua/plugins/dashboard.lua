local g = vim.g

g.dashboard_custom_section = {
  a = {description = {"  Find File                 Ctrl p  "}, command = "Telescope find_files"},
  b = {description = {"  Recents                   SPC  h  "}, command = "Telescope oldfiles"},
  c = {description = {"  Find Word                 SPC  f  "}, command = "Telescope live_grep"},
  e = {description = {"  Projects                  SPC  p  "}, command = "Telescope marks"},
}
