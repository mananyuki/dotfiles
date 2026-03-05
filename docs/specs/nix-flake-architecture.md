# Nix Flake Architecture

## Philosophy

This dotfiles system uses Nix as a **declarative orchestration layer** for macOS environment management. Nix itself does not hold configuration content; it wires together native configuration files and manages their lifecycle. The guiding principles are:

- **Nix as glue, not storage**: Configuration content lives in native-format files (`.fish`, `.toml`, etc.). Nix modules read and compose these files but never embed substantive config as Nix string literals.
- **Single `darwin-rebuild switch` reproduces everything**: The flake is the sole entry point. No manual steps, no imperative scripts.
- **Profile-based variation with minimal delta**: Differences between environments (home/work) are handled through Nix conditionals or local override files, not by duplicating configurations.

## Prerequisites

### Nix Installation

Nix is installed via [NixOS/nix-installer](https://github.com/NixOS/nix-installer) (the community installer, not Determinate Nix and not the `nixos.org/nix/install` shell script):

```shell
curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install
```

## Functional Requirements

### FR-1: Flake Inputs

The flake pins four inputs:

| Input | Source | Purpose |
|---|---|---|
| `nixpkgs` | `github:NixOS/nixpkgs/nixpkgs-24.11-darwin` | Package repository |
| `nix-darwin` | `github:nix-darwin/nix-darwin/nix-darwin-24.11` | macOS system configuration |
| `home-manager` | `github:nix-community/home-manager/release-24.11` | User-scoped configuration |
| `llm-agents` | `github:numtide/llm-agents.nix` | Fast-moving AI CLI tools (claude-code, codex, etc.) |

nixpkgs, nix-darwin, and home-manager are on the 24.11 release track. nix-darwin and home-manager follow `nixpkgs` to ensure a single package set. `llm-agents` uses its own nixpkgs pin for latest tool versions.

### FR-2: Flake Outputs

The flake exposes:

| Output | Description |
|---|---|
| `darwinConfigurations."<profile>"` | Complete macOS system configurations (`"home"` or `"work"`) |
| `formatter.<system>` | `nixfmt-rfc-style` for consistent formatting |

### FR-3: Profile System

Profiles parameterize environment differences.

**Contract**: `profile` is a string, either `"home"` or `"work"`, passed via `specialArgs` to all modules.

**State machine**:

```
flake.nix
  ├─ darwinConfigurations."home"
  │    ├─ specialArgs.profile = "home"  → darwin modules
  │    └─ extraSpecialArgs.profile = "home" → home-manager modules
  └─ darwinConfigurations."work"
       ├─ specialArgs.profile = "work"  → darwin modules
       └─ extraSpecialArgs.profile = "work" → home-manager modules
```

Modules consume `profile` via their function arguments: `{ profile, ... }:`. Profile-conditional logic uses `lib.optionals (profile == "work") [ ... ]` for package lists, or `lib.mkIf` for option blocks.

**Naming convention**: `darwinConfigurations."<profile>"` where profile is `"home"` or `"work"`. Hostname is intentionally excluded from the output key because:
- A profile is sufficient to identify an environment; multiple machines may share the same profile.
- Machine-specific overrides (if ever needed) are handled by local files outside the repo (`config.local.fish`, `~/.config/git/local`).

### FR-4: Module Composition

The `mkDarwinConfiguration` helper wires two module layers:

```
darwinSystem
  ├─ nix/modules/darwin/           (system scope)
  │    ├─ default.nix              nix settings, shell registration, login shell
  │    ├─ defaults.nix             macOS system.defaults.*
  │    └─ homebrew.nix             declarative Homebrew (casks, masApps, subversion)
  └─ home-manager integration
       └─ nix/modules/home/        (user scope)
            ├─ default.nix         home.packages, starship, atuin, fzf, direnv
            ├─ dotfiles.nix        xdg.configFile + home.file links
            ├─ fish.nix            programs.fish
            └─ git.nix             programs.git
nix/packages/                      (custom packages from GitHub releases)
  ├─ worktrunk.nix
  ├─ pup.nix
  └─ gogcli.nix
```

**Boundary contract**:

| Concern | Owner | Examples |
|---|---|---|
| System-level settings | `nix/modules/darwin/` | Nix daemon, macOS defaults, system packages, Homebrew declaration |
| User-level settings | `nix/modules/home/` | Shell config, git, starship, XDG files, user packages, dotfile links |

Darwin modules receive `specialArgs`: `{ username, profile, configDir }`.
Home Manager modules receive `extraSpecialArgs`: `{ profile, configDir, llmAgentsPkgs }`.

### FR-5: `configDir` Injection

The flake defines `configDir = ./config` in the top-level `let` block and passes it to both darwin and home-manager modules via `specialArgs`/`extraSpecialArgs`. Modules use `configDir` to reference native configuration files without hard-coding relative paths.

### FR-6: Home Manager Integration

Home Manager is integrated as a nix-darwin module (not standalone):

```nix
home-manager.darwinModules.home-manager
{
  home-manager = {
    useGlobalPkgs = true;          # share nixpkgs instance with nix-darwin
    useUserPackages = true;         # install packages to /etc/profiles/per-user
    backupFileExtension = "backup"; # auto-backup conflicting files
  };
}
```

### FR-7: Nix Daemon and Channel Configuration

```nix
nix.channel.enable = false;  # flakes do not use channels
```

This is required for compatibility with NixOS/nix-installer, which stores channel profiles at `~/.local/state/nix/profiles/` rather than `/nix/var/nix/profiles/per-user/$USER/` where nix-darwin's activation script expects them. Since this is a flake-based setup, channels are not needed.

### FR-9: Binary Cache for llm-agents

The numtide binary cache is configured to avoid building AI CLI tools from source:

```nix
nix.settings = {
  extra-substituters = [ "https://cache.numtide.com" ];
  extra-trusted-public-keys = [
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
  ];
};
```

`llmAgentsPkgs` is derived from `llm-agents.packages.${system}` in flake.nix and passed to home-manager modules via `extraSpecialArgs`. Packages are consumed in `home/default.nix` with `(with llmAgentsPkgs; [ ... ])`.

### FR-8: Fish Shell Registration and Login Shell

```nix
programs.fish.enable = true;
environment.shells = [ "/etc/profiles/per-user/${username}/bin/fish" ];
```

nix-darwin registers fish as a known shell and manages `/etc/shells`. The Nix fish binary at `/etc/profiles/per-user/<username>/bin/fish` is the login shell (set via `chsh`). Nix paths are added in `config/fish/interactiveShellInit.fish` after `brew shellenv` to ensure Nix binaries take precedence over Homebrew.

### FR-10: Custom Packages from GitHub Releases

Tools not available in nixpkgs are packaged as `stdenv.mkDerivation` with `fetchurl` from GitHub releases. These live in `nix/packages/` and are consumed via `pkgs.callPackage` in `home/default.nix`.

| Package | Binary | Source |
|---|---|---|
| `worktrunk` | `wt`, `git-wt` | `max-sixty/worktrunk` |
| `pup` | `pup` | `datadog-labs/pup` |
| `gogcli` | `gog` | `steipete/gogcli` |

To update: bump `version`, update the `url`, set `hash = ""`, build to get the correct hash from the error message, then set it.

## Non-Functional Requirements

### NFR-1: Reproducibility

`flake.lock` pins all inputs to exact revisions. `darwin-rebuild build` must succeed without network access after initial fetch.

### NFR-2: Build Validation Before Apply

`darwin-rebuild build --flake .#<config>` must exit 0 before any `switch` is attempted. This is the safety gate.

### NFR-3: Rollback

`darwin-rebuild switch --rollback` must restore the previous generation. No configuration change is irreversible.

### NFR-4: Single Architecture

The system targets `aarch64-darwin` (Apple Silicon) exclusively. No multi-arch abstraction is needed.

## Definition of Done

- [x] `darwin-rebuild build --flake .#home` exits 0
- [x] `darwin-rebuild build --flake .#work` exits 0
- [x] All module arguments (`profile`, `configDir`, `username`) are threaded correctly with no unused parameters
- [x] `flake.lock` is committed and pins all inputs
- [x] No configuration content is embedded as Nix string literals (delegated to `config/` files per nix-config-pipeline spec)
