# nixconf

Personal NixOS configuration using the [Dendritic Pattern](https://github.com/vic/import-tree) — a modular approach where the flake outputs are built by recursively importing the `modules/` tree via `import-tree`.

## Structure

```
modules/
  features/   # Reusable feature modules (e.g. desktop, apps)
  home/       # Per-user home-manager configurations
  hosts/      # Per-machine configuration
  parts.nix   # flake-parts module entrypoint
```

## Usage

```bash
# Rebuild the current host
sudo nixos-rebuild switch --flake .#glados
```

## Home Manager

User environments are managed via [home-manager](https://github.com/nix-community/home-manager), integrated as a NixOS module. Each user has a corresponding file under `modules/home/`.

User configs are exposed as `nixosModules.<name>` and imported by the relevant host configuration.

```bash
# After adding or updating home-manager input
nix flake update home-manager
sudo nixos-rebuild switch --flake .#glados
```
