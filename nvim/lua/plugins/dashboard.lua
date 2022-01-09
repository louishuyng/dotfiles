local g = vim.g

g.dashboard_custom_section = {
  a = {description = {"  Find File                 Ctrl p  "}, command = "Telescope git_files layout_config={'width':0.7}"},
  b = {description = {"  Recents                   SPC  h  "}, command = "Telescope oldfiles previewer=false cwd_only=true"},
  c = {description = {"  Find Word                 SPC  f  "}, command = "Telescope live_grep layout_config={'width':0.7}"},
  e = {description = {"  Projects                  SPC  p  "}, command = "Telescope project"},
}
