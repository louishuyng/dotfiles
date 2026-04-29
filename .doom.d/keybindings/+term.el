;;; keybindings/+term.el -*- lexical-binding: t; -*-
;; Vterm bindings.

;; --- Toggle / new / split ---------------------------------------------
(defun +my/vterm-horizontal ()
  "Open vterm in a horizontal split below."
  (interactive)
  (split-window-below) (other-window 1) (+vterm/here nil))

(defun +my/vterm-vertical ()
  "Open vterm in a vertical split on the right."
  (interactive)
  (split-window-right) (other-window 1) (+vterm/here nil))

(defun +my/vterm-new ()
  "Open a fresh vterm in the current frame (not toggle)."
  (interactive)
  (+vterm/here nil))

;; Mirrors nvim's snacks: tt toggle, th horizontal, tv vertical.
;; (test runner uses `tr` for results to avoid the `tv` clash.)
(map! :leader
      :desc "Terminal toggle"      :n "tt" #'+vterm/toggle
      :desc "Terminal horizontal"  :n "th" #'+my/vterm-horizontal
      :desc "Terminal vertical"    :n "tv" #'+my/vterm-vertical
      :desc "Terminal new"         :n "tN" #'+my/vterm-new)

;; --- Inside vterm: window nav + Ctrl-C interrupt -----------------------
;; `C-c c` sends a literal Ctrl-C (interrupts claude / cancels a running
;; shell command). We can't make plain `C-c` a leaf because Doom +
;; evil-collection bind `C-c C-y`, `C-c C-z` etc. as sub-prefixes.
(after! vterm
  (setq vterm-max-scrollback 10000
        vterm-timer-delay 0.01)
  (defun +my/vterm-send-C-c ()
    "Send a literal Ctrl-C to the running process in this vterm buffer."
    (interactive)
    (vterm-send-key "c" nil nil :ctrl))

  (map! :map vterm-mode-map
        "C-h"   #'evil-window-left
        "C-j"   #'evil-window-down
        "C-k"   #'evil-window-up
        "C-l"   #'evil-window-right
        "C-c c" #'+my/vterm-send-C-c    ; interrupt: C-c then c
        "C-c i" #'+my/vterm-send-C-c    ; alias: C-c i ("interrupt")
        "M-c"   #'vterm-copy-mode))

;; Vterm runs evil-emacs-state by default — bind window nav there too so
;; muscle memory works regardless of state.
(after! evil
  (define-key evil-emacs-state-map (kbd "C-h") #'evil-window-left)
  (define-key evil-emacs-state-map (kbd "C-j") #'evil-window-down)
  (define-key evil-emacs-state-map (kbd "C-k") #'evil-window-up)
  (define-key evil-emacs-state-map (kbd "C-l") #'evil-window-right))
