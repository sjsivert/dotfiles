---
name: run-plan
description: Execute a written implementation plan by dispatching one fresh subagent per task, gated by a single parallel review from the repo's own reviewer agents (or generic ones when it has none). Use when a plan exists in docs/plans/ or docs/superpowers/plans/ and you want it built without the superpowers subagent-driven-development overhead. No TDD gate — verification is a scoped build plus the affected tests.
disable-model-invocation: false
user-invocable: true
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, Task, Agent, Skill
---

# run-plan

Execute a plan task-by-task: fresh implementer subagent per task, **one** review
gate per task, **one** fix round, then move on.

**Usage:** `/run-plan docs/plans/<plan>.md`

This is the lighter alternative to `superpowers:subagent-driven-development`.
It keeps the three mechanics that actually pay for themselves — a ledger that
survives compaction, serial implementers, and artifacts passed as file paths —
and drops the rest.

| Superpowers SDD | run-plan |
|---|---|
| TDD required; RED/GREEN evidence in every report | **No TDD.** Gate is a green scoped build + affected tests passing |
| Up to 5 fix rounds, each with its own scoped re-review agent | **One** fix round, then adjudicate |
| Generic two-stage reviewer (spec + quality) per task | The repo's own reviewer agents (or generic ones), **in parallel**, selected by changed files |
| Pre-flight conflict table over every task pair | Shared-file check only |
| Plan must contain literal code for every step | Plan carries paths, signatures and acceptance — not the implementation |

## Plan contract

A plan runs through this skill when each task looks like this. No code blocks
required — the implementer writes the code, the plan says what it must satisfy.
`## Task N:` and `### Task N:` are both recognised.

```markdown
## Task N: <name>

**Files:**
- Create: `exact/path/Foo.cs`
- Modify: `exact/path/Bar.cs`
- Test: `tests/exact/path/FooTests.cs`

**Interfaces:**
- Consumes: <exact signatures this task relies on from earlier tasks>
- Produces: <exact names, parameter and return types later tasks rely on>

**Does:** 2-5 lines of prose.

**Done when:**
- <concrete, checkable acceptance conditions>

**Verify:** `dotnet build ./src/Orders/Orders.csproj -c Release && dotnet test ./tests/Orders.Tests`
```

**Interfaces stays.** Everything else can be prose, but an implementer sees only
its own brief — exact signatures are the only way it learns the names its
neighbours use. Drop them and Task 5 invents `ClearLayers()` against Task 3's
`ClearFullLayers()`.

**Verify is per-task and scoped.** The whole-solution build belongs in the
final gate, not in twelve consecutive tasks. Name the one project or package the
task touches. Build in the configuration the final gate uses: in .NET that is
`-c Release`, because Debug skips analyzers and a Debug-green task fails the
final gate.

A plan written by `superpowers:writing-plans` runs here unchanged; its literal
code blocks are treated as reference, not as transcription targets.

## Setup

1. **Worktree.** Work never starts on `main`. Create or reuse a git worktree
   (`git worktree add`, or the harness's worktree tool). Gitignored local config
   never follows a new worktree; if `CLAUDE.md` names files or a skill for
   syncing it (launch settings, `.env`), run that before the first task.
2. **Workspace + ledger.** Run `scripts/workspace.sh PLAN_FILE`; it prints the
   plan's git-ignored directory. Check `<workspace>/progress.md`:
   - First line names **this** plan → tasks with a `Task N: complete` line are
     done. Resume at the first task without one. **Never re-dispatch a completed task.**
   - First line names another plan → leave it, start your own.
   - Missing → create it, first line `# run-plan ledger — plan: <path>`.

   Your context does not survive compaction; the ledger does. After a compaction,
   trust the ledger and `git log` over your own recollection.
3. **Read the plan once.** Create a todo per task. If it names a Spec, read that
   too — the spec is the binding authority when the plan contradicts itself.
4. **Shared-file check.** List each file two or more tasks both touch, and note
   which task creates it. Write the list to the ledger. That is the whole
   pre-flight — the review gate catches the rest.

## Model selection

**Always name the model in every dispatch.** An omitted model inherits this
session's — often the most expensive one available — which silently defeats
this entire section. It is the single largest cost and latency lever in the skill.

| Work | Model |
|---|---|
| Single-file mechanical edit, plan says exactly what to write | `haiku` |
| Ordinary task: a handler, a service, a component, its tests | `sonnet` |
| Cross-layer design judgment, tricky concurrency, schema change | `opus` |
| Task review personas | `sonnet` |
| Final whole-branch review | `opus` |
| Fix round after a failed review | one tier above the implementer that missed it |

Turn count beats token price: the cheapest model routinely takes 2-3× the turns
on multi-step work and costs more overall. `sonnet` is the floor for anything
that spans two files.

## The task loop

### 1. Dispatch the implementer

Record `BASE=$(git rev-parse HEAD)` **before** dispatching — the review package
needs it.

Run `scripts/task-brief.sh PLAN_FILE N`. The dispatch prompt contains exactly:

1. One line on where this task sits in the project.
2. The brief path — "read this first, it is your requirements".
3. Interfaces and decisions from earlier tasks the brief cannot know.
4. Your resolution of any ambiguity you spotted in the brief.
5. The report-file path (`task-N-report.md`, beside the brief).

Nothing else. Do **not** paste prior-task summaries into later dispatches —
that is how a dispatch prompt reaches 40k characters of which almost all is
history the subagent will never use.

Template: [implementer-prompt.md](implementer-prompt.md)

**Batch same-shape work.** Several tasks that are each the same small edit
across different files — one constant, one field, one rename — go out as **one**
dispatch listing every file, reviewed as one diff. One dispatch per task is for
work that needs its own judgment and its own review surface.

**Never dispatch two implementers in parallel.** They conflict in the worktree.

### 2. Handle the report

- **DONE** → go to the review gate.
- **DONE_WITH_CONCERNS** → read them first. Correctness or scope concerns get
  resolved before review; observations go to the ledger.
- **NEEDS_CONTEXT** → supply what is missing, re-dispatch the same agent.
- **BLOCKED** → change something: more context, a more capable model, a smaller
  slice, or a ruling on a plan defect. Never re-dispatch unchanged.

Before reviewing, confirm the report carries the build command, the test command,
and their output. A report without evidence is not DONE.

### 3. Review gate — parallel reviewers

Run `scripts/review-package.sh PLAN_FILE BASE HEAD` and hand every reviewer the
path it prints. Never paste a diff into a dispatch. If the script warns that the
package is too large for one `Read`, the task was too big: dispatch the reviewers
per file group rather than letting each one silently review the first page.

**Use the repo's reviewers when it has them.** Look in `.claude/agents/` (often
`.claude/agents/review/`) and for a table that picks them by changed files, in
`CLAUDE.md` or a review-team command. If one exists, use it as written.

Otherwise pick generic reviewers by the changed-file set:

- **Always:** correctness, code quality, testing
- security — auth, public endpoints, user input, sensitive fields
- migration — migrations, schema changes, raw SQL
- concurrency — caching, shared mutable state, background work, session state
- performance — ORM queries, loops over collections, I/O-heavy paths
- architecture — cross-layer references, a new service or module
- frontend — templates, styles, client-side scripts

Spawn all selected reviewers **in one message** so they run concurrently, on
`sonnet`. Each gets: the review-package path, the brief path, the plan's Global
Constraints verbatim, and the task's `Done when` list.

Never tell a reviewer what not to flag. If you think a finding will be a false
positive, let it be raised and adjudicate it — "don't treat X as a defect" in a
review prompt is pre-judging to spare yourself a fix round.

Triage findings on a P0-P3 scale, or the repo's own scale if its review command
defines one: P0 breaks the build, loses data or opens a security hole; P1 is
wrong behaviour or an unmet `Done when`; P2 is maintainability; P3 is a nit.

- **P0/P1** → fix round.
- **P2/P3** → ledger as `Task N: deferred: <one-liner>`, carried to the final review.

### 4. One fix round

Resume the original implementer with the open findings verbatim — its context is
intact. If your harness cannot message a live subagent, dispatch a fresh one with
the brief path, the report path and the findings.

It fixes, re-runs the affected tests, appends to the same report file.

**Verify the fix yourself** — read the fix report and the diff. Do not spawn a
re-review agent; that seat is what makes SDD expensive, and a one-round loop does
not need it. Re-run the persona gate only if the fix touched files outside the
findings.

Still open after one round? Adjudicate, do not loop:

- **Reviewer wrong or contestable** → park it: `Task N: parked — <finding> — Ruling: <why the code stands>`
- **Real but nothing downstream depends on it** → park it with a ruling that says so.
- **Real and load-bearing** — a later task builds on it, or it exposes a plan
  defect → rule on the smallest change that unblocks the dependent work, ledger
  the ruling, carry it into the next dispatch.

Never fix findings yourself in the controller session: it pollutes the context you
need for coordination, and controller fixes reach `main` unreviewed.

### 5. Complete

Append `Task N: complete (commits <base7>..<head7>, review clean)` — or
`(… , K parked)` — mark the todo done, move on. No check-in with the user between
tasks. They asked for the plan to be executed.

## Rulings, not stalls

A running plan does not wait for a human. Contradictions, plan defects, ambiguity:
decide them, record `Ruling: <what> — <why> — <cost if wrong>` in the ledger, keep
going. Four things stop you and only these: an irreversible or destructive
operation; a security-sensitive action; a side effect outside this worktree (a
merge, a push to a shared branch, a publish, a released package); a plan so broken
that every path forward is a guess.

## Final gate

1. **Full build, lint and tests** — the one time the whole solution runs. Use
   the repo's full command from `CLAUDE.md` or the CI config (`make check`,
   `npm run lint && npm test`, a build script), frontend included if it was
   touched. Formatting failures → run the repo's formatter on the changed paths
   only; a repo-wide pass can rewrite every file.
2. **Whole-branch review** on `opus`:
   `scripts/review-package.sh PLAN_FILE $(git merge-base main HEAD) HEAD`, then
   the repo's review-team command against that package, or the task-gate
   reviewers if it has none. Point it at the ledger's deferred and parked lines
   so it can triage what must be fixed before merge.
3. **One** fix dispatch with the complete findings list — never one fixer per
   finding; each rebuilds context and re-runs the suite. There is no second wave;
   residuals surface to the user.
4. **Feature flags** — if the repo gates new behaviour behind flags and this
   change needs one, follow its flag process from `CLAUDE.md` before the PR.
5. **Report the rulings.** Collect every ledger line containing `Ruling:` into your
   final message, in order, each with what it costs if wrong. This is the only
   place decisions you took on the user's behalf reach them.
6. Delete the workspace (`rm -rf <workspace>`) — git history is the record now.
   Then hand back the branch name and commit range. Pushing and opening the PR
   are the user's call.

## Common rationalizations

| Excuse | Reality |
|---|---|
| "I'll fix this finding myself, dispatching is overhead" | Controller fixes skip review and burn the context you need to coordinate. |
| "One more fix round will converge" | One round is the budget. A second failure is structural — adjudicate and route. |
| "Skip the review, the diff is tiny" | Tiny diffs are where the unreviewed regression lands. The gate is cheap: three sonnet agents, in parallel. |
| "The ledger is bookkeeping overhead" | It is what survives compaction. Controllers without one have re-run entire completed task sequences. |
| "Debug builds are faster for the inner loop" | Debug skips analyzers. A Debug-green task fails the final gate and you debug it twice. |
| "I'll ask the user which way to go" | Rule on it, ledger the cost, keep moving. Only the four named stops are stops. |
| "No TDD means no tests" | It means no test-first ceremony. The testing reviewer still gates coverage on every task. |
