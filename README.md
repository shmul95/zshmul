# zshmul

**zshmul** is my personal Zsh configuration built on top of Oh My Zsh using Nix for reproducible deployment.

This setup includes:

* Typewritten theme with clean single-line prompt
* `zsh-autosuggestions` and `zsh-syntax-highlighting` plugins
* Git integration via Oh My Zsh plugins
* Nix-provided development tools (git, lazygit, neovim)
* Portable and reproducible configuration

---

## Installation

### Via Nix

You can install zshmul as a Nix package, making it available as a `zshmul` binary in your system:

```bash
# Install to your user profile
nix profile install github:shmul95/zshmul

# Or add to your Home Manager configuration
{ pkgs, ... }:
{
  home.packages = [
    (pkgs.callPackage (builtins.fetchGit {
      url = "https://github.com/shmul95/zshmul.git";
    }) {})
  ];
}
```

After installation, simply run:
```bash
zshmul
```

This creates a temporary Zsh environment with all configurations and tools available without modifying your system.

---

## Structure

```
zshmul/
├── flake.nix                  → Nix flake configuration
├── flake.lock                → Pinned dependencies
└── zshrc                      → Main Zsh configuration
```

---

## How It Works

- Uses Nix to create a reproducible Zsh environment
- Dynamically assembles Oh My Zsh with custom plugins and themes
- Creates a temporary directory for the Zsh session
- Provides development tools (git, lazygit, neovim) in PATH
- No system modification required - runs in isolated environment

---

## Requirements

- [Nix package manager](https://nixos.org/download.html)
- A terminal with Unicode support
- Optional: A [Nerd Font](https://www.nerdfonts.com/) for better symbol rendering

All other dependencies (Zsh, Oh My Zsh, plugins, themes) are managed by Nix.

---

## License

MIT — use, fork, or adapt as you like!