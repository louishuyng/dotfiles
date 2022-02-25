local package = require("package-info")

local package_info = {
  provider = function()
    return package.get_status()
  end,
  hl = {
      style = "bold",
  },
  left_sep = "  ",
  right_sep = " ",
}

return package_info
