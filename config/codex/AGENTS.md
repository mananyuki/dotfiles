# Codex CLI Agent Guidelines

Personal conventions and guardrails that apply across all projects.

## Core Rules

- When asked to update or modify an existing file, ALWAYS update the existing file in place. Never create a new file unless explicitly asked to create one.
- When interrupted or cancelled, pause and ask what went wrong before retrying. Do not simply re-run the same approach.
- Do not proceed to the next phase of a multi-step workflow without explicit approval.
- Always prefer simplicity over pathological correctness. YAGNI, KISS, DRY. No backward-compat shims or fallback paths unless they come free without adding cyclomatic complexity.
- When proposing an approach, surface assumptions, blind spots, and opportunity costs. Challenge the premise before jumping to implementation.

## Git Workflow

- Before committing, always run `git status` and confirm the exact list of files to be included.
- Never commit files outside the explicitly requested scope. If unsure, ask.

## Conventions

- All dates and times should be handled in JST (Asia/Tokyo, UTC+9) unless explicitly stated otherwise. When querying APIs with date filters (Slack, Backlog, GitHub), widen the UTC date range by 1 day to account for timezone offset.
- Use English for all generated code, documentation, and file content by default. Only use Japanese when explicitly requested.
- Before designing a custom solution, check whether existing tools or CLI flags already handle the use case.
- When researching or citing information, prefer primary sources (official docs, specs, peer-reviewed papers) over secondary sources (blogs, aggregators). Clearly separate facts from inferences.
- Lead with the conclusion (BLUF), then provide supporting details. Keep responses concise.

## Writing Style

- Avoid overusing em dashes (—). They are an AI writing tell when used excessively. Reserve em dashes for a single dramatic pause or contrast per piece (e.g., "— and failed."). For all other cases, use the natural punctuation: semicolons for contrast, commas for parenthetical inserts, colons for lists or elaboration.
