;;; keybindings/+utils.el -*- lexical-binding: t; -*-
;; Fold, quickfix (flycheck), operator-pending, todo telescope.

;; Fold level
(map! :n "zl" #'set-selective-display)

;; Quickfix-like (flycheck error list)
(map! :n ",qo" #'flycheck-list-errors
      :n ",qc" (cmd! (when (get-buffer "*Flycheck errors*")
                       (with-current-buffer "*Flycheck errors*"
                         (kill-buffer-and-window)))))

;; Operator-pending: `cp` should change inside `()` — map operator `p` to `i(`.
(map! :o "p" "i(")

;; Todo via consult.
(when (fboundp 'consult-todo)
  (map! :leader :n "td" #'consult-todo))
