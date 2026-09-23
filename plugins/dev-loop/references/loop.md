# The dev-loop development loop

This is the loop's only full description; skills name just the step before and after them.

## The session map extract

Between the markers is what `hooks/session-map.sh` prints at session start and after
compaction: the classification rule, one line per path, the closing precedence and short-output
rules — nothing else.

Its budget — the session map budget, read by name from
`${CLAUDE_PLUGIN_ROOT}/references/limits.md` — is enforced by `tests/session-map_test.sh`:
anything added buys its room from something already there.

<!-- session-map:start -->
**Classify the work first** and name the path; in doubt, go heavier.

- **spike**: a feasibility question, throwaway code, no loop;
- **surgical**: mirrors a pattern beside it, one area, no new decision, no shared interface, no
  money, security, data or concurrency path;
- **bounded**: a contained change to an existing flow, refactors included;
- **architectural**: the rest: new projects, subsystems, shared interfaces.

A superpowers "bounded" is checked against surgical first; surgical that breaks a criterion is
reclassified for good.

**Architectural:** spec → `/dev-loop:spec-revision` → `/dev-loop:plan-batching` →
`/dev-loop:plan-drafting` → `/dev-loop:plan-revision` → `/dev-loop:plan-execution` →
`/dev-loop:design-revision` → close the branch.
**Bounded:** note the base, implement, commit → tests (`/dev-loop:test-writing`; inline if the diff is
small) → `/dev-loop:code-revision`, both on `base..HEAD`. Prose only: a
`dev-loop:reviewer` on `code-revision/prose.md`.
**Surgical:** main thread, no agents or skills: implement, run area tests, one test per
new logic branch, commit.

Superpowers' steps yield to these. Keep output short: test tails, `diff --stat`.
<!-- session-map:end -->

## The four paths, in full

### Classification

State the classification first. With superpowers, brainstorming classifies — a bounded result is
then checked against the surgical criteria, spike and architectural stand as returned — without
it, classify using the session map above. Work between two paths goes to the heavier one; the
surgical criteria are yes-or-no, so one failing reclassifies between bounded and architectural —
a shared interface, for one, is architectural.

### Architectural path

1. Brainstorming, if superpowers is installed.
2. Spec, then `/dev-loop:spec-revision` until approved — no open questions left.
3. `/dev-loop:plan-batching` sets the batch boundaries, folder, and shared-vocabulary index;
   below the batching threshold it writes a single-file plan instead.
4. `/dev-loop:plan-drafting` fills the empty batch files, one drafter per batch.
5. `/dev-loop:plan-revision` reviews the batches and their seams.
6. `/dev-loop:plan-execution` runs the plan batch by batch, asking no permission between them.
   Inside a batch: an executor implements and commits production code, `/dev-loop:test-writing`
   writes and repairs tests, `/dev-loop:code-revision` reviews or defers it
   (`references/deferred-review.md`), then the index's closing criteria are checked. Parallel
   work inside a batch runs parallel; batches stay sequential.
7. `/dev-loop:design-revision` once, after the last batch and before closing — a branch's shape
   emerges *between* batches, not inside one.
8. Close the branch (`git-flow` if installed); the merge is always the user's call.

Between batches, send the user a short summary; execution does not wait for a reply.

### Bounded path

1. The main thread notes the base commit before the first commit, implements, and commits.
2. The tests. Run `scripts/devloop-diffsize base..HEAD` — a path relative to
   the plugin root this file was read from, resolved to absolute first, since this file bypasses
   the skill loader and `${CLAUDE_PLUGIN_ROOT}` would reach the shell unexpanded — without
   `--with-tests`, and compare its output to the small batch threshold in
   `${CLAUDE_PLUGIN_ROOT}/references/limits.md`. Below it, read
   `${CLAUDE_PLUGIN_ROOT}/skills/test-writing/SKILL.md` and follow it inline: every step, list
   before code, tests seen red. At or above it, invoke `/dev-loop:test-writing` with `base..HEAD`
   and the worklog's calibration.
3. `/dev-loop:code-revision` on `base..HEAD`.

**Prose-only diffs** — markdown, instructions, descriptive manifest text — leave nothing for
steps 2–3: no test to fail, no code to review. Launch one `dev-loop:reviewer` on `base..HEAD`,
with `${CLAUDE_PLUGIN_ROOT}/skills/code-revision/prose.md` as criteria, and apply what it
returns. A diff that also touches code or executable configuration (e.g. a hook command) takes
the full path. A reviewer returning a question stops the run like a fork: its question and
checks go into the worklog as a partial line.

No spec, no plan, no batch files, no executor: the main thread owns any production change along
the way — see the branch worklog below.

### Surgical path

For a change that repeats something nearby in the repository: a filter next to an existing
filter. Every criterion has to hold:

- **mirrors a pattern already beside it**, not a new choice;
- stays in **one area** of the code;
- takes **no decision** the user has not already made;
- changes **no interface** other code depends on;
- touches **no money, security, data-loss or concurrency path**.

A refactor is never surgical: a new shape is itself a decision.

1. The main thread implements: no fork, agent, worklog, or dev-loop skill —
   `/dev-loop:test-writing` and `/dev-loop:code-revision` stay uninvoked even though the test
   below would trigger the first.
2. It runs the tests that already cover the area; none covering it does not move the work up a
   path.
3. A change adding a branch of logic (a condition, a case, a computation) gets **one** test, seen
   failing with it removed before restoring it. Wiring or data alone needs none.
4. It commits.

A prose-only surgical change skips steps 2–3, with no reviewer.

**The path only goes up.** When a criterion stops holding (a decision appears, a second area, a
shared interface moves) the work says so and reclassifies, continuing from the commit before the
change — never back down.

### Spike

A feasibility question runs no loop; its code is thrown away.

## Short output in the main thread

Show a test run's tail, not all of it; `git diff --stat`, not a whole diff; skip printing a file
an agent is about to read.

## When superpowers would suggest a different step

Both plugins can run together; where a step overlaps, dev-loop wins:

| where superpowers would say | dev-loop uses |
|---|---|
| after brainstorming (architectural): writing-plans | `/dev-loop:spec-revision`, then the loop |
| after brainstorming (bounded): implement normally | the surgical criteria, then surgical or bounded |
| writing-plans | `/dev-loop:plan-batching` + `/dev-loop:plan-drafting` |
| executing-plans, subagent-driven-development | `/dev-loop:plan-execution` |
| test-driven-development | `/dev-loop:test-writing`; on surgical, its single test |
| requesting-code-review | `/dev-loop:code-revision` |
| finishing-a-development-branch | `/dev-loop:design-revision`, then closing the branch |

Nothing in superpowers is modified; dev-loop does not require it.

## The branch worklog of the bounded path

The bounded path has no plan folder or batch files; what one would hold lives in the worklog
instead.

**One per branch, in `.dev-loop/` at the repository root**, named after the branch with every
`/` replaced by `-`, plus `.md`: `feature/rate-limit` writes `.dev-loop/feature-rate-limit.md`.
Its first line repeats the branch name as git spells it.

**What it holds**, as on the architectural path — written only by the main thread; forks return
their state instead of touching the file:

- the **base**, `HEAD`'s SHA noted before the first commit, written once and never overwritten
  on resume;
- a **progress line per step** — implementation and commit, test-writing, code-revision, or a
  prose-only diff's single reviewer pass — each with the SHA it ended on. A step stopped halfway
  is marked partial, not done;
- the **calibration** of the test suite, written once per branch from the first test-writing
  report or inline pass, reused by every later invocation;
- the **state of a fork that stopped**: test-writing or code-revision write their `state` here
  before the question reaches the user, and read it back on re-invocation.

**How long it lives:** as long as the branch; committing it is the project's call
(`references/ledger.md`'s rule for the review ledger), and leaving it uncommitted does the same
for `.dev-loop/`.

**Resuming:** re-read it with `git log`/`git status` and restart from the first step with no
valid line — a partial line restarts from its `state`, not from scratch.
