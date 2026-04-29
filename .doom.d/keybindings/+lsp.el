;;; keybindings/+lsp.el -*- lexical-binding: t; -*-
;; LSP shortcuts via eglot (Emacs-native LSP client).

;; Doom's `+lookup` module already binds `g d`, `g f`, `g r` to dispatchers
;; that work for both lsp-mode and eglot. We add nvim-style aliases and a
;; few extras.

(map! :n "gf" #'+lookup/definition
      :n "gd" #'+lookup/declaration
      :n "gi" #'+lookup/implementations
      :n "gt" #'+lookup/type-definition
      :n "gr" #'+lookup/references
      :n "gS" #'consult-imenu)

;; --- K → hover doc popup (nvim's vim.lsp.buf.hover) -------------------
;; `eldoc-box-help-at-point` is the built-in command — child-frame popup
;; in GUI, echo-area in TTY. It reads from eldoc, which eglot/lsp-mode
;; already populate with LSP textDocument/hover content.
(map! :n "K" #'eldoc-box-help-at-point)

;; --- ]d / [d → next/prev diagnostic ------------------------------------
;; Works with both flymake (eglot's checker) and flycheck (lsp-mode's).
(defun +my/next-diagnostic ()
  "Jump to the next diagnostic in the current buffer."
  (interactive)
  (cond ((bound-and-true-p flymake-mode)  (flymake-goto-next-error))
        ((bound-and-true-p flycheck-mode) (flycheck-next-error))
        (t (next-error))))

(defun +my/prev-diagnostic ()
  "Jump to the previous diagnostic in the current buffer."
  (interactive)
  (cond ((bound-and-true-p flymake-mode)  (flymake-goto-prev-error))
        ((bound-and-true-p flycheck-mode) (flycheck-previous-error))
        (t (previous-error))))

(map! :n "]d" #'+my/next-diagnostic
      :n "[d" #'+my/prev-diagnostic)

;; Better "show diagnostic at point" — works with both flymake and lsp-mode.
(defun +my/show-diagnostic ()
  "Display diagnostic message at point (eglot/flymake or lsp-mode)."
  (interactive)
  (cond ((bound-and-true-p eglot--managed-mode)
         (call-interactively #'flymake-show-buffer-diagnostics))
        ((bound-and-true-p lsp-mode)
         (call-interactively #'lsp-ui-doc-glance))
        (t (message "No LSP active in this buffer"))))
(map! :n "gl" #'+my/show-diagnostic)

;; Vsplit + go to definition (nvim gv)
(defun +my/lsp-definition-vsplit ()
  "Open the definition in a vertical split."
  (interactive)
  (split-window-right) (other-window 1)
  (call-interactively #'+lookup/definition))
(map! :n "gv" #'+my/lsp-definition-vsplit)

;; Code action — dispatch to whichever LSP backend is active.
(defun +my/code-action ()
  "Run code-action via the active LSP backend (eglot or lsp-mode)."
  (interactive)
  (cond ((bound-and-true-p eglot--managed-mode)
         (call-interactively #'eglot-code-actions))
        ((bound-and-true-p lsp-mode)
         (call-interactively #'lsp-execute-code-action))
        (t (message "No LSP active"))))
(map! :leader :n "ca" #'+my/code-action)

(defun +my/lsp-rename ()
  "Rename symbol at point (eglot or lsp-mode)."
  (interactive)
  (cond ((bound-and-true-p eglot--managed-mode)
         (call-interactively #'eglot-rename))
        ((bound-and-true-p lsp-mode)
         (call-interactively #'lsp-rename))
        (t (message "No LSP active"))))
(map! :n ",rr" #'+my/lsp-rename)

;; Trigger linting (nvim ,l)
(map! :n ",l" #'flycheck-buffer)

;; Diagnostics list (nvim <leader>fd)
(map! :leader :n "fd" #'consult-flymake)

;; Organize imports (nvim <leader>oi)
(defun +my/organize-imports ()
  "Organize imports via the active LSP backend."
  (interactive)
  (cond ((bound-and-true-p eglot--managed-mode)
         (call-interactively #'eglot-code-action-organize-imports))
        ((bound-and-true-p lsp-mode)
         (call-interactively #'lsp-organize-imports))
        (t (message "No LSP active"))))
(map! :leader :n "oi" #'+my/organize-imports)
