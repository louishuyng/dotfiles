;;; keybindings/+lsp.el -*- lexical-binding: t; -*-

;; ============================================================================
;; LSP NAVIGATION (like nvim gd, gr, K)
;; ============================================================================
(map! :n "gd" #'lsp-find-definition
      :n "gD" #'lsp-find-declaration
      :n "gr" #'lsp-find-references
      :n "gi" #'lsp-find-implementation
      :n "gt" #'lsp-find-type-definition
      :n "K" #'lsp-ui-doc-glance)

;; gv - Go to definition in vertical split
(defun my/lsp-find-definition-vsplit ()
  "Go to definition in vertical split."
  (interactive)
  (evil-window-vsplit)
  (lsp-find-definition))

(map! :n "gv" #'my/lsp-find-definition-vsplit)

;; ============================================================================
;; DIAGNOSTIC NAVIGATION (like nvim ]d [d)
;; ============================================================================
(map! :n "]d" #'flycheck-next-error
      :n "[d" #'flycheck-previous-error
      :n "]e" #'next-error
      :n "[e" #'previous-error)

;; ============================================================================
;; LSP CODE ACTIONS (using Doom's SPC c prefix)
;; SPC c a = code action (built-in)
;; SPC c r = rename (built-in)
;; SPC c f = format (built-in)
;; SPC c d = documentation
;; ============================================================================
