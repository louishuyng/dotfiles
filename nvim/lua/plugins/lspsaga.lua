local present, saga = pcall(require, "lspsaga")
if not present then
    return
end

saga.init_lsp_saga({
  use_saga_diagnostic_sign = false,
  max_preview_lines = 10
})
