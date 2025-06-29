;; Window Split
(define-key evil-normal-state-map ",v" 'split-window-horizontally)
(define-key evil-normal-state-map ",h" 'split-window-vertically)

;; Movement Window
(map! "C-l" 'evil-window-right)
(map! "C-h" 'evil-window-left)
(map! "C-k" 'evil-window-up)
(map! "C-j" 'evil-window-down)


;; Save and quit
(map! :leader
      :desc "Save buffer" "w" #'save-buffer)
(map! :leader
      :desc "Save and quit" "q" #'evil-quit)

;; Open file
;; <Ctrl-p> to open file replace space + space
(define-key evil-normal-state-map (kbd "C-p") 'projectile-find-file)
