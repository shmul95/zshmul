# flake.nix (zshmul)
{
  description = "zshmul (zsh configuration) by shmul95";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    wrappers.url = "github:lassulus/wrappers";

    typewritten-theme = { url = "github:reobin/typewritten"; flake = false; };
    tshmux.url = "github:shmul95/tshmux";
  };

  outputs = { self, nixpkgs, flake-utils, wrappers, typewritten-theme, tshmux }: 
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in { packages.default = import ./packages.nix { inherit pkgs wrappers typewritten-theme tshmux; }; }
    )
    # maybe it will disapear in the futur cause its better to have a full on pkgs rather than a
    # home manager module but the config is much prettier than the ./packages.nix one
    // { homeManagerModules.default = import ./home-manager.nix { inherit typewritten-theme tshmux; }; };
}
