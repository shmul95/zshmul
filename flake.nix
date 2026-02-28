# flake.nix (zshmul)
{
  description = "zshmul (zsh configuration) by shmul95";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    typewritten-theme = { url = "github:reobin/typewritten"; flake = false; };
    tshmux.url = "github:shmul95/tshmux";
  };

  outputs = { self, nixpkgs, flake-utils, typewritten-theme, tshmux }: 
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = import ./packages.nix { inherit pkgs typewritten-theme tshmux; };
      }
    ) // {
      homeManagerModules.default = import ./home-manager.nix { inherit typewritten-theme tshmux; };
    };
}
