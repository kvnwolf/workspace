#!/bin/bash

jq -n --arg date "$(date +%Y-%m-%d)" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    additionalContext: ("Today is " + $date + ". When searching, use the current year for recent information.")
  }
}'
