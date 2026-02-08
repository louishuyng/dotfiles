;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; ============================================================================
;; FONTS
;; ============================================================================
(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 14)
      doom-variable-pitch-font (font-spec :family "JetBrainsMono Nerd Font" :size 14)
      doom-big-font (font-spec :family "JetBrainsMono Nerd Font" :size 20))

;; ============================================================================
;; THEME (Catppuccin like nvim)
;; ============================================================================
(setq doom-theme 'catppuccin)
(setq catppuccin-flavor 'frappe)

;; ============================================================================
;; LINE NUMBERS (like nvim relativenumber)
;; ============================================================================
(setq display-line-numbers-type 'relative)

;; ============================================================================
;; TREEMACS (like neo-tree)
;; ============================================================================
(after! treemacs
  (setq treemacs-position 'right
        treemacs-width 35))

;; ============================================================================
;; VTERM (Terminal)
;; ============================================================================
(after! vterm
  (setq vterm-max-scrollback 10000
        vterm-shell "/opt/homebrew/bin/fish"))

;; ============================================================================
;; PROJECTILE
;; ============================================================================
(after! projectile
  (setq projectile-project-search-path '("~/Projects" "~/Work")))

;; ============================================================================
;; EVIL ENHANCEMENTS
;; ============================================================================
(after! evil
  (setq evil-want-Y-yank-to-eol t
        evil-want-fine-undo t))

;; ============================================================================
;; COMPANY (fast completion)
;; ============================================================================
(after! company
  (setq company-idle-delay 0
        company-minimum-prefix-length 1))

;; ============================================================================
;; WHICH-KEY
;; ============================================================================
(after! which-key
  (setq which-key-idle-delay 0.3))

;; ============================================================================
;; LOAD KEYBINDINGS
;; ============================================================================
(load! "keybindings/+init")
