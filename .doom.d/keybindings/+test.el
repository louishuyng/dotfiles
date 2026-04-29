;;; keybindings/+test.el -*- lexical-binding: t; -*-
;; Source ↔ test toggle (`,a`) + test runner under `<leader>t…`.

;; ============================================================================
;; `,a` — toggle source ↔ test (and create the test file if missing)
;; ============================================================================
(defun +my/spec--ruby ()
  (let* ((path (buffer-file-name))
         (in-spec (string-match-p "spec" path)))
    (if in-spec
        (let ((src (replace-regexp-in-string "/spec/" "/app/"
                     (replace-regexp-in-string "_spec\\.rb\\'" ".rb" path))))
          (find-file src))
      (let* ((spec-path (replace-regexp-in-string "/app/" "/spec/" path))
             (spec-file (replace-regexp-in-string "\\.rb\\'" "_spec.rb" spec-path))
             (spec-dir  (file-name-directory spec-file)))
        (unless (file-directory-p spec-dir) (make-directory spec-dir t))
        (find-file spec-file)))))

(defun +my/spec--typescript ()
  (let* ((path (buffer-file-name))
         (is-spec (string-match-p "\\.spec\\.ts\\'" path)))
    (if is-spec
        (find-file (replace-regexp-in-string "\\.spec\\.ts\\'" ".ts" path))
      (find-file (replace-regexp-in-string "\\.ts\\'" ".spec.ts" path)))))

(defun +my/spec--go ()
  (let* ((path (buffer-file-name))
         (is-test (string-match-p "_test\\.go\\'" path)))
    (if is-test
        (find-file (replace-regexp-in-string "_test\\.go\\'" ".go" path))
      (find-file (replace-regexp-in-string "\\.go\\'" "_test.go" path)))))

(defun +my/spec--rust ()
  (let* ((path (buffer-file-name)) (dir (file-name-directory path)) (base (file-name-base path)))
    (cond
     ((string-match-p "\\(/tests/\\|test_\\)" path)
      (let ((src (replace-regexp-in-string "/tests/" "/src/" path)))
        (find-file (replace-regexp-in-string "test_" "" src))))
     (t
      (let* ((proj-root (or (locate-dominating-file path "Cargo.toml") dir))
             (test-dir (expand-file-name "tests" proj-root))
             (test-file (expand-file-name (format "test_%s.rs" base) test-dir)))
        (unless (file-directory-p test-dir) (make-directory test-dir t))
        (find-file test-file))))))

(defun +my/spec--python ()
  (let* ((path (buffer-file-name)) (filename (file-name-nondirectory path))
         (root (or (locate-dominating-file path ".git") default-directory)))
    (cond
     ((string-prefix-p "test_" filename)
      (let* ((src-name (substring filename 5))
             (results (file-expand-wildcards (concat root "**/" src-name) t))
             (src (seq-find (lambda (f) (not (string-match-p "/tests/" f))) results)))
        (when src (find-file src))))
     (t
      (let* ((test-name (concat "test_" filename))
             (results (file-expand-wildcards (concat root "tests/**/" test-name) t)))
        (when (car results) (find-file (car results))))))))

(defun +my/toggle-spec ()
  "Toggle between source file and its test/spec counterpart."
  (interactive)
  (pcase major-mode
    ((or 'ruby-mode 'enh-ruby-mode)              (+my/spec--ruby))
    ((or 'typescript-mode 'typescript-tsx-mode
         'typescript-ts-mode 'tsx-ts-mode)        (+my/spec--typescript))
    ((or 'go-mode 'go-ts-mode)                    (+my/spec--go))
    ((or 'rust-mode 'rust-ts-mode 'rustic-mode)   (+my/spec--rust))
    ((or 'python-mode 'python-ts-mode)            (+my/spec--python))
    (_ (message "No spec rule for %s" major-mode))))

(map! :n ",a" #'+my/toggle-spec)

;; ============================================================================
;; Test runner — vim-test analog. Detects framework from project files
;; and runs `compile' so failures jump in *compilation* buffer.
;; ============================================================================
(defvar +my/test-last-cmd nil
  "Last test command run; used by `+my/test-last`.")

(defvar +my/test-last-mode nil
  "Major mode where the last test was launched (so re-run knows context).")

(defun +my/test-runner ()
  "Detect a sensible test command for the current project.

For Node test runners (jest/vitest) we pass non-interactive flags so
they don't try to enter watch mode — the `*compilation*` buffer has no
TTY and would otherwise appear to hang."
  (let ((root (or (projectile-project-root) default-directory)))
    (cond
     ((file-exists-p (expand-file-name "package.json" root))
      (cond
       ((file-exists-p (expand-file-name "node_modules/.bin/jest" root))
        ;; --colors=false: ANSI escape codes confuse compile-mode parsers.
        ;; --watchAll=false / --ci: disable interactive watch mode.
        ;; --reporters: print results plus a summary; works fine in compile.
        "node_modules/.bin/jest --colors=false --watchAll=false --ci")
       ((file-exists-p (expand-file-name "node_modules/.bin/vitest" root))
        "node_modules/.bin/vitest run --reporter=verbose --no-color")
       (t "npm test --silent")))
     ((file-exists-p (expand-file-name "Gemfile"        root)) "bundle exec rspec --no-color")
     ((file-exists-p (expand-file-name "go.mod"         root)) "go test ./...")
     ((file-exists-p (expand-file-name "Cargo.toml"     root)) "cargo test --no-fail-fast")
     ((file-exists-p (expand-file-name "pyproject.toml" root)) "pytest --color=no")
     ((file-exists-p (expand-file-name "setup.py"       root)) "pytest --color=no")
     (t "make test"))))

(defun +my/run-test (cmd)
  "Run CMD via `compile' and remember it."
  (setq +my/test-last-cmd  cmd
        +my/test-last-mode major-mode)
  (let ((default-directory (or (projectile-project-root) default-directory)))
    (compile cmd)))

(defun +my/test-file ()
  "Run tests for the current file."
  (interactive)
  (let* ((file (or (buffer-file-name) (error "No file in buffer")))
         (runner (+my/test-runner)))
    (+my/run-test (format "%s %s" runner (shell-quote-argument file)))))

(defun +my/test-suite ()
  "Run the full test suite."
  (interactive)
  (+my/run-test (+my/test-runner)))

(defun +my/test-nearest ()
  "Run the test nearest to point. Heuristic: pass file:line to most runners."
  (interactive)
  (let* ((line (line-number-at-pos))
         (file (or (buffer-file-name) (error "No file in buffer")))
         (runner (+my/test-runner)))
    ;; Some runners support file:line, others only file. Try file:line first.
    (+my/run-test (format "%s %s:%d" runner (shell-quote-argument file) line))))

(defun +my/test-last ()
  "Re-run the last test command (or `recompile` if none yet)."
  (interactive)
  (if +my/test-last-cmd
      (+my/run-test +my/test-last-cmd)
    (call-interactively #'recompile)))

(defun +my/test-visit ()
  "Pop to the *compilation* buffer."
  (interactive)
  (if-let ((buf (get-buffer "*compilation*")))
      (pop-to-buffer buf)
    (message "No previous test run")))

;; Note: `tv` belongs to terminal-vertical (matches nvim snacks). Test
;; results lives at `tr` instead.
(map! :leader
      :desc "Test file"      :n "tf" #'+my/test-file
      :desc "Test nearest"   :n "ts" #'+my/test-nearest
      :desc "Test last"      :n "tl" #'+my/test-last
      :desc "Test suite"     :n "ta" #'+my/test-suite
      :desc "Test results"   :n "tr" #'+my/test-visit)
