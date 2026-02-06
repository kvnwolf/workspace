---
name: begin
description: Start working on a new task with a clean, up-to-date workspace.
disable-model-invocation: true
argument-hint: "[what you'll work on]"
allowed-tools: Bash(git status *), Bash(git checkout *), Bash(git pull *)
---

# Begin

Start working on a new task with a clean, up-to-date workspace.

## Branch Naming

Convert user input to semantic branch name in kebab-case:

**Format:** `<type>/<description>` or `<type>/<ticket-or-issue-id>/<description>` if issue tracker is setup

**Types** (from conventional commits):
- `feat` — new feature
- `fix` — bug fix
- `docs` — documentation
- `style` — formatting, no code change
- `refactor` — code restructuring
- `perf` — performance improvement
- `test` — adding/updating tests
- `build` — build system, dependencies
- `ci` — CI/CD configuration
- `chore` — maintenance tasks

**Examples:**

| User Input | Branch Name |
|------------|-------------|
| "add dark mode" | `feat/add-dark-mode` |
| "fix login bug" | `fix/login-bug` |
| "GH-456 fix memory leak" | `fix/gh-456/memory-leak` |
| "update readme" | `docs/update-readme` |
| "refactor auth module" | `refactor/auth-module` |

## Workflow

1. **Ensure clean state:** verify no uncommitted changes exist, otherwise ask user to stash or commit first
2. **Sync with latest:** switch to main and pull the latest changes
3. **Create workspace:** create and switch to the new branch
4. **Confirm:** show new branch name, remind to use `/finish` when ready

### Git Actions

```
git status --porcelain
git checkout main
git pull origin main
git checkout -b <branch-name>
```

**IMPORTANT:** Run each git command separately. Do NOT chain commands with `&&`.
