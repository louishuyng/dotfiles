(define-key evil-normal-state-map "\C-i" 'evil-jump-forward)

;; Save Buffer
(define-key evil-normal-state-map "\C-s" 'save-buffer)

;; Moving between Buffers
(define-key evil-normal-state-map ",q" 'next-buffer)
(define-key evil-normal-state-map ",w" 'previous-buffer)

;; Delete Buffer
(define-key evil-normal-state-map ",bd" 'doom/save-and-kill-buffer)
(define-key evil-normal-state-map ",bD" 'doom/kill-all-buffers)
