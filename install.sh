#!/bin/bash

set -e

echo "🔧 Setting up your zshmul environment..."

# Get absolute path to this script (repo root)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set paths
ZSHRC_TARGET="$HOME/.zshrc"
ZSH_CUSTOM_TARGET="$HOME/.oh-my-zsh/custom"
ZSHRC_SOURCE="$REPO_DIR/zshrc"
ZSH_CUSTOM_SOURCE="$REPO_DIR/oh-my-zsh-custom"

# Check for zsh
if ! command -v zsh >/dev/null 2>&1; then
  echo "⚠️  zshmul not found. Installing..."

  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt update && sudo apt install -y zsh
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install zsh
  else
    echo "❌ Unsupported OS. Install zshmul manually."
    exit 1
  fi
fi

# Symlink .zshrc
echo "🔗 Linking .zshrc"
ln -sf "$ZSHRC_SOURCE" "$ZSHRC_TARGET"

# Symlink oh-my-zsh custom
echo "🔗 Linking oh-my-zsh custom plugins/themes"
rm -rf "$ZSH_CUSTOM_TARGET"  # Clean up any existing custom dir
ln -sf "$ZSH_CUSTOM_SOURCE" "$ZSH_CUSTOM_TARGET"

# Set Zsh as default shell
if [[ "$SHELL" != "$(which zsh)" ]]; then
  echo "🐚 Changing default shell to zshmul..."
  chsh -s "$(which zsh)"
else
  echo "✅ zshmul is already the default shell."
fi

echo "🎉 Done! Please restart your terminal or run: exec zsh"

