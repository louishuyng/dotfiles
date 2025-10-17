local icons = require('config.libs.icons')
local bufferline = require('bufferline')

bufferline.setup {
  options = {
    mode = 'tabs',
    buffer_close_icon = '',
    close_icon = '',
    show_buffer_icons = true,
    style_preset = {
      bufferline.style_preset.no_italic,
      bufferline.style_preset.no_bold,
    },
    themable = true,
  },
}
