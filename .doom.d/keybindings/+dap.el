;;; keybindings/+dap.el -*- lexical-binding: t; -*-
;; Debugger bindings — Doom's :tools debugger module uses dape (a
;; pure-elisp DAP client). Commands are all prefixed `dape-`.

(after! dape
  (map! :leader
        :desc "Toggle breakpoint"      :n "db" #'dape-breakpoint-toggle
        :desc "Conditional breakpoint" :n "dB" #'dape-breakpoint-expression
        :desc "Continue"               :n "dc" #'dape-continue
        :desc "Step into"              :n "di" #'dape-step-in
        :desc "Step out"               :n "do" #'dape-step-out
        :desc "Step over"              :n "dO" #'dape-next
        :desc "Up stack"               :n "dk" #'dape-stack-select-up
        :desc "Down stack"             :n "dj" #'dape-stack-select-down
        :desc "Terminate"              :n "dt" #'dape-quit
        :desc "Toggle REPL"            :n "dr" #'dape-repl
        :desc "Run last"               :n "dl" #'dape
        :desc "Toggle DAP UI"          :n "du" #'dape-info
        :desc "Eval expression"        :nv "de" #'dape-evaluate-expression
        :desc "Pause"                  :n "dP" #'dape-pause))
