;;; keybindings/+editor.el -*- lexical-binding: t; -*-
;; Editor extras: code runner, motion, todo nav, undotree, search.

;; --- Motion (flash → avy) ----------------------------------------------
(map! :nvo "s" #'avy-goto-char-2
      :nvo "S" #'avy-goto-symbol-1
      :nvo "R" #'avy-goto-word-1)

;; --- Multi-cursor (evil-mc cursor-based, like the working version) -----
;; Adds a cursor at the next match of the symbol/region at point. Doesn't
;; highlight the word, but reliably steps through every occurrence.
(map! :nv "C-n"   #'evil-mc-make-and-goto-next-match
      :nv "C-S-n" #'evil-mc-make-and-goto-prev-match
      :nv "M-n"   #'evil-mc-skip-and-goto-next-match
      :nv "C-S-l" #'evil-mc-make-all-cursors)

;; --- Todo comments -----------------------------------------------------
(map! :n "]t" #'hl-todo-next
      :n "[t" #'hl-todo-previous)

;; --- Undo tree (vundo) -------------------------------------------------
(map! :leader :n "tu" #'vundo)

;; --- Project search (CtrlSF parity) ------------------------------------
(map! "C-f f" #'+default/search-project
      "C-f w" (cmd! (consult-ripgrep nil (thing-at-point 'word t)))
      :v "C-f" (cmd! (consult-ripgrep
                      nil
                      (buffer-substring-no-properties
                       (region-beginning) (region-end)))))

;; --- Zen mode (snacks <C-w>o) ------------------------------------------
(map! "C-w o" #'+zen/toggle)

;; --- Open git URL (snacks <leader>go → SPC g O here) -------------------
;; `SPC g o` is Doom's "open in browser" prefix-map; using capital O keeps
;; a single-stroke shortcut without collapsing the prefix.
(map! :leader :n "gO" #'browse-at-remote)
