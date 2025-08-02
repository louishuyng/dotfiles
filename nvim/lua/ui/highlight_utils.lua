local function transaprent(opts)
  if opts == nil then
    opts = {}
  end

  if opts.background == 'transparent' then
    vim.cmd [[
      hi Normal guibg=NONE
      hi NormalNC guibg=NONE
    ]]
  end

  vim.cmd [[
    hi SignColumn guibg=NONE
    hi LineNr guibg=NONE
    hi MsgArea guibg=NONE
    hi Whitespace guibg=NONE
  ]]
end

local function gitTransparent()
  vim.cmd [[
    hi GitSignsAdd guibg=NONE
    hi GitSignsChange guibg=NONE
    hi GitSignsDelete guibg=NONE
    hi GitSignsChangeDelete guibg=NONE
    hi GitSignsStagedAdd guibg=NONE
    hi GitSignsStagedChange guibg=NONE
    hi GitSignsStagedDelete guibg=NONE
    hi GitSignsStagedChangeDelete guibg=NONE
  ]]
end

local function diagnosticTransparent()
  vim.cmd [[
    hi DiagnosticError guibg=NONE
    hi DiagnosticWarn guibg=NONE
    hi DiagnosticInfo guibg=NONE
    hi DiagnosticHint guibg=NONE
  ]]
end

local function highlight_telescope(colors)
  local colors = colors or {}

  local input = colors.input or '#21252E'
  local fg_title = colors.title or input
  local bg_title = colors.title_bg or input
  local selection_bg = colors.selection_bg or '#2E2C2F'
  local selection_fg = colors.selection_fg or 'NONE'
  local bg_result = colors.result or '#222222'
  local fg_counter = colors.counter or '#c0afff'

  vim.api.nvim_set_hl(0, 'TelescopePreviewBorder', { bg = input, fg = input })
  vim.api.nvim_set_hl(0, 'TelescopePreviewNormal', { bg = input })
  vim.api.nvim_set_hl(0, 'TelescopePreviewTitle', { bg = bg_title, fg = fg_title })
  vim.api.nvim_set_hl(0, 'TelescopePromptBorder', { bg = input, fg = input })
  vim.api.nvim_set_hl(0, 'TelescopePromptCounter', { fg = fg_counter, bold = true })
  vim.api.nvim_set_hl(0, 'TelescopePromptNormal', { bg = input })
  vim.api.nvim_set_hl(0, 'TelescopePromptPrefix', { bg = input })
  vim.api.nvim_set_hl(0, 'TelescopeResultsBorder', { bg = bg_result, fg = bg_result })
  vim.api.nvim_set_hl(0, 'TelescopeResultsNormal', { bg = bg_result })
  vim.api.nvim_set_hl(0, 'TelescopeResultsTitle', { bg = bg_result, fg = bg_result })
  vim.api.nvim_set_hl(0, 'TelescopeSelection', { bg = selection_bg, fg = selection_fg })
  vim.api.nvim_set_hl(0, 'TelescopeSelectionCaret', { bg = selection_bg, fg = selection_fg })
end

return {
  transaprent = transaprent,
  gitTransparent = gitTransparent,
  highlight_telescope = highlight_telescope,
  diagnosticTransparent = diagnosticTransparent,
}
