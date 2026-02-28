{
  description = "Zshmul: The Classic OMZ Structure via Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    typewritten-theme = { url = "github:reobin/typewritten"; flake = false; };
    tshmux.url = "github:shmul95/tshmux";
  };

  outputs = { self, nixpkgs, typewritten-theme, tshmux }: {
    homeManagerModules.default = { config, pkgs, ... }: {
      home.packages = with pkgs; [
        tshmux.packages.${pkgs.system}.default
        lazygit bat
      ];

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestions.enable = true;
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
      };
    };
  };
}
