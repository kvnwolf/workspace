---
name: review-pr
description: Review and merge a pull request. Analyzes code changes, validates the test plan, runs tests, posts a review with inline comments, and merges if everything passes.
disable-model-invocation: true
argument-hint: "<PR number>"
allowed-tools: Bash(gh pr view *), Bash(gh pr diff *), Bash(gh pr checkout *), Bash(gh api *), Bash(git switch *), Bash(git checkout *), Read, Grep, Glob
---

# Review

Review a pull request: analyze code changes, validate and execute the test plan, post a review with inline comments, and merge.

## PR Context

!`gh pr view $0 --json number,title,body,author,state,baseRefName,headRefName,mergeable,labels,reviewDecision,statusCheckRollup 2>/dev/null || echo "ERROR: Could not fetch PR #$0. Verify the PR number and try again."`

## Workflow

### 1. Validate PR State

Confirm the PR is open and mergeable using the context above.

**Stop conditions:**
- PR is not found → inform and stop
- PR is already merged or closed → inform and stop
- PR has merge conflicts (`mergeable` is `CONFLICTING`) → inform and stop

### 2. Fetch and Analyze the Diff

Retrieve the full diff and the list of changed files.

```bash
gh pr diff $0
```

```bash
gh pr diff $0 --name-only
```

### 3. Review the Code

Read each changed file and review the new code thoroughly. For each file, evaluate:

- **Correctness**: logic errors, edge cases, null/undefined handling
- **Security**: injection vulnerabilities, exposed secrets, unsafe operations
- **Performance**: unnecessary allocations, N+1 queries
- **Readability**: unclear naming, dead code
- **Consistency**: adherence to existing patterns and conventions
- **Commit messages**: conventional commits format (`type(scope): lowercase subject`, imperative mood, no period, max 70 chars)

Use `Read`, `Grep`, and `Glob` on unchanged source files when surrounding context is needed to understand the changes.

Classify each finding and track the file path and line number:

| Severity | Meaning | Effect |
|----------|---------|--------|
| `blocking` | Must fix before merge | Request changes, do NOT merge |
| `suggestion` | Worth considering | Include in review, still merge |
| `nit` | Minor stylistic note | Include in review, still merge |

### 4. Execute the Test Plan

Extract the test plan from the `## Test plan` section of the PR body (loaded in PR Context above).

**If no test plan exists**, this is a `blocking` finding. Do NOT proceed.

**If a test plan exists**, check out the PR branch and execute each step described in it:

```bash
gh pr checkout $0
```

Run each command or verification step listed in the test plan. Only run what is specified — do not assume or add project-specific commands.

**On failure:** record the output as a `blocking` finding.

After all steps are executed, update the PR body to mark completed checkboxes. Replace `- [ ]` with `- [x]` for each step that passed:

```bash
gh pr edit $0 --body '<updated body with checked boxes>'
```

After running, switch back to the previous branch:

```bash
git switch -
```

### 5. Post Review

Build the review with **inline comments** on specific files and lines for each finding, plus a brief summary.

Derive `{owner}/{repo}` and the head commit SHA:

```bash
gh repo view --json nameWithOwner --jq '.nameWithOwner'
```

```bash
gh pr view $0 --json headRefOid --jq '.headRefOid'
```

#### Inline comment format

Use `line` (file line number) and `side: "RIGHT"` for each comment. For multi-line comments, also include `start_line` and `start_side: "RIGHT"`.

When a finding has a **concrete code fix**, use GitHub's suggested changes syntax in the comment body. This renders an "Apply suggestion" button the author can click to commit the fix directly:

````
```suggestion
corrected code here
```
````

For multi-line suggestions, attach the comment to the full line range using `start_line` and `line`, and include the complete replacement in the suggestion block.

#### Submit the review

Pass the entire payload via heredoc to `--input -`. Do NOT combine `--input` with `-f` flags — `--input` overrides them.

**If blocking findings exist** (`REQUEST_CHANGES`):

```bash
gh api repos/{owner}/{repo}/pulls/$0/reviews \
  --method POST \
  --input - <<'REVIEW'
{
  "commit_id": "<head commit SHA>",
  "event": "REQUEST_CHANGES",
  "body": "<brief summary of blocking issues>",
  "comments": [
    {
      "path": "src/example.ts",
      "line": 42,
      "side": "RIGHT",
      "body": "blocking: description\n\n```suggestion\nfixed code here\n```"
    }
  ]
}
REVIEW
```

**If no blocking findings** (`APPROVE`):

```bash
gh api repos/{owner}/{repo}/pulls/$0/reviews \
  --method POST \
  --input - <<'REVIEW'
{
  "commit_id": "<head commit SHA>",
  "event": "APPROVE",
  "body": "<brief summary or LGTM>",
  "comments": [
    {
      "path": "src/example.ts",
      "line": 42,
      "side": "RIGHT",
      "body": "suggestion: Consider using..."
    }
  ]
}
REVIEW
```

**Self-review fallback:** GitHub does not allow `APPROVE` or `REQUEST_CHANGES` on your own PR. If the API returns a 422 with "Can not approve your own pull request", resubmit with `"event": "COMMENT"` instead and inform the user.

### 6. Merge

Only if the review in step 5 was an approval (or a `COMMENT` fallback with no blocking findings).

This step is NOT in `allowed-tools` — the user must confirm the merge.

```bash
gh pr merge $0 --squash --delete-branch
```

Confirm the merge succeeded and report the result.

**Re-review:** If changes were requested, the author can apply the suggested changes via GitHub's one-click "Apply suggestion" button, then re-run `/review-pr $0`. On re-review, if no blocking issues remain, the skill will approve and merge.

**IMPORTANT:** Run each command separately. Do NOT chain commands with `&&`.
