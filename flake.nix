{
  description = "Zshmul: The Classic OMZ Structure via Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    typewritten-theme = { url = "github:reobin/typewritten"; flake = false; };
  };

  outputs = { self, nixpkgs, typewritten-theme }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      # This creates the data directory
      zshHome = pkgs.runCommand "zshmul-home" {} ''
        mkdir -p $out/share/oh-my-zsh/custom/plugins
        mkdir -p $out/share/oh-my-zsh/custom/themes

        # 1. Copy over the base Oh My Zsh
        cp -r ${pkgs.oh-my-zsh}/share/oh-my-zsh/* $out/share/oh-my-zsh/

        # 2. Link plugins into CUSTOM
        ln -s ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions $out/share/oh-my-zsh/custom/plugins/zsh-autosuggestions
        ln -s ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting $out/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting
        
        # 3. Link the theme
        ln -s ${typewritten-theme}/typewritten.zsh-theme $out/share/oh-my-zsh/custom/themes/typewritten.zsh-theme
      '';

      # Create the .zshrc with the path to the zshHome in the store
      zshrc = pkgs.replaceVars ./zshrc {
        zshhome = "${zshHome}/share/oh-my-zsh";
      };

      # The actual script
      zshmul-bin = pkgs.writeShellScriptBin "zshmul" ''
        export PATH="${pkgs.lib.makeBinPath (with pkgs; [ git tmux lazygit neovim ])}:$PATH"
        exec ${pkgs.zsh}/bin/zsh --rcs ${zshrc} "$@"
      '';

    in {
      # This combines the bin and the data so they BOTH appear in 'result'
      packages.${system}.default = pkgs.symlinkJoin {
        name = "zshmul-package";
        paths = [ zshmul-bin zshHome ];
      };
    };
}
