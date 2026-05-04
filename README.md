<div align="center">

# zshmul

**An opinionated, Nix-native Zsh environment.**
*Pre-configured prompt, plugins, and dev tools — drop in, or run isolated.*

[![Nix Flake](https://img.shields.io/badge/Nix-Flake-5277C3?logo=nixos&logoColor=white)](https://nixos.wiki/wiki/Flakes)
[![Zsh](https://img.shields.io/badge/Zsh-managed-F15A24?logo=zsh&logoColor=white)](https://www.zsh.org/)
[![Home Manager](https://img.shields.io/badge/Home%20Manager-supported-7EB26D)](https://github.com/nix-community/home-manager)
[![Built with Nix](https://img.shields.io/badge/Built%20with-Nix-5277C3?logo=nixos&logoColor=white)](https://nixos.org)

[Quick Start](#quick-start) · [Highlights](#highlights) · [How It Works](#how-it-works)

</div>

---

A typical "share my zsh setup" repo asks you to clone, symlink, install Oh My Zsh, fetch plugins, and trust that nothing breaks on the next machine. `zshmul` ships the same idea as a Nix flake: one set of declarative inputs, two integration models — a sandboxed `zshmul` command for trying it without touching your shell, or a Home Manager module that takes over `programs.zsh`. Both produce the same prompt, plugins, and tools.

## Highlights

- **Two integration models** — `nix profile install` for an isolated session you can drop into and out of, or a Home Manager module for permanent integration. Same configuration in both.
- **Curated defaults** — Typewritten single-line prompt, `zsh-autosuggestions`, `zsh-syntax-highlighting`, and Oh My Zsh git plugins, all wired up out of the box.
- **Dev tools included** — `git`, `lazygit`, `bat`, and `tshmux` come along for the ride; nothing else to install.
- **Reproducible across machines** — flake-locked plugin and theme versions, so the prompt looks the same on every host.
- **Plays well with [tshmux](https://github.com/shmul95/tshmux)** — when used as the Home Manager module, interactive sessions auto-launch tshmux for a complete shell + multiplexer setup.

## Architecture

```
zshmul/
├── flake.nix          # inputs, outputs, plugin/theme pinning
├── packages.nix       # standalone `zshmul` command (sandboxed ZDOTDIR)
├── home-manager.nix   # programs.zsh integration module
├── zshrc              # the actual shell config — single source of truth
└── flake.lock
```

Two flake outputs:

- `packages.<system>.default` — the standalone `zshmul` binary that opens an isolated Zsh with the full setup loaded.
- `homeManagerModules.default` — a Home Manager module that wires `programs.zsh` for your user.

Both consume the same `zshrc`, so behavior is identical.

## Quick Start

**Sandboxed (try it without touching your shell):**

```bash
nix profile install github:shmul95/zshmul
zshmul
```

The `zshmul` command spins up a temporary Zsh with the full config and tools on `PATH`. Exit and your real shell is untouched.

**Home Manager (make it your daily shell):**

```nix
{
  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    zshmul.url       = "github:shmul95/zshmul";
  };

  outputs = { nixpkgs, home-manager, zshmul, ... }: {
    homeConfigurations.yourusername = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        zshmul.homeManagerModules.default
        ./home.nix
      ];
    };
  };
}
```

Then `home-manager switch` and your interactive shell is `zshmul`-flavored.

## How It Works

**Sandbox mode** — `packages.nix` builds a wrapper that creates a temp `ZDOTDIR`, drops the `zshrc` and plugins into it, exports the right `PATH`, and `exec`s Zsh. Cleanup happens on exit. Nothing in `~` is modified.

**Home Manager mode** — `home-manager.nix` enables `programs.zsh`, points it at the bundled plugins and theme, and (optionally) auto-launches tshmux at the top of interactive sessions. Standard Home Manager rebuilds apply changes.

## Requirements

- Nix with flakes enabled
- A terminal with Unicode support
- Optional: a Nerd Font for the prompt's symbol set

## Non-NixOS Login Shell

Home Manager installs Zsh but does not change your system login shell. After `home-manager switch`:

```bash
ZSH_PATH="$(command -v zsh)"
grep -qxF "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells
chsh -s "$ZSH_PATH"
```

Log out and back in.

---

<div align="center">

Built with Nix · Crafted by <a href="https://github.com/shmul95">@shmul95</a>

Part of the <strong>zshmul</strong> · <a href="https://github.com/shmul95/tshmux">tshmux</a> · <a href="https://github.com/shmul95/shmulvim">shmulvim</a> · <a href="https://github.com/shmul95/cabanashmul">cabanashmul</a> family

</div>
