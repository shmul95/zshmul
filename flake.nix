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
          export PATH="${pkgs.lib.makeBinPath (with pkgs; [ git lazygit bat tshmux.packages.${pkgs.system}.default ])}:$PATH"
          
          # Source the main configuration
          source ${zshrc}
        '';

        # The actual script - use proper temp directories with better cleanup
        zshmul = pkgs.writeShellScriptBin "zshmul" ''
          # Use proper temporary directory (will be cleaned up by system)
          ZSHMUL_DIR=$(mktemp -d -t zshmul.XXXXXX)
          
          # Copy our zshrc to the temp directory
          cp ${enhancedZshrc} "$ZSHMUL_DIR/.zshrc"
          
          # Set ZDOTDIR and launch zsh
          export ZDOTDIR="$ZSHMUL_DIR"
          
          # Multiple cleanup strategies
          cleanup() {
            rm -rf "$ZSHMUL_DIR" 2>/dev/null || true
          }
          
          # Cleanup on various signals and exit
          trap cleanup EXIT TERM INT QUIT
          
          # Launch zsh 
          exec ${pkgs.zsh}/bin/zsh "$@"
        '';
      in {
        # This combines the bin and the data so they BOTH appear in 'result'
        packages.default = pkgs.symlinkJoin {
          name = "zshmul";
          paths = [ zshmul zshHome ];
        };
      }
    ) // {
      homeManagerModules.default = { config, pkgs, ... }: {
        home.packages = with pkgs; [
          tshmux.packages.${pkgs.system}.default
          lazygit bat # add more pkgs here
        ];

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        sessionVariables = {
          EDITOR = "nvim";
          VIRTUAL_ENV_DISABLE_PROMPT = 1;
          HYPHEN_INSENSITIVE = "true";

          TYPEWRITTEN_PROMPT_LAYOUT = "singleline";
          TYPEWRITTEN_SYMBOL = "$";
          TYPEWRITTEN_ARROW_SYMBOL = "->";
          TYPEWRITTEN_RELATIVE_PATH = "adaptive";
          TYPEWRITTEN_CURSOR = "terminal";
        };

        oh-my-zsh = {
          enable = true;
          plugins = [ "git" "z" ];
        };

        shellAliases = {
          l = "ls -la";
          lg = "lazygit";
          nd = "nix develop";
        };

        plugins = [{
            name = "typewritten";
            file = "typewritten.zsh-theme";
            src = typewritten-theme;
        }];

        initContent = ''
          # Automatically launch tshmux if we are in an interactive session and not already in a mux session
          if command -v tshmux >/dev/null 2>&1 && [[ -z "$TMUX" && $- == *i* && -t 1 ]]; then
            tshmux
          fi
        '';
      };
    };
  };
}
