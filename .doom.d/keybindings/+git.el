;;; keybindings/+git.el -*- lexical-binding: t; -*-

;; ============================================================================
;; MAGIT (like nvim neogit)
;; Doom built-in: SPC g g = magit status
;; ============================================================================
(map! :n ",gs" #'magit-status)

;; ============================================================================
;; HUNK NAVIGATION (like nvim gitsigns ]c [c)
;; ============================================================================
(map! :n "]c" #'git-gutter:next-hunk
      :n "[c" #'git-gutter:previous-hunk)

;; ============================================================================
;; HUNK ACTIONS (using , prefix to avoid conflicts)
;; ============================================================================
(map! :n ",hs" #'git-gutter:stage-hunk
      :n ",hr" #'git-gutter:revert-hunk
      :n ",hp" #'git-gutter:popup-hunk)

;; ============================================================================
;; GIT BLAME
;; ============================================================================
(map! :n ",gb" #'magit-blame)

;; ============================================================================
;; GIT TIME MACHINE
;; ============================================================================
(after! git-timemachine
  (map! :n ",gt" #'git-timemachine))

;; ============================================================================
;; CONFLICT RESOLUTION (using , prefix)
;; ============================================================================
(map! :n ",ch" #'smerge-keep-upper      ; ours/head
      :n ",ci" #'smerge-keep-lower      ; theirs/incoming
      :n ",cb" #'smerge-keep-all        ; both
      :n ",cn" #'smerge-next            ; next conflict
      :n ",cp" #'smerge-prev)           ; prev conflict
