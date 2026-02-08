;;; keybindings/+term.el -*- lexical-binding: t; -*-

;; ============================================================================
;; VTERM KEYBINDINGS
;; SPC o t = toggle terminal (Doom built-in)
;; SPC o T = terminal here (Doom built-in)
;; ============================================================================
(after! vterm
  (map! :map vterm-mode-map
        "C-h" #'evil-window-left
        "C-j" #'evil-window-down
        "C-k" #'evil-window-up
        "C-l" #'evil-window-right))
