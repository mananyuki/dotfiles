# Nix Dotfiles System

Declarative macOS configuration using nix-darwin and Home Manager.

## Prerequisites

- Nix with flakes enabled
- macOS (Darwin) on Apple Silicon (aarch64-darwin)

## Directory Structure

```
nix/
├── modules/
│   ├── darwin/          # System-scoped configuration (nix-darwin)
│   │   └── default.nix  # Base system settings
│   └── home/            # User-scoped configuration (Home Manager)
│       └── default.nix  # Base user settings
└── README.md
```

## Quick Start

### Build-only (dry-run validation)

```bash
# Validate configuration without applying
darwin-rebuild build --flake .#JPN-2024-059-home

# Compare with current system
nix store diff-closures /run/current-system ./result
```

### Apply configuration

```bash
# Switch to new configuration
darwin-rebuild switch --flake .#JPN-2024-059-home
```

### Rollback

```bash
# Return to previous generation
darwin-rebuild switch --rollback
```

## Host/Profile Naming Convention

Configurations follow the pattern: `<hostname>-<profile>`

- `hostname`: Machine identifier (e.g., `JPN-2024-059`)
- `profile`: Either `home` or `work`

Example outputs:
- `darwinConfigurations."JPN-2024-059-home"`
- `darwinConfigurations."JPN-2024-059-work"`

## Architecture Boundaries

| Layer | Owner | Scope |
|-------|-------|-------|
| System | nix-darwin | macOS settings, system packages, services |
| User | Home Manager | dotfiles, XDG configs, user packages |

## Flake Inputs

| Input | Purpose | Branch/Tag |
|-------|---------|------------|
| nixpkgs | Package repository | nixpkgs-24.11-darwin |
| nix-darwin | macOS system configuration | nix-darwin-24.11 |
| home-manager | User configuration | release-24.11 |



