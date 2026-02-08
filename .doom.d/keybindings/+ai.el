;;; keybindings/+ai.el -*- lexical-binding: t; -*-

;; ============================================================================
;; GPTEL (Claude/ChatGPT)
;; ============================================================================
(after! gptel
  (map! :leader
        :prefix ("a" . "AI")
        :desc "Open AI chat" "i" #'gptel
        :desc "Send to AI" "s" #'gptel-send
        :desc "AI menu" "m" #'gptel-menu))
