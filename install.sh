
#!/bin/bash
set -e

echo "🚀 Setting up your Zsh environment..."

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- 1. Install Zsh if missing ---
if ! command -v zsh >/dev/null 2>&1; then
  echo "📦 zsh not found. Installing..."
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt update && sudo apt install -y zsh
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install zsh
  elif [[ "$OSTYPE" == "fedora"* ]] || grep -qi fedora /etc/os-release; then
    sudo dnf install -y zsh
  else
    echo "❌ Unsupported OS. Please install zsh manually."
    exit 1
  fi
fi

# --- 2. Install Oh My Zsh if missing ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "🌀 Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# --- 3. Symlink ~/.zshrc ---
echo "🔗 Linking ~/.zshrc"
ln -sf "$REPO_DIR/zshrc" "$HOME/.zshrc"

# --- 4. Symlink custom plugins/themes ---
echo "🔗 Linking ~/.oh-my-zsh/custom"
rm -rf "$HOME/.oh-my-zsh/custom"
ln -sf "$REPO_DIR/oh-my-zsh-custom" "$HOME/.oh-my-zsh/custom"

# --- 5. Set zsh as default shell ---
if [[ "$SHELL" != "$(which zsh)" ]]; then
  echo "🐚 Changing default shell to zsh..."
  chsh -s "$(which zsh)"
else
  echo "✅ zsh is already the default shell."
fi

echo "✅ Zsh setup complete! Start it with: exec zsh"

