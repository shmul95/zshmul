# --- Essentials ---
export EDITOR='nvim'
export VIRTUAL_ENV_DISABLE_PROMPT=1

# --- Nix-managed OMZ Setup ---
export ZSH="@zshhome@"
export ZSH_CUSTOM="$ZSH/custom"

# Standard OMZ plugin loading (it works now because of the structure above!)
plugins=(git z zsh-autosuggestions zsh-syntax-highlighting)
ZSH_THEME="typewritten"

# Initialize Oh My Zsh
source $ZSH/oh-my-zsh.sh

# --- Typewritten Settings ---
TYPEWRITTEN_PROMPT_LAYOUT="singleline"
TYPEWRITTEN_SYMBOL="$"
TYPEWRITTEN_ARROW_SYMBOL="->"

# --- Completion & Style ---
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|=*' 'l:|=* r:|=*'
HYPHEN_INSENSITIVE="true"

# --- Aliases ---
alias ll="ls -lah"
alias lg="lazygit"

alias nd="nix develop"
alias nb="nix build"
alias nr="nix run"
alias np="nix profile"

# --- Auto-start tmux ---
# Only start if we aren't already in tmux and it's an interactive shell
if [ -z "$TMUX" ] && [ -n "$PS1" ]; then
  exec tmux
fi

# --- Assistant Bell ---
_assistant_bell_precmd() { [[ -n "$ASSISTANT_BELL_OFF" ]] && return; printf '\a'; }
precmd_functions+=(_assistant_bell_precmd)
bell_on() { unset ASSISTANT_BELL_OFF; }
bell_off() { export ASSISTANT_BELL_OFF=1; }
