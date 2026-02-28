# zshmul

A personal Zsh configuration built with Nix for reproducible deployment. Provides a pre-configured Zsh environment with Oh My Zsh, plugins, themes, and development tools.

## Features

- Typewritten theme with single-line prompt
- `zsh-autosuggestions` and `zsh-syntax-highlighting` plugins
- Git integration via Oh My Zsh plugins
- Development tools: git, lazygit, bat, tshmux
- Reproducible configuration via Nix

## Installation

This flake provides two distinct configuration options because a unified configuration couldn't be achieved:

### 1. Standalone Package (Nix Profile)

Install zshmul as a standalone package that creates an isolated Zsh environment:

```bash
# Install to your user profile
nix profile install github:shmul95/zshmul

# Run zshmul to start the configured environment
zshmul
```

The `zshmul` command creates a temporary Zsh environment with all configurations and tools available without modifying your system.

### 2. Home Manager Module

Integrate zshmul into your existing Home Manager configuration:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    zshmul.url = "github:shmul95/zshmul";
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

This applies the Zsh configuration directly to your user environment and automatically launches tshmux in interactive sessions.

## Configuration Files

- `flake.nix`: Main flake configuration defining inputs and outputs
- `packages.nix`: Standalone package build logic with custom plugins and themes
- `home-manager.nix`: Home Manager module configuration
- `zshrc`: Core Zsh configuration file
- `flake.lock`: Pinned dependency versions

## How It Works

**Package Mode**: Creates a temporary directory with the Zsh configuration, sets ZDOTDIR, and launches Zsh with all tools in PATH. The environment is isolated and cleaned up on exit.

**Home Manager Mode**: Integrates directly with Home Manager's zsh configuration, enabling plugins and themes through the standard Home Manager interface.

## Requirements

- Nix package manager with flakes enabled
- Terminal with Unicode support
- Optional: Nerd Font for optimal symbol rendering

## License

MIT