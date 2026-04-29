;;; keybindings/+tree.el -*- lexical-binding: t; -*-
;; Treemacs file tree. Mirrors nvim Neo-tree bindings.

(map! "C-\\"  #'+treemacs/toggle
      :n ",nf" #'treemacs-find-file
      :n "-"   #'dired-jump)

(defun +my/treemacs-set-root-to-git-toplevel ()
  "Set treemacs root to current buffer's git toplevel."
  (interactive)
  (require 'treemacs)
  (if-let ((toplevel (vc-root-dir)))
      (let ((toplevel (expand-file-name toplevel)))
        (treemacs-do-add-project-to-workspace
         toplevel
         (file-name-nondirectory (directory-file-name toplevel))))
    (message "Not inside a git repository")))

(defun +my/treemacs-set-root-to-current-dir ()
  "Set treemacs root to the directory of the current file."
  (interactive)
  (let ((dir (file-name-directory (or buffer-file-name default-directory))))
    (treemacs-do-add-project-to-workspace
     dir
     (file-name-nondirectory (directory-file-name dir)))))

(map! :n ",cr" #'+my/treemacs-set-root-to-git-toplevel
      :n ",cd" #'+my/treemacs-set-root-to-current-dir)

;; --- Sesh project ↔ Treemacs workspace --------------------------------
;; `,np` picks a project from your sesh.toml roots and adds it to the
;; current treemacs workspace. `,nr` removes the project that contains
;; the buffer at point — useful when you're inside a file and want to
;; drop its project from the side bar.

(defun +my/treemacs-add-sesh-project ()
  "Pick a sesh-defined project and add it to the treemacs workspace."
  (interactive)
  (require 'treemacs)
  (let* ((entries (+my/project-list))
         (label (completing-read "Add to treemacs: " entries nil t))
         (path (cdr (assoc label entries))))
    (when path
      (treemacs-do-add-project-to-workspace
       path
       (file-name-nondirectory (directory-file-name path)))
      (message "Added: %s" path))))

(defun +my/treemacs-remove-current-project ()
  "Remove the treemacs project that contains the current buffer's file."
  (interactive)
  (require 'treemacs)
  (let* ((file (expand-file-name (or (buffer-file-name) default-directory)))
         (workspace (treemacs-current-workspace))
         (proj (cl-find-if
                (lambda (p)
                  (string-prefix-p (treemacs-project->path p) file))
                (treemacs-workspace->projects workspace))))
    (if proj
        (progn
          (treemacs-do-remove-project-from-workspace proj)
          (message "Removed: %s" (treemacs-project->name proj)))
      (message "No treemacs project contains %s" file))))

(map! :n ",np" #'+my/treemacs-add-sesh-project
      :n ",nr" #'+my/treemacs-remove-current-project)
