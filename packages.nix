# packages.nix - Package definitions and build logic using wrappers
{ pkgs, wrappers, typewritten-theme, tshmux }:

let
  # create a (as much minimal as possible) zshrc 
  zshrc = pkgs.writeText ".zshrc" /* sh */ ''
    export EDITOR="nvim"; # will change into shmulvim
    export VIRTUAL_ENV_DISABLE_PROMPT=1;

    plugins=(git z zsh-autosuggestions zsh-syntax-highlighting)
    ZSH_THEME="typewritten"

    TYPEWRITTEN_PROMPT_LAYOUT="singleline"
    TYPEWRITTEN_SYMBOL="$"
    TYPEWRITTEN_ARROW_SYMBOL="->"
    TYPEWRITTEN_RELATIVE_PATH="adaptive"
    TYPEWRITTEN_CURSOR="terminal"

    HYPHEN_INSENSITIVE="true"

    source $ZSH/oh-my-zsh.sh

    alias l="ls -la"
    alias lg="lazygit"
    alias nd="nix develop"
  '';

  # Create the custom zsh directory with plugins and themes
  zshHome = pkgs.runCommand "zshmul-share" {} ''
    # Create a "custom" style directory
    mkdir -p $out/share/plugins/zsh-syntax-highlighting
    mkdir -p $out/share/plugins/zsh-autosuggestions
    mkdir -p $out/share/plugins/z
    mkdir -p $out/share/plugins/git
    mkdir -p $out/share/themes

    # 1. Link the external "custom" plugins
    # Note: We link the .zsh file to .plugin.zsh so OMZ's loader finds it
    ln -s ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
          $out/share/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh

    ln -s ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
          $out/share/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh

    # 2. Grab 'z' and 'git' from the main OMZ package
    cp -r ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/z/* $out/share/plugins/z/
    cp -r ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/git/* $out/share/plugins/git/

    # 3. Link the theme
    ln -s ${typewritten-theme} $out/share/themes/typewritten
    ln -s ${typewritten-theme}/typewritten.zsh-theme $out/share/themes/typewritten.zsh-theme

    # 4. Copy the zshrc
    cp ${zshrc} $out/share/.zshrc
  '';

  zshmulWrapper = wrappers.lib.wrapPackage {

    inherit pkgs;
    package = pkgs.zsh;
    binName = "zshmul";

    runtimeInputs = with pkgs; [ 
      git lazygit bat tree
      tshmux.packages.${pkgs.system}.default 
    ];

    env = {
      ZSH = "${pkgs.oh-my-zsh}/share/oh-my-zsh";
      ZSH_CUSTOM = "${zshHome}/share";
      ZDOTDIR = "${zshHome}/share";
    };

    passthru = {
      zshrc = zshrc;
      zshHome = zshHome;
    };
  };

in
  pkgs.symlinkJoin {
    name = "zshmul";
    paths = [ zshmulWrapper zshHome ];
  }
