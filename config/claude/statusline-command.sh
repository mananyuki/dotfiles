#!/usr/bin/env bash
# Claude Code status line — Starship Jetpack aesthetic
# 2-line layout with geometric symbols and color-coded metrics

set -euo pipefail

# ── ANSI styles ───────────────────────────────────────────────────────────────
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'

# Palette — Starship Jetpack-inspired 256-color
CYAN='\033[38;5;75m'        # bright-blue (model, git branch)
GREEN='\033[38;5;114m'      # bright-green (low usage, additions)
YELLOW='\033[38;5;221m'     # bright-yellow (medium usage, cost)
RED='\033[38;5;203m'        # red (high usage, deletions)
PURPLE='\033[38;5;141m'     # bright-purple (duration)
GREY='\033[38;5;245m'       # dimmed (separators, labels)
WHITE='\033[38;5;252m'      # bright white (values)

# ── Symbols (Starship Jetpack geometric) ──────────────────────────────────────
SYM_MODEL='◎'    # model
SYM_THINK='⟡'    # thinking/effort level
SYM_CTX='◈'      # context gauge
SYM_GIT='△'      # git branch
SYM_COST='◇'     # session cost
SYM_TIME='◷'     # duration
SYM_ADD='▴'      # lines added
SYM_DEL='▿'      # lines removed
SEP="${DIM}${GREY}│${RESET}"

# ── Constants ─────────────────────────────────────────────────────────────────
BAR_WIDTH=12

# ── Helpers ───────────────────────────────────────────────────────────────────
util_color() {
  local pct=${1:-0}
  if   (( pct >= 80 )); then printf '%s' "$RED"
  elif (( pct >= 50 )); then printf '%s' "$YELLOW"
  else                       printf '%s' "$GREEN"
  fi
}

progress_bar() {
  local pct=${1:-0}
  local filled=$(( pct * BAR_WIDTH / 100 ))
  local empty=$(( BAR_WIDTH - filled ))
  local color
  color=$(util_color "$pct")
  printf '%s' "${GREY}▕${RESET}"
  printf '%s' "${color}"
  for (( i=0; i<filled; i++ )); do printf '█'; done
  printf '%s' "${DIM}${GREY}"
  for (( i=0; i<empty; i++ )); do printf '░'; done
  printf '%s' "${RESET}${GREY}▏${RESET}"
}

format_duration() {
  local ms=${1:-0}
  local total_sec=$(( ms / 1000 ))
  if (( total_sec < 60 )); then
    printf '%ds' "$total_sec"
  elif (( total_sec < 3600 )); then
    printf '%dm %ds' $(( total_sec / 60 )) $(( total_sec % 60 ))
  else
    printf '%dh %dm' $(( total_sec / 3600 )) $(( (total_sec % 3600) / 60 ))
  fi
}

format_cost() {
  local cost="${1:-0}"
  # Use awk for float formatting
  awk "BEGIN { printf \"\$%.2f\", ${cost} }"
}

# ── Read stdin JSON (single jq call for performance) ──────────────────────────
INPUT=$(cat)

eval "$(printf '%s' "$INPUT" | jq -r '
  @sh "model_name=\(.model.display_name // "Unknown")",
  @sh "used_pct=\(.context_window.used_percentage // "")",
  @sh "cwd=\(.workspace.current_dir // .cwd // "")",
  @sh "cost_usd=\(.cost.total_cost_usd // 0)",
  @sh "duration_ms=\(.cost.total_duration_ms // 0)",
  @sh "lines_add=\(.cost.total_lines_added // 0)",
  @sh "lines_del=\(.cost.total_lines_removed // 0)",
  @sh "vim_mode=\(.vim.mode // "")"
' 2>/dev/null)" 2>/dev/null || {
  model_name="Unknown"; used_pct=""; cwd=""; cost_usd=0
  duration_ms=0; lines_add=0; lines_del=0; vim_mode=""
}

# ── Effort level (not in statusline JSON yet; read from env/settings) ────────
effort_level=""
if [[ -n "${CLAUDE_CODE_EFFORT_LEVEL:-}" ]]; then
  effort_level="$CLAUDE_CODE_EFFORT_LEVEL"
elif [[ -n "$cwd" && -f "$cwd/.claude/settings.json" ]]; then
  effort_level=$(jq -r '.effortLevel // empty' "$cwd/.claude/settings.json" 2>/dev/null)
fi
if [[ -z "$effort_level" && -f "$HOME/.claude/settings.json" ]]; then
  effort_level=$(jq -r '.effortLevel // empty' "$HOME/.claude/settings.json" 2>/dev/null)
fi
: "${effort_level:=medium}"

effort_color="$YELLOW"
case "$effort_level" in
  high) effort_color="$GREEN" ;;
  low)  effort_color="$GREY"  ;;
esac

# ── Line 1: Model │ Context bar │ Git ─────────────────────────────────────────
# Model + effort level
line1="${BOLD}${CYAN}${SYM_MODEL} ${model_name}${RESET} ${DIM}${effort_color}${SYM_THINK} ${effort_level}${RESET}"

# Vim mode (if active)
if [[ -n "$vim_mode" ]]; then
  if [[ "$vim_mode" == "NORMAL" ]]; then
    line1+=" ${DIM}${GREEN}■${RESET}"
  else
    line1+=" ${DIM}${YELLOW}▪${RESET}"
  fi
fi

# Context usage
line1+=" ${SEP} "
if [[ -n "$used_pct" && "$used_pct" != "null" ]]; then
  used_int=$(printf '%.0f' "$used_pct")
  ctx_color=$(util_color "$used_int")
  bar=$(progress_bar "$used_int")
  line1+="${ctx_color}${SYM_CTX} ${used_int}%${RESET} ${bar}"
else
  line1+="${GREY}${SYM_CTX} --${RESET}"
fi

# Git branch + diff stats
if [[ -n "$cwd" ]] && git -C "$cwd" rev-parse --git-dir &>/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$cwd" rev-parse --short HEAD 2>/dev/null \
    || echo "")
  if [[ -n "$branch" ]]; then
    line1+=" ${SEP} ${ITALIC}${CYAN}${SYM_GIT} ${branch}${RESET}"
    diff_stat=$(git -C "$cwd" diff --no-lock-index --shortstat HEAD 2>/dev/null || echo "")
    if [[ -n "$diff_stat" ]]; then
      ins=$(echo "$diff_stat" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo "")
      del=$(echo "$diff_stat" | grep -oE '[0-9]+ deletion'  | grep -oE '[0-9]+' || echo "")
      [[ -n "$ins" && "$ins" -gt 0 ]] && line1+=" ${GREEN}${SYM_ADD}${ins}${RESET}"
      [[ -n "$del" && "$del" -gt 0 ]] && line1+=" ${RED}${SYM_DEL}${del}${RESET}"
    fi
  fi
fi

# ── Dog: emoji-based, context usage drives energy level ───────────────────────
# Determine context level
if [[ -n "$used_pct" && "$used_pct" != "null" ]]; then
  used_int_dog=$(printf '%.0f' "$used_pct")
else
  used_int_dog=0
fi

# Animation: alternate on elapsed seconds (odd/even)
elapsed_sec=$(( duration_ms / 1000 ))

# Energy tiers:
#   low  (< 50%): 🐕💨💨 ↔ 🐕💨  — sprinting, lots of wind
#   mid  (50-79%): 🐕💨  ↔ 🐕    — tiring, wind fades
#   high (>= 80%): 🐕             — stopped, exhausted (no animation)
if (( used_int_dog >= 80 )); then
  dog_str='🐕'
elif (( used_int_dog >= 50 )); then
  if (( elapsed_sec % 2 == 0 )); then dog_str='🐕💨'
  else                                dog_str='🐕'
  fi
else
  if (( elapsed_sec % 2 == 0 )); then dog_str='🐕💨💨'
  else                                dog_str='🐕💨'
  fi
fi

# ── Line 2: Cost │ Duration │ Lines changed │ Dog ─────────────────────────────
cost_str=$(format_cost "$cost_usd")
dur_str=$(format_duration "$duration_ms")

line2="${ITALIC}${YELLOW}${SYM_COST} ${cost_str}${RESET}"
line2+=" ${DIM}${GREY}◈${RESET} "
line2+="${ITALIC}${PURPLE}${SYM_TIME} ${dur_str}${RESET}"

# Lines changed (only show if non-zero)
if [[ "$lines_add" -gt 0 || "$lines_del" -gt 0 ]]; then
  line2+=" ${DIM}${GREY}◈${RESET} "
  [[ "$lines_add" -gt 0 ]] && line2+="${ITALIC}${GREEN}${SYM_ADD}${lines_add}${RESET}"
  if [[ "$lines_add" -gt 0 && "$lines_del" -gt 0 ]]; then
    line2+=" "
  fi
  [[ "$lines_del" -gt 0 ]] && line2+="${ITALIC}${RED}${SYM_DEL}${lines_del}${RESET}"
fi

# Dog
line2+=" ${DIM}${GREY}◈${RESET} ${WHITE}${dog_str}${RESET}"

# ── Output ────────────────────────────────────────────────────────────────────
printf '%b\n' "$line1"
printf '%b\n' "$line2"
