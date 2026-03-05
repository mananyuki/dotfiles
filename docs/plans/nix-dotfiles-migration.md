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

### Repository structure (final)

```
flake.nix                          # entry point
flake.lock                         # pinned inputs
Taskfile.yml                       # task runner (build, switch, update, etc.)
config/                            # native config files (source of truth)
  fish/{shellInit,interactiveShellInit}.fish
  starship.toml
  git/ignore
  ghostty/config
  zellij/config.kdl
  aerospace/{aerospace.toml,pip-move.sh}
  helix/config.toml
  karabiner/karabiner.json
  nvim/{init.lua,lazyvim.json,lua/**/*.lua}
  codex/AGENTS.md
  claude/{CLAUDE.md,settings.json,statusline-command.sh}
nix/modules/
  darwin/
    default.nix                    # system-level: nix settings, fish/zsh registration, login shell
    defaults.nix                   # macOS system.defaults.*
    homebrew.nix                   # declarative Homebrew (casks, masApps, subversion)
  home/
    default.nix                    # user-level: home.packages, starship, atuin, fzf, direnv
    dotfiles.nix                   # xdg.configFile + home.file links
    fish.nix                       # programs.fish (plugins, abbrs, config via readFile)
    git.nix                        # programs.git (delta, ghq, includes)
nix/packages/                      # custom packages from GitHub releases
  worktrunk.nix                    # git worktree manager
  pup.nix                          # Datadog pipelines tool
  gogcli.nix                       # Google services CLI (Gmail, Calendar, Drive, etc.)
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

**Block 4** — retire mise, all runtimes via Nix
- Added `numtide/llm-agents.nix` flake input for fast-moving AI CLI tools
- Numtide binary cache (`cache.numtide.com`) for pre-built packages
- `home.packages` expanded with all runtimes: go, nodejs, bun, deno, rustup, uv, jdk11
- Dev tools added: biome, buf, coursier, metals, ruff, vale, terraform, tflint, kubectl, krew, minikube, lima, lazydocker, go-task, devcontainer, duckdb
- LLM agents via `llmAgentsPkgs`: claude-code, codex, gemini-cli, agent-browser, copilot-cli
- `programs.fzf` and `programs.direnv` (with nix-direnv) added as HM modules
- Removed standalone `rust-analyzer` (collision with `rustup` proxy)
- Removed `fish-evalcache` plugin (no longer needed without mise)
- Removed `_evalcache mise activate fish` from interactiveShellInit
- Removed `mise` from Homebrew brews
- Removed chezmoi artifacts: `dot_config/mise/config.toml`, `run_once_20-install-runtimes.sh.tmpl`
- Python managed by `uv` only (no system python3 needed); pynvim dropped (nvim not used)
- npm global packages (commitlint, textlint) dropped; per-project or unnecessary
- All tools verified resolving from Nix store (`/etc/profiles/per-user/yuki/bin/`)

**Block 5** — retire chezmoi, migrate remaining brews, Nix fish as login shell
- Custom Nix packages from GitHub releases: worktrunk, pup (Datadog), gogcli
- Migrated brews to nixpkgs: deck, mas, awscli2 (work only)
- Homebrew brews reduced to `subversion` only (font cask dependency)
- Removed Homebrew taps: `steipete/tap`, `datadog-labs/pack`
- Login shell switched from Homebrew fish to Nix fish (`/etc/profiles/per-user/yuki/bin/fish`)
- `environment.shells` in darwin module manages `/etc/shells`
- Removed Homebrew `fish` and `zsh` brews
- Deleted all remaining chezmoi artifacts:
  - `.chezmoi.toml.tmpl`, `.chezmoiignore`
  - `dot_config/` (alacritty, git/ignore, private_fish, sheldon, starship.toml, zsh)
  - `dot_gitconfig.tmpl`, `dot_zshenv`, `run_update-completions.sh`
- Dropped unused configs: alacritty (ghostty), sheldon (fish), zsh (fish primary)
- nvim config migrated to `config/nvim/` and added to `xdg.configFile` (Block 4)
- neovim added to `home.packages`
- No `dot_*` or `run_*` files remain in repo

### Known issues and learnings

| Issue | Resolution |
|---|---|
| NixOS/nix-installer stores channels at `~/.local/state/nix/profiles/` but nix-darwin expects them under `/nix/var/nix/profiles/per-user/` | `nix.channel.enable = false` (flakes don't need channels) |
| Homebrew fish (`/opt/homebrew/bin/fish`) does not source `/etc/fish/` where nix-darwin writes PATH setup | Nix paths added manually in `config/fish/interactiveShellInit.fish` |
| `mise activate fish` overwrites `$PATH` entirely, removing Nix paths | Resolved in Block 4: mise removed |
| `rust-analyzer` collides with `rustup` proxy binary | Do not include standalone `rust-analyzer` in `home.packages` when `rustup` is present |
| `darwin-rebuild switch` with sudo causes Homebrew errors (Homebrew refuses root) | Run `darwin-rebuild switch` without sudo; it prompts for password only when needed |
| `home-manager.backupFileExtension` needed for first switch when chezmoi files exist | Set to `"backup"` in flake.nix; delete stale `.backup` files before switch if they already exist |
| `home.homeDirectory` was null when `useUserPackages = true` | Set `users.users.${username}.home` in darwin module |
| New files must be `git add`-ed before `darwin-rebuild build` (flake only sees tracked/staged files) | Always `git add` new config files before building |
| Karabiner-Elements cannot write to read-only Nix store symlinks | Acceptable: config changes go through repo, not GUI |
| `nix-prefetch-url --unpack` returns unpacked hash but `fetchurl` needs archive hash | Use hash from Nix build error message (`got: sha256-...`) for `fetchurl` |
| `fetchurl` tar.xz with subdirectory needs correct `sourceRoot` | Set `sourceRoot` to the subdirectory name inside the tarball |
| `/etc/shells` conflict on `darwin-rebuild switch` after manual edit | Rename to `/etc/shells.before-nix-darwin` and let nix-darwin regenerate |

---

## Remaining work

### Post-migration

- [x] Remove `chezmoi` from `home.packages`
- [x] Update README and AGENTS.md with Nix-based workflow
- [x] Add Taskfile for common commands
- [x] Move repo from `~/.local/share/chezmoi` to `~/go/src/github.com/mananyuki/dotfiles`
- `brew shellenv | source` in fish config remains needed (Homebrew casks + subversion)
- Nix PATH `set --prepend` in fish config remains needed (brew shellenv must come first)
- Add CI (GitHub Actions) for flake evaluation checks

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
