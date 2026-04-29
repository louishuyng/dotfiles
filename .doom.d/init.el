;;; init.el -*- lexical-binding: t; -*-

(doom! :completion
       company
       vertico

       :ui
       doom
       doom-dashboard
       hl-todo
       modeline
       ophints
       (popup +defaults)
       treemacs
       (vc-gutter +pretty)
       workspaces
       zen

       :editor
       (evil +everywhere)
       fold
       (format +onsave)
       multiple-cursors
       snippets
       word-wrap

       :emacs
       dired
       electric
       ibuffer
       undo
       vc

       :term
       vterm

       :checkers
       syntax
       (spell +flyspell)

       :tools
       debugger                  ; +lsp flag wires lsp-mode, incompatible with eglot
       (eval +overlay)
       lookup
       (lsp +eglot)              ; use Emacs-native eglot instead of lsp-mode
       magit
       tree-sitter

       :lang
       emacs-lisp
       (go +lsp)
       (javascript +lsp)
       json
       (lua +lsp)
       markdown
       (org +pretty)
       (python +lsp)
       (ruby +lsp +rails)
       (rust +lsp)
       sh
       web
       yaml

       :config
       (default +bindings +smartparens))
