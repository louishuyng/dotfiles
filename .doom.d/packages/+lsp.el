;; LSP Mode
(use-package lsp-mode
  :init
  :hook ((ruby-mode . lsp))
  :commands lsp)

;; LSP Lang
(load! "lang/+ruby")

;; LSP UI
(use-package lsp-ui :commands lsp-ui-mode)
