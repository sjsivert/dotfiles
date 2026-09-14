---
name: pr-review-html
description: "Full PR review rendered as a self-contained interactive HTML page (dashboard, file heatmap, risk flow, inline annotated code, action checklist). Use when the user says 'review this PR as HTML', 'pr-review-html', '/pr-review-html', or pastes a PR link and wants a visual review document."
argument-hint: "<pr-url-or-number>  e.g. https://github.com/owner/repo/pull/123  or  123"
---

# PR Review → Interactive HTML

Turn a GitHub PR into a single-file interactive review page with severity dashboard, file hotspot heatmap, Mermaid risk flow, inline annotated code findings, test coverage gaps, and an action checklist.

## When to use

- User pastes a PR link/number and asks for a visual review.
- User invokes `/pr-review-html <pr>`.
- User says "review this PR as HTML / as a website / with visualisations".

Do NOT use this for inline GitHub comments — use `code-review` for that. This skill produces a static viewer instead.

## Argument

`$ARGUMENTS` may be a PR URL, `owner/repo#123`, or a bare PR number when the cwd is a git repo for the same project. Resolve to `(owner, repo, number)` before continuing.

## Pipeline (run in order)

### 1. Fetch PR metadata + diff

Use `gh` from the Bash tool:

```bash
gh pr view <num> --repo <owner>/<repo> --json number,title,author,state,mergeable,mergeStateStatus,additions,deletions,changedFiles,baseRefName,headRefName,headRefOid,body,reviewDecision,statusCheckRollup,reviews,comments,files
gh pr diff  <num> --repo <owner>/<repo> > /tmp/pr-<num>.diff
gh pr view  <num> --repo <owner>/<repo> --json files --jq '.files[].path'
```

Capture: title, additions, deletions, changedFiles, mergeable, mergeStateStatus, check count, review count, head SHA. The head SHA is used to build GitHub deep links: `https://github.com/<o>/<r>/blob/<sha>/<path>#L<a>-L<b>`.

### 2. Read changed files

For each changed file in the diff:
- If the repo is checked out locally and on the right SHA: read with Read.
- Otherwise: `gh api repos/<o>/<r>/contents/<path>?ref=<sha> --jq .content | base64 -d`.

For very large files, read the hunks of interest based on the diff context lines.

### 3. Perform the review

Cover these axes — produce structured findings, don't free-write:

| Axis | What to look for |
|------|------------------|
| Correctness | logic errors, off-by-one, null/edge cases, intent vs implementation, data integrity |
| Architecture | layering violations, cohesion, abstractions leaking across boundaries |
| Performance | N+1, unbounded loops, missing batching, hot-path I/O |
| Security | injection, identifier interpolation in SQL, auth/authz on new endpoints, secret exposure |
| Reliability | transactional boundaries, partial-state windows, retries, idempotency |
| Frontend↔Backend contract | header names, payload shapes, advertised vs accepted |
| Readability | giant methods, tuple/dict for typed data, magic strings, name clarity |
| Tests | covered paths vs missing, refactor safety, smoke vs deep |

For each finding capture:

```
{ id, title, severity, category, file, lineStart, lineEnd, githubUrl, codeSnippet, language, why, fix }
```

`severity` ∈ `must-fix | architecture | performance | correctness | readability | reliability | polish`.

Rank: pick a Top-5 (highest-impact items, must-fix first).

### 4. Build the risk flow

Create a Mermaid `flowchart LR` that traces the most consequential code path in the PR. Mark unguarded failure windows / decision points as red nodes. Skip this section gracefully if the PR is purely cosmetic.

### 5. Build the file heatmap

Aggregate finding count per file, classify by layer/project (best-effort from path). Render as a grid where intensity scales with finding count.

### 6. Render the HTML

Write `pr-<number>-review.html` to the current working directory using the template at `references/template.html` in this skill. The template uses Tailwind/Chart.js/Mermaid/Prism via CDN — no build step needed. Substitute the placeholders listed in `references/PLACEHOLDERS.md`.

After writing the file, open it: `open <path>` on macOS, `xdg-open` on Linux, `start` on Windows.

### 7. Report back

In chat, return:
- Path to the HTML file.
- 1-line verdict (`request changes` / `approve with nits` / `approve`).
- Top-3 findings as bullets with GitHub deep-links.

Nothing else. The HTML is the deliverable.

## Style rules for the output

- Verdict must be honest. If the PR is good, say so — don't manufacture findings.
- Severity counts in the dashboard MUST match the finding cards. No phantom numbers.
- Every finding card MUST include a working GitHub deep-link with line range.
- Code snippets must be the exact bytes from the PR, not paraphrased.
- Never include secrets, tokens, internal URLs, or personal data in the rendered HTML.
- Keep the HTML self-contained — CDN only, no local assets, no fonts download requirement.

## Failure modes

- **PR not found / private and no auth**: ask the user to run `gh auth login` and stop.
- **Diff too large to fully read**: review the highest-risk files only and state the limitation in the rendered HTML's hero subtitle.
- **No findings at all**: still render the page, with a single "no significant issues" card and a populated metadata header. The visualisations make the absence visible.
