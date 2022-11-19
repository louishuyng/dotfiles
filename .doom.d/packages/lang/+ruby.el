(use-package ruby-mode
  :mode ("\\.rb\\'" . ruby-mode))

;; Hook for lsp
(add-hook 'ruby-mode-hook #'lsp-deferred)

;; Set up before-save hooks to format buffer and add/delete imports.
(defun lsp-ruby-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'ruby-mode-hook #'lsp-ruby-install-save-hooks)
