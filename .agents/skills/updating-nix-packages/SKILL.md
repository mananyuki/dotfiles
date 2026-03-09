---
name: updating-nix-packages
description: Updates custom Nix packages in nix/packages/ to their latest GitHub release versions, computing new SRI hashes. Use when the user wants to bump package versions, check for outdated packages, or automate Nix package maintenance.
user-invocable: true
---

# Updating Nix Packages

Check and update custom Nix packages in `nix/packages/` to their latest GitHub release versions.

## Command

```
/updating-nix-packages [arguments]
```

| Argument | Description |
|----------|-------------|
| (none) | Check all packages and update any with newer releases |
| `<name>` | Update a specific package (e.g., `mo`, `deck`) |
| `check` | Dry run; report available updates without modifying files |

## Workflow

### Step 1: Parse Arguments

Parse `$ARGUMENTS`:

| Input | Mode |
|-------|------|
| (empty) | Update all packages |
| `check` | Dry run; report only |
| `<name>` | Update only the named package |

### Step 2: Run Update Script

Run `scripts/update-packages.ts` from the skill directory:

```bash
bun run .agents/skills/updating-nix-packages/scripts/update-packages.ts [--check] [--package <name>]
```

Flag mapping:
- (no args) → update all
- `check` mode → `--check`
- `<name>` → `--package <name>`

### Step 3: Report Results

The script outputs JSON lines. Convert to a summary table for the user:

```markdown
| Package | Before | After | Status |
|---------|--------|-------|--------|
| mo | 0.16.1 | 0.17.0 | updated |
| deck | 1.23.0 | 1.23.0 | up-to-date |
| datadog-mcp-cli | — | — | skipped |
```

---

## Key Decisions and Gotchas

### Skip condition

Files without a `github.com/.../releases/download/` URL pattern are skipped. This covers `datadog-mcp-cli.nix` which uses a fixed, non-versioned URL.

### Hash computation

Use `nix store prefetch-file --json <url>` to compute SRI hashes. This returns the hash for the file as downloaded (not unpacked). This is the correct hash for `fetchurl`.

Do NOT use `nix-prefetch-url --unpack`; that computes the hash of the unpacked content, which causes a mismatch with `fetchurl`.

### Version extraction

The `version` field in `.nix` files does not include a `v` prefix. GitHub release tags typically do (e.g., `v0.16.1`). Always strip the `v` prefix from the tag before comparing or substituting.

### URL template

The URL in each `.nix` file uses `${version}` interpolation. When constructing the new download URL for hash computation, substitute the new version into the template extracted from the file.

### sed portability

On macOS, `sed -i` requires an empty string argument: `sed -i '' ...`. The update script uses Bun's file APIs instead of sed to avoid this issue.

---

## Error Handling

| Scenario | Handling |
|----------|----------|
| `gh` CLI not available | Exit with error message |
| `nix` CLI not available | Exit with error message |
| GitHub API rate limit | Show warning with reset time, continue with remaining packages |
| Hash computation fails | Show error for that package, continue with others |
| No `.nix` files match | Report "no packages found" |

---

## File Format Assumptions

Each `.nix` file in `nix/packages/` follows this structure:

- `version = "<semver>";` on its own line
- `hash = "sha256-...";` on its own line
- URL contains `github.com/<owner>/<repo>/releases/download/`
