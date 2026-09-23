---
name: plan-drafting
description: Fills a plan's tasks, one drafter per batch file, writing only its file.
when_to_use: A plan folder with index, empty batches, or single-file plan. Not batching (/dev-loop:plan-batching) or review (/dev-loop:plan-revision).
argument-hint: <plan folder, or single-file plan>
effort: high
---

# plan-drafting

Write the tasks of a plan that already has a shape, without touching the shape.

Every batch file has one writer, and none of them reads what another is writing. What does not
parallelise is everything the batches share: holding the index still while the drafters work,
and being the only one who edits it once they are done.

## Input

Two distinct ways in, and the index rule applies only to the first.

**A plan folder.** Find its index by the rule held in
`${CLAUDE_PLUGIN_ROOT}/references/plan-folder.md`, which also says what to do when more than
one candidate is present and when to declare the choice. Read it before anything else: it
carries the batch order, the shared vocabulary and its owners, and what counts as the end of a
batch. **If there is no index, or the index has no shared vocabulary, say so and hand the work
to `/dev-loop:plan-batching`** rather than inventing the shape here.

**A plan that stays one file.** It has no index, by definition, **and nothing is handed back to
anyone.** In place of the index the drafter is given the spec and the file's own header, which
from the single-file template already carries the closing criteria and the verification
command. The "no index, hand it back" rule does not apply here — written the other way round it
would send a single-file plan to a skill that would only send it back, and the two would pass
it between them forever.

## Workflow

### Step 1 — Fan out

One `dev-loop:drafter` per batch file, **launched in the same request**. Beyond the
agents-per-wave cap held in `${CLAUDE_PLUGIN_ROOT}/references/limits.md`, proceed in waves. A
single-file plan is filled by one drafter.

Every drafter writes **only** in its own file. What goes in the message to each one:

- the path of the spec;
- the path of the index — or, for a single-file plan, the file's header in its place;
- the path of its own file;
- the line of the index saying what that batch delivers and what it inherits;
- the ban on writing anywhere else.

**If the file's header carries a starting-material line** — the plan was cut from a monolithic
one — the message also carries the path of that original plan and the sections of it that
belong to this batch. That is what stops the drafter rewriting from the spec tasks that already
exist.

A drafter closes in the shape held by
`${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`, which also says what to do when one fails,
is interrupted, or comes back in a shape that cannot be read.

### Step 2 — Wait for the whole fan-out

**Do nothing with any return until every drafter is back.** A drafter still in flight is
reading the index, and the index is not touched while anyone is reading it.

"Back" means **all the waves**, not the current one: with twelve batch files and a cap of six,
the index stays untouchable until the second wave has returned as well.

### Step 3 — The questions, in one block

A drafter that finds a hole in the index returns `status: question`. With the fan-out closed,
collect every question and put it through the filter held in
`${CLAUDE_PLUGIN_ROOT}/references/asking.md`: the ones that close by reading or by searching,
close yourself — with `Explore` where that is the cheapest route — and cite the source. Ask the
rest in one block, in the four-line shape that file holds.

### Step 4 — Write the answers into the index

**When an answer adds an entry to the shared vocabulary, this skill writes it into the index**,
with the fan-out closed and therefore with no readers in flight. **No drafter ever writes into
the index**, not even the one that asked for the entry.

Notes a drafter produced for other batches cannot be written by the drafter either — it writes
only in its own file. **This skill writes each note into its destination file**, at the same
moment, which is also the only moment when it is not colliding with that file's own drafter.
Each note is then summarised in the report, one line each, with the file it landed in.

### Step 5 — Resume

With the index updated, resume — under the rules held in
`${CLAUDE_PLUGIN_ROOT}/references/asking.md`:

- **the drafters that asked**, with `SendMessage`, so they keep their context; where one can no
  longer be resumed, launch a new one with the answers and the state it returned;
- **plus the drafters whose file cites the term just added.** Find that second set with a
  `grep` for the term across the batch files, not from memory.

Resume waves obey the same agents-per-wave cap.

A resume can raise new questions: return to "wait for every wave, then ask in one block, then
the index, then resume". How many times that round may repeat is the drafting round cap, held in
`${CLAUDE_PLUGIN_ROOT}/references/limits.md`. Once it is spent, declare the files that are
still incomplete as such in the report and hand the decision to the user: a half-drafted plan
that says it is half-drafted beats a plan going round in circles.

### Step 6 — Report

```
## Plan drafted — N batch files

### The files
- `01-<name>.md` — N tasks
- `02-<name>.md` — N tasks

### Added to the index
- [entry] -> owned by [where], from the answer to [question]

### Notes filed elsewhere
- [note] -> `NN-<name>.md`

### Still open
- [question with no answer, and the file it leaves incomplete]

### Next
`/dev-loop:plan-revision <folder>`
```
