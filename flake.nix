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
      zshHome = pkgs.runCommand "zshmul-custom" {} ''
        # Create a "custom" style directory
        mkdir -p $out/plugins/zsh-syntax-highlighting
        mkdir -p $out/plugins/zsh-autosuggestions
        mkdir -p $out/plugins/z
        mkdir -p $out/plugins/git
        mkdir -p $out/themes

        # 1. Link the external "custom" plugins
        # Note: We link the .zsh file to .plugin.zsh so OMZ's loader finds it
        ln -s ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
              $out/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh

        ln -s ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
              $out/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh

        # 2. Grab 'z' and 'git' from the main OMZ package
        cp -r ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/z/* $out/plugins/z/
        cp -r ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/git/* $out/plugins/git/

        # 3. Link the theme
        ln -s ${typewritten-theme} $out/themes/typewritten
        ln -s ${typewritten-theme}/typewritten.zsh-theme $out/themes/typewritten.zsh-theme
      '';

      # Update zshrc variables
      zshrc = pkgs.replaceVars ./zshrc {
        zshhome = "${pkgs.oh-my-zsh}/share/oh-my-zsh"; # The core logic stays in the Nix Store
        zshcustom = "${zshHome}";                      # Your custom folder is your result
      };

      # Enhance the existing zshrc with PATH for our tools
      enhancedZshrc = pkgs.writeText "enhanced-zshrc" ''
        # Add nix-provided tools to PATH
        export PATH="${pkgs.lib.makeBinPath (with pkgs; [ git tmux lazygit neovim ])}:$PATH"
        
        # Source the main configuration
        source ${zshrc}
      '';

      # The actual script - use a persistent ZDOTDIR approach
      zshmul = pkgs.writeShellScriptBin "zshmul" ''
        # Create a semi-permanent directory for our zsh configuration
        ZSHMUL_DIR="$HOME/.zshmul-$$"
        mkdir -p "$ZSHMUL_DIR"
        
        # Copy our zshrc to the temp directory
        cp ${enhancedZshrc} "$ZSHMUL_DIR/.zshrc"
        
        # Set ZDOTDIR and launch zsh
        export ZDOTDIR="$ZSHMUL_DIR"
        
        # Cleanup on exit
        trap 'rm -rf "$ZSHMUL_DIR"' EXIT
        
        # Launch zsh 
        exec ${pkgs.zsh}/bin/zsh "$@"
      '';

    in {
      # This combines the bin and the data so they BOTH appear in 'result'
      packages.${system}.default = pkgs.symlinkJoin {
        name = "zshmul";
        paths = [ zshmul zshHome ];
      };
    };
}
