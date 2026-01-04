# Repository Guidelines

## Purpose

- This repository is the source of truth for my dotfiles managed with `chezmoi`.
- `chezmoi apply` materializes these source files into `$HOME`.

## Where things live

- `dot_config/**`: XDG config directory content (e.g. `dot_config/nvim`, `dot_config/zsh`, `dot_config/ghostty`, `dot_config/zellij`).
- `dot_*`: files that map to dotfiles under `$HOME` (chezmoi naming convention).
- `run_once_*`: bootstrap/provisioning scripts (executed in numeric prefix order).
- `run_onchange_*`: update hooks (re-run when the script/template changes).
- `*.tmpl`: Go templates rendered by chezmoi (example: `dot_Brewfile.tmpl`).
- `.chezmoi.toml.tmpl`: generates `.chezmoi.toml` and defines `[data]` values used by templates (notably `profile`).

## Safe workflow

- Prefer this sequence whenever changing anything:
  - `chezmoi diff`
  - `chezmoi apply --dry-run`
  - `chezmoi apply`
- If something looks off, start with `chezmoi doctor`.

## Profiles & templates

- Templates may branch on `.profile` (e.g. `{{ if eq .profile "work" }}`).
- Keep template conditionals tight and lists sorted to minimize churn and diffs.

## Conventions (when editing)

- Shell (`run_once_*`, `run_onchange_*`):
  - Use `#!/bin/bash`, 2-space indentation, and idempotent operations.
  - Always `mkdir -p` before writing; avoid destructive changes without guards.
- Neovim Lua (`dot_config/nvim/lua/**`):
  - Follow LazyVim conventions (2-space indentation; keep configs modular).

## Tooling (optional)

- Homebrew packages: `dot_Brewfile.tmpl` renders `~/.Brewfile` (then use `brew bundle --global`).
- Runtimes: `dot_config/mise/config.toml` (use `mise run setup` / `mise run update`).

## Secrets

- Never commit secrets.
- Prefer `chezmoi secrets` and/or local, untracked data/templates for sensitive values.
- Use `.chezmoiignore` to exclude files that should never be applied to `$HOME`.
