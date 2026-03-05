# Nix Configuration Pipeline

## Philosophy

Configuration content is authored in **native formats** and consumed by Nix modules as read-only inputs. The developer edits `.fish`, `.toml`, and plain-text files with full editor support (syntax highlighting, linting, completion). Nix's role is to read these files, wire them into the correct Home Manager or nix-darwin options, and manage their deployment to the system.

This separation enforces a clear contract: **config files define _what_; Nix modules define _where_ and _how_**.

## Data Flow

```
config/                          Nix modules                       System
──────────────────────────────── ─────────────────────────────────── ──────────────────────────
config/fish/shellInit.fish ──→ builtins.readFile ──→ programs.fish.shellInit ──→ ~/.config/fish/config.fish
config/fish/interactive*.fish ─→ builtins.readFile ──→ programs.fish.interactiveShellInit ──→ (merged into config.fish)
config/starship.toml ──────────→ builtins.fromTOML ─→ programs.starship.settings ──→ ~/.config/starship.toml
config/git/ignore ─────────────→ builtins.readFile ──→ programs.git.ignores (parsed) ──→ ~/.config/git/ignore
(N/A) ─────────────────────────→ Nix attrset ────────→ programs.git.{delta,extraConfig} ──→ ~/.config/git/config
```

### Reading Strategies

| Strategy | When to use | Example |
|---|---|---|
| `builtins.readFile` | Content is opaque to Nix (shell scripts, ignore patterns) | `programs.fish.shellInit` |
| `builtins.fromTOML` + `readFile` | Content is structured and Nix needs the parsed value | `programs.starship.settings` |
| Nix attrset (direct) | Nix adds value (path resolution, type checking, program-specific options) | `programs.git.delta`, `programs.git.extraConfig` |

**Decision rule**: Use native files by default. Only use Nix attrsets when the Home Manager module provides meaningful benefits (e.g., `programs.git.delta.enable` resolves the delta binary path from the Nix store).

## Functional Requirements

### FR-1: Directory Layout

```
config/
  fish/
    shellInit.fish           # Non-interactive shell initialization
    interactiveShellInit.fish # Interactive shell initialization
  starship.toml              # Starship prompt configuration
  git/
    ignore                   # Global git ignore patterns
```

All files under `config/` are in their native format. No Nix syntax, no templating.

### FR-2: `configDir` Contract

- `configDir` is a Nix path (`./config`) defined in `flake.nix` and passed to all modules via `specialArgs`/`extraSpecialArgs`.
- Modules reference files as `configDir + "/relative/path"`.
- Adding a new config file requires: (1) create the file in `config/`, (2) reference it from the appropriate Nix module.

### FR-3: Program Module Mapping

| Config source | Home Manager module | Key options |
|---|---|---|
| `config/fish/shellInit.fish` | `programs.fish` | `shellInit`, `interactiveShellInit`, `plugins`, `shellAbbrs` |
| `config/starship.toml` | `programs.starship` | `settings` (via `fromTOML`) |
| `config/git/ignore` | `programs.git` | `ignores` (parsed from file), `delta`, `extraConfig`, `includes` |
| (no config file) | `programs.atuin` | `enable`, `enableFishIntegration` |

### FR-4: Fish Plugin Management

Fish plugins are managed declaratively via `programs.fish.plugins`, replacing the imperative `fisher` plugin manager.

**Contract**:
- Each plugin is a `{ name, src }` attrset where `src` is a `fetchFromGitHub` derivation.
- Plugin revisions and hashes are pinned for reproducibility.
- Adding/removing plugins: edit `nix/modules/home/fish.nix`, then `darwin-rebuild switch`.

Current plugins:

| Plugin | Purpose | Transitional? |
|---|---|---|
| `fish-ghq` | ghq repository navigation | No |
| `fish-evalcache` | Cache slow shell init commands | Yes (remove when brew/mise are eliminated) |

### FR-5: Git Identity Delegation

Git identity (name, email) is **not** managed by Nix. It is delegated to a local file outside the repository.

**Contract**:
- `programs.git.includes` adds `{ path = "~/.config/git/local"; }`.
- The user creates `~/.config/git/local` manually with `[user]` section.
- This file is machine-specific and never committed to the repo.
- Profile differences (home vs work identity) are handled entirely by this local file.

### FR-6: Shell Abbreviations

Fish abbreviations are declared as a Nix attrset in `programs.fish.shellAbbrs`, not in the fish config files. This is an intentional exception to the "native files" rule because:
- Abbreviations are key-value pairs that map naturally to Nix attrsets.
- Home Manager generates the `abbr --add` calls in the correct location within `config.fish`.

### FR-7: Transitional Elements

During migration from chezmoi/Homebrew/mise to Nix, some config files contain transitional code:

| Element | Location | Remove when |
|---|---|---|
| `brew shellenv \| source` | `config/fish/interactiveShellInit.fish` | When all Homebrew brews are eliminated (casks don't need PATH) |
| `_evalcache mise activate fish` | `config/fish/interactiveShellInit.fish` | Block 4 (mise retired) |
| `fish-evalcache` plugin | `nix/modules/home/fish.nix` | Block 4 (no more commands to cache) |
| Nix PATH `set --prepend` | `config/fish/interactiveShellInit.fish` | When login shell switches from Homebrew fish to Nix fish |

**Critical ordering constraint**: `mise activate fish` overwrites `$PATH` entirely (`set -gx PATH ...`). The Nix PATH prepend (`set --prepend -gx PATH`) MUST come AFTER `mise activate` in `interactiveShellInit.fish`. After changing PATH-related config, run `_evalcache_clear mise` to invalidate the cached mise activation output.

## Non-Functional Requirements

### NFR-1: Edit Experience

Config files must be editable with standard tooling. A developer should never need to understand Nix to modify shell configuration or git ignores.

### NFR-2: No Content Duplication

Each piece of configuration exists in exactly one place. The `config/` file is the source of truth; Nix modules must not duplicate or restate its content.

### NFR-3: Additive Changes

Adding a new configuration file to the pipeline requires exactly two touches:
1. Create the native file in `config/`.
2. Reference it from the Nix module with `builtins.readFile` or `builtins.fromTOML`.

No changes to `flake.nix` or other modules should be needed.

## Definition of Done

- [ ] All configuration content in `config/` is in native format with no Nix syntax
- [ ] Every file in `config/` is referenced by exactly one Nix module
- [ ] `darwin-rebuild build` succeeds and generated config files match the content of `config/` sources
- [ ] Editing a `config/` file and running `darwin-rebuild switch` updates the deployed file
- [ ] `~/.config/git/local` exists on each machine with the correct identity (manual, not Nix-managed)
