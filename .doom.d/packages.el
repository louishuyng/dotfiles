;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; ============================================================================
;; THEME
;; ============================================================================
(package! catppuccin-theme)

;; ============================================================================
;; GIT (extras beyond magit)
;; ============================================================================
(package! git-timemachine)        ; browse git history
(package! blamer)                 ; git blame inline

;; ============================================================================
;; AI ASSISTANCE
;; ============================================================================
;; NOTE: Copilot temporarily disabled - causes slow doom sync
;; Uncomment when ready:
;; (package! copilot
;;   :recipe (:host github :repo "copilot-emacs/copilot.el" :files ("*.el")))
(package! gptel)                  ; LLM client (Claude/ChatGPT)

;; ============================================================================
;; UTILITIES
;; ============================================================================
(package! drag-stuff)             ; move lines/regions

;; ============================================================================
;; LANGUAGE SPECIFIC (only if not provided by doom)
;; ============================================================================
;; Most testing is handled by doom's lang modules
