function use-nix --description 'Use nix shell for a specific project'
  nix-shell ~/.dotfiles/nix/$argv[1].conf
end
