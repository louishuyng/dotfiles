(add-hook 'c-mode-hook #'format-all-mode)

;; Navigation
(define-key evil-normal-state-map "gf" 'lsp-find-definition)
(define-key evil-normal-state-map "gr" 'lsp-find-references)
(define-key evil-normal-state-map "K" 'lsp-ui-doc-glance)

;; Diagnostic
(define-key evil-normal-state-map "]d" 'flycheck-next-error)
(define-key evil-normal-state-map "[d" 'flycheck-previous-error)
