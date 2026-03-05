# Nix Dotfiles System

Declarative macOS configuration using nix-darwin and Home Manager.

## Prerequisites

- Nix with flakes enabled
- macOS (Darwin) on Apple Silicon (aarch64-darwin)

## Directory Structure

```
nix/
├── modules/
│   ├── darwin/              # System-scoped configuration (nix-darwin)
│   │   ├── default.nix      # Nix settings, shell registration, login shell
│   │   ├── defaults.nix     # macOS system.defaults.*
│   │   └── homebrew.nix     # Declarative Homebrew (casks, masApps, subversion)
│   └── home/                # User-scoped configuration (Home Manager)
│       ├── default.nix      # home.packages, starship, atuin, fzf, direnv
│       ├── dotfiles.nix     # xdg.configFile + home.file links
│       ├── fish.nix         # programs.fish (plugins, abbrs, config)
│       └── git.nix          # programs.git (delta, ghq, includes)
├── packages/                # Custom packages from GitHub releases
│   ├── worktrunk.nix        # Git worktree manager (wt, git-wt)
│   ├── pup.nix              # Datadog Pipelines Utility Pack
│   └── gogcli.nix           # Google services CLI (Gmail, Calendar, Drive, etc.)
└── README.md
```

## Quick Start

### Build-only (dry-run validation)

```bash
# Validate configuration without applying
darwin-rebuild build --flake .#work

# Compare with current system
nix store diff-closures /run/current-system ./result
```

### Apply configuration

```bash
# Switch to new configuration
darwin-rebuild switch --flake .#work
```

### Update packages

```bash
# Update all flake inputs and rebuild
nix flake update && darwin-rebuild switch --flake .#work
```

### Rollback

```bash
# Return to previous generation
darwin-rebuild switch --rollback
```

## Profile System

Configurations use `<profile>` as the key:

| Profile | Output | Use case |
|---------|--------|----------|
| `home` | `darwinConfigurations."home"` | Personal machine |
| `work` | `darwinConfigurations."work"` | Work machine |

Profile-conditional packages use `lib.optionals (profile == "work") [ ... ]`.

## Architecture Boundaries

| Layer | Owner | Scope |
|-------|-------|-------|
| System | nix-darwin | Nix daemon, macOS defaults, Homebrew, shell registration |
| User | Home Manager | Dotfiles, shell config, git, user packages, XDG links |

## Flake Inputs

| Input | Purpose | Branch/Tag |
|-------|---------|------------|
| nixpkgs | Package repository | nixpkgs-24.11-darwin |
| nix-darwin | macOS system configuration | nix-darwin-24.11 |
| home-manager | User configuration | release-24.11 |
| llm-agents | AI CLI tools (claude-code, codex, etc.) | latest |

## Custom Packages

Tools not in nixpkgs are packaged via `fetchurl` from GitHub releases.

To update a custom package:
1. Bump `version` in the `.nix` file
2. Set `hash = ""`
3. Run `darwin-rebuild build` — the error message shows the correct hash
4. Set the hash and rebuild
