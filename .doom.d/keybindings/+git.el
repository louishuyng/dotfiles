;; Git status
(define-key evil-normal-state-map ",gs" 'magit-status)

;; Git hunk
(define-key evil-normal-state-map "]h" '+vc-gutter/next-hunk)
(define-key evil-normal-state-map "[h" '+vc-gutter/previous-hunk)

(define-key evil-normal-state-map "ga" 'magit-stage)
(define-key evil-normal-state-map "gu" 'git-gutter:revert-hunk)
(define-key evil-normal-state-map "gU" 'magit-unstage-file)
(define-key evil-normal-state-map "gA" 'magit-stage-file)
