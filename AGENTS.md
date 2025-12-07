# Repository Guidelines

## Project Structure & Module Organization

- This repository stores chezmoi source files; `chezmoi apply` materializes them under `$HOME`.
- Configuration lives in `dot_config/**`: notable subfolders include `dot_config/nvim` for LazyVim, `dot_config/zsh` for shell customizations, and `dot_config/ghostty` or `dot_config/zellij` for terminal tooling.
- Provisioning scripts sit in `run_once_*` and `run_onchange_*`. The numeric prefixes define execution order during bootstrap and updates.
- Template files such as `dot_Brewfile.tmpl` or `run_once_20-install-runtimes.sh.tmpl` use Go template directives to switch packages and tasks per profile (`home`, `work`, etc.).

## Build, Test & Development Commands

- `chezmoi diff` — inspect pending changes versus the live home directory to avoid unintended churn.
- `chezmoi apply --dry-run` — simulate writes before applying to guard against destructive edits.
- `chezmoi apply` — apply changes once the diff is approved.
- `chezmoi doctor` — verify chezmoi prerequisites on the current host.
- `mise run setup` / `mise run update` — install or refresh toolchains defined in `dot_config/mise/config.toml`.
- `brew bundle --file ~/.Brewfile` — reconcile Homebrew packages after templates are rendered.

## Coding Style & Naming Conventions

- Shell scripts use `#!/bin/bash`, two-space indentation, explicit `mkdir -p`, and must stay idempotent.
- Lua modules follow LazyVim defaults: two-space indentation, trailing commas in tables, and modularized configs under `dot_config/nvim/lua/**`.
- Go templates keep conditional blocks tight (e.g., `{{ if eq .profile "work" }}`) and lists sorted alphabetically to minimize churn.
- Script names follow `run_once_XX-description.sh` or `run_onchange_task.sh` to signal intent and execution order.

## Testing Guidelines

- Always run `chezmoi diff` and `chezmoi apply --dry-run` before committing to validate the rendered output.
- For shell updates, run `shellcheck run_once_*.sh` (or relevant paths) and use `$SHELL -n` for zsh/fish syntax checks.
- For Neovim changes, execute `nvim --headless "+Lazy sync" +qa` to confirm plugin sync and formatting.
- For documentation edits, run `npx textlint -c dot_textlintrc.json README.md AGENTS.md` to enforce wording consistency.

## Commit & Pull Request Guidelines

- Follow Conventional Commits (`feat(nvim): enable relative numbers`, `chore(deps): update awscli`). Use directory-based scopes and keep one logical change per commit.
- Pull requests must summarize intent, specify affected profiles, list validation commands (e.g., `chezmoi diff` output), and include screenshots when UI-facing assets change.
- Document additions to `dot_config/mise/config.toml` or new scripts so reviewers understand environment prerequisites.
- Use the PR body to reference issues, note secrets handling, and mention any follow-up tasks.

## Security & Secrets Management

- Never commit secrets. Inject tokens and private keys via `chezmoi secrets` or local data templates that remain untracked.
- When introducing profile-specific corporate settings, minimize the scope of `{{ if eq .profile "work" }}` blocks and ensure private files are excluded through `.chezmoiignore`.
