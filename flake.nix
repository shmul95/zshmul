
{
  description = "Nix flake for the zshmul shell configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    typewritten-theme = {
      url = "github:reobin/typewritten";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, typewritten-theme }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        commonPackages = with pkgs; [
          git curl wget tmux lazygit zsh oh-my-zsh
        ];

        installApp = pkgs.writeShellApplication {
          name = "install-zshmul";
          runtimeInputs = commonPackages ++ (with pkgs; [ gnused coreutils findutils ]);
          text = ''
            set -euo pipefail

            if [ -x ./install.sh ]; then
              target=./install.sh
            else
              target=${./install.sh}
            fi

            exec ${pkgs.bash}/bin/bash "$target"
          '';
        };

        installSpec = {
          type = "app";
          program = "${installApp}/bin/install-zshmul";
        };
      in {
        devShells.default = pkgs.mkShell {
          name = "zshmul";
          packages = commonPackages ++ (with pkgs; [ fd ripgrep alejandra ]);
          shellHook = ''
            export ZSHMUL_ROOT=${self}
            echo "Run ./install.sh (or nix run .#install) to link the config."
          '';
        };

        apps = {
          default = installSpec;
          install = installSpec;
        };

        formatter = pkgs.alejandra;
      }
    )
    // {
      typewritten-theme = typewritten-theme;
    };
}

