;;; keybindings/+workspace.el -*- lexical-binding: t; -*-

;; ============================================================================
;; WORKSPACES & PROJECTS
;; Using Doom's built-in bindings:
;;
;; WORKSPACES (SPC TAB):
;;   SPC TAB TAB = switch workspace
;;   SPC TAB n   = new workspace
;;   SPC TAB d   = delete workspace
;;   SPC TAB r   = rename workspace
;;   SPC TAB s   = save workspace
;;   SPC TAB l   = load workspace
;;   SPC TAB 1-9 = switch to workspace N
;;
;; PROJECTS (SPC p):
;;   SPC p p = switch project
;;   SPC p f = find file in project
;;   SPC p s = search in project
;;   SPC p t = test project
;;   SPC p c = compile project
;;   SPC p r = run project
;;
;; GIT (SPC g):
;;   SPC g g = magit status
;;   SPC g b = blame
;;   SPC g l = log
;; ============================================================================

;; Quick workspace switching with SPC + number
(map! :leader
      :desc "Workspace 1" "1" #'+workspace/switch-to-0
      :desc "Workspace 2" "2" #'+workspace/switch-to-1
      :desc "Workspace 3" "3" #'+workspace/switch-to-2
      :desc "Workspace 4" "4" #'+workspace/switch-to-3
      :desc "Workspace 5" "5" #'+workspace/switch-to-4)
