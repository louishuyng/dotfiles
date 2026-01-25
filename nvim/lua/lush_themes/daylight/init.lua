-- Daylight theme - uses main builder with daylight colors
local build_theme = require('lush_themes.main')
local colors = require('lush_themes.daylight.colors')

return build_theme(colors)
