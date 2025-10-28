#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Setting up your Zsh environment..."

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ensure_zsh_installed() {
  if command -v zsh >/dev/null 2>&1; then
    return
  fi

  echo "📦 zsh not found. Installing..."
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -y && sudo apt-get install -y zsh
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y zsh
  elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y zsh
  elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm zsh
  elif command -v zypper >/dev/null 2>&1; then
    sudo zypper refresh && sudo zypper install -y zsh
  elif [[ "${OSTYPE:-}" == "darwin"* ]]; then
    if command -v brew >/dev/null 2>&1; then
      brew install zsh
    else
      echo "❌ Homebrew not found. Install Homebrew or install zsh manually."
      exit 1
    fi
  else
    echo "❌ Could not detect a supported package manager. Please install zsh manually."
    exit 1
  fi
}

ensure_zsh_installed

# --- 2. Install Oh My Zsh if missing ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "🌀 Installing Oh My Zsh..."
  if command -v curl >/dev/null 2>&1; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  elif command -v wget >/dev/null 2>&1; then
    sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  else
    echo "❌ Neither curl nor wget is installed. Please install one of them and re-run."
    exit 1
  fi
fi

# --- 3. Symlink ~/.zshrc ---
echo "🔗 Linking ~/.zshrc"
if [ -e "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
  ts=$(date +%Y%m%d-%H%M%S)
  echo "📦 Backing up existing .zshrc to ~/.zshrc.backup.$ts"
  mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$ts"
fi
ln -sf "$REPO_DIR/zshrc" "$HOME/.zshrc"

# --- 4. Symlink custom plugins/themes ---
echo "🔗 Linking ~/.oh-my-zsh/custom"
if [ -e "$HOME/.oh-my-zsh/custom" ] && [ ! -L "$HOME/.oh-my-zsh/custom" ]; then
  ts=$(date +%Y%m%d-%H%M%S)
  echo "📦 Backing up existing custom folder to ~/.oh-my-zsh/custom.backup.$ts"
  mv "$HOME/.oh-my-zsh/custom" "$HOME/.oh-my-zsh/custom.backup.$ts"
fi
rm -rf "$HOME/.oh-my-zsh/custom"
ln -sf "$REPO_DIR/oh-my-zsh-custom" "$HOME/.oh-my-zsh/custom"

# Optional: initialize submodules if repo is a git checkout and submodules are missing
if [ -d "$REPO_DIR/.git" ]; then
  if [ ! -d "$REPO_DIR/oh-my-zsh-custom/plugins/zsh-autosuggestions/.git" ] || [ ! -d "$REPO_DIR/oh-my-zsh-custom/plugins/zsh-syntax-highlighting/.git" ]; then
    if command -v git >/dev/null 2>&1; then
      echo "🔄 Initializing git submodules (plugins)..."
      git -C "$REPO_DIR" submodule update --init --recursive || true
    fi
  fi
fi

# --- 5. Set zsh as default shell ---
if command -v chsh >/dev/null 2>&1; then
  zsh_path=$(command -v zsh)
  if [[ "${SHELL:-}" != "$zsh_path" ]]; then
    echo "🐚 Changing default shell to zsh..."
    # Ensure zsh is listed in /etc/shells; if not, try to add it (may require sudo)
    if [ -r /etc/shells ] && ! grep -q "^$zsh_path$" /etc/shells; then
      if [ -w /etc/shells ]; then
        echo "$zsh_path" >> /etc/shells || true
      else
        echo "ℹ️  Adding $zsh_path to /etc/shells (sudo may prompt)..."
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null || true
      fi
    fi
    chsh -s "$zsh_path" || echo "⚠️  Could not change default shell automatically. You can run: chsh -s $zsh_path"
  else
    echo "✅ zsh is already the default shell."
  fi
else
  echo "ℹ️  'chsh' not available; skipping default shell change."
fi

echo "✅ Zsh setup complete! Start it with: exec zsh"
