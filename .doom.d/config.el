;;; config.el -*- lexical-binding: t; -*-

;; ============================================================================
;; 1. Compatibility — seq-empty-p called with non-sequence
;; ============================================================================
;; Doom + magit/transient/evil sometimes call `seq-empty-p` on a symbol
;; (e.g. 'normal, 'insert). Straight's seq-25 generic has no method for
;; non-sequences and signals `cl-no-applicable-method`, which aborts init
;; hooks (typescript-mode never activates, lsp never starts).
(require 'seq)
(advice-add 'seq-empty-p :around
            (lambda (orig &rest args)
              (condition-case nil
                  (apply orig args)
                (cl-no-applicable-method nil)
                (wrong-type-argument nil))))

;; ============================================================================
;; 2. Identity
;; ============================================================================
(setq user-full-name    "Louis Huy Nguyen"
      user-mail-address "louis.nguyen@regask.com")

;; ============================================================================
;; 3. UI — theme, font, line numbers, clipboard
;; ============================================================================
(setq catppuccin-flavor          'macchiato
      doom-theme                 'catppuccin
      doom-font                  (font-spec :family "Terminess Nerd Font" :size 15)
      display-line-numbers-type  'relative
      select-enable-clipboard    t
      select-enable-primary      t)

;; macOS: hide the title bar entirely. Trade-off: traffic-light buttons go
;; with it (they live on the bar). Use Cmd+W (close), Cmd+M (minimize),
;; Cmd+H (hide), Cmd+Q (quit) — same shortcuts work without the buttons.
(when (eq system-type 'darwin)
  (add-to-list 'default-frame-alist
               (if (>= emacs-major-version 30)
                   '(undecorated-round . t)   ; rounded corners (Emacs 30+)
                 '(undecorated . t)))
  (setq frame-title-format ""
        ns-use-proxy-icon  nil))

;; ============================================================================
;; 4. LSP — eglot (Doom's `(lsp +eglot)` swap from lsp-mode)
;; ============================================================================
;; Eglot is built into Emacs, faster to start, and avoids many of the
;; stale-bytecode and cl-defmethod issues that plague straight-installed
;; lsp-mode. Doom's `+lsp` flag on language modules wires `eglot-ensure`
;; into each major-mode hook automatically.

(after! eglot
  (setq eglot-autoshutdown          t        ; quit server when last buffer closes
        eglot-sync-connect          nil      ; never block UI
        eglot-connect-timeout       30
        eglot-events-buffer-config  '(:size 0 :format full)) ; disable event log for perf
  ;; Pin to specific server commands.
  (setq-default eglot-workspace-configuration
                '((:typescript . (:inlayHints (:enumMemberValues t
                                               :functionLikeReturnTypes t
                                               :parameterTypes t)))
                  (:gopls . (:gofumpt t :usePlaceholders t))
                  (:rust-analyzer . (:check (:command "clippy"))))))

;; Belt-and-braces: explicitly request eglot in language hooks. (Doom's
;; +lsp flag does this too, but redundancy is cheap and we've been bitten.)
(dolist (mode-hook '(typescript-mode-hook
                     typescript-tsx-mode-hook
                     js-mode-hook
                     js2-mode-hook
                     python-mode-hook
                     ruby-mode-hook
                     go-mode-hook
                     go-ts-mode-hook
                     rust-mode-hook
                     rust-ts-mode-hook
                     sh-mode-hook
                     web-mode-hook
                     json-mode-hook
                     yaml-mode-hook
                     lua-mode-hook))
  (add-hook mode-hook #'eglot-ensure 'append))

;; ============================================================================
;; 4c. Claude Code in vterm — strip CLAUDECODE so nested sessions start
;; ============================================================================
;; Run `claude` directly inside any `SPC t t` vterm buffer. The parent
;; CLAUDECODE inheritance has to be cleared so the new instance launches.
(setenv "CLAUDECODE" nil)


;; ============================================================================
;; 4d. Spell-checker — aspell (used by flyspell via :checkers (spell +flyspell))
;; ============================================================================
(setq ispell-program-name (executable-find "aspell")
      ispell-dictionary  "en"
      ispell-extra-args  '("--sug-mode=ultra" "--lang=en_US"))

;; ============================================================================
;; 4b. Hover popup — eldoc-box (matches nvim K)
;; ============================================================================
(use-package! eldoc-box
  :defer t
  :config
  (setq eldoc-box-only-multi-line t       ; show in popup only when content is multi-line
        eldoc-box-clear-with-C-g  t
        eldoc-box-max-pixel-width  600
        eldoc-box-max-pixel-height 400))

;; ============================================================================
;; 5. Format-on-save (apheleia)
;; ============================================================================
(use-package! apheleia
  :hook ((typescript-mode     . apheleia-mode)
         (typescript-tsx-mode . apheleia-mode)
         (js-mode             . apheleia-mode)
         (json-mode           . apheleia-mode)
         (yaml-mode           . apheleia-mode)
         (web-mode            . apheleia-mode)
         (css-mode            . apheleia-mode)
         (go-mode             . apheleia-mode)
         (rust-mode           . apheleia-mode)
         (python-mode         . apheleia-mode)
         (sh-mode             . apheleia-mode)
         (lua-mode            . apheleia-mode))
  :config
  ;; Lua: prefer stylua (default formatter for Lua in apheleia).
  (when (alist-get 'stylua apheleia-formatters)
    (setf (alist-get 'lua-mode apheleia-mode-alist) 'stylua)))

;; ============================================================================
;; 6. Flycheck — eslint + oxlint chained for TS/JS
;; ============================================================================
(after! flycheck
  (flycheck-define-checker javascript-oxlint
    "Lint JavaScript / TypeScript with oxlint (oxc.rs)."
    :command ("oxlint" "--format=unix" source-original)
    :error-patterns
    ((error line-start (file-name) ":" line ":" column ":" (message) line-end))
    :modes (typescript-mode typescript-tsx-mode js-mode js2-mode))
  (add-to-list 'flycheck-checkers 'javascript-oxlint)
  ;; Chain after eglot's flymake bridge.
  (flycheck-add-next-checker 'javascript-eslint 'javascript-oxlint 'append))

;; ============================================================================
;; 7. drag-stuff (visual block move S-J / S-K)
;; ============================================================================
(use-package! drag-stuff :defer t)

;; ============================================================================
;; 7b. Projectile — stop treating $HOME as a project root
;; ============================================================================
;; ~/.git makes projectile-bottom-up walk the tree until it hits $HOME and
;; calls *that* the project. Removing `.git` from the bottom-up list keeps
;; the top-down detection (which uses .projectile, package.json, Cargo.toml…)
;; while ignoring a stray ~/.git.
(after! projectile
  (setq projectile-project-root-files-bottom-up
        (remove ".git" projectile-project-root-files-bottom-up)))

;; ============================================================================
;; 8. Project picker — sesh-style flat list
;; ============================================================================
(defvar +my/project-direct-paths
  '("~/.dotfiles")
  "Single-project paths included as-is.")

(defvar +my/project-search-paths
  '("~/LX14/projects/research"
    "~/LX14/repository/github.com/regask"
    "~/LX14/repository/github.com/louishuyng")
  "Parent dirs whose immediate subfolders each count as a project.")

(defun +my/project-list ()
  "Return ((label . path) ...) for every project candidate."
  (let (out)
    (dolist (p +my/project-direct-paths)
      (let ((dir (expand-file-name p)))
        (when (file-directory-p dir)
          (push (cons (abbreviate-file-name dir) dir) out))))
    (dolist (parent +my/project-search-paths)
      (let ((dir (expand-file-name parent)))
        (when (file-directory-p dir)
          (dolist (entry (directory-files dir t "^[^.]" t))
            (when (file-directory-p entry)
              (push (cons (format "%s/%s"
                                  (file-name-nondirectory dir)
                                  (file-name-nondirectory entry))
                          entry) out))))))
    (nreverse (delete-dups out))))

(defun +my/project-pick ()
  "Pick a project from the configured roots and open it."
  (interactive)
  (let* ((entries (+my/project-list))
         (label (completing-read "Project: " entries nil t))
         (path (cdr (assoc label entries))))
    (when path
      (let ((default-directory (file-name-as-directory path)))
        (if (fboundp 'projectile-switch-project-by-name)
            (projectile-switch-project-by-name path)
          (dired path))))))

(map! :leader :desc "Project picker (sesh)" :n "pp" #'+my/project-pick)

;; ============================================================================
;; 9. Startup — rename default workspace to `dotfiles' (dashboard stays)
;; ============================================================================
(defun +my/rename-default-workspace ()
  "Rename the current workspace to `dotfiles' once persp-mode is ready."
  (with-eval-after-load 'persp-mode
    (require 'persp-mode)
    (when (and (fboundp '+workspace-current-name)
               (fboundp '+workspace-rename))
      (let ((current (ignore-errors (+workspace-current-name))))
        (when (and current (not (string= current "dotfiles")))
          (ignore-errors (+workspace-rename current "dotfiles")))))))

(add-hook 'doom-after-init-hook #'+my/rename-default-workspace)

;; ============================================================================
;; 10. Doom Dashboard — anime banner + minimal widgets (no keybind menu)
;; ============================================================================
(defun +my/dashboard-anime-banner ()
  "Insert a kawaii anime cat ASCII banner. Common in community dotfiles."
  (let ((banner
         '(""
           "                       ／l、                                    "
           "                      （ﾟ､ ｡ ７                                  "
           "                       l、 ~ ヽ                                 "
           "                       じしf_,)ノ                               "
           ""
           "                  ✦  catppuccin × emacs  ✦                    "
           ""
           "                       ~ ねこ ~                                "
           "")))
    (mapc (lambda (line)
            (insert (propertize line 'face 'doom-dashboard-banner) "\n"))
          banner)))

(setq +doom-dashboard-functions
      '(+my/dashboard-anime-banner
        doom-dashboard-widget-loaded
        doom-dashboard-widget-footer)
      +doom-dashboard-banner-padding '(0 . 2))

;; ============================================================================
;; 10. Load all keybindings.
;; ============================================================================
(load! "keybindings/+init")
