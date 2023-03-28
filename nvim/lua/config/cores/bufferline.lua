local present, bufferline = pcall(require, "bufferline")
if not present then return end

bufferline.setup {
  animation = false,
  closable = false,
  icon_separator_active = '',
  icon_separator_inactive = ''
}
