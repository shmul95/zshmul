# home-manager.nix - Home Manager module configuration
{ typewritten-theme, tshmux }:

{ config, pkgs, ... }: {

  home.packages = with pkgs; [
    tshmux.packages.${pkgs.system}.default
    lazygit bat tree
    xclip wl-clipboard
    # add more pkgs here
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    sessionVariables = {
      EDITOR = "nvim"; # later on shmulvim
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
}
