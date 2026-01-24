#!/bin/bash

input=$(cat)

current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
dir=$(echo "$current_dir" | sed "s|/Users/$USER|~|" | sed "s|~/Developer/github.com/| |")

badges=()

branch=$(git -C "$current_dir" branch --show-current 2>/dev/null)
if [ -n "$branch" ]; then
  status=$(git -C "$current_dir" -c diff.ignoreSubmodules=all status --porcelain 2>/dev/null)
  if [ -n "$status" ]; then
    badges+=("$branch *")
  else
    badges+=("$branch")
  fi
fi

model=$(echo "$input" | jq -r '.model.display_name // empty')
if [ -n "$model" ]; then
  badges+=("$model")
fi

context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
current_usage=$(echo "$input" | jq -r '.context_window.current_usage // null')

if [ "$current_usage" != "null" ] && [ "$context_size" -gt 0 ]; then
  current_tokens=$(echo "$current_usage" | jq -r '(.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)')
  percent_used=$((current_tokens * 100 / context_size))
  badges+=("${percent_used}%")
fi

printf "%s" "$dir"

for badge in "${badges[@]}"; do
  printf " [%s]" "$badge"
done