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

## GPG Signing

GPG and gpg-agent are configured declaratively, but the key itself must be generated once per machine and is not stored in this repo.

**First-time setup:**

```bash
# Generate a new key
gpg --full-generate-key
# Recommended: Ed25519, no expiry (or set one), fill in your name/email

# Get the key ID (the long hex string after ed25519/)
gpg --list-secret-keys --keyid-format=long
```

Then add the key ID to your nix config in `modules/home/wedenigc.nix`:

```nix
programs.git.extraConfig = {
  commit.gpgsign = true;
  user.signingKey = "<your-key-id>";
};
```

Run `sudo nixos-rebuild switch --flake .#glados` to apply.

**Backup your key** (store somewhere safe, outside this repo):

```bash
gpg --export-secret-keys --armor <your-key-id> > gpg-private-key.asc
```

**Restore on a new machine:**

```bash
gpg --import gpg-private-key.asc
gpg --edit-key <your-key-id>
# type: trust → 5 (ultimate) → quit
```
