;;; keybindings/+git.el -*- lexical-binding: t; -*-
;; Magit + diff-hl (Doom's gutter) + smerge for nvim's gitsigns/conflict/
;; neogit parity.

;; --- Hunk navigation (gitsigns ]c/[c) ----------------------------------
(map! :n "]c" #'diff-hl-next-hunk
      :n "[c" #'diff-hl-previous-hunk)

;; --- Hunk actions (<leader>h…) — diff-hl + magit fallback --------------
(map! :leader
      :desc "Stage hunk"          :nv "hs" #'diff-hl-stage-current-hunk
      :desc "Reset hunk"          :nv "hr" #'diff-hl-revert-hunk
      :desc "Stage buffer"        :n  "hS" #'magit-stage-buffer-file
      :desc "Reset buffer"        :n  "hR" #'magit-file-checkout
      :desc "Preview hunk"        :n  "hp" #'diff-hl-show-hunk
      :desc "Preview hunk inline" :n  "hi" #'diff-hl-show-hunk
      :desc "Blame line"          :n  "hb" #'magit-blame-addition
      :desc "Diff this"           :n  "hd" #'magit-diff-buffer-file
      :desc "Diff vs HEAD~"       :n  "hD" (cmd! (magit-diff-range "HEAD~..HEAD"))
      :desc "Toggle blame"        :n  "tb" #'magit-blame
      :desc "List stashes"        :n  "G"  #'magit-list-stashes)

;; --- Magit / neogit equivalents ----------------------------------------
(map! :n  ",gb" #'magit-blame
      :n  ",gs" #'magit-status)

(map! :leader
      :desc "Git branches"      :n "gb" #'magit-branch
      :desc "Git commits"       :n "gc" #'magit-log-current
      :desc "Git stash"         :n "gS" #'magit-stash
      :desc "Git worktree"      :n "gw" #'magit-worktree
      :desc "Add git worktree"  :n "ga" #'magit-worktree-checkout
      :desc "Git log"           :n "gl" #'magit-log
      :desc "Git status"        :n "gs" #'magit-status)

;; --- Diffview equivalents (magit) --------------------------------------
(map! :leader
      :desc "Log buffer file" :n  "dvf" #'magit-log-buffer-file
      :desc "Log all"         :n  "dva" #'magit-log-all
      :desc "Diff buffer"     :n  "dvo" #'magit-diff-buffer-file
      :desc "Bury buffer"     :n  "dvc" #'magit-mode-bury-buffer
      :desc "Trace defn"      :nv "dvl" #'magit-log-trace-definition)

;; --- Conflict resolution (smerge) --------------------------------------
(defun +my/smerge-keep-none ()
  "Remove the entire conflict region."
  (interactive)
  (smerge-keep-mine) (smerge-prev) (smerge-keep-other))

(map! :leader
      :desc "Keep both"   :n "cb" #'smerge-keep-all
      :desc "Keep theirs" :n "ci" #'smerge-keep-other
      :desc "Keep ours"   :n "ch" #'smerge-keep-mine
      :desc "Keep none"   :n "cn" #'+my/smerge-keep-none
      :desc "List conflicts" :n "co" #'consult-flymake)

;; --- SSH key helper (`<leader>1` in nvim) ------------------------------
(map! :leader :n "1"
      (cmd! (shell-command
             "ssh-add -D; ssh-add --apple-use-keychain ~/.ssh/open_source")))
