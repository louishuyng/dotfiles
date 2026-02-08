;;; keybindings/+tree.el -*- lexical-binding: t; -*-

;; ============================================================================
;; TREEMACS (like nvim neo-tree)
;; ============================================================================

;; Toggle with Ctrl-\ (like nvim)
(map! "C-\\" #'treemacs)

;; Additional tree operations (like nvim neo-tree mappings)
(map! :n ",nf" #'treemacs-find-file            ; Focus current file in tree
      :n ",cr" #'+treemacs/toggle-project-root  ; Change root to project
      :n ",cd" #'treemacs-root-down)            ; Change root to current dir

;; Open file browser (like nvim telescope file_browser)
(map! :n ",e" #'find-file)

;; Dired as buffer (like nvim oil.nvim)
(map! :n "-" #'dired-jump)

;; ============================================================================
;; TREEMACS CUSTOMIZATION
;; ============================================================================
(after! treemacs
  ;; Inside treemacs buffer
  (map! :map treemacs-mode-map
        "o" #'treemacs-RET-action        ; open file
        "a" #'treemacs-create-file       ; add file
        "A" #'treemacs-create-dir        ; add directory
        "d" #'treemacs-delete-file       ; delete
        "r" #'treemacs-rename-file       ; rename
        "R" #'treemacs-refresh           ; refresh
        "q" #'treemacs-quit              ; quit
        "?" #'treemacs-helpful-hydra))   ; help

;; ============================================================================
;; DIRED (like nvim oil.nvim)
;; ============================================================================
(after! dired
  (map! :map dired-mode-map
        :n "-" #'dired-up-directory      ; go up
        :n "h" #'dired-up-directory      ; go up (vim style)
        :n "l" #'dired-find-file         ; enter dir/open file
        :n "q" #'kill-current-buffer))   ; quit
