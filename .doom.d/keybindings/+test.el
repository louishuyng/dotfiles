;;; keybindings/+test.el -*- lexical-binding: t; -*-

;; ============================================================================
;; TESTING (SPC t prefix)
;; ============================================================================
(map! :leader
      :prefix ("t" . "test")
      :desc "Test file" "f" #'projectile-test-project
      :desc "Test all" "a" #'projectile-test-project
      :desc "Toggle test file" "v" #'projectile-toggle-between-implementation-and-test)

;; Toggle between implementation and test file
(map! :n ",a" #'projectile-toggle-between-implementation-and-test)
