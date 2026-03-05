# Nix Configuration Pipeline

## Philosophy

Configuration content is authored in **native formats** and consumed by Nix modules as read-only inputs. The developer edits `.fish`, `.toml`, and plain-text files with full editor support (syntax highlighting, linting, completion). Nix's role is to read these files, wire them into the correct Home Manager or nix-darwin options, and manage their deployment to the system.

This separation enforces a clear contract: **config files define _what_; Nix modules define _where_ and _how_**.

## Data Flow

There are two pipelines: **parsed** (Nix reads and interprets file content) and **linked** (Nix deploys files as-is via symlinks).

### Parsed pipeline

```
config/                          Nix modules                       System
──────────────────────────────── ─────────────────────────────────── ──────────────────────────
config/fish/shellInit.fish ──→ builtins.readFile ──→ programs.fish.shellInit ──→ ~/.config/fish/config.fish
config/fish/interactive*.fish ─→ builtins.readFile ──→ programs.fish.interactiveShellInit ──→ (merged into config.fish)
config/starship.toml ──────────→ builtins.fromTOML ─→ programs.starship.settings ──→ ~/.config/starship.toml
config/git/ignore ─────────────→ builtins.readFile ──→ programs.git.ignores (parsed) ──→ ~/.config/git/ignore
(N/A) ─────────────────────────→ Nix attrset ────────→ programs.git.{delta,extraConfig} ──→ ~/.config/git/config
```

### Linked pipeline

```
config/                          Nix modules                       System
──────────────────────────────── ─────────────────────────────────── ──────────────────────────
config/ghostty/config ─────────→ xdg.configFile ────→ ~/.config/ghostty/config (symlink)
config/zellij/config.kdl ──────→ xdg.configFile ────→ ~/.config/zellij/config.kdl (symlink)
config/aerospace/*.toml,*.sh ──→ xdg.configFile ────→ ~/.config/aerospace/* (symlinks)
config/helix/config.toml ──────→ xdg.configFile ────→ ~/.config/helix/config.toml (symlink)
config/karabiner/karabiner.json→ xdg.configFile ────→ ~/.config/karabiner/karabiner.json (symlink)
config/nvim/**/* ──────────────→ xdg.configFile ────→ ~/.config/nvim/* (symlinks, recursive)
config/codex/AGENTS.md ────────→ home.file ──────────→ ~/.codex/AGENTS.md (symlink)
config/claude/* ───────────────→ home.file ──────────→ ~/.claude/* (symlinks)
```

### Reading Strategies

| Strategy | When to use | Example |
|---|---|---|
| `builtins.readFile` | Content is opaque to Nix (shell scripts, ignore patterns) | `programs.fish.shellInit` |
| `builtins.fromTOML` + `readFile` | Content is structured and Nix needs the parsed value | `programs.starship.settings` |
| Nix attrset (direct) | Nix adds value (path resolution, type checking, program-specific options) | `programs.git.delta`, `programs.git.extraConfig` |
| `xdg.configFile.*.source` | File deployed as-is to `~/.config/` (no parsing needed) | ghostty, zellij, aerospace, helix, karabiner |
| `home.file.*.source` | File deployed as-is to `~/` (non-XDG locations) | .claude/*, .codex/* |

**Decision rule**: Use `programs.*` modules when Home Manager provides meaningful benefits (e.g., `programs.git.delta.enable` resolves the delta binary path). Use link-based deployment (`xdg.configFile`/`home.file`) for everything else.

## Functional Requirements

### FR-1: Directory Layout

```
config/
  fish/
    shellInit.fish                # Non-interactive shell initialization
    interactiveShellInit.fish     # Interactive shell initialization
  starship.toml                   # Starship prompt configuration
  git/
    ignore                        # Global git ignore patterns
  ghostty/
    config                        # Ghostty terminal configuration
  zellij/
    config.kdl                    # Zellij multiplexer configuration
  aerospace/
    aerospace.toml                # AeroSpace window manager configuration
    pip-move.sh                   # PiP window workspace-follow script
  helix/
    config.toml                   # Helix editor configuration
  karabiner/
    karabiner.json                # Karabiner-Elements key remapping
  codex/
    AGENTS.md                     # Codex CLI agent guidelines
  claude/
    CLAUDE.md                     # Claude Code global instructions
    settings.json                 # Claude Code settings and hooks
    statusline-command.sh         # Claude Code status line script
  nvim/
    init.lua                      # Neovim entry point (LazyVim)
    lazyvim.json                  # LazyVim extras configuration
    lua/config/*.lua              # Neovim config (autocmds, keymaps, lazy, options)
    lua/plugins/*.lua             # Neovim plugin specs (colorscheme, core, lang, lsp)
```

All files under `config/` are in their native format. No Nix syntax, no templating.

### FR-2: `configDir` Contract

- `configDir` is a Nix path (`./config`) defined in `flake.nix` and passed to all modules via `specialArgs`/`extraSpecialArgs`.
- Modules reference files as `configDir + "/relative/path"`.
- Adding a new config file requires: (1) create the file in `config/`, (2) reference it from the appropriate Nix module.

### FR-3: Module Mapping

| Config source | Nix module | Mechanism | Key options |
|---|---|---|---|
| `config/fish/*.fish` | `home/fish.nix` | `builtins.readFile` | `shellInit`, `interactiveShellInit`, `plugins`, `shellAbbrs` |
| `config/starship.toml` | `home/default.nix` | `builtins.fromTOML` | `programs.starship.settings` |
| `config/git/ignore` | `home/git.nix` | `builtins.readFile` | `programs.git.ignores` (parsed) |
| (no config file) | `home/default.nix` | Nix attrset | `programs.atuin.{enable,enableFishIntegration}` |
| `config/{ghostty,zellij,aerospace,helix,karabiner,nvim}/*` | `home/dotfiles.nix` | `xdg.configFile.*.source` | Symlink to `~/.config/` |
| `config/{codex,claude}/*` | `home/dotfiles.nix` | `home.file.*.source` | Symlink to `~/` |

### FR-4: Fish Plugin Management

Fish plugins are managed declaratively via `programs.fish.plugins`, replacing the imperative `fisher` plugin manager.

**Contract**:
- Each plugin is a `{ name, src }` attrset where `src` is a `fetchFromGitHub` derivation.
- Plugin revisions and hashes are pinned for reproducibility.
- Adding/removing plugins: edit `nix/modules/home/fish.nix`, then `darwin-rebuild switch`.

Current plugins:

| Plugin | Purpose |
|---|---|
| `fish-ghq` | ghq repository navigation |

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

### FR-7: Linked Dotfiles

Files that don't benefit from `programs.*` modules are deployed as symlinks via `xdg.configFile` (for `~/.config/` paths) or `home.file` (for `~/` paths). The Nix module `home/dotfiles.nix` owns all link-based deployments.

**Contract**:
- Files are read-only symlinks to the Nix store.
- Applications that need to write to their config files (e.g., Karabiner-Elements) must have config changes committed to the repo instead of using the GUI.
- Executable scripts (e.g., `pip-move.sh`, `statusline-command.sh`) set `executable = true` in the Nix module.

### FR-8: Transitional Elements

During migration from chezmoi/Homebrew/mise to Nix, some config files contain transitional code:

| Element | Location | Remove when |
|---|---|---|
| `brew shellenv \| source` | `config/fish/interactiveShellInit.fish` | Block 5: when all Homebrew brews are eliminated (casks don't need PATH) |
| Nix PATH `set --prepend` | `config/fish/interactiveShellInit.fish` | Block 5: when login shell switches from Homebrew fish to Nix fish |

Previously removed (Block 4): `_evalcache mise activate fish`, `fish-evalcache` plugin (mise retired).

## Non-Functional Requirements

### NFR-1: Edit Experience

Config files must be editable with standard tooling. A developer should never need to understand Nix to modify shell configuration or git ignores.

### NFR-2: No Content Duplication

Each piece of configuration exists in exactly one place. The `config/` file is the source of truth; Nix modules must not duplicate or restate its content.

### NFR-3: Additive Changes

Adding a new configuration file to the pipeline requires exactly two touches:
1. Create the native file in `config/`.
2. Reference it from the Nix module (`dotfiles.nix` for links, or the relevant `programs.*` module for parsed content).

No changes to `flake.nix` or other modules should be needed.

## Definition of Done

- [x] All configuration content in `config/` is in native format with no Nix syntax
- [x] Every file in `config/` is referenced by exactly one Nix module
- [x] `darwin-rebuild build` succeeds and generated config files match the content of `config/` sources
- [x] Editing a `config/` file and running `darwin-rebuild switch` updates the deployed file
- [x] `~/.config/git/local` exists on each machine with the correct identity (manual, not Nix-managed)
- [x] All link-based dotfiles are verified as symlinks to Nix store
