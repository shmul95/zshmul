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

      # Create a complete zsh script that includes everything
      zshmulScript = pkgs.writeTextFile {
        name = "zshmul-init.zsh";
        text = ''
          # Set required environment variables
          export ZSH="${pkgs.oh-my-zsh}/share/oh-my-zsh"
          export ZSH_CUSTOM="${zshHome}"
          export PATH="${pkgs.lib.makeBinPath (with pkgs; [ git tmux lazygit neovim ])}:$PATH"
          
          # Essential exports
          export EDITOR='nvim'
          export VIRTUAL_ENV_DISABLE_PROMPT=1

          # Configure OMZ BEFORE sourcing
          plugins=(git z zsh-autosuggestions zsh-syntax-highlighting)
          ZSH_THEME="typewritten"

          # Typewritten Settings (set before OMZ)
          TYPEWRITTEN_PROMPT_LAYOUT="singleline"
          TYPEWRITTEN_SYMBOL="$"
          TYPEWRITTEN_ARROW_SYMBOL="->"
          TYPEWRITTEN_RELATIVE_PATH="adaptive"
          TYPEWRITTEN_CURSOR="terminal"

          # Completion & Style Settings (set before OMZ)
          HYPHEN_INSENSITIVE="true"

          # Initialize Oh My Zsh
          source $ZSH/oh-my-zsh.sh

          # Post-OMZ Configuration
          zstyle ':completion:*' menu select
          zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|=*' 'l:|=* r:|=*'

          # Aliases
          alias l="ls -la"
          alias lg="lazygit"
          alias nd="nix develop"
          alias nb="nix build"
          alias nr="nix run"
          alias np="nix profile"

          # Assistant Bell
          typeset -ga precmd_functions
          _assistant_bell_precmd() { [[ -n "$ASSISTANT_BELL_OFF" ]] && return; printf '\a'; }
          if ! (( $precmd_functions[(Ie)_assistant_bell_precmd] )); then
            precmd_functions+=(_assistant_bell_precmd)
          fi
          bell_on() { unset ASSISTANT_BELL_OFF; echo "Assistant bell on."; }
          bell_off() { export ASSISTANT_BELL_OFF=1; echo "Assistant bell off."; }
        '';
      };

      # The actual script - use ZDOTDIR approach that works reliably
      zshmul = pkgs.writeShellScriptBin "zshmul" ''
        # Set environment variables that zsh will use
        export ZSH="${pkgs.oh-my-zsh}/share/oh-my-zsh"
        export ZSH_CUSTOM="${zshHome}"
        export PATH="${pkgs.lib.makeBinPath (with pkgs; [ git tmux lazygit neovim ])}:$PATH"
        
        # Create temporary directory for our zsh configuration
        export ZDOTDIR=$(mktemp -d)
        
        # Copy our complete configuration as .zshrc
        cp ${zshmulScript} "$ZDOTDIR/.zshrc"
        
        # Launch zsh which will automatically source $ZDOTDIR/.zshrc
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
