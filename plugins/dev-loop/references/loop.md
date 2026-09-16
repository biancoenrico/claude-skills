# The dev-loop development loop

This file is the only place where the loop is described in full. Skills name the step
before them and the step after them; the whole picture lives here.

## The session map extract

Everything between the two markers below is what `hooks/session-map.sh` prints at session
start and after a compaction. It carries the classification rule, one line per path, and one
line of precedence — nothing else, so that it stays small enough to be repeated for free.

**The extract has a size budget**, and it is not advisory: read it by name — the session map
budget — from `${CLAUDE_PLUGIN_ROOT}/references/limits.md`. `tests/session-map_test.sh`
measures the shipped map and turns red as soon as it goes over, so anything added between the
markers below has to buy its room from something already there.

<!-- session-map:start -->
**Classify the work first** and name the path; in doubt, go heavier.

- **spike**: a feasibility question, throwaway code;
- **surgical**: mirrors a pattern beside it, one area, no new decision, no shared interface, no
  money, security, data or concurrency path;
- **bounded**: a contained change to an existing flow, refactors included;
- **architectural**: the rest: new projects, subsystems, shared interfaces.

A superpowers "bounded" is checked against surgical first. Surgical that breaks a criterion is
classified again, never surgical.

**Architectural:** spec → `/dev-loop:spec-revision` → `/dev-loop:plan-batching` →
`/dev-loop:plan-drafting` → `/dev-loop:plan-revision` → `/dev-loop:plan-execution` →
`/dev-loop:design-revision` → close the branch.
**Bounded:** note the base, implement, commit → tests (`/dev-loop:test-writing`, or inline for a
small diff) → `/dev-loop:code-revision`, both on `base..HEAD`. Prose only: one
`dev-loop:reviewer` on `code-revision/prose.md`.
**Surgical:** main thread, no agents or skills: implement, run the area's tests, one test for a
new logic branch, commit.
**Spike:** no loop at all.

Superpowers' own steps yield to these.
<!-- session-map:end -->

## The four paths, in full

### Classification

Classification happens before anything else, and the choice is stated. With superpowers
installed, brainstorming runs first, but it knows only three paths: a change it calls bounded is
checked against the surgical criteria before the bounded path starts. Its spike and architectural
results stand as they are. Without superpowers, the
model classifies with the four lines of the session map above.

A piece of work that sits between two paths goes to the heavier one: the cost of a spec nobody
needed is an afternoon, the cost of a subsystem built without one is the branch. The surgical
criteria are yes-or-no questions, so this rule rarely applies to them: a change is surgical when
every one of them holds. As soon as one does not, the change is not surgical, and it is classified
again between bounded and architectural by the usual rule: a shared interface, for one, is
architectural.

### Architectural path

For new projects, subsystems, and interfaces other code will depend on.

1. Brainstorming, if superpowers is installed.
2. Write the spec, then `/dev-loop:spec-revision` until it comes out approved — no open
   questions left.
3. `/dev-loop:plan-batching` decides the shape of the plan: the batch boundaries, the folder,
   and the index that holds the shared vocabulary. Below the batching threshold it says so and
   writes a single-file plan instead.
4. `/dev-loop:plan-drafting` fills the batch files that plan-batching left empty, one drafter
   per batch.
5. `/dev-loop:plan-revision` reviews the batches and the seams between them.
6. `/dev-loop:plan-execution` runs the plan one batch at a time, without asking permission to
   move to the next one. Inside a batch: an executor does the work of the batch and commits the
   production code, `/dev-loop:test-writing` writes and repairs the tests, `/dev-loop:code-revision`
   reviews that batch, and then the closing criteria from the index are checked one by one. What
   can run in parallel inside a batch does; batches themselves stay in sequence.
7. `/dev-loop:design-revision` once, after the last batch and before closing: the shape of a
   branch emerges *between* the batches, not inside one.
8. Close the branch — with the `git-flow` plugin if it is installed. The merge is the user's
   call, always.

Between one batch and the next, a summary of a few lines goes to the user: it exists so they can
stop the work, not so that execution waits for an answer.

### Bounded path

For a contained change to a flow that already exists.

1. The main thread notes the base commit before the first commit of the work, then implements
   and commits.
2. The tests, on `base..HEAD`. **Below the small batch threshold** in
   `${CLAUDE_PLUGIN_ROOT}/references/limits.md`, the main thread writes them itself: it reads
   `${CLAUDE_PLUGIN_ROOT}/skills/test-writing/SKILL.md` and follows it inline, every step
   included, the list before the code and every test seen red. A fork would rebuild the context
   this thread already holds. At or above the threshold, invoke `/dev-loop:test-writing` with
   `base..HEAD` and the calibration from the worklog when there is one.
3. `/dev-loop:code-revision` on `base..HEAD`.

**When the diff is prose only** — markdown, instructions, descriptive text in manifests — steps 2
and 3 have nothing to hold on to: no test can go red and there is no code to review. Launch one
`dev-loop:reviewer` on `base..HEAD` instead, with
`${CLAUDE_PLUGIN_ROOT}/skills/code-revision/prose.md` as its criteria, and apply what it returns
in the main thread. A diff that also touches code, or configuration a program executes (a hook
command, a script path, a build setting), takes the full path. A reviewer that returns a question
stops the run like a fork does: its question and what it had checked go into the worklog as a
partial line.

No spec, no plan, no batch files, no executor. The main thread owns the production changes that
turn out to be needed along the way, and keeps the base, the progress lines, and the state of a
stopped fork in the branch worklog described below.

### Surgical path

For a change that repeats something the repository already does a few lines away: a filter next
to an existing filter, a column next to its siblings, a field the form already handles the same
way. Every criterion has to hold:

- it **mirrors a pattern already beside it**, rather than choosing how to do something new;
- it stays in **one area** of the code;
- it takes **no decision** the user has not already made;
- it changes **no interface** other code depends on;
- it touches **no money, security, data-loss or concurrency path**.

A refactor is never surgical, however small, because choosing a new shape for the code is a
decision.

1. The main thread implements the change. No fork, no agent, no worklog, and no dev-loop skill:
   `/dev-loop:test-writing` and `/dev-loop:code-revision` are not invoked, even though writing a
   test would otherwise trigger the first.
2. It runs the tests that already cover the area. When no test covers it, there is nothing to
   run, and that alone does not move the work up a path.
3. When the change adds a branch of logic (a condition, a case, a computation) it writes **one**
   test for it, and runs it once with that branch removed to see it fail before restoring it. A
   change that only adds wiring or data needs no test.
4. It commits.

A prose-only surgical change skips steps 2 and 3 and gets no reviewer.

**The path only goes up.** When a criterion stops holding along the way (a decision appears, the
diff reaches a second area, a shared interface has to move) the work says so and continues on the
path it is classified into again, taking the commit before the change as its base. It never
steps back down.

### Spike

A feasibility question runs no loop. The answer is a direction; the code that came out of it is
throwaway and is treated as such.

## When superpowers would suggest a different step

Both plugins can be installed at once, and superpowers will suggest its own step at the same
moments. Where the two overlap, dev-loop wins:

| where superpowers would say | dev-loop uses |
|---|---|
| after brainstorming (architectural): writing-plans | `/dev-loop:spec-revision`, then the rest of the loop |
| after brainstorming (bounded): "implement via the normal workflow" | the surgical criteria, then the surgical or bounded path |
| writing-plans | `/dev-loop:plan-batching` + `/dev-loop:plan-drafting` |
| executing-plans, subagent-driven-development | `/dev-loop:plan-execution` |
| test-driven-development | `/dev-loop:test-writing`; on the surgical path, its single test |
| requesting-code-review | `/dev-loop:code-revision` |
| finishing-a-development-branch | `/dev-loop:design-revision`, then closing the branch |

Nothing in superpowers is modified, and nothing in dev-loop requires it: where superpowers is
absent, the classification rule above is what replaces brainstorming.

## The branch worklog of the bounded path

The bounded path has no plan folder and no batch files, so what would live in a
batch file needs a home of its own. That home is the branch worklog.

**One per branch, in `.dev-loop/` at the repository root.** The file is named after the branch,
with every `/` replaced by a single `-`, plus the `.md` extension: work on `feature/rate-limit`
writes `.dev-loop/feature-rate-limit.md`, work on `hotfix/token-expiry` writes
`.dev-loop/hotfix-token-expiry.md`. The rule has to be stated, because branch names contain
slashes and an unflattened name would silently create nested folders — and two runs of the same
path would then write in two different places. The first line of the file repeats the branch name
exactly as git spells it, so that two branches that flatten to the same file name are visible
instead of merging quietly.

**What it holds** — the same things a batch file holds on the architectural path:

- the **base**, the SHA of `HEAD` noted before the first commit of the work, written once and
  never overwritten on resume;
- a **progress line per step** of the bounded path — the implementation and its commit, the
  test-writing pass, the code-revision pass, or the single reviewer pass of a prose-only diff — each with the SHA it ended on. A step that stopped
  halfway is marked as partial, and partial does not count as done;
- the **calibration** of the test suite, written once per branch from the first test-writing
  report or inline pass, and handed to every later test-writing invocation;
- the **state of a fork that stopped**: when test-writing or code-revision returns with a
  question, its `state` field is written here before the question goes to the user, and it is
  passed back in the arguments when the skill is re-invoked.

**Who writes it:** only the main thread, exactly as for a batch file. Forks never touch it —
they return their state, and the main thread is the one that puts it on disk.

**How long it lives:** as long as the branch. Whether it gets committed is the project's call,
the same way it is for the review ledger; when it is not committed, the project ignores
`.dev-loop/`.

**Resuming after a closed session:** re-read the worklog together with `git log` and
`git status`, and restart from the first step that has no valid line. A partial line is not a
valid line, and its step restarts from the `state` written in the file rather than from scratch.
