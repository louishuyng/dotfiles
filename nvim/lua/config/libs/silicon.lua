local present, silicon = pcall(require, "silicon")

if not present then return end

require('silicon').setup({font = 'Hack=20', theme = 'Coldark-Dark'})
