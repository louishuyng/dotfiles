;; LSP Mode
(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  :commands lsp)

;; LSP Lang
(load! "lang/+ruby")

;; LSP UI
(use-package lsp-ui :commands lsp-ui-mode)
