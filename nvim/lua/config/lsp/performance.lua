-- LSP Performance Optimizations

-- Reduce default timeout for LSP requests
vim.lsp.set_log_level("ERROR")

-- Configure LSP for better performance
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or "single"
  opts.max_width = opts.max_width or 80
  opts.max_height = opts.max_height or 20
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Optimize completion
vim.lsp.protocol.CompletionItemKind = {
  '', -- Text
  '', -- Method
  '', -- Function
  '', -- Constructor
  '', -- Field
  '', -- Variable
  '', -- Class
  'ﰮ', -- Interface
  '', -- Module
  '', -- Property
  '', -- Unit
  '', -- Value
  '', -- Enum
  '', -- Keyword
  '﬌', -- Snippet
  '', -- Color
  '', -- File
  '', -- Reference
  '', -- Folder
  '', -- EnumMember
  '', -- Constant
  '', -- Struct
  '', -- Event
  '', -- Operator
  '', -- TypeParameter
}

-- Disable unnecessary capabilities for better performance
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true
}

-- Global LSP settings for performance
vim.lsp.set_log_level("ERROR")

-- Debounce text changes
local timer = vim.loop.new_timer()
local DEBOUNCE_MS = 200
local orig_buf_text_changed = vim.lsp.util.buf_text_changed

vim.lsp.util.buf_text_changed = function(bufnr)
  timer:stop()
  timer:start(DEBOUNCE_MS, 0, function()
    timer:stop()
    vim.schedule(function()
      orig_buf_text_changed(bufnr)
    end)
  end)
end

-- Disable semantic tokens for better performance
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      client.server_capabilities.semanticTokensProvider = nil
    end
  end,
})

return capabilities