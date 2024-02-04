vim.keymap.set("n", "<leader>rc", ":Econtroller ")
vim.keymap.set("n", "<leader>re", ":Eenvironment ")
vim.keymap.set("n", "<leader>rj", ":Ejob ")
vim.keymap.set("n", "<leader>rm", ":Emodel ")
vim.keymap.set("n", "<leader>rp", ":Epolicy ")
vim.keymap.set("n", "<leader>rr", ":Eresource ")
vim.keymap.set("n", "<leader>rd", ":Eschema ")
vim.keymap.set("n", "<leader>rS", ":Eservice ")
vim.keymap.set("n", "<leader>rs", ":Espec ")
vim.keymap.set("n", "<leader>rh", ":Ehelper ")
vim.keymap.set("n", "<leader>rt", ":Etask ")
vim.keymap.set("n", "<leader>rg", ":Generate ")

vim.keymap.set("n", "<leader>rC", ":Vcontroller ")
vim.keymap.set("n", "<leader>rE", ":Venvironment ")
vim.keymap.set("n", "<leader>rJ", ":Vjob ")
vim.keymap.set("n", "<leader>rM", ":Vmodel ")
vim.keymap.set("n", "<leader>rP", ":Vpolicy ")
vim.keymap.set("n", "<leader>rR", ":Vresource ")
vim.keymap.set("n", "<leader>rD", ":Vschema ")
vim.keymap.set("n", "<leader>rS", ":Vservice ")
vim.keymap.set("n", "<leader>rS", ":Vspec ")
vim.keymap.set("n", "<leader>rH", ":Vhelper ")
vim.keymap.set("n", "<leader>rT", ":Vtask ")

vim.keymap.set("n", ",r", ":R<CR>")

function create_spec()
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

vim.keymap.set("n", ",a", ":lua create_spec()<CR>")
