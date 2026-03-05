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

## Migration inventory

### chezmoi-managed assets

| Asset | Type | Nix target | Block |
|---|---|---|---|
| dot_config/private_fish/ | shell config | `programs.fish` | 1 |
| dot_config/starship.toml | prompt | `programs.starship` | 1 |
| dot_config/git/ + dot_gitconfig.tmpl | git config | `programs.git` | 1 |
| dot_Brewfile.tmpl | packages | `homebrew.{brews,casks,masApps}` | 2 |
| dot_config/ghostty/ | terminal | `xdg.configFile` link | 3 |
| dot_config/zellij/ | terminal mux | `xdg.configFile` link | 3 |
| dot_config/aerospace/ | window mgr | `xdg.configFile` link | 3 |
| dot_config/borders/ | window mgr addon | `xdg.configFile` link | 3 |
| dot_config/mise/ | tool mgr | removed (Nix replaces) | 4 |
| dot_config/nvim/ | editor | drop (not actively used) | - |
| dot_config/alacritty/ | terminal (legacy) | drop (using ghostty) | - |
| dot_config/sheldon/ + dot_config/zsh/ + dot_zshenv | zsh config | drop or minimal (fish is primary) | 5 |
| dot_config/sketchybar/ | status bar | `xdg.configFile` link | 3 |
| dot_textlintrc.json | linter | `home.file` link | 3 |
| dot_codex/ | codex config | `home.file` link | 3 |
| run_once_90-configure-macos.sh.tmpl | macOS defaults | `system.defaults.*` (nix-darwin) | 2 |
| run_once_10/20, run_onchange_* | bootstrap scripts | replaced by nix-darwin activation | 2/4 |
| .chezmoi.toml.tmpl (profile logic) | profile selection | flake output `<host>-<profile>` | 1 |

### Profile differences

- **Brewfile**: work adds awscli, Edge, Zoom, session-manager-plugin. home adds balenaetcher, Affinity, Prime Video.
- **dotfiles**: git user.name/email differs by profile. Possibly other config differences (to audit in Block 1).

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

---

## Blocks

### Block 0: Nix bootstrap + flake skeleton ✓

**Goal**: Nix is installed, flake evaluates, `darwin-rebuild build` succeeds with a no-op config.

**Scope**:
- Install Nix (NixOS/nix-installer — the official modern installer, fork of Determinate installer for pure Nix)
- Create minimal `flake.nix` with nix-darwin + Home Manager wired up
- `"home"` and `"work"` outputs defined (profile-only, no hostname)
- Profile passed as `specialArgs` to modules
- `darwin-rebuild build --flake .#work` succeeds
- Commit on `feat/nix-migration` branch

**Not in scope**: Any actual config management. This is pure scaffolding.

**Verification**: `darwin-rebuild build` exits 0.

### Block 1: Shell + Git (first `programs.*` migration) ✓

**Goal**: fish, starship, and git are managed by Home Manager. chezmoi no longer owns these files.

**Scope**:
- `programs.fish` with config content in native `.fish` files under `config/`
  - Shell variables, abbreviations, PATH additions
  - Fish plugins via Home Manager (replace fisher: fish-ghq, fish-evalcache)
  - `config.local.fish` sourcing preserved as local override escape hatch
  - `brew shellenv` and `mise activate` kept as transitional (not removed yet)
- `programs.starship` with `builtins.fromTOML` reading `config/starship.toml`
- `programs.git` with delta, ghq, rebase settings
  - Identity (name/email) via `include.path` to a local-only file (not in repo)
  - Profile differences handled by local override, not Nix conditionals
- `programs.atuin` (promoted to Home Manager module with fish integration)
- `config/` directory pattern established: native files + `configDir` injection

**Key decision**: `brew shellenv` and `mise activate fish` are kept during transition. Nix PATH must be set AFTER `mise activate` because mise overwrites PATH entirely.

**Verification**:
- New terminal opens fish with correct prompt, abbreviations, PATH ✓
- `git config user.name` returns expected value ✓
- Config files are symlinks to Nix store ✓

### Block 2: Packages + macOS defaults (in progress)

**Goal**: Homebrew is managed declaratively by nix-darwin. macOS system preferences are declared in Nix. CLI tools are Nix-first.

**Scope**:
- `homebrew.enable = true` in nix-darwin with:
  - `homebrew.onActivation.cleanup = "zap"` (auto-remove undeclared packages)
  - `homebrew.onActivation.autoUpdate = true`
  - Taps, brews, casks, masApps from current Brewfile.tmpl
  - Profile-conditional packages via Nix `lib.optionals (profile == "work") [...]`
- CLI tools classification:
  - **Nix-first** (via `home.packages`): coreutils, curl, gnupg, gnused, helix, lua, luarocks, neovim, pandoc, tree, unzip, zellij
  - **Homebrew brews** (login shell, tap-only, transitional): fish, mas, mise, subversion, zsh, deck, worktrunk, pup, gogcli, awscli (work)
  - **Homebrew casks** (GUI): aerospace, ghostty, orbstack, slack, chrome, discord, fonts, etc.
  - **masApps**: Kindle, LINE + profile-conditional (Affinity/Prime for home)
- `system.defaults.*` for macOS settings (from run_once_90):
  - NSGlobalDomain (key repeat, autocorrection, locale)
  - Dock (autohide, tile size, persistent-apps)
  - Finder (show all files, path bar, column view)
  - Trackpad settings
  - Input method (Kotoeri), Dictionary, Spotlight via `CustomUserPreferences`
- Remove Brewfile.tmpl and run_once_90 from chezmoi after verification

**Verification**:
- `darwin-rebuild switch` installs all declared packages
- `brew list` matches declared set (no extras, no missing)
- macOS defaults are applied (check key repeat, dock autohide, etc.)

### Block 3: Remaining dotfiles (link-based)

**Goal**: All remaining XDG configs and home dotfiles are managed by Home Manager.

**Scope**:
- `xdg.configFile` links for: ghostty, zellij, aerospace, borders, sketchybar
- `home.file` for: .textlintrc.json, .codex/
- Audit and handle any remaining profile-conditional dotfile differences
- Remove corresponding chezmoi source files

**Verification**:
- All config files are symlinks pointing to Nix store
- Applications launch and use correct config

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
- Remove mise config from chezmoi, uninstall mise

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
- Remove all remaining chezmoi artifacts:
  - `dot_*` prefixed files/dirs
  - `run_once_*`, `run_onchange_*` scripts
  - `.chezmoi.toml.tmpl`
  - `.chezmoiignore`
- Handle zsh config: keep minimal `.zshenv` if needed (nix-darwin sets up zsh for Nix), drop sheldon/zsh config
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
