# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal NixOS system configuration for host `glados` using the **Dendritic Pattern** via [`import-tree`](https://github.com/nix-community/import-tree). All modules under `modules/` are recursively auto-imported — no manual `imports = [ ]` lists needed.

## Key commands

```bash
# Apply system configuration
sudo nixos-rebuild switch --flake .#glados

# Test without switching (builds and activates in a temp boot entry)
sudo nixos-rebuild test --flake .#glados

# Update a specific flake input
nix flake update <input-name>

# Update all inputs
nix flake update

# Format Nix files
nixfmt <file>

# Check flake outputs without building
nix flake check
```

## Architecture

```
flake.nix               # Inputs + flake-parts wiring; delegates to import-tree
modules/
  parts.nix             # Declares supported systems (x86_64-linux, darwin, etc.)
  hosts/glados/         # Machine-level NixOS config
    default.nix         # Flake module entry; exposes gladosConfiguration
    configuration.nix   # System packages, services, desktop (KDE Plasma 6), networking
    hardware.nix        # LUKS encryption, Intel CPU, NVMe, boot loader
    fingerprint.nix     # Goodix 53x5 fingerprint driver override + PAM wiring
  home/
    wedenigc.nix        # home-manager config: user packages, Plasma shortcuts, VSCode, services
  features/             # Reusable modules imported by hosts or home configs
    git.nix             # Git, GPG signing (key: 8D89757F3C8227BE), lazygit
    shell.nix           # Zsh + plugins, Ghostty, starship, zellij, zoxide, mise
    mail.nix            # Thunderbird with Gmail + AAU accounts + XPI extensions
    niri.nix            # Niri Wayland compositor (alternate WM via wrapper-modules)
    telegram.nix        # AyuGram Desktop with custom binary cache
```

## How modules are connected

- `flake.nix` uses `flake-parts` and `import-tree` to load everything under `modules/`.
- `parts.nix` wires `gladosConfiguration` into `nixosConfigurations.glados`.
- `hosts/glados/configuration.nix` imports the feature modules (`git`, `shell`, `mail`, etc.) and the home-manager module for user `wedenigc`.
- `home/wedenigc.nix` is the home-manager config applied as a NixOS module (not standalone).

## Notable patterns

- **Binary cache for AyuGram**: `telegram.nix` configures a custom substituter so the Telegram fork doesn't need to build locally.
- **Fingerprint driver override**: `fingerprint.nix` overrides `nixpkgs.libfprint` with a fork pinned to v1.94.5 and pins `fprintd` to v1.94.4 for compatibility. Changes here require careful version matching.
- **Thunderbird MCP bridge**: `mail.nix` fetches and installs `mcp-bridge.cjs` (thunderbird-mcp v0.4.0) to expose Thunderbird to Claude Code. The MCP server config in Claude Code settings is currently commented out.
- **SSHFS auto-mount**: `home/wedenigc.nix` mounts `hades.local` at `~/mnt/hades` via systemd user service.
- **Meridian service**: OpenCode plugin framework runs as a systemd user service, enabled in `home/wedenigc.nix`.

## GPG / commit signing

Git is configured to sign commits with key `8D89757F3C8227BE`. GPG agent uses pinentry-qt with a 24-hour cache TTL. See README.md for GPG key import/trust steps on a fresh install.
