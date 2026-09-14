---
name: squash-git-analysis
description: Analyse git history, suggest squash groups for interactive rebase, help resolve merge conflicts, and verify correctness against origin after rebase. Use when cleaning up a feature branch before rebase onto main.
user-invocable: true
allowed-tools: Bash, Read, Edit, Write
---

# Squash Git Analysis

Full lifecycle skill for cleaning up a feature branch before rebasing onto main. Detects which phase you are in and acts accordingly.

## Context

**Current branch:**
!`git branch --show-current`

**Rebase in progress:**
!`test -d .git/rebase-merge && echo "YES" || echo "NO"`

**Rebase progress (if active):**
!`test -d .git/rebase-merge && echo "Step $(cat .git/rebase-merge/msgnum)/$(cat .git/rebase-merge/end)" || echo "N/A"`

**Current conflicts (if any):**
!`git status --short | grep "^UU\|^AA\|^DD\|^AU\|^UA\|^DU\|^UD" || echo "none"`

**Remote default branch:**
!`git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|origin/||' || echo "main"`

**Commits ahead of main:**
!`git log main..HEAD --oneline 2>/dev/null || git log origin/main..HEAD --oneline`

**Remote tracking branch:**
!`git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "none"`

---

## Phase Detection

Read the context above and determine which phase applies:

| Condition | Phase |
|-----------|-------|
| Rebase = NO, commits exist ahead of base | **Phase 1: Analyse** |
| Rebase = YES, conflicts exist | **Phase 2: Resolve conflict** |
| Rebase = YES, no conflicts | **Phase 2b: Rebase in progress, no conflict** |
| Rebase = NO, remote tracking branch exists | **Phase 3: Verify** |

If the user's message contains a directive ("check conflicts", "verify", "analyse"), honour that over auto-detection.

---

## Phase 1: Analyse and Suggest Squash Groups

### 1. Gather full commit detail

```bash
# Commit list with stats
git log main..HEAD --stat --format="%H %s%n"
```

### 2. Group commits

Scan the commits and identify logical groups. Typical patterns:

- **Docs/chore** — design docs, planning docs, gitignore, devenv config, CLAUDE.md
- **Feature A** — the first main feature commit + all its fixups (PR review fixes, lint fixes, CI fixes, formatting, test fixes)
- **Feature B** — same pattern for a second feature
- **Refactor** — structural moves (package-by-feature, namespace renames, entity renames)
- **Migration cleanup** — migration additions/removals that belong with their parent feature

A commit belongs to a group if:
- Its message references the same feature/area as the parent
- It says "fix:", "chore:", or "doc:" and clearly corrects the parent
- It is a lint/format/CI fix immediately following the parent

### 3. Output a suggested rebase script

Present two things:

**A. Named groups** with commit SHAs and a rationale for each grouping:

```
Group 1 — Docs/chore (squash into 1)
  pick <sha> doc: ...
  squash <sha> chore: ...
  squash <sha> doc: ...

Group 2 — Feature: <name> (squash into 1)
  pick <sha> feat: ...
  squash <sha> fix: PR review ...
  squash <sha> fix: lint ...
  ...
```

**B. A ready-to-paste rebase todo** the user can drop straight into `git rebase -i`:

```
pick <sha> <msg>
squash <sha> <msg>
...
```

### 4. Flag decisions for the user

Call out anything that needs a human decision:
- Commits that remove migrations (ask: should a fresh migration be added at the end?)
- Commits that rename things mid-branch (should rename be its own commit or folded in?)
- Large commits that mix features (suggest splitting)

Do not start the rebase — hand the script to the user and stop.

---

## Phase 2: Resolve Conflict

A conflict during rebase means git cannot auto-merge the incoming commit's patch because the lines it expected have changed.

### 1. Show the conflict

```bash
git diff -- <conflicted-file>
```

Read the conflict markers:

```
<<<<<<< HEAD
  what's already been replayed (commits already applied)
=======
  what the incoming commit is trying to change
>>>>>>> <sha> (<commit message>)
```

### 2. Identify the correct resolution

Ask: **"What is the correct final state of this file?"**

Decision tree:

1. Read the incoming commit message (`>>>>>>> sha (message)`) — what was it trying to do?
2. Is HEAD missing something the incoming adds? → Take incoming (or combine if additive)
3. Is the incoming reverting something HEAD intentionally has? → Take HEAD
4. Are both sides valid changes to the same area? → Write the version that satisfies both intents

Common patterns:

| Situation | Resolution |
|-----------|-----------|
| Fix commit corrects something HEAD has wrong | Take incoming (`=======` side) |
| Incoming adds new code, HEAD has old version | Take incoming |
| Both sides add different things to same area | Combine manually |
| Rename landed before a fix touches old name | Apply fix using new name |

### 3. Advise, don't edit

Tell the user **which side to take and why**. Be specific: "take the `=======` side — it's the fix correcting the `.AsNoTracking()` call that HEAD still has wrong."

Only edit files if the user explicitly asks.

### 4. After resolution

Remind the user:
```bash
git add <file>
git rebase --continue
```

---

## Phase 3: Verify Against Origin

After rebase completes, the final file state should match the original branch tip on origin.

### 1. Find diverged files

```bash
git diff origin/<branch> HEAD --name-only
```

Where `<branch>` is the current branch name.

### 2. Triage

- **Migration files** — differences here are usually expected (rebase reordered them). Ask the user whether to ignore.
- **Source/test files** — any difference here is a wrong conflict resolution. Show the diff.

```bash
git diff origin/<branch> HEAD -- <file>
```

### 3. Interpret the diff

Direction: `git diff A B` shows what changes from A→B.
- `-` lines: what origin has that local HEAD doesn't (missing code — likely cause of failures)
- `+` lines: what local HEAD has that origin doesn't (extra/wrong code)

### 4. Fix diverged files

For files that should match origin exactly:

```bash
git checkout origin/<branch> -- <file1> <file2> ...
```

Then verify the diff is clean:

```bash
git diff origin/<branch> HEAD -- <file1> <file2> ...
```

### 5. Commit the fix

```bash
git commit -m "fix: restore <description> lost during rebase"
```

### 6. Final check

```bash
git diff origin/<branch> HEAD --name-only
```

Only migration files should remain. If anything else differs, repeat from step 2.

---

## Notes

- Never force-push without asking the user first.
- Never run `git rebase` automatically — always hand the script to the user.
- During conflict help, explain WHY a side wins, not just which side.
- The verify phase should always run after rebase — even a clean rebase can silently drop code via wrong conflict resolution.
