local present, git_conflict = pcall(require, "git-conflict")

if not (present) then return end

git_conflict.setup({
  default_mappings = false,
  disable_diagnostics = false,
  highlights = {incoming = 'DiffText', current = 'DiffAdd'}
})
