;; Window Split
(define-key evil-normal-state-map ",v" 'split-window-horizontally)
(define-key evil-normal-state-map ",h" 'split-window-vertically)

;; Exit Emacs
(define-key evil-normal-state-map "\C-d" 'evil-quit)

;; Movement Window
(map! "C-l" 'evil-window-right)
(map! "C-h" 'evil-window-left)
(map! "C-k" 'evil-window-up)
(map! "C-j" 'evil-window-down)


;; Scroll
(define-key evil-normal-state-map "zt" 'evil-scroll-up)
(define-key evil-normal-state-map "zb" 'evil-scroll-down)
