# Repository Guidelines

## Purpose

- Declarative macOS environment using nix-darwin and Home Manager.
- `darwin-rebuild switch --flake .#<profile>` reproduces the full environment.

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
