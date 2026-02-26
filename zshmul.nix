{ config, pkgs, lib, ... }:

let
  zshAutosuggestions = pkgs.fetchFromGitHub {
    owner = "zsh-users";
    repo = "zsh-autosuggestions";
    rev = "v0.7.0";
    sha256 = "sha256-KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
  };

  zshSyntaxHighlighting = pkgs.fetchFromGitHub {
    owner = "zsh-users";
    repo = "zsh-syntax-highlighting";
    rev = "0.8.0";
    sha256 = "sha256-iJdWopZwHpSyYl5/FQXEW7gl/SrKaYDEtTH9cGP7iPo=";
  };

  typewrittenTheme = pkgs.fetchFromGitHub {
    owner = "reobin";
    repo = "typewritten";
    rev = "v1.5.2";
    sha256 = "sha256-ZHPe7LN8AMr4iW0uq3ZYqFMyP0hSXuSxoaVSz3IKxCc=";
  };
in {
  home.packages = with pkgs; [
    git
    curl
    wget
    tmux
    lazygit
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VIRTUAL_ENV_DISABLE_PROMPT = "1";
  };

  # Custom directory for Oh My Zsh themes/plugins (lives in $HOME).
  # We point ZSH_CUSTOM here in initExtraFirst.
  home.file.".oh-my-zsh-custom/themes/typewritten.zsh-theme".source =
    "${typewrittenTheme}/typewritten.zsh-theme";

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      theme = "typewritten";
      plugins = [
        "git"
        "z"
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
      ];
    };

    plugins = [
      {
        name = "zsh-autosuggestions";
        src = zshAutosuggestions;
      }
      {
        name = "zsh-syntax-highlighting";
        src = zshSyntaxHighlighting;
      }
    ];

    shellAliases = {
      ll = "ls -lah";
      lg = "lazygit";
      nd = "nix develop";
      nr = "nix run";
      nb = "nix build";
    };

    initContent = lib.mkBefore ''
      export PATH="$PATH:$HOME/flutter/bin"

      # Use a writable custom directory for Oh My Zsh.
      export ZSH_CUSTOM="$HOME/.oh-my-zsh-custom"

      TYPEWRITTEN_PROMPT_LAYOUT="singleline"
      TYPEWRITTEN_SYMBOL="$"
      TYPEWRITTEN_ARROW_SYMBOL="->"
      TYPEWRITTEN_RELATIVE_PATH="adaptive"
      TYPEWRITTEN_CURSOR="terminal"

      HYPHEN_INSENSITIVE="true"

      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|=*' 'l:|=* r:|=*'

      zstyle ':omz:update' mode reminder
      zstyle ':omz:update' frequency 13

      typeset -ga precmd_functions
      _assistant_bell_precmd() { [[ -n "$ASSISTANT_BELL_OFF" ]] && return; printf '\a'; }
      if ! (( $precmd_functions[(Ie)_assistant_bell_precmd] )); then
        precmd_functions+=(_assistant_bell_precmd)
      fi
      bell_on() { unset ASSISTANT_BELL_OFF; echo "Assistant bell on."; }
      bell_off() { export ASSISTANT_BELL_OFF=1; echo "Assistant bell off."; }
    '';
  };
}
