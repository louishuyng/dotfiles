-- Read all the folders in ~/Dev/Projects/Regask/platform-services/apps
local base = "~/Dev/Projects/Regask/platform-services/apps"

local dirs = vim.fn.glob(base .. "/*", 1, 1)

local scopes = {}

for _, dir in ipairs(dirs) do
  local name = vim.fn.fnamemodify(dir, ":t")
  table.insert(scopes, {name = name, dirs = {dir}})
end

require("neoscopes").setup({scopes = scopes})
