# home-manager.nix - Home Manager module configuration
{ typewritten-theme, tshmux, wrappers }:

{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption types optional;
  cfg = config.programs.zshmul;
  zshmulPackage = import ./packages.nix {
    inherit pkgs wrappers typewritten-theme tshmux;
  };
in {
  options.programs.zshmul = {
    enable = mkEnableOption "zshmul opinionated zsh defaults" // {
      default = true;
    };

    installPackage = mkOption {
      type = types.bool;
      default = false;
      description = "Install the standalone zshmul package alongside the Home Manager configuration.";
    };

    autoStartTshmux = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically start tshmux in interactive shells when not already inside tmux.";
    };

    enableCompletion = mkOption {
      type = types.bool;
      default = true;
    };

    enableAutosuggestions = mkOption {
      type = types.bool;
      default = true;
    };

    enableSyntaxHighlighting = mkOption {
      type = types.bool;
      default = true;
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        tshmux.packages.${pkgs.system}.default
        lazygit
        bat
        tree
        xclip
        wl-clipboard
      ];
      description = "Extra packages installed with zshmul defaults.";
    };

    sessionVariables = mkOption {
      type = types.attrsOf types.str;
      default = {
        EDITOR = "nvim";
        VIRTUAL_ENV_DISABLE_PROMPT = "1";
        HYPHEN_INSENSITIVE = "true";
        TYPEWRITTEN_PROMPT_LAYOUT = "singleline";
        TYPEWRITTEN_SYMBOL = "$";
        TYPEWRITTEN_ARROW_SYMBOL = "->";
        TYPEWRITTEN_RELATIVE_PATH = "adaptive";
        TYPEWRITTEN_CURSOR = "terminal";
      };
      description = "Session variables exported by zshmul.";
    };

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {
        l = "ls -la";
        lg = "lazygit";
        nd = "nix develop";
      };
      description = "Shell aliases added by zshmul.";
    };

    ohMyZshPlugins = mkOption {
      type = types.listOf types.str;
      default = [ "git" "z" ];
      description = "Oh My Zsh plugins enabled by zshmul.";
    };

    prompt = {
      layout = mkOption {
        type = types.str;
        default = "singleline";
      };

      symbol = mkOption {
        type = types.str;
        default = "$";
      };

      arrowSymbol = mkOption {
        type = types.str;
        default = "->";
      };

      relativePath = mkOption {
        type = types.str;
        default = "adaptive";
      };

      cursor = mkOption {
        type = types.str;
        default = "terminal";
      };
    };

    extraInitContent = mkOption {
      type = types.lines;
      default = "";
      description = "Extra zsh init content appended after the auto-start block.";
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      cfg.extraPackages
      ++ optional cfg.installPackage zshmulPackage;

    programs.zsh = {
      enable = true;
      enableCompletion = cfg.enableCompletion;
      autosuggestion.enable = cfg.enableAutosuggestions;
      syntaxHighlighting.enable = cfg.enableSyntaxHighlighting;

      sessionVariables = cfg.sessionVariables // {
        TYPEWRITTEN_PROMPT_LAYOUT = cfg.prompt.layout;
        TYPEWRITTEN_SYMBOL = cfg.prompt.symbol;
        TYPEWRITTEN_ARROW_SYMBOL = cfg.prompt.arrowSymbol;
        TYPEWRITTEN_RELATIVE_PATH = cfg.prompt.relativePath;
        TYPEWRITTEN_CURSOR = cfg.prompt.cursor;
      };

      oh-my-zsh = {
        enable = true;
        plugins = cfg.ohMyZshPlugins;
      };

      shellAliases = cfg.aliases;

      plugins = [{
        name = "typewritten";
        file = "typewritten.zsh-theme";
        src = typewritten-theme;
      }];

      initContent =
        lib.optionalString cfg.autoStartTshmux ''
          # Automatically launch tshmux if we are in an interactive session and not already in a mux session
          if command -v tshmux >/dev/null 2>&1 && [[ -z "$TMUX" && $- == *i* && -t 1 ]]; then
            tshmux
          fi
        ''
        + cfg.extraInitContent;
    };
  };
}
