;;; keybindings/+general.el -*- lexical-binding: t; -*-
;; Window nav, splits, save/quit, buffer cycle, jumplist — nvim feel.

;; --- Window navigation (nvim C-h/j/k/l) -------------------------------
(map! :nvm "C-h" #'evil-window-left
      :nvm "C-j" #'evil-window-down
      :nvm "C-k" #'evil-window-up
      :nvm "C-l" #'evil-window-right)

;; --- Jumplist (nvim C-o / C-i) ----------------------------------------
;; In GUI Emacs C-i is distinct from TAB; in TTY they are the same key.
;; Bind both so it works either way.
(map! :nvm "C-o" #'evil-jump-backward
      :nvm "C-i" #'evil-jump-forward)
;; Doom + Emacs sometimes alias C-i to <tab>; bind <tab> too for forward jump
;; in normal/motion (not insert/visual where TAB has its own meaning).
(map! :n "<tab>" #'evil-jump-forward)

;; --- Splits (nvim ,s / ,v) --------------------------------------------
(map! :n ",s" #'split-window-below
      :n ",v" #'split-window-right)

;; --- Save / quit (nvim <leader>w / <leader>q / <leader>W) -------------
(defun +my/quit-window-and-buffer ()
  "Close window; kill buffer if no other window shows it. Mirrors `:q!'."
  (interactive)
  (let ((buf (current-buffer)))
    (if (one-window-p)
        (kill-buffer buf)
      (delete-window)
      (unless (get-buffer-window buf t)
        (kill-buffer buf)))))

(map! :leader
      :desc "Save buffer"        :n "w" #'save-buffer
      :desc "Save all"           :n "W" #'save-some-buffers
      :desc "Quit window+buffer" :n "q" #'+my/quit-window-and-buffer)

;; --- Clipboard cut/yank --------------------------------------------------
;; Doom's defaults handle this fine via evil + `select-enable-clipboard t'.
;; `y` (yank) and `d` (delete) already use the system clipboard. We keep
;; C-c and C-x at their Emacs defaults (prefixes for many keymaps) to
;; avoid breaking `C-c X` and `C-x X` chord bindings.

;; --- Visual block move (nvim S-J / S-K) -------------------------------
(map! :v "S-j" #'drag-stuff-down
      :v "S-k" #'drag-stuff-up)

;; --- Buffer cycle (nvim ,q / ,w) --------------------------------------
;; Note: there's a subtle clash — ,q here cycles backward, but the leader
;; SPC-q quits a buffer. nvim has the same dual meaning (`,q` and `:q`).
(map! :n ",q"          #'previous-buffer
      :n ",w"          #'next-buffer
      :n "<backspace>" #'evil-switch-to-windows-last-buffer)

;; --- Buffer delete (nvim ,bd / ,bD) ------------------------------------
;; `,bd` kills the current buffer; `,bD` (capital D) kills all buffers.
(defun +my/kill-all-buffers ()
  "Kill every buffer (project-friendly) — Doom's `doom/kill-all-buffers'."
  (interactive)
  (cond ((fboundp 'doom/kill-all-buffers)        (call-interactively #'doom/kill-all-buffers))
        ((fboundp '+default/kill-all-buffers)    (call-interactively #'+default/kill-all-buffers))
        (t (mapc #'kill-buffer (buffer-list)) (message "Killed all buffers"))))

(map! :n ",bd" #'kill-current-buffer
      :n ",bD" #'+my/kill-all-buffers)

;; --- Sort selection (nvim <leader>so) ----------------------------------
(map! :leader :v "so" #'sort-lines)

;; --- Open URL at point (nvim <leader>ou) ------------------------------
(map! :leader :n "ou" #'browse-url-at-point)

;; --- Reload buffer + LSP restart (nvim <leader>rb) --------------------
(defun +my/reload-buffer ()
  "Revert current buffer and restart eglot/lsp if active."
  (interactive)
  (revert-buffer t t)
  (cond ((and (bound-and-true-p eglot--managed-mode) (fboundp 'eglot-reconnect))
         (call-interactively #'eglot-reconnect))
        ((bound-and-true-p lsp-mode)
         (call-interactively #'lsp-workspace-restart)))
  (message "Buffer reloaded"))
(map! :leader :n "rb" #'+my/reload-buffer)

;; --- Window zoom (tmux-style C-a z) -----------------------------------
;; Toggle: first press saves the layout and maximizes the current window;
;; second press restores the layout. Works in any buffer — vterm or
;; coding editor — since it's purely window-configuration based.
(defvar +my/zoom-saved-config nil
  "Window configuration captured before the most recent zoom.")

(defun +my/toggle-zoom-window ()
  "Maximize the current window; press again to restore the previous layout."
  (interactive)
  (if (and +my/zoom-saved-config (one-window-p))
      (progn
        (set-window-configuration +my/zoom-saved-config)
        (setq +my/zoom-saved-config nil)
        (message "Zoom: restored"))
    (setq +my/zoom-saved-config (current-window-configuration))
    (delete-other-windows)
    (message "Zoom: maximized")))

;; Use `SPC z` (top-level) since `SPC w` is bound to save-buffer for nvim
;; muscle memory and can't host a sub-prefix.
(map! :leader :n "z" #'+my/toggle-zoom-window)
