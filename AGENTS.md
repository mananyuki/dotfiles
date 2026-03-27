# Repository Guidelines

## Purpose

- Declarative macOS environment using nix-darwin and Home Manager.
- `darwin-rebuild switch --flake .#<profile>` reproduces the full environment.

## Single Source of Truth

This repository is the **single source of truth** for the entire macOS environment. All packages, settings, and configurations are managed declaratively through Nix. The running system is a pure function of this repo.

**Consequences:**
- **Never run imperative package commands** (`brew install`, `brew uninstall`, `nix-env -i`, etc.). To add or remove a package, edit the corresponding Nix file. `darwin-rebuild switch` reconciles the system.
- **Never modify dotfiles outside this repo.** Symlinked config files point here; editing the target is editing the source.
- **If it's not in this repo, it doesn't exist.** An app, package, or setting that isn't declared here is either unmanaged (and should be declared) or unwanted (and should stay out).

## Where things live

- `flake.nix`: entry point. Defines `darwinConfigurations` for `home` and `work` profiles.
- `config/`: native-format configuration files (fish, starship, git, ghostty, nvim, etc.). Nix reads these; they contain no Nix syntax.
- `nix/modules/darwin/`: system-scoped nix-darwin modules (Nix settings, macOS defaults, Homebrew).
- `nix/modules/home/`: user-scoped Home Manager modules (packages, shell, git, dotfile links).
- `nix/packages/`: custom Nix packages built from GitHub releases.
- `docs/specs/`: architecture and pipeline specs.
- `docs/plans/`: migration plans and progress tracking.

## Safe workflow

1. Edit config files in `config/` or Nix modules in `nix/`.
2. `git add` new files (flakes only see tracked files).
3. `darwin-rebuild build --flake .#work` (validate).
4. `darwin-rebuild switch --flake .#work` (apply).
5. `darwin-rebuild switch --rollback` (if something breaks).

## Profiles

- `home`: personal machine.
- `work`: work machine. Adds `awscli2` and work-specific Homebrew casks.
- Profile-conditional logic uses `lib.optionals (profile == "work") [ ... ]`.

## Conventions

- Config content lives in native files under `config/`. Nix modules wire them in via `builtins.readFile`, `builtins.fromTOML`, or `xdg.configFile.*.source`.
- Shell abbreviations are declared as Nix attrsets in `programs.fish.shellAbbrs` (exception to the native-file rule).
- Git identity is delegated to `~/.config/git/local` (not committed).
- Never commit secrets.
