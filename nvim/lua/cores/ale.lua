vim.g.ale_linters = {
  javascript = {"eslint","prettier","flow"},
  typescript = {"tslint","eslint"},
  ruby = {"rubocop"},
  python = {"flake8","pylint"},
  go = {"gofmt", "golps", "golint"},
}

vim.g.ale_fixers = {
  javascript = {"prettier","eslint"},
  ruby = {"rubocop"},
  go = {"gofmt", "goimports", "golines"},
  typescript = {"tslint","eslint"},
}

vim.g.ale_enabled = 1
vim.g.ale_fix_on_save = 1
vim.g.ale_sign_error = ''
vim.g.ale_sign_warning = ''
