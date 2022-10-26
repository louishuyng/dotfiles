local packer = require "packer"
local use = packer.use
use {
  "nvim-neorg/neorg",
  run = ":Neorg sync-parsers" -- This is the important bit!
}
