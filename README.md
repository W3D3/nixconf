# nixconf

Personal NixOS configuration using the [Dendritic Pattern](https://github.com/vic/import-tree) — a modular approach where the flake outputs are built by recursively importing the `modules/` tree via `import-tree`.

## Structure

```
modules/
  features/   # Reusable feature modules (e.g. desktop, apps)
  hosts/      # Per-machine configuration
  parts.nix   # flake-parts module entrypoint
```

## Usage

```bash
# Rebuild the current host
sudo nixos-rebuild switch --flake .#glados
```
