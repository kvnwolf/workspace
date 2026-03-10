#!/usr/bin/env bash
# PostToolUse hook: auto-sync dotfiles via stow when new files are created
# or files are deleted in shared/home/ or macos/home/.
#
# Write: runs stow to create symlinks for new files
# Bash(rm): runs stow -R to clean up orphaned symlinks
set -euo pipefail

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name')
project_dir=$(echo "$input" | jq -r '.cwd')

needs_sync=""
is_delete=""

case "$tool_name" in
  Write)
    file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')
    if [[ "$file_path" =~ (shared/home|macos/home) ]]; then
      needs_sync=1
    fi
    ;;
  Bash)
    command=$(echo "$input" | jq -r '.tool_input.command // empty')
    if [[ "$command" =~ rm[[:space:]] && "$command" =~ (shared/home|macos/home) ]]; then
      needs_sync=1
      is_delete=1
    fi
    ;;
esac

if [[ -n "$needs_sync" ]]; then
  cd "$project_dir"

  if [[ -n "$is_delete" ]]; then
    # Restow: removes orphaned symlinks then re-stows
    [[ -d shared/home ]] && stow -R --no-folding -d shared -t ~ home 2>/dev/null || true
    [[ -d macos/home ]] && stow -R --no-folding -d macos -t ~ home 2>/dev/null || true
  else
    # Regular stow: creates symlinks for new files
    [[ -d shared/home ]] && stow --no-folding -d shared -t ~ home 2>/dev/null || true
    [[ -d macos/home ]] && stow --no-folding -d macos -t ~ home 2>/dev/null || true
  fi
fi

exit 0
