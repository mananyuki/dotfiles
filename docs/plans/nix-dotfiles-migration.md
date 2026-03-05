# Nix Dotfiles Migration Plan

## Context

Replace chezmoi + Homebrew + mise with nix-darwin + Home Manager as the single declarative source of truth for environment management.

### Why

| Current tool | Pain point |
|---|---|
| chezmoi | Hooks unreliable, manual cleanup on file removal, chezmoi-specific concepts (dot_, run_once_, tmpl) |
| Homebrew | Implicit side effects, manual `brew cleanup`, python@3.13 leaking as transitive dep |
| mise | Works well for tools, but `mise run update` is daily ceremony that Nix should eliminate |

### Lessons from previous attempt

- Kiro spec was too heavy (30+ subtasks), led to big-bang migration that stalled
- Requirements weren't clear before starting implementation
- 5+ years of false starts with Nix; need to keep each step small and working

### Completion criteria

`chezmoi apply` is never needed again. `darwin-rebuild switch` reproduces the full environment.

---

## Current state

### Repository structure (as of Block 3 completion)

```
flake.nix                          # entry point
flake.lock                         # pinned inputs
config/                            # native config files (source of truth)
  fish/{shellInit,interactiveShellInit}.fish
  starship.toml
  git/ignore
  ghostty/config
  zellij/config.kdl
  aerospace/{aerospace.toml,pip-move.sh}
  helix/config.toml
  karabiner/karabiner.json
  codex/AGENTS.md
  claude/{CLAUDE.md,settings.json,statusline-command.sh}
nix/modules/
  darwin/
    default.nix                    # system-level: nix settings, fish shell registration
    defaults.nix                   # macOS system.defaults.*
    homebrew.nix                   # declarative Homebrew (brews, casks, masApps)
  home/
    default.nix                    # user-level: home.packages, starship, atuin
    dotfiles.nix                   # xdg.configFile + home.file links
    fish.nix                       # programs.fish (plugins, abbrs, config via readFile)
    git.nix                        # programs.git (delta, ghq, includes)
```

### Remaining chezmoi artifacts

```
.chezmoi.toml.tmpl                 # profile selection → Block 5
.chezmoiignore                     # → Block 5
dot_config/alacritty/              # → Block 5 (drop, using ghostty)
dot_config/git/ignore              # → Block 5 (already in config/git/ignore)
dot_config/mise/config.toml        # → Block 4
dot_config/nvim/                   # → Block 5 (drop, not actively used)
dot_config/private_fish/           # → Block 5 (already in config/fish/)
dot_config/sheldon/                # → Block 5 (drop, fish is primary)
dot_config/starship.toml           # → Block 5 (already in config/starship.toml)
dot_config/zsh/                    # → Block 5 (drop or minimal)
dot_gitconfig.tmpl                 # → Block 5 (already in programs.git)
dot_zshenv                         # → Block 5
run_once_20-install-runtimes.sh.tmpl  # → Block 4
run_update-completions.sh          # → Block 5
```

---

## Progress

### Completed

**Block 0** — `feat/nix-migration` branch, commit `760efb8`
- Nix installed via NixOS/nix-installer (pure Nix, not Determinate Nix)
- Flake skeleton: nixpkgs/nix-darwin/home-manager 24.11
- Profile-only output keys: `darwinConfigurations."home"` / `"work"` (hostname excluded from key)
- `darwin-rebuild build` exits 0 for both profiles

**Block 1** — commit `8e48826`
- `programs.fish` with plugins (fish-ghq, fish-evalcache via `fetchFromGitHub`)
- `programs.starship` with `builtins.fromTOML` reading `config/starship.toml`
- `programs.git` with delta, ghq, includes for local identity
- `programs.atuin` with fish integration
- `config/` directory pattern: native files consumed by Nix modules via `configDir`
- fisher replaced by Home Manager plugin management
- `~/.gitconfig` (chezmoi) deleted; git config now at `~/.config/git/config` (HM) + `~/.config/git/local` (manual)

**Block 2** — commits `4906ed0`..`3ca5ce4`
- `homebrew.enable = true` with `cleanup = "zap"`, profile-conditional packages
- CLI tools moved to `home.packages`: coreutils, curl, gnupg, gnused, helix, lua, luarocks, neovim, pandoc, tree, unzip, zellij
- macOS `system.defaults.*` + `CustomUserPreferences` from run_once_90
- Added: `dock.orientation = "right"`, `AppleInterfaceStyleSwitchesAutomatically = true`, `JIMPrefLiveConversionKey = true`
- `darwin-rebuild switch` succeeded on work PC
- Homebrew zap removed: old brews (atuin, starship, git, fisher, borders, etc.), casks (chrome@beta, chrome@canary, vivaldi), mas (Keynote)
- Xcode removed from masApps (Command Line Tools is sufficient)
- All macOS defaults verified against live system
- All Nix-first CLI tools verified (12/12 resolve from Nix store)
- Removed chezmoi scripts: run_once_00, run_once_10, run_once_90, run_onchange_update-brew-packages, run_onchange_update-aqua-packages
- Removed `dot_Brewfile.tmpl` (replaced by `homebrew.nix`)

**Block 3** — commit `b85e32b`
- New module `nix/modules/home/dotfiles.nix` for link-based dotfiles
- `xdg.configFile`: ghostty, zellij, aerospace (toml + pip-move.sh), helix (new), karabiner (new)
- `home.file`: .codex/AGENTS.md, .claude/{CLAUDE.md, settings.json, statusline-command.sh}
- Removed Vivaldi rule from karabiner config (Vivaldi uninstalled)
- Dropped: borders (unused), sketchybar (unused), .textlintrc.json (no global need)
- Removed chezmoi sources: dot_config/{ghostty,zellij,aerospace,borders}, dot_codex, dot_textlintrc.json
- All 10 managed files verified as symlinks to Nix store
- cmux skipped (defaults-based config, not file-based)

### Known issues and learnings

| Issue | Resolution |
|---|---|
| NixOS/nix-installer stores channels at `~/.local/state/nix/profiles/` but nix-darwin expects them under `/nix/var/nix/profiles/per-user/` | `nix.channel.enable = false` (flakes don't need channels) |
| Homebrew fish (`/opt/homebrew/bin/fish`) does not source `/etc/fish/` where nix-darwin writes PATH setup | Nix paths added manually in `config/fish/interactiveShellInit.fish` |
| `mise activate fish` overwrites `$PATH` entirely, removing Nix paths | Nix PATH `set --prepend` must come AFTER `mise activate` in `interactiveShellInit.fish`. Also `_evalcache_clear mise` needed after PATH changes |
| `darwin-rebuild switch` with sudo causes Homebrew errors (Homebrew refuses root) | Run `darwin-rebuild switch` without sudo; it prompts for password only when needed |
| `home-manager.backupFileExtension` needed for first switch when chezmoi files exist | Set to `"backup"` in flake.nix; delete stale `.backup` files before switch if they already exist |
| `home.homeDirectory` was null when `useUserPackages = true` | Set `users.users.${username}.home` in darwin module |
| New files must be `git add`-ed before `darwin-rebuild build` (flake only sees tracked/staged files) | Always `git add` new config files before building |
| Karabiner-Elements cannot write to read-only Nix store symlinks | Acceptable: config changes go through repo, not GUI |

---

## Remaining blocks

### Block 4: Runtimes + tool management (retire mise)

**Goal**: Language runtimes and dev tools are managed by Nix. mise is no longer needed.

**Scope**:
- Runtimes via `home.packages` or dedicated modules:
  - Python (+ uv for project-level venv management)
  - Go
  - Rust (rustup via Nix, or `pkgs.rustup`)
  - Node.js + Bun
  - Deno
  - Java (corretto-11)
- Dev tools currently in mise config: biome, buf, terraform, tflint, kubectl, krew, minikube, lima, vale, ruff, etc.
- npm global packages: commitlint (evaluate if still needed or move to per-project)
- `uv pip install --system neovim` for pynvim: becomes `home.packages = [ pkgs.python3Packages.pynvim ]`
- Update workflow: `nix flake update && darwin-rebuild switch` replaces `mise run update`
- Remove `dot_config/mise/config.toml` and `run_once_20-install-runtimes.sh.tmpl` from chezmoi
- Remove transitional elements from fish config:
  - `_evalcache mise activate fish` from `config/fish/interactiveShellInit.fish`
  - `fish-evalcache` plugin from `nix/modules/home/fish.nix` (if no other commands to cache)
- Uninstall mise from Homebrew brews

**Key consideration**: Some tools (codex, gemini-cli, agent-browser) may not be in nixpkgs. Options:
- Keep as npm global installs managed by a small script
- Use `home.packages` with `pkgs.nodePackages` if available
- Or accept these as manual installs documented in README

**Verification**:
- `which python3` → Nix store path
- `which go`, `which deno`, etc. → Nix store paths
- `mise` is not installed
- Existing projects build and test successfully

### Block 5: Cleanup + retire chezmoi

**Goal**: chezmoi is fully removed. The dotfiles repo is a pure Nix flake.

**Scope**:
- Remove all remaining chezmoi artifacts (see "Remaining chezmoi artifacts" above)
- Drop unused configs: alacritty, nvim, sheldon
- Handle zsh config: keep minimal `.zshenv` if needed (nix-darwin sets up zsh for Nix), drop sheldon/zsh config
- Remove transitional elements from fish config:
  - `brew shellenv | source` (if all Homebrew brews are eliminated; casks don't need PATH)
  - Nix PATH `set --prepend` (when login shell switches from Homebrew fish to Nix fish)
- Remove chezmoi from system
- Update README with new workflow:
  - Bootstrap: install Nix → clone repo → `darwin-rebuild switch --flake .#<profile>`
  - Daily: `nix flake update && darwin-rebuild switch`
  - Review: `darwin-rebuild build` + `nix store diff-closures`
  - Rollback: `darwin-rebuild switch --rollback`
- Add CI (GitHub Actions) for flake evaluation checks

**Verification**:
- `chezmoi` command not found
- `darwin-rebuild switch` from clean clone reproduces full environment
- No `dot_*` or `run_*` files remain in repo

---

## Principles

1. **One block at a time**. Each block ends with a working system. Never proceed to the next block until the current one is verified.
2. **Parallel operation**. chezmoi and Nix coexist during migration. chezmoi files are removed only after Nix has taken ownership.
3. **No perfectionism**. Link files first, refine into `programs.*` modules later (except Block 1 core apps).
4. **Local overrides stay local**. Identity, secrets, and machine-specific values live outside the repo via include/source mechanisms.
5. **Drop what's unused**. nvim config, alacritty config, and anything not actively used gets dropped, not migrated. Git history preserves it.

## Risks

| Risk | Mitigation |
|---|---|
| Nix learning curve stalls progress again | Block 0+1 are tightly scoped. If Block 1 succeeds, confidence builds. |
| PATH conflicts during parallel operation | Fish config explicitly handles both Nix and Homebrew paths during transition |
| nixpkgs missing some tools | Homebrew fallback is intentional; tap-only brews stay in Homebrew |
| `darwin-rebuild switch` breaks environment | Always `darwin-rebuild build` first. Rollback via `--rollback`. |
| Profile logic more complex than expected | Audit profile diffs early in Block 1. Keep profile deltas minimal. |
