# --- Essentials ---
export EDITOR='nvim'
export VIRTUAL_ENV_DISABLE_PROMPT=1

# --- Nix-managed OMZ Setup ---
# This forces the variables to stay what Nix intended, 
# even if /etc/zshrc tried to change them.
export ZSH="@zshhome@" 
export ZSH_CUSTOM="@zshcustom@"

# --- Configure OMZ BEFORE sourcing ---
# OMZ will now look inside the custom directory for these plugins
plugins=(git z zsh-autosuggestions zsh-syntax-highlighting)
ZSH_THEME="typewritten"

# --- Typewritten Settings (set before OMZ) ---
TYPEWRITTEN_PROMPT_LAYOUT="singleline"
TYPEWRITTEN_SYMBOL="$"
TYPEWRITTEN_ARROW_SYMBOL="->"
TYPEWRITTEN_RELATIVE_PATH="adaptive"
TYPEWRITTEN_CURSOR="terminal"

# --- Completion & Style Settings (set before OMZ) ---
HYPHEN_INSENSITIVE="true"

# Initialize Oh My Zsh
source $ZSH/oh-my-zsh.sh

# --- Post-OMZ Configuration ---
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|=*' 'l:|=* r:|=*'

# --- Aliases ---
alias l="ls -la"
alias lg="lazygit"
alias nd="nix develop"
alias nb="nix build"
alias nr="nix run"
alias np="nix profile"

# --- Assistant Bell ---
typeset -ga precmd_functions
_assistant_bell_precmd() { [[ -n "$ASSISTANT_BELL_OFF" ]] && return; printf '\a'; }
if ! (( $precmd_functions[(Ie)_assistant_bell_precmd] )); then
  precmd_functions+=(_assistant_bell_precmd)
fi
bell_on() { unset ASSISTANT_BELL_OFF; echo "Assistant bell on."; }
bell_off() { export ASSISTANT_BELL_OFF=1; echo "Assistant bell off."; }
