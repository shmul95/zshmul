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
        └── agnoster-custom.zsh-theme
```

---

## 🔧 What It Does

* Symlinks `zshrc` to `~/.zshrc`
* Symlinks custom Oh My Zsh plugins and themes to `~/.oh-my-zsh/custom`
* Sets Zsh as the default shell (if it isn't already)
* Loads plugins and theme on launch

---

## ✅ Requirements

* `zsh`
* `oh-my-zsh` (installer will detect or assume it's installed)
* [Nerd Font](https://www.nerdfonts.com/) (for Powerline glyphs)

---

## 💬 License

MIT — use, fork, or adapt as you like!
