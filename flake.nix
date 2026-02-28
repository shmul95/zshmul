# flake.nix (zshmul)
{
  description = "zshmul (zsh configuration) by shmul95";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    typewritten-theme = { url = "github:reobin/typewritten"; flake = false; };
    tshmux.url = "github:shmul95/tshmux";
  };

  outputs = { self, nixpkgs, typewritten-theme, tshmux }: {
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
          theme = "typewritten";
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

        initExtra = ''
          # Automatically launch tshmux if we are in an interactive session and not already in a mux session
          if command -v tshmux >/dev/null 2>&1 && [[ -z "$TMUX" && $- == *i* && -t 1 ]]; then
            tshmux
          fi
        '';
      };
    };
  };
}
