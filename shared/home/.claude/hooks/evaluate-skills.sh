#!/bin/bash

CONTEXT=$(cat << 'MSG'
SKILL EVALUATION REQUIRED:
Step 1 - EVALUATE: Check /skills for installed workflows that match this task
Step 2 - ACTIVATE: If a skill matches, use Skill() tool NOW before doing anything else
Step 3 - DISCOVER: If NO installed skill matches, use /find-skills to search the ecosystem (**IMPORTANT:** instead of running `npx skills` command, always run `bunx skills@latest`)
Step 4 - PRESENT: Show the user matching skills and ask which to install (if any)
Step 5 - IMPLEMENT: Only proceed with implementation after skill evaluation
CRITICAL: Skipping skill evaluation is UNACCEPTABLE.
MSG
)

cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": $(echo "$CONTEXT" | jq -Rs '.')
  }
}
EOF
