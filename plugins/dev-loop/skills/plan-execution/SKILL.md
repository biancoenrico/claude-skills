---
name: plan-execution
description: Executes a plan that is already cut into batches, one batch at a time, without asking permission at every step. It reads the shape and the closing criteria from the plan's index rather than carrying its own, works out on its own which batch is next, and records in the batch file how it went.
when_to_use: A plan folder with open batches, or one batch file to run. Triggers — "pick the plan back up", "carry on with the batches", "go ahead on your own", "execute the plan in docs/...", or a batch folder handed over to be run.
argument-hint: <plan folder, or a single batch file>
effort: high
---

# plan-execution

Run a folder of batches to the end, stopping **only** where a decision is needed that is not
yours.

The failure this skill exists to prevent is not the technical error: it is **the loop fraying**.
A batch closes, someone asks "shall I go on?", work restarts with half the context, the review
is skipped as "small", and three batches later the closing criteria have
become a memory. Every skipped step costs little alone; the bill arrives all at once.

**It is thin by choice.** No criteria, checks or definition of "done" of its own: those live
**in the plan's index**, the only place they stay true; a copy here would drift at the first edit.

It calls `dev-loop:executor` for the work, `/dev-loop:test-writing` for the tests and
`/dev-loop:code-revision` for the review, each at its own point in the batch procedure.

## Input

In order of priority:

1. **An explicit folder**, or a single batch file when only that one is to be run.
2. **The plan already under discussion** in this conversation.
3. **A single plan folder** with open batches under the usual paths (`docs/plans/`, `plans/`).

With more than one candidate and none named, **ask which**: here guessing costs more.

## Step 1 — Read the index, and take four things from it

Find the index by the rule held in `${CLAUDE_PLUGIN_ROOT}/references/plan-folder.md`, which
also holds the template of a batch file. Extract, and **state in a few lines** before touching
anything:

1. **The order and the dependencies** of the batches — which cannot start before which, and why.
2. **The closing criteria**, word for word. Cite them, do not summarise: at the gate you walk
   them one by one and each wants its own proof. Criteria a batch adds of its own hold in
   addition.
3. **The shared vocabulary and its owners** — who creates what. It is the rule that stops two
   batches writing the same piece: if you are about to create something the index assigns to
   another batch, **it is not your work**, and the right place to say so is that batch's file.
4. **The verification command** and how it is run, filter included. Without it nothing closes.

Read the project's own instructions too (`CLAUDE.md`/`AGENTS.md`, nested ones included): syntax
constraints, language, commit conventions, files not to touch. They win over any habit.

If the plan has never been through `/dev-loop:plan-revision`, say so in one line and offer to do
that first — executing an unreviewed plan is the most expensive way to find its holes.

### When the plan is a single file

A plan that stayed one file has no index. **Treat it as a single batch**, and read it like this:

- **From the file's header** come the two things the single-file template carries: the closing
  criteria and the verification command. Those are the two the gate at step 5 demands, so the
  batch closes just the same.
- **Declare the other two absent, in one line of the report**: order and dependencies (there are
  none, there is one batch) and shared vocabulary with its owners (nobody: there is no second
  batch that could duplicate anything). Declaring them absent is not a fallback, it is what the
  batching threshold implies; what you do not do is deduce them or invent them.
- **If the closing criteria or the verification command are missing too**, the file was not
  written from the template: stop, and the question goes to the user rather than executing with
  no gate.
- **The progress lines** go in the place the single-file template reserves, exactly as in a
  batch file. The single file is both the plan and its only batch file: create no other, and
  touch nothing else in the folder.

## Step 2 — Work out where you are, without asking

The next batch is **read**, not asked about:

- the progress lines in each batch file say which steps are done and which are not;
- the index says which batches are cancelled or brought forward;
- `git log` confirms it, and `git status` shows what was left uncommitted.

State in one line: **which batch you are opening, and which dependencies are satisfied.** Where a
wrap-up and `git log` contradict each other, **`git log` wins**, and the contradiction is noted.

**Before opening a new batch, pay the previous one's debt.** If the batch before closed without
one of its criteria — typically the review — that comes first. A finding on code that three
batches have since rewritten over is no longer the same finding. A `code-revision deferred` line
is debt only once no open batch is left to pay it.

## The batch procedure

Two rules hold across all six steps:

- **the only writer of the batch files is the main thread.** Executors, forked skills and any
  agent they launch return their work; they do not edit the plan folder;
- **no agent stages the plan folder**, not even the batch file being executed.

Every step leaves a progress line in the batch file, in the place the template held in
`${CLAUDE_PLUGIN_ROOT}/references/plan-folder.md` reserves for it: that file owns **the place**,
this one owns the list.

**The markers are fixed, and they are in English**, even when the plan is written in another
language:

```
base @<sha>
executor @<sha>
executor (partial) @<sha>
test-writing @<sha>
test-writing skipped: no targets
test-writing (partial) @<sha>
code-revision @<sha>
code-revision (partial) @<sha>
code-revision deferred @<sha>
code-revision in NN @<sha>
criteria ok @<sha>
report @<sha>
back to test-writing @<sha>
restart from test-writing @<sha>
```

**A machine reads those lines** to work out what a resume redoes, so they are names, not prose.
The rest of the batch file — wrap-up, notes — stays in the language of the project's documents.

**`@<sha>` is on all of them**: without it a line does not say which code it passed on, and
picked up later, with other commits on top, it is unreadable.

### 1. Base

Write the base of the batch — the sha of `HEAD` — **once only**. On a resume it is never
overwritten. Line `base @<sha>`.

**If the base no longer resolves on a resume** — `git cat-file -e <sha>^{commit}` fails, or the
sha is no longer an ancestor of `HEAD`: a rebase, a reset, an amend on the branch — then the
`base..HEAD` range that three of the steps depend on is lost. Do **not** rewrite the line and do
**not** guess a new base: look for the equivalent commit in the `reflog`, and put the question
to the user in the shape held by `${CLAUDE_PLUGIN_ROOT}/references/asking.md`. If the user
approves a new base, **add** a line `base @<new sha> (supersedes <old sha>)` and restart steps
3-5 on that range; the original line stays where it is, as a trace.

### 2. Executor

Launch `dev-loop:executor` with the index, the batch file, the verification command and the
base.

- Returns `done` → line `executor @<sha>`, then the notes for other batches, each written into
  the file where its remedy belongs.
- Returns `question` → line `executor (partial) @<sha>`, with the state and the questions in the
  batch file. **The steps do not advance** until the answer arrives and the executor has been
  resumed. A new executor is given the base, and knows the commits in `base..HEAD` are the
  batch's.

Inside a batch, independent work is launched in the same request rather than one piece after
another, and the test is single: **two pieces of work are parallel only when neither reads what
the other writes.** These always stay in sequence: the batches themselves, mutations, commits,
and anything that goes through the same database or the same container.

Here the work is the executor's, and it may launch agents of its own. Those agents **never
stage and never commit**, and their questions do not stop with them: they travel up through the
executor as part of its own `status: question`.

### 3. Tests

The targets are the batch's test tasks **plus** the executor's `test_targets` — the existing
tests a deliberate change has broken.

With targets: invoke `/dev-loop:test-writing` with the targets, `base..HEAD`, **the path of
the batch file**, and the calibration when a batch file of the plan already has one; then write
the line `test-writing @<sha>`. When no batch file has one yet, copy the `Calibration` section of
this report into the current batch file under `## Calibration`. The first three always matter: a
forked skill does not see the conversation, so everything it needs travels as arguments. The
path is not a nicety — the authorisation to delete a test lives in the batch file, and without
it test-writing can only come back `status: question`, burning a round on every batch.

Without targets the step is **skipped**: line `test-writing skipped: no targets`.

Returns `question` → line `test-writing (partial) @<sha>`, with its `state` written into the
batch file; the step closes only after the skill has been invoked again with that state.

### 4. Review

**Now or deferred** is decided by `${CLAUDE_PLUGIN_ROOT}/references/deferred-review.md`, which
also holds the scope and the line order of the last batch, who pays the deferrals. A leaf writes
`code-revision deferred @<sha>` and goes on to step 5.

Otherwise invoke `/dev-loop:code-revision` on the scope that file gives **with the batch file's
path** — without it comment-writing misses the index and runs degraded — then line
`code-revision @<sha>`. A `question` gives `code-revision (partial) @<sha>`, with the state in
the file.

### 5. Criteria

Walk the index's closing criteria **one at a time**, each with its own command and its own
outcome, on code already reviewed or whose review is deferred; the last batch adds the batches it
paid, as `deferred-review.md` says. Line `criteria ok @<sha>`, or the list of the reds.

- A red that depends on production goes through the unplanned-change re-entry below.
- A red that depends on a missing or wrong test **goes back to step 3** — and the return leaves
  its trace: line `back to test-writing @<sha>`, which cancels the step 3, 4 and 5 lines that
  precede it; without it a resumed run would restart at step 5, still red.
- `back to test-writing` **does not count as a re-entry**: it does not touch production, and
  only `restart from test-writing` lines enter the count.

### 6. Wrap-up

In the batch file: what was done and with which commits, where the plan did not get it right,
and what is left open. Where the plan folder is tracked by git, the main thread commits the
wrap-up. Line `report @<sha>`. Then a few lines of summary, and **the next batch opens without
asking**. The summary ends with one line suggesting `/compact` or a fresh session
before the next batch: every turn re-reads the whole context, and the batch files already hold
everything a resume needs.

## The unplanned-change re-entry

Production changes the batch did not foresee are made by the executor — never by the main
thread, never by test-writing. There are two triggers, and **they reach the user differently**:

- **test-writing asks for a production change** → this is a stop. The forked skill returns
  `status: question`, and the executor restarts only if the user approves.
- **a criterion at step 5 is red because of production** → **this is not a stop.** The criterion
  is in the index, the remedy is inside the batch's perimeter, and stopping would mean asking
  permission to do work the plan has already assigned. The executor restarts on its own. The
  usual exception holds: if the remedy changes a visible behaviour the batch did not foresee, it
  falls back into stop 4 and the question goes to the user.

In both cases the main thread resumes the executor — or launches a new one with the base and the
state — and the executor commits. Then write the line `restart from test-writing @<sha>`,
**which cancels the step 3-5 lines that precede it**, and the batch restarts from step 3.

**The targets of step 3 after a re-entry** are the union of the batch's test tasks and the
`test_targets` of the **latest** executor return — not the sum of every return, and not the
latest `test_targets` alone: the batch's own list stays valid every time round.

### What cancels what, word for word

Two rules, without which the re-entry cap can fail to fire at all:

1. a cancelling marker — `restart from test-writing`, `back to test-writing` — holds **only for
   the lines that precede it** in the file; the lines written after it belong to the new round
   and stay valid;
2. **a re-entry line does not cancel other re-entry lines.** The `restart from test-writing`
   lines accumulate, and that is what makes them countable.

**How many re-entries a batch may have** is the unplanned-change re-entry cap, held in
`${CLAUDE_PLUGIN_ROOT}/references/limits.md`. The count is how many `restart from test-writing`
lines the file contains — not from memory, and not net of cancellations. Past the cap the batch
stops and the question goes to the user.

## Autonomy, and its limits

The point of this skill is not asking. So it has to be said exactly what is not asked and what
is, or autonomy becomes a matter of mood.

**Decide on your own, always:** the order within the tasks, the names, the structure of the
files, how to turn a red green, when to commit and with what message, whether a finding is
fixed here or noted elsewhere, and **whether to open the next batch**.

**Stop only here:**

1. **A decision the plan assigns to the user** — merging branches, a realignment, a choice the
   index marks as theirs.
2. **A closing criterion you cannot satisfy** without something you do not have: an access, a
   datum, an environment.
3. **The plan says one thing and the code says another**, and the two readings lead to different
   work. Do not settle it quietly one way or the other.
4. **A production change the batch did not foresee that alters a visible behaviour.** This is
   the trigger of the unplanned-change re-entry above; it stays a stop only because the approval
   is the user's.
5. **The work is about to leave the plan** — a batch widening until it swallows another.

The shape of the question is not copied here: it is held in
`${CLAUDE_PLUGIN_ROOT}/references/asking.md`, together with the filter that decides which
findings are questions at all and how a partial answer is handled.

**Before stopping, finish everything that does not depend on that answer.** A stop that also
blocks independent work costs twice. The one exception is the one that file states: inside a
batch the steps do not advance while a question is open.

## Resuming after a closed session

Read the progress lines, `git log` and `git status`, and restart from the first step with no
valid line.

- A `(partial)` line does not count as done.
- Lines cancelled by a `restart from test-writing` or a `back to test-writing` no longer count.
- A partial step restarts from the `state` written in the file.
- If there is no valid line at all, restart from step 1.

## When an agent does not come back

An agent that fails, is interrupted, or returns something unreadable is relaunched **once**,
with the error and the partial state, after looking at `git status` and the diff. On the second
failure the main thread carries on from that state and the report declares the degraded mode.
The full rule, and what counts as a malformed return, is held in
`${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`.

## Report, at every batch

```
## Batch NN — <title>

**Dependencies:** <which batches, and that they are closed>
**Tasks:** N — <one line each, with the outcome>

### Closing
| criterion (from the index) | proof | outcome |
|---|---|---|
| 1. <criterion, word for word> | <command and result> | ok / red |

### Where the plan did not get it right
- <what it said -> what it turned out to be -> why reality was right>

### Noted elsewhere
- <finding> -> `NN-<name>.md`, because the remedy belongs there
```

## Rules of behaviour

- **Do not rewrite the criteria.** They are cited from the index. Noticing that a criterion is
  wrong is a stop of type 3, not a rewrite.
- **Do not declare anything closed without proof.** Every criterion wants its command and its
  outcome.
- **Do not widen a batch.** The finding is written where the remedy is.
- **Do not skip the review, and defer only a leaf's.** Under a batch others build on, a bug
  becomes their base.
- **The tests are written by `/dev-loop:test-writing`, production by the executor.** Neither job
  moves to the main thread because it looks small.
- **Do not ask permission to carry on.** Summarise and go. Whoever is reading can stop you; you
  do not wait for them.
- **The wrap-up also says where the plan was wrong.** A batch file that always turns out to have
  guessed right was not executed, it was transcribed.
