;;; keybindings/+general.el -*- lexical-binding: t; -*-

;; ============================================================================
;; WINDOW NAVIGATION (like nvim Ctrl-h/j/k/l)
;; ============================================================================
(map! "C-h" #'evil-window-left
      "C-j" #'evil-window-down
      "C-k" #'evil-window-up
      "C-l" #'evil-window-right)

;; ============================================================================
;; WINDOW SPLITS (like nvim ,s / ,v)
;; ============================================================================
(map! :n ",s" #'split-window-below
      :n ",v" #'split-window-right)

;; ============================================================================
;; FILE NAVIGATION (like nvim telescope)
;; ============================================================================
(map! :n "C-p" #'projectile-find-file)

;; ============================================================================
;; BUFFER NAVIGATION (like nvim ,q / ,w for bufferline)
;; ============================================================================
(map! :n ",q" #'previous-buffer
      :n ",w" #'next-buffer
      :n ",bd" #'kill-current-buffer)

;; Backspace to switch between recent buffers
(map! :n "<backspace>" #'evil-switch-to-windows-last-buffer)

;; ============================================================================
;; TREEMACS / FILE EXPLORER (like nvim neo-tree)
;; ============================================================================
(map! "C-\\" #'+treemacs/toggle
      :n ",e" #'find-file
      :n "-" #'dired-jump)

;; ============================================================================
;; MOTION / JUMP (like nvim flash.nvim)
;; ============================================================================
(map! :n "s" #'avy-goto-char-2
      :n "S" #'avy-goto-word-1)

;; ============================================================================
;; RESIZE WINDOWS (simple, no hydra)
;; ============================================================================
(map! :leader
      :prefix ("w" . "window")
      :desc "Increase width" "l" #'evil-window-increase-width
      :desc "Decrease width" "h" #'evil-window-decrease-width
      :desc "Increase height" "j" #'evil-window-increase-height
      :desc "Decrease height" "k" #'evil-window-decrease-height)
