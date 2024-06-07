-- Read all the folders inside /src & /apps & /app and create a scope for each one
-- only find folders not files
local scopes = {}

local base = vim.fn.expand("%:p:h")

local folderToWatch = { "src", "apps", "app" }

for _, folder in ipairs(folderToWatch) do
  local dirs = vim.fn.glob(base .. "/" .. folder .. "/*", 1, 1)

  dirs = vim.tbl_filter(function(dir)
    return vim.fn.isdirectory(dir) == 1
  end, dirs)

  for _, dir in ipairs(dirs) do
    local name = vim.fn.fnamemodify(dir, ":t")
    table.insert(scopes, { name = name, dirs = { dir } })
  end
end


require("neoscopes").setup({ scopes = scopes })
