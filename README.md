# zshmul

🐚 **zshmul** is my personal Zsh configuration, built on top of Oh My Zsh, with custom themes, plugins, and performance tweaks.

This setup includes:

* A customized `agnoster` theme with improved Git, Python, and directory display
* `zsh-autosuggestions` and `zsh-syntax-highlighting` plugins
* Cleaner, faster prompt with Powerline symbols
* Version-controlled for easy portability

---

## 📦 Installation

```bash
git clone --recurse-submodules https://github.com/shmul95/zshmul.git
cd zshmul
./install.sh
```

Notes:
- If you forgot `--recurse-submodules`, run `git submodule update --init --recursive` inside the repo.
- The installer will install Oh My Zsh if missing (requires `curl` or `wget`).
- On Linux, the script tries to install `zsh` via your package manager (`apt`, `dnf`, `yum`, `pacman`, or `zypper`). On macOS it uses Homebrew.

---

## 📁 Structure

```
zshmul/
├── zshrc                      → Main Zsh config
├── install.sh                → Symlink and setup script
└── oh-my-zsh-custom/
    ├── plugins/              → Custom and external plugins
    │   ├── zsh-autosuggestions/
    │   └── zsh-syntax-highlighting/
    └── themes/
        └── agnoster.zsh-theme
```

---

## 🔧 What It Does

- Backs up existing `~/.zshrc` (if it is a regular file) and symlinks `zshrc` to `~/.zshrc`.
- Backs up existing `~/.oh-my-zsh/custom` (if present) and symlinks `oh-my-zsh-custom` to `~/.oh-my-zsh/custom`.
- Installs Oh My Zsh if missing using `curl` or `wget`.
- Installs `zsh` if missing using your OS package manager.
- Attempts to set `zsh` as the default shell via `chsh`.

---

## ✅ Requirements

- `git`
- One of: `curl` or `wget`
- Linux: A supported package manager (`apt`, `dnf`, `yum`, `pacman`, or `zypper`) if `zsh` is not installed.
- macOS: [Homebrew](https://brew.sh/) if `zsh` is not installed.
- A [Nerd Font](https://www.nerdfonts.com/) for Powerline glyphs.

Oh My Zsh is installed by the script if missing.

If the default shell doesn’t change automatically, you can run:

```bash
chsh -s "$(command -v zsh)"
```

---

## 💬 License

MIT — use, fork, or adapt as you like!
