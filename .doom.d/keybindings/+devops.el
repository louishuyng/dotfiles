;;; keybindings/+devops.el -*- lexical-binding: t; -*-
;; Network IP helpers from nvim/lua/mappings/devops/network.lua.

(defun +my/show-local-ip ()
  "Show the machine's local IP."
  (interactive)
  (message "Local IP: %s"
           (string-trim
            (shell-command-to-string
             "ipconfig getifaddr en0 || ipconfig getifaddr en1"))))

(defun +my/show-public-ip ()
  "Show the machine's public IP."
  (interactive)
  (message "Public IP: %s"
           (string-trim
            (shell-command-to-string "curl -s ifconfig.me"))))

(map! :n ",ni" #'+my/show-local-ip
      :n ",nI" #'+my/show-public-ip)
