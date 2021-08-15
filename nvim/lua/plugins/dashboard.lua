local g = vim.g

g.dashboard_custom_header = {
":::::::..       ....:::::::::     :. .::::. :::.    :::.:::      .::.",
";;;;``;;;;   ;;;;;;;;;````;;;     ;;`;.  ,;'`;;;;,  `;;;';;,   ,;;;' ",
" [[[,/[[['   ''`  `[[.    [[[     [[  [nn[,   [[[[[. '[[ [[  .[[/   ",
" $$$$$$c    ,,,    `$$    $$'     $$ $\"   $c  $$$ \"Y$c$$  Y$c.$$\"    ",
" 888b \"88bo,888boood88   o88oo,.__88 Yb,_,8P  888    Y88   Y88P      ",
" MMMM   \"W\" \"MMMMMMMM\"   \"\"\"\"YUMMMMM  \"YMP\"   MMM     YM    MP       ",
}

g.dashboard_custom_section = {
    a = {description = {"  Find File                 Ctrl p  "}, command = "Telescope find_files"},
    b = {description = {"  Recents                   SPC  h  "}, command = "Telescope oldfiles"},
    c = {description = {"  Find Word                 SPC  f  "}, command = "Telescope live_grep"},
    d = {description = {"洛 New File                  SPC  f n"}, command = "DashboardNewFile"},
    e = {description = {"  Bookmarks                 SPC  b m"}, command = "Telescope marks"},
    f = {description = {"  Load Last Session         SPC  s l"}, command = "SessionLoad"}
}
