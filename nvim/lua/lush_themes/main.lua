-- Main theme builder - takes a color palette and generates a complete theme
local lush = require('lush')
local hsl = lush.hsl

local function build_theme(palette)
  ---@diagnostic disable: undefined-global
  return lush(function(injected_functions)
    local sym = injected_functions.sym
    
    -- Convert hex colors to HSL for lush
    local colors = {
      -- Background shades
      bg_dark = hsl(palette.bg_dark),
      bg = hsl(palette.bg),
      bg_float = hsl(palette.bg_float),
      bg_highlight = hsl(palette.bg_highlight),
      bg_visual = hsl(palette.bg_visual),
      
      -- Foreground shades
      fg = hsl(palette.fg),
      fg_dark = hsl(palette.fg_dark),
      fg_gutter = hsl(palette.fg_gutter),
      
      -- Syntax colors
      red = hsl(palette.red),
      orange = hsl(palette.orange),
      yellow = hsl(palette.yellow),
      green = hsl(palette.green),
      cyan = hsl(palette.cyan),
      blue = hsl(palette.blue),
      purple = hsl(palette.purple),
      magenta = hsl(palette.magenta),
      
      -- UI colors
      border = hsl(palette.border),
      selection = hsl(palette.selection),
      comment = hsl(palette.comment),
      error = hsl(palette.error),
      warning = hsl(palette.warning),
      info = hsl(palette.info),
      hint = hsl(palette.hint),
    }
    
    return {
      -- Base groups
      Normal { fg = colors.fg, bg = colors.bg },
      NormalFloat { fg = colors.fg, bg = colors.bg_float },
      NormalNC { fg = colors.fg, bg = colors.bg },
      
      -- Cursor
      Cursor { fg = colors.bg, bg = colors.fg },
      CursorLine { bg = colors.bg_highlight },
      CursorColumn { bg = colors.bg_highlight },
      ColorColumn { bg = colors.bg_highlight },
      CursorLineNr { fg = colors.yellow, gui = 'bold' },
      LineNr { fg = colors.fg_gutter },
      
      -- Visual selection
      Visual { bg = colors.bg_visual },
      VisualNOS { bg = colors.bg_visual },
      
      -- Search
      Search { bg = colors.orange.darken(30), fg = colors.orange },
      IncSearch { bg = colors.orange, fg = colors.bg },
      CurSearch { bg = colors.orange, fg = colors.bg },
      
      -- Statusline
      StatusLine { fg = colors.fg, bg = colors.bg_highlight },
      StatusLineNC { fg = colors.fg_dark, bg = colors.bg_dark },
      
      -- Tabline
      TabLine { fg = colors.fg_dark, bg = colors.bg_dark },
      TabLineFill { bg = colors.bg_dark },
      TabLineSel { fg = colors.fg, bg = colors.bg },
      
      -- Window elements
      WinSeparator { fg = colors.border },
      VertSplit { fg = colors.border },
      FloatBorder { fg = colors.border, bg = colors.bg_float },
      
      -- Popup menu
      Pmenu { fg = colors.fg, bg = colors.bg_float },
      PmenuSel { bg = colors.bg_visual },
      PmenuSbar { bg = colors.bg_float },
      PmenuThumb { bg = colors.fg_gutter },
      
      -- Folds
      Folded { fg = colors.blue, bg = colors.bg_highlight },
      FoldColumn { fg = colors.comment, bg = colors.bg },
      
      -- Diff
      DiffAdd { bg = colors.green.darken(70) },
      DiffChange { bg = colors.blue.darken(70) },
      DiffDelete { bg = colors.red.darken(70) },
      DiffText { bg = colors.blue.darken(50) },
      
      -- Spelling
      SpellBad { sp = colors.error, gui = 'undercurl' },
      SpellCap { sp = colors.warning, gui = 'undercurl' },
      SpellRare { sp = colors.info, gui = 'undercurl' },
      SpellLocal { sp = colors.hint, gui = 'undercurl' },
      
      -- Messages
      ErrorMsg { fg = colors.error },
      WarningMsg { fg = colors.warning },
      ModeMsg { fg = colors.fg_dark },
      MoreMsg { fg = colors.blue },
      Question { fg = colors.blue },
      
      -- Misc
      Directory { fg = colors.blue },
      Title { fg = colors.blue, gui = 'bold' },
      Bold { gui = 'bold' },
      Italic { gui = 'italic' },
      Underlined { gui = 'underline' },
      MatchParen { fg = colors.orange, gui = 'bold' },
      NonText { fg = colors.fg_gutter },
      SpecialKey { fg = colors.fg_gutter },
      Whitespace { fg = colors.fg_gutter },
      
      -- Syntax groups
      Comment { fg = colors.comment, gui = 'italic' },
      Constant { fg = colors.orange },
      String { fg = colors.green },
      Character { fg = colors.green },
      Number { fg = colors.orange },
      Boolean { fg = colors.orange },
      Float { fg = colors.orange },
      
      Identifier { fg = colors.fg },
      Function { fg = colors.blue },
      
      Statement { fg = colors.purple },
      Conditional { fg = colors.purple },
      Repeat { fg = colors.purple },
      Label { fg = colors.purple },
      Operator { fg = colors.cyan },
      Keyword { fg = colors.purple },
      Exception { fg = colors.purple },
      
      PreProc { fg = colors.magenta },
      Include { fg = colors.magenta },
      Define { fg = colors.magenta },
      Macro { fg = colors.magenta },
      PreCondit { fg = colors.magenta },
      
      Type { fg = colors.yellow },
      StorageClass { fg = colors.yellow },
      Structure { fg = colors.yellow },
      Typedef { fg = colors.yellow },
      
      Special { fg = colors.cyan },
      SpecialChar { fg = colors.cyan },
      Tag { fg = colors.blue },
      Delimiter { fg = colors.fg_dark },
      SpecialComment { fg = colors.comment, gui = 'italic' },
      Debug { fg = colors.red },
      
      Error { fg = colors.error },
      Todo { fg = colors.purple, bg = colors.bg_highlight, gui = 'bold' },
      
      -- TreeSitter
      sym('@variable') { fg = colors.fg },
      sym('@variable.builtin') { fg = colors.red },
      sym('@variable.parameter') { fg = colors.fg },
      sym('@variable.member') { fg = colors.cyan },
      
      sym('@constant') { Constant },
      sym('@constant.builtin') { fg = colors.orange },
      sym('@constant.macro') { fg = colors.orange },
      
      sym('@module') { fg = colors.yellow },
      sym('@label') { fg = colors.blue },
      
      sym('@string') { String },
      sym('@string.regexp') { fg = colors.cyan },
      sym('@string.escape') { fg = colors.magenta },
      sym('@string.special') { fg = colors.cyan },
      
      sym('@character') { Character },
      sym('@character.special') { SpecialChar },
      
      sym('@boolean') { Boolean },
      sym('@number') { Number },
      sym('@number.float') { Float },
      
      sym('@type') { Type },
      sym('@type.builtin') { fg = colors.yellow },
      sym('@type.qualifier') { fg = colors.purple },
      sym('@type.definition') { Typedef },
      
      sym('@attribute') { fg = colors.magenta },
      sym('@property') { fg = colors.cyan },
      
      sym('@function') { Function },
      sym('@function.builtin') { fg = colors.blue },
      sym('@function.call') { fg = colors.blue },
      sym('@function.macro') { fg = colors.magenta },
      sym('@function.method') { fg = colors.blue },
      sym('@function.method.call') { fg = colors.blue },
      
      sym('@constructor') { fg = colors.blue },
      sym('@operator') { Operator },
      
      sym('@keyword') { Keyword },
      sym('@keyword.coroutine') { Keyword },
      sym('@keyword.function') { fg = colors.purple },
      sym('@keyword.operator') { fg = colors.purple },
      sym('@keyword.return') { fg = colors.purple },
      sym('@keyword.conditional') { Conditional },
      sym('@keyword.repeat') { Repeat },
      sym('@keyword.import') { Include },
      sym('@keyword.exception') { Exception },
      
      sym('@punctuation.delimiter') { Delimiter },
      sym('@punctuation.bracket') { fg = colors.fg_dark },
      sym('@punctuation.special') { fg = colors.cyan },
      
      sym('@comment') { Comment },
      sym('@comment.documentation') { fg = colors.comment, gui = 'italic' },
      sym('@comment.error') { fg = colors.error },
      sym('@comment.warning') { fg = colors.warning },
      sym('@comment.note') { fg = colors.info },
      sym('@comment.todo') { Todo },
      
      sym('@markup.strong') { gui = 'bold' },
      sym('@markup.italic') { gui = 'italic' },
      sym('@markup.strikethrough') { gui = 'strikethrough' },
      sym('@markup.underline') { gui = 'underline' },
      
      sym('@markup.heading') { fg = colors.blue, gui = 'bold' },
      sym('@markup.heading.1') { fg = colors.blue, gui = 'bold' },
      sym('@markup.heading.2') { fg = colors.yellow, gui = 'bold' },
      sym('@markup.heading.3') { fg = colors.green, gui = 'bold' },
      sym('@markup.heading.4') { fg = colors.cyan, gui = 'bold' },
      sym('@markup.heading.5') { fg = colors.purple, gui = 'bold' },
      sym('@markup.heading.6') { fg = colors.magenta, gui = 'bold' },
      
      sym('@markup.quote') { fg = colors.comment },
      sym('@markup.math') { fg = colors.orange },
      
      sym('@markup.link') { fg = colors.cyan },
      sym('@markup.link.label') { fg = colors.blue },
      sym('@markup.link.url') { fg = colors.cyan, gui = 'underline' },
      
      sym('@markup.raw') { fg = colors.green },
      sym('@markup.raw.block') { fg = colors.green },
      
      sym('@markup.list') { fg = colors.cyan },
      sym('@markup.list.checked') { fg = colors.green },
      sym('@markup.list.unchecked') { fg = colors.comment },
      
      sym('@diff.plus') { DiffAdd },
      sym('@diff.minus') { DiffDelete },
      sym('@diff.delta') { DiffChange },
      
      sym('@tag') { Tag },
      sym('@tag.attribute') { fg = colors.yellow },
      sym('@tag.delimiter') { Delimiter },
      
      -- LSP
      sym('@lsp.type.class') { Type },
      sym('@lsp.type.decorator') { fg = colors.magenta },
      sym('@lsp.type.enum') { Type },
      sym('@lsp.type.enumMember') { Constant },
      sym('@lsp.type.function') { Function },
      sym('@lsp.type.interface') { Type },
      sym('@lsp.type.macro') { Macro },
      sym('@lsp.type.method') { Function },
      sym('@lsp.type.namespace') { sym('@module') },
      sym('@lsp.type.parameter') { sym('@variable.parameter') },
      sym('@lsp.type.property') { sym('@property') },
      sym('@lsp.type.struct') { Type },
      sym('@lsp.type.type') { Type },
      sym('@lsp.type.typeParameter') { Type },
      sym('@lsp.type.variable') { sym('@variable') },
      
      -- Diagnostics
      DiagnosticError { fg = colors.error },
      DiagnosticWarn { fg = colors.warning },
      DiagnosticInfo { fg = colors.info },
      DiagnosticHint { fg = colors.hint },
      DiagnosticOk { fg = colors.green },
      
      DiagnosticUnderlineError { sp = colors.error, gui = 'undercurl' },
      DiagnosticUnderlineWarn { sp = colors.warning, gui = 'undercurl' },
      DiagnosticUnderlineInfo { sp = colors.info, gui = 'undercurl' },
      DiagnosticUnderlineHint { sp = colors.hint, gui = 'undercurl' },
      DiagnosticUnderlineOk { sp = colors.green, gui = 'undercurl' },
      
      DiagnosticVirtualTextError { fg = colors.error, bg = colors.error.darken(80) },
      DiagnosticVirtualTextWarn { fg = colors.warning, bg = colors.warning.darken(80) },
      DiagnosticVirtualTextInfo { fg = colors.info, bg = colors.info.darken(80) },
      DiagnosticVirtualTextHint { fg = colors.hint, bg = colors.hint.darken(80) },
      
      -- Git signs
      GitSignsAdd { fg = colors.green },
      GitSignsChange { fg = colors.blue },
      GitSignsDelete { fg = colors.red },
      
      -- Telescope
      TelescopeBorder { FloatBorder },
      TelescopeNormal { NormalFloat },
      TelescopeSelection { bg = colors.bg_visual },
      TelescopeSelectionCaret { fg = colors.blue },
      TelescopeMatching { fg = colors.orange },
      TelescopePromptPrefix { fg = colors.blue },
      
      -- Neo-tree
      NeoTreeNormal { fg = colors.fg, bg = colors.bg_dark },
      NeoTreeNormalNC { fg = colors.fg, bg = colors.bg_dark },
      NeoTreeDirectoryIcon { fg = colors.blue },
      NeoTreeDirectoryName { fg = colors.blue },
      NeoTreeFileName { fg = colors.fg },
      NeoTreeFileIcon { fg = colors.fg_dark },
      NeoTreeGitAdded { fg = colors.green },
      NeoTreeGitModified { fg = colors.yellow },
      NeoTreeGitDeleted { fg = colors.red },
      NeoTreeGitConflict { fg = colors.orange },
      NeoTreeGitUntracked { fg = colors.cyan },
      NeoTreeIndentMarker { fg = colors.fg_gutter },
      NeoTreeRootName { fg = colors.purple, gui = 'bold' },
      
      -- Which-key
      WhichKey { fg = colors.cyan },
      WhichKeyGroup { fg = colors.blue },
      WhichKeyDesc { fg = colors.purple },
      WhichKeySeperator { fg = colors.comment },
      WhichKeyFloat { NormalFloat },
      WhichKeyBorder { FloatBorder },
      
      -- Indent Blankline
      IblIndent { fg = colors.fg_gutter },
      IblScope { fg = colors.purple },
      
      -- Noice
      NoicePopupmenu { Pmenu },
      NoicePopupmenuSelected { PmenuSel },
      NoiceCmdlinePopup { NormalFloat },
      NoiceCmdlinePopupBorder { FloatBorder },
    }
  end)
end

return build_theme
