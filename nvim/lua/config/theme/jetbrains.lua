-- JetBrains Islands colorscheme, ported from the Zed "jetbrains-themes"
-- extension (Artem Evsevev, Apache-2.0): themes/jetbrains-islands-{dark,light}.json.
-- Hex values are copied verbatim from those files; only the derived tints
-- (blend) are computed here.

local M = {}

M.palettes = {
  dark = {
    bg = '#191a1c', -- editor.background
    bg_alt = '#26282b', -- surface.background
    active_line = '#1f2024', -- editor.active_line.background
    element = '#393b41', -- element.background
    hover = '#3c3e41', -- element.hover
    selected = '#43454a', -- element.selected
    border = '#393b40', -- editor.wrap_guide (border is invisible on islands)
    selection = '#214283', -- players[0].selection
    cursor = '#ced0d6',
    search = '#32cbf0',
    search_active = '#9bfd87',
    search_alpha = 0.4,
    doc_read = '#373b39',
    doc_write = '#402f33',

    fg = '#bcbec4', -- editor.foreground
    text = '#dfe1e5',
    muted = '#b0b1b3',
    placeholder = '#6f737a',
    line_nr = '#4b5059',
    line_nr_active = '#a1a3ab',
    accent = '#3474f0',
    link = '#548af7',

    error = '#fa6675',
    warn = '#f2c55c',
    info = '#3592c4',
    hint = '#868a91',
    ok = '#57965d',
    error_bg = '#402929',
    warn_bg = '#665014',
    ok_bg = '#253627',

    git_add = '#549159',
    git_change = '#375fad',
    git_delete = '#a75749',
    diff_add = '#1f2b26',
    diff_delete = '#2b2322',
    diff_add_text = '#294436',
    diff_delete_text = '#45302b',

    ansi = {
      '#878787',
      '#f27481',
      '#6bcc62',
      '#e0ce70',
      '#5594fa',
      '#c092fa',
      '#47ccbd',
      '#ced0d6',
      '#8c8e93',
      '#ff6b7a',
      '#67ff59',
      '#ffec1a',
      '#3399ff',
      '#d970ff',
      '#40ffe9',
      '#ffffff',
    },
    comment_italic = false,

    syn = {
      keyword = '#cf8e6d',
      string = '#6aab73',
      number = '#2aacb8',
      comment = '#7a7e85',
      comment_doc = '#5f826b',
      func = '#56a8f5',
      func_special = '#4eade5',
      type = '#86985d',
      interface = '#8d91dc',
      type_param = '#20999d',
      property = '#c77dbb',
      constant = '#c77dbb',
      attribute = '#b3ae60',
      tag = '#d5b778',
      enum_member = '#6da1ab',
      escape = '#cf8e6d',
      self = '#d98eb3',
      constructor = '#57aaf7',
      punctuation = '#bcbec4',
      operator = '#bcbec4',
    },
  },

  light = {
    bg = '#ffffff',
    bg_alt = '#f5f7f9',
    active_line = '#f5f8fe',
    element = '#e3e3e5',
    hover = '#ededed',
    selected = '#dfe1e5',
    border = '#ebecf0',
    selection = '#a6d2ff',
    cursor = '#000000',
    search = '#f9aa00',
    search_active = '#218fff',
    search_alpha = 0.5,
    doc_read = '#edebfc',
    doc_write = '#fce8f4',

    fg = '#080808',
    text = '#000000',
    muted = '#404040',
    placeholder = '#818594',
    line_nr = '#aeb3c2',
    line_nr_active = '#767a8a',
    accent = '#3573f0',
    link = '#006dcc',

    error = '#ff0000',
    warn = '#f49810',
    info = '#389fd6',
    hint = '#7a7a7a',
    ok = '#55a76a',
    error_bg = '#ffe8e8',
    warn_bg = '#fff8dc',
    ok_bg = '#e9f5e6',

    git_add = '#7fc784',
    git_change = '#88adf7',
    git_delete = '#ff8266',
    diff_add = '#e5f5e5',
    diff_delete = '#ffeeeb',
    diff_add_text = '#bee6be',
    diff_delete_text = '#ffd5cc',

    ansi = {
      '#000000',
      '#c93645',
      '#357d1f',
      '#817600',
      '#225cd6',
      '#6e32e5',
      '#007a80',
      '#6e6f73',
      '#6c707e',
      '#ce434f',
      '#268426',
      '#7b6c00',
      '#0071b9',
      '#ac48ce',
      '#1f7f74',
      '#6e6e71',
    },
    comment_italic = true,

    syn = {
      keyword = '#0033b3',
      string = '#067d17',
      number = '#1750eb',
      comment = '#8c8c8c',
      comment_doc = '#8c8c8c',
      func = '#00627a',
      func_special = '#c27203',
      type = '#a04908',
      interface = '#835dda',
      type_param = '#007e8a',
      property = '#871094',
      constant = '#871094',
      attribute = '#9e880d',
      tag = '#0033b3',
      enum_member = '#0e7fc5',
      escape = '#0037a6',
      self = '#1c5dfe',
      constructor = '#00627a',
      punctuation = '#080808',
      operator = '#080808',
    },
  },
}

local function blend(fg, bg, alpha)
  local function channel(hex, i)
    return tonumber(hex:sub(i, i + 1), 16)
  end
  local out = {}
  for _, i in ipairs({ 2, 4, 6 }) do
    out[#out + 1] = math.floor(channel(fg, i) * alpha + channel(bg, i) * (1 - alpha) + 0.5)
  end
  return ('#%02x%02x%02x'):format(out[1], out[2], out[3])
end

function M.colors(variant)
  local p = vim.deepcopy(M.palettes[variant == 'light' and 'light' or 'dark'])
  p.search_bg = blend(p.search, p.bg, p.search_alpha)
  p.search_active_bg = blend(p.search_active, p.bg, p.search_alpha)
  p.diff_change = blend(p.git_change, p.bg, 0.15)
  p.diff_change_text = blend(p.git_change, p.bg, 0.3)
  p.info_bg = blend(p.info, p.bg, 0.15)
  p.hint_bg = blend(p.hint, p.bg, 0.12)
  return p
end

local function groups(c)
  local s = c.syn
  return {
    -- Editor UI
    Normal = { fg = c.fg, bg = c.bg },
    NormalNC = { link = 'Normal' },
    NormalFloat = { fg = c.fg, bg = c.bg_alt },
    FloatBorder = { fg = c.border, bg = c.bg_alt },
    FloatTitle = { fg = c.text, bg = c.bg_alt, bold = true },
    Cursor = { fg = c.bg, bg = c.cursor },
    lCursor = { link = 'Cursor' },
    TermCursor = { link = 'Cursor' },
    CursorLine = { bg = c.active_line },
    CursorColumn = { link = 'CursorLine' },
    ColorColumn = { bg = c.active_line },
    LineNr = { fg = c.line_nr },
    CursorLineNr = { fg = c.line_nr_active },
    SignColumn = { fg = c.line_nr },
    FoldColumn = { fg = c.line_nr },
    Folded = { fg = c.muted, bg = c.bg_alt },
    WinSeparator = { fg = c.border },
    VertSplit = { link = 'WinSeparator' },
    StatusLine = { fg = c.muted, bg = c.bg_alt },
    StatusLineNC = { fg = c.placeholder, bg = c.bg_alt },
    TabLine = { fg = c.placeholder, bg = c.bg_alt },
    TabLineFill = { bg = c.bg_alt },
    TabLineSel = { fg = c.text, bg = c.bg },
    WinBar = { fg = c.muted },
    WinBarNC = { fg = c.placeholder },
    Visual = { bg = c.selection },
    VisualNOS = { link = 'Visual' },
    Search = { bg = c.search_bg },
    IncSearch = { bg = c.search_active_bg },
    CurSearch = { link = 'IncSearch' },
    Substitute = { link = 'IncSearch' },
    MatchParen = { bg = c.selected, bold = true },
    NonText = { fg = c.line_nr },
    Whitespace = { fg = c.line_nr },
    SpecialKey = { fg = c.placeholder },
    EndOfBuffer = { fg = c.bg },
    Conceal = { fg = c.placeholder },
    Directory = { fg = c.accent },
    Title = { fg = s.constant, bold = true },
    Pmenu = { fg = c.fg, bg = c.bg_alt },
    PmenuSel = { bg = c.selection },
    PmenuSbar = { bg = c.bg_alt },
    PmenuThumb = { bg = c.element },
    PmenuMatch = { fg = c.accent, bold = true },
    PmenuMatchSel = { fg = c.accent, bold = true },
    WildMenu = { link = 'PmenuSel' },
    QuickFixLine = { bg = c.selected },
    ModeMsg = { fg = c.text, bold = true },
    MoreMsg = { fg = c.ok },
    Question = { fg = c.accent },
    ErrorMsg = { fg = c.error },
    WarningMsg = { fg = c.warn },
    SpellBad = { sp = c.error, undercurl = true },
    SpellCap = { sp = c.warn, undercurl = true },
    SpellLocal = { sp = c.info, undercurl = true },
    SpellRare = { sp = c.hint, undercurl = true },

    -- Syntax (legacy groups — treesitter captures fall back to these)
    Comment = { fg = s.comment, italic = c.comment_italic },
    Constant = { fg = s.constant, italic = true },
    String = { fg = s.string },
    Character = { link = 'String' },
    Number = { fg = s.number },
    Float = { link = 'Number' },
    Boolean = { fg = s.keyword },
    Identifier = { fg = c.fg },
    Function = { fg = s.func },
    Statement = { fg = s.keyword },
    Keyword = { fg = s.keyword },
    Conditional = { link = 'Keyword' },
    Repeat = { link = 'Keyword' },
    Label = { fg = s.keyword },
    Exception = { link = 'Keyword' },
    Operator = { fg = s.operator },
    PreProc = { fg = s.keyword },
    Include = { link = 'Keyword' },
    Define = { link = 'Keyword' },
    Macro = { fg = s.attribute },
    Type = { fg = s.type },
    StorageClass = { link = 'Keyword' },
    Structure = { link = 'Type' },
    Typedef = { link = 'Type' },
    Special = { fg = s.escape },
    SpecialChar = { fg = s.escape },
    Tag = { fg = s.tag },
    Delimiter = { fg = s.punctuation },
    SpecialComment = { fg = s.comment_doc, italic = true },
    Debug = { fg = c.warn },
    Underlined = { underline = true },
    Error = { fg = c.error },
    Todo = { fg = c.bg, bg = c.warn, bold = true },
    Added = { fg = c.git_add },
    Changed = { fg = c.git_change },
    Removed = { fg = c.git_delete },

    -- Treesitter (mapped to the Zed syntax keys of the same name)
    ['@variable'] = { fg = c.fg },
    ['@variable.builtin'] = { fg = s.self },
    ['@variable.parameter'] = { fg = c.fg },
    ['@variable.member'] = { fg = s.property },
    ['@property'] = { fg = s.property },
    ['@constant'] = { fg = s.constant, italic = true },
    ['@constant.builtin'] = { fg = s.keyword },
    ['@constant.macro'] = { fg = s.attribute },
    ['@module'] = { fg = c.fg },
    ['@label'] = { fg = s.keyword },
    ['@string'] = { link = 'String' },
    ['@string.escape'] = { fg = s.escape },
    ['@string.regexp'] = { fg = s.string },
    ['@string.special'] = { fg = s.func },
    ['@string.special.symbol'] = { fg = s.constant },
    ['@string.special.url'] = { fg = c.link, underline = true },
    ['@character'] = { link = 'String' },
    ['@boolean'] = { fg = s.keyword },
    ['@number'] = { link = 'Number' },
    ['@type'] = { fg = s.type },
    ['@type.builtin'] = { fg = s.keyword },
    ['@type.definition'] = { fg = s.type },
    ['@attribute'] = { fg = s.attribute },
    ['@function'] = { fg = s.func },
    ['@function.builtin'] = { fg = s.func_special },
    ['@function.macro'] = { fg = s.attribute },
    ['@function.method'] = { fg = s.func },
    ['@constructor'] = { fg = s.constructor, italic = true },
    ['@operator'] = { fg = s.operator },
    ['@keyword'] = { fg = s.keyword },
    ['@punctuation.delimiter'] = { fg = s.punctuation },
    ['@punctuation.bracket'] = { fg = s.punctuation },
    ['@punctuation.special'] = { fg = s.attribute },
    ['@comment'] = { link = 'Comment' },
    ['@comment.documentation'] = { fg = s.comment_doc, italic = true },
    ['@comment.error'] = { fg = c.error, bold = true },
    ['@comment.warning'] = { fg = c.warn, bold = true },
    ['@comment.todo'] = { fg = c.info, bold = true },
    ['@comment.note'] = { fg = c.info, bold = true },
    ['@markup.heading'] = { fg = s.constant, bold = true },
    ['@markup.strong'] = { bold = true },
    ['@markup.italic'] = { italic = true },
    ['@markup.strikethrough'] = { strikethrough = true },
    ['@markup.underline'] = { underline = true },
    ['@markup.link'] = { fg = c.link },
    ['@markup.link.label'] = { fg = c.link },
    ['@markup.link.url'] = { fg = s.constructor, underline = true },
    ['@markup.raw'] = { fg = s.string },
    ['@markup.list'] = { fg = s.keyword },
    ['@markup.quote'] = { fg = s.comment, italic = true },
    ['@tag'] = { fg = s.tag },
    ['@tag.attribute'] = { fg = s.attribute },
    ['@tag.delimiter'] = { fg = s.punctuation },
    ['@tag.builtin'] = { fg = s.tag },
    ['@diff.plus'] = { fg = c.git_add },
    ['@diff.minus'] = { fg = c.git_delete },
    ['@diff.delta'] = { fg = c.git_change },

    -- LSP semantic tokens
    ['@lsp.type.interface'] = { fg = s.interface },
    ['@lsp.type.typeParameter'] = { fg = s.type_param },
    ['@lsp.type.enum'] = { fg = s.type, italic = true },
    ['@lsp.type.enumMember'] = { fg = s.enum_member, italic = true },
    ['@lsp.type.namespace'] = { link = '@module' },
    ['@lsp.type.parameter'] = { link = '@variable.parameter' },
    ['@lsp.type.property'] = { link = '@property' },
    ['@lsp.type.variable'] = {},
    ['@lsp.type.lifetime'] = { fg = s.type_param, italic = true },
    ['@lsp.typemod.variable.readonly'] = { link = '@constant' },
    ['@lsp.typemod.variable.defaultLibrary'] = { link = '@variable.builtin' },
    LspReferenceText = { bg = c.doc_read },
    LspReferenceRead = { bg = c.doc_read },
    LspReferenceWrite = { bg = c.doc_write },
    LspInlayHint = { fg = c.hint, bg = c.hint_bg },
    LspCodeLens = { fg = c.hint },
    LspSignatureActiveParameter = { bold = true, underline = true },

    -- Diagnostics
    DiagnosticError = { fg = c.error },
    DiagnosticWarn = { fg = c.warn },
    DiagnosticInfo = { fg = c.info },
    DiagnosticHint = { fg = c.hint },
    DiagnosticOk = { fg = c.ok },
    DiagnosticVirtualTextError = { fg = c.error, bg = c.error_bg },
    DiagnosticVirtualTextWarn = { fg = c.warn, bg = c.warn_bg },
    DiagnosticVirtualTextInfo = { fg = c.info, bg = c.info_bg },
    DiagnosticVirtualTextHint = { fg = c.hint, bg = c.hint_bg },
    DiagnosticUnderlineError = { sp = c.error, undercurl = true },
    DiagnosticUnderlineWarn = { sp = c.warn, undercurl = true },
    DiagnosticUnderlineInfo = { sp = c.info, undercurl = true },
    DiagnosticUnderlineHint = { sp = c.hint, undercurl = true },
    DiagnosticUnnecessary = { fg = c.placeholder },
    DiagnosticDeprecated = { strikethrough = true },

    -- Diff
    DiffAdd = { bg = c.diff_add },
    DiffDelete = { bg = c.diff_delete },
    DiffChange = { bg = c.diff_change },
    DiffText = { bg = c.diff_change_text },
    diffAdded = { fg = c.git_add },
    diffRemoved = { fg = c.git_delete },
    diffChanged = { fg = c.git_change },

    -- Plugins
    GitSignsAdd = { fg = c.git_add },
    GitSignsChange = { fg = c.git_change },
    GitSignsDelete = { fg = c.git_delete },
    GitSignsAddInline = { bg = c.diff_add_text },
    GitSignsDeleteInline = { bg = c.diff_delete_text },
    GitSignsChangeInline = { bg = c.diff_change_text },
    DiffviewDiffAddAsDelete = { bg = c.diff_delete },
    NeogitDiffAdd = { fg = c.git_add, bg = c.diff_add },
    NeogitDiffDelete = { fg = c.git_delete, bg = c.diff_delete },
    NeogitDiffAddHighlight = { fg = c.git_add, bg = c.diff_add_text },
    NeogitDiffDeleteHighlight = { fg = c.git_delete, bg = c.diff_delete_text },

    TelescopeNormal = { link = 'NormalFloat' },
    TelescopeBorder = { link = 'FloatBorder' },
    TelescopeSelection = { bg = c.selected },
    TelescopeMatching = { fg = c.accent, bold = true },
    TelescopePromptPrefix = { fg = c.accent },

    NvimTreeNormal = { fg = c.fg, bg = c.bg },
    NvimTreeRootFolder = { fg = c.text, bold = true },
    NvimTreeFolderName = { fg = c.fg },
    NvimTreeOpenedFolderName = { fg = c.text },
    NvimTreeFolderIcon = { fg = c.muted },
    NvimTreeGitDirty = { fg = c.git_change },
    NvimTreeGitNew = { fg = c.git_add },
    NvimTreeGitDeleted = { fg = c.git_delete },
    NvimTreeWinSeparator = { link = 'WinSeparator' },

    CmpItemAbbrMatch = { fg = c.accent, bold = true },
    CmpItemAbbrMatchFuzzy = { fg = c.accent },
    CmpItemAbbrDeprecated = { fg = c.placeholder, strikethrough = true },
    CmpItemMenu = { fg = c.placeholder },
    CmpItemKindFunction = { fg = s.func },
    CmpItemKindMethod = { fg = s.func },
    CmpItemKindVariable = { fg = c.fg },
    CmpItemKindField = { fg = s.property },
    CmpItemKindProperty = { fg = s.property },
    CmpItemKindKeyword = { fg = s.keyword },
    CmpItemKindClass = { fg = s.type },
    CmpItemKindInterface = { fg = s.interface },
    CmpItemKindConstant = { fg = s.constant },
    CmpItemKindSnippet = { fg = s.attribute },

    SnacksPickerMatch = { fg = c.accent, bold = true },
    SnacksPickerDir = { fg = c.placeholder },
    WhichKeyNormal = { link = 'NormalFloat' },
    WhichKey = { fg = s.keyword },
    WhichKeyGroup = { fg = s.func },
    WhichKeyDesc = { fg = c.fg },
    FlashLabel = { fg = c.bg, bg = c.accent, bold = true },
    FlashMatch = { bg = c.search_bg },
    FlashCurrent = { bg = c.search_active_bg },
    NotifyBackground = { bg = c.bg },
    TodoBgTODO = { fg = c.bg, bg = c.info, bold = true },
    TodoFgTODO = { fg = c.info },
  }
end

function M.load()
  if vim.g.colors_name then
    vim.cmd.highlight('clear')
  end
  vim.g.colors_name = 'jetbrains'
  local variant = vim.o.background == 'light' and 'light' or 'dark'
  local c = M.colors(variant)
  for name, spec in pairs(groups(c)) do
    vim.api.nvim_set_hl(0, name, spec)
  end

  -- Terminal ANSI colors from the same theme file.
  for i, color in ipairs(c.ansi) do
    vim.g['terminal_color_' .. (i - 1)] = color
  end
end

return M
