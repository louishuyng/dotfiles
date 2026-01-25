-- Midnight theme - uses main builder with midnight colors
local build_theme = require('lush_themes.main')
local colors = require('lush_themes.midnight.colors')

return build_theme(colors)
