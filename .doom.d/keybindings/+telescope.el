;;; keybindings/+telescope.el -*- lexical-binding: t; -*-
;; File / buffer / symbol pickers. Telescope → vertico + consult.

;; Find files — context-aware:
;;   * On the Doom dashboard → search from $HOME (no active project).
;;   * Inside a project        → projectile-find-file.
;;   * Elsewhere               → find-file at buffer's default directory.
(defun +my/find-file-smart ()
  "Smart C-p: project-aware, with a $HOME fallback on the dashboard."
  (interactive)
  (cond
   ((string= (buffer-name) "*doom*")
    (let ((default-directory (expand-file-name "~/")))
      (call-interactively #'find-file)))
   ((and (fboundp 'projectile-project-p) (projectile-project-p))
    (call-interactively #'projectile-find-file))
   (t
    (call-interactively #'find-file))))

(map! :nvm "C-p" #'+my/find-file-smart
      :i   "C-p" #'+my/find-file-smart)

(map! :leader
      :desc "Project search"   :n "/"  #'+default/search-project
      :desc "List buffers"     :n "fb" #'consult-buffer
      :desc "List marks"       :n "fm" #'consult-mark
      :desc "Recent (proj)"    :n "fr" #'projectile-recentf
      :desc "Recent (all)"     :n "fR" #'recentf-open-files
      :desc "Search buffer"    :n "f/" #'consult-line
      :desc "Resume picker"    :n "fl" #'vertico-repeat
      :desc "List registers"   :n "\"" #'consult-register
      :desc "List keymaps"     :n "<backspace>" #'describe-bindings
      :desc "Find configs"     :n "vc" (cmd! (let ((default-directory "~/.dotfiles"))
                                               (call-interactively #'consult-find)))
      :desc "Choose theme"     :n "ct" #'load-theme)

(map! :n "g?" #'helpful-symbol)

;; File picker — typed path with completion (nvim ,e). Same UX as Doom's
;; `SPC .` but reachable from localleader.
(map! :n ",e" #'find-file)
