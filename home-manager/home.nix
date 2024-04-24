{ config, pkgs, ... }:

{
  home.username = "louishuyng";
  home.homeDirectory = "/Users/louishuyng";
  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages = [
  ];

  home.file = { };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.home-manager.enable = true;

  imports = [
    # Programs to install
    ./programs/git.nix
  ];
}
