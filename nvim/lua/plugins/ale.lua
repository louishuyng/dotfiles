vim.g.ale_linters = {
 javascript = {"eslint","prettier","flow"},
 typescript = {"tslint","eslint"},
 ruby = {"rubocop"},
 python = {"flake8","pylint"}
}

vim.g.ale_fixers = {
 typescript = {"tslint","eslint"},
 javascript = {"prettier","eslint"},
 ruby = {"rubocop"}
}

vim.g.ale_enabled = 1
vim.g.ale_fix_on_save = 1
vim.g.ale_sign_error = ''
vim.g.ale_sign_warning = ''
