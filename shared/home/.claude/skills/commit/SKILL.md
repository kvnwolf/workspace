---
name: commit
description: Wrap up your work with documentation sync, commit, push, and pull request creation.
disable-model-invocation: true
allowed-tools: Bash(git diff *), Bash(git log *), Bash(git add *), Bash(git commit *), Bash(git branch)
---

# Commit

Wrap up your work: sync documentation, commit changes, push, and open a pull request.

## Workflow

### 1. Require Documentation Section

Check if @CLAUDE.md contains a `## Documentation` section.

If the section exists, skip to step 2.

If NOT exists:

1. Inform: "This project needs a documentation section in CLAUDE.md. Starting setup..."
2. Launch **3 parallel subagents** (Task tool with `subagent_type: Explore`):
   **Agent 1 - Project Structure & Tech Stack:**
   - Analyze top-level and src/ directories to identify logical areas
   - Identify package manager, framework, and build tools
   - Return project context summary with detected areas and stack
   **Agent 2 - Existing Documentation:**
   - Find all `*.md` files (excluding node_modules, .git, dist)
   - Read each file and analyze its content in depth
   - For each file, determine its purpose and what specific condition should trigger an update (be precise — e.g. "Function signatures in src/api/ change" not just "Code changes")
   - Return mapping of files to their detected purpose and update condition
   **Agent 3 - Documentation Gaps:**
   - Based on project structure and existing docs, identify what documentation is missing
   - Common gaps: API reference, contributing guide, changelog, architecture overview
   - Only suggest files that provide real value for the project's size and type
   - Return suggestions with file path, purpose, and rationale
3. Wait for all agents to complete.
4. If Agent 3 found gaps, present suggestions to the user with `AskUserQuestion` (`multiSelect: true`). Create any selected files with initial content.
5. Build the `## Documentation` table from Agent 2 results (plus any files created in step 4):
   | File | Purpose | Update When |
   |------|---------|-------------|
   | (each file with its detected purpose and precise update condition) |
6. Edit @CLAUDE.md to add the `## Documentation` section with the table. It must be the **last section** in the file.
7. Show the generated table to the user for confirmation.

Do NOT continue until the documentation section exists.

### 2. Gather Context

Run each command separately:

1. `git diff --staged`
2. Only if step 1 had NO output: `git diff`
3. `git log --oneline`

### 3. Determine Staging

- If `git diff --staged` has output -> staged changes exist, use them as-is (user curated manually)
- If `git diff --staged` is empty -> run `git add -A` to stage everything

### 4. Sync Documentation

1. Read the `## Documentation` table from @CLAUDE.md
2. Find all staged `*.md` files, detect its purpose and update condition, then register it in the table.
3. For each tracked file, evaluate whether its "Update When" condition is met by the staged changes.
4. Read and update every file whose condition is met. The update must reflect the actual staged changes accurately.
5. If new files were registered in step 2, persist the updated table in @CLAUDE.md.

### 5. Stage Documentation

Stage any `.md` files updated or created in step 4:

```bash
git add <updated-doc-files>
```

### 6. Generate and Execute Commit

**Subject line:** imperative mood, **always start with a lowercase letter**, no period, max 70 characters. Describe **what** the change does as a clear, self-contained statement.

**Body:** explain **why** the change was made. Include context that the diff alone cannot convey: motivation, trade-offs, decisions, or migration steps. If the change breaks backward compatibility, state it explicitly in the body.

**References:** append issue/ticket references on their own line at the end (e.g., `Closes #142`).

1. Analyze the staged diff to understand what changed
2. Write a subject line that describes the change in imperative mood
3. Write a body explaining why the change was made
4. Add issue references if applicable
5. Execute with HEREDOC:

```bash
git commit -m "$(cat <<'EOF'
subject line describing what changed

Body explaining why this change was made. What problem does it solve?
What was the motivation? Any important context the diff can't convey.

Closes #issue (if applicable)
EOF
)"
```

### 7. Push

```bash
git push -u origin HEAD
```

### 8. Pull Request

Only offer this step if the branch was pushed in step 8.

1. Run `git branch` to determine the current branch. If the branch is `main`, then stop
2. Generate a PR title and body from commits since divergence:
   ```bash
   git log <base-branch>..HEAD --oneline
   git diff <base-branch>...HEAD
   ```
3. Create the PR:
   ```bash
   gh pr create --title "<title>" --body "$(cat <<'EOF'
   ## Summary
   <bullet points from commit analysis>

   ## Test plan
   <checklist>
   EOF
   )"
   ```
