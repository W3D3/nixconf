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

## Thunderbird Extensions

Thunderbird extensions cannot be managed declaratively (Thunderbird overwrites the extensions database on startup). They are made available as XPI files by the nix config and must be installed once manually.

**Install extensions:**

1. Open Thunderbird → Tools → Add-ons and Themes
2. Click the gear icon → Install Add-on From File
3. Install `~/.local/share/thunderbird-extensions/thunderai.xpi`
4. Install `~/.local/share/thunderbird-mcp/thunderbird-mcp.xpi`

Extensions persist in the Thunderbird profile across rebuilds.

## Gmail (App Password)

Google has disabled plain password auth. Use an app-specific password instead:

1. Go to [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)
2. Create an app password named "Thunderbird"
3. Use the 16-character password when Thunderbird prompts for Gmail credentials

## Thunderbird MCP (Claude Code)

The `thunderbird-mcp` extension exposes Thunderbird to Claude Code via MCP. The bridge and MCP config are managed by nix — no manual config needed beyond installing the extension (see above).

After installing the extension, Claude Code will automatically connect to Thunderbird when it starts. Verify with `/mcp` in Claude Code.

