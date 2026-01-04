#!/bin/bash
set -euo pipefail

# Get current workspace.
current_workspace="$(aerospace list-workspaces --focused)"

# Move PiP windows to current workspace (handles both "Picture-in-Picture" and "Picture in Picture").
aerospace list-windows --all \
  | grep -E '(Picture-in-Picture|Picture in Picture|ピクチャーインピクチャー|ピクチャー イン ピクチャー)' \
  | awk '{print $1}' \
  | while IFS= read -r window_id; do
      if [[ -n "$window_id" ]]; then
        aerospace move-node-to-workspace --window-id "$window_id" "$current_workspace"
      fi
    done || true
