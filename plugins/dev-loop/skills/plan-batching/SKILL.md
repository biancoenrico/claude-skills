---
name: plan-batching
description: Decides the shape of an implementation plan before anyone writes it — where the batch boundaries fall, what the batches share, and who owns each shared rule. Produces a plan folder with its index and the batch files, headed and empty. It does not write the tasks, and it reviews nothing.
when_to_use: Work too large for a single pass; an approved spec handed over to become a plan; a monolithic plan that has to be cut. Triggers — "how do I split this work", "prepare the batches", "let's break this plan up", "this plan is too big for one pass".
argument-hint: <path to the approved spec, or to a monolithic plan to cut>
effort: xhigh
---

# plan-batching

Decide how the work is cut **before** anyone starts writing it.

A plan is executed in sequence, and the longer the sequence, the more whoever walks it loses
sight of their own earlier work: by task 12 the decisions of task 3 are no longer in working
memory, only a summary of them is. That is where the duplications come from that nobody
recognises as such — not laziness, but **ignorance of one's own work from two hours ago**.
Splitting the plan *after* it has been written does not repair this: the boundaries end up
drawn over a document already conceived as one block, and the writing happened in a single
pass anyway.

This skill reverses the order: **shape first, content after.** When each slice is written with
an index in front of it saying what it may *call*, duplication becomes hard rather than merely
discouraged.

## What it does, and what it does not

| Does | Does not |
|---|---|
| Decide the batch boundaries | Write the tasks |
| Write the index of the plan folder | Write the code |
| Give every shared rule an owner | Review (that is `/dev-loop:plan-revision`) |
| Create the batch files, headed and empty | Replace `/dev-loop:plan-drafting` |

**It composes, it does not compete.** `/dev-loop:plan-drafting` works *inside* the shape
decided here. Below the batching threshold the plan stays a single file — this skill says so
and writes that file, rather than handing back a folder whose two files cost more than the
plan they replace.

## Input

1. **An approved spec.** The normal way in.
2. **A monolithic plan already written.** Cut what is there, knowing it is the second-best
   outcome: the writing has already happened in a single pass, and all that is recovered is the
   benefit on execution. Say so rather than letting it be believed. **The work then resumes on
   the folder that comes out** — that folder is the plan from this point on, and the monolithic
   file is starting material, not a second source of truth.
3. **Nothing.** Ask for the spec rather than inventing the scope.

**Open the project too.** Owners of shared rules are assigned knowing what the code already
has: a type that exists, a module that already owns a similar rule, a declared convention
(`CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING`). Without that, this skill invents owners, and that
is the worst defect it can produce — an index that sends the batches to call something that
does not exist. Run those searches with `Explore` (`model: haiku`), several at once inside the
agents-per-wave cap held in `${CLAUDE_PLUGIN_ROOT}/references/limits.md`.

## Workflow

### Step 1 — The shared vocabulary, before the boundaries

**Start here, not with the batches.** The boundaries are drawn *after* understanding what
crosses the work from end to end; otherwise they cut in half the things that had to stay whole.

Walk the spec and collect:

- **The types and the data** that more than one part of the work touches.
- **The rules with more than one reader** — a judgement, a derivation, a formatting that two
  screens, two flows or two commands will use. *Every entry on this list is a duplication about
  to be born*, if nobody owns it.
- **The invariants between surfaces** — "these two screens cannot say different things about
  the same fact". The spec should have declared them; where it has not, that is a finding to
  report, not a hole to fill in silence.
- **The decisions the project has already taken** and that hold here: conventions, existing
  helpers, mechanisms to reuse. Name them by name and by path.

For each one, assign **an owner**: which module, type or file holds it, and who asks it for it.
Where it has no home yet, write that it is to be created **once**, and in which batch — the
first one that uses it, never the second.

### Step 2 — The boundaries

Cut the work into slices. Three criteria, and the first two are not negotiable:

1. **A batch has to pass the project's verification on its own** — tests, build, checks,
   whatever the project uses. If it needs the next one in order to build, it is not a batch: it
   is half a batch, and it goes back together with its twin. A slice that does not close is not
   a slice, it is a pause.
2. **Units that touch the same file stay together.** Split apart, the second one works on code
   it did not write and has not read.
3. **Shared foundations go in the first batch.** Everything Step 1 listed without a home is
   born before its readers. It is the only order that makes duplication hard: whoever arrives
   later has something to call instead of something to invent.

Then check the cut against itself: if two batches need the same thing and that thing is not in
the first of them, the cut is wrong — not the index.

### Step 3 — Write the folder

The plan becomes a folder with the same name the file would have had. The folder convention,
the template of a batch file and the template of a plan that stays a single file are held in
`${CLAUDE_PLUGIN_ROOT}/references/plan-folder.md`; use them as they are written there.

**The index holds three things, and nothing else.** Every extra line is material that will
drift from the batches, and once it has, nobody can tell which of the two versions counts:

1. **The order of the batches and the dependencies between them** — who cannot start before
   whom, and why.
2. **The shared vocabulary and its owners** — the list from Step 1, with where each one lives.
   It is the part that makes all the rest work.
3. **What counts as the end of a batch** — the project's verification, passed by that batch on
   its own.

**The batch files are born headed and empty**: title, what the batch delivers, what it
inherits from the earlier ones (naming the entries of the index), what it leaves to the later
ones. This skill does not write the tasks.

**When the input was a monolithic plan, every batch file carries its starting material.** In
the header line the template reserves for it, write the path of the original plan and the
titles of its sections that belong to that batch. The header grows by one line, the tasks do
not: whoever drafts the file gets that pointer together with the spec, and does not re-derive
from the spec work that had already been written once.

**The threshold is not a number written here.** Read it by name — the batching threshold — from
`${CLAUDE_PLUGIN_ROOT}/references/limits.md`. Below it, say so and write
`<plan folder>/<name>.md` from the single-file template: closing criteria, verification command
and the tasks left empty. That is a delivery, not a refusal to act.

### Step 4 — The questions

Before asking anything, apply the filter and the shape held in
`${CLAUDE_PLUGIN_ROOT}/references/asking.md`: what closes by reading or by searching, close
yourself and cite the source; only what depends on the user's intent becomes a question, and
the questions go in one block.

**Numbers carry their provenance.** Every threshold, window or limit has to be a measurement, a
cited standard, or a choice declared as such. A number without a provenance is a finding, not a
requirement.

Two questions are typically this skill's, and they are genuinely the user's: **where a boundary
falls** when two cuts are both defensible, and **who owns a rule** when the project has no
obvious home for it.

### Step 5 — Delivery

```
## Plan shape — N batches

**Folder:** [path]

### The shared vocabulary
- [rule/type] -> owned by [where] — called by batches [N, M]
- [rule with no home] -> to be created in batch 01

### The batches
- **01 — [name]** · delivers: [...] · closes with: [...]
- **02 — [name]** · inherits: [...] · delivers: [...]

### Open questions
- [if there are any: the shape is not decided until they are answered]

### Next
`/dev-loop:plan-drafting <folder>`
```

**With the shape decided, invoke `/dev-loop:plan-drafting` on the folder.** With questions
still open, stop and say so: the report already declares that the shape is not decided until
the questions have answers, and this is that rule's consequence.

## Rules of behaviour

They exist because this skill's risk is cutting for the sake of cutting, and handing back a
folder that costs more than the plan it replaces.

- **Do not write the tasks.** This skill decides the shape. Filling it is another trade, and
  doing it here means redoing in a single pass exactly what was to be avoided.
- **Small work gets a single-file plan, not a folder.** Below the batching threshold, or when
  completion is already verifiable halfway through, say so and write the plan as one file.
- **Do not invent owners.** Where a rule has no obvious home in the project, write that it is
  to be created and in which batch — do not attribute it to a module that does not exist or has
  nothing to do with it. An index that lies is worse than an absent index: the batches follow
  it.
- **A batch that does not close is not a batch.** If the cut does not hold up under the
  verification criterion, change the cut; do not lower the criterion.
- **The index holds three things.** Every extra section is material the batches will
  contradict, and nobody will know which of the two versions counts.
