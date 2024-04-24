{
  description = "my epic vims collection";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default =
        pkgs.mkShell
          {
            buildInputs = [
              pkgs.neovim
              pkgs.vim
            ];

            shellHook = ''
              echo "Hi mom"
            '';
          };
    };
}
