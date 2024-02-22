vim.keymap.set("n", ",r", ":R<CR>")

local function rubyCreateSpec()
  local path = vim.fn.expand("%:p")

  -- if path include spec then run :A to open the implementation
  if string.find(path, "spec") then
    vim.cmd("A")
    return
  end

  -- if no spec_path folder exists, create it
  local spec_path = string.gsub(path, "app", "spec")
  if vim.fn.isdirectory(spec_path) == 0 then
    -- ignore the file at the end of the path
    local new_dir = string.gsub(spec_path, "/[^/]*$", "")
    vim.fn.mkdir(new_dir, "p")
  end

  spec_path = string.gsub(spec_path, ".rb", "_spec.rb")
  vim.cmd("e " .. spec_path)
end

local function nestJsCreateSpec()
  local path = vim.fn.expand("%:p")

  -- if path include spec then run :A to open the implementation
  if string.find(path, ".spec.ts$") then
    local file_path = string.gsub(path, ".spec.ts$", ".ts")

    vim.cmd("e" .. file_path)
    return
  end

  -- create the spec file for the current file
  -- replace extension .ts with .spec.ts
  local path = vim.fn.expand("%:p")
  local spec_path = string.gsub(path, ".ts$", ".spec.ts")

  vim.cmd("e " .. spec_path)
end

local function create_spec()
  local filetype = vim.bo.filetype

  if filetype == "ruby" then rubyCreateSpec() end

  -- NOTE: I only want to focus on nestjs for now
  if filetype == "typescript" then nestJsCreateSpec() end
end

vim.keymap.set("n", ",a", create_spec)
