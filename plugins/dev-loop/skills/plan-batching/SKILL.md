---
name: plan-batching
description: Produces a plan folder with its index and the batch files, headed and empty.
when_to_use: Work too large for one pass, or a monolithic plan to cut. Triggers: "split this work", "prepare the batches".
argument-hint: <approved spec, or monolithic plan to cut>
---

# plan-batching

Decide how the work is cut **before** anyone writes it: shape first, content after. Cutting
after the fact doesn't recover this — the boundaries land on a document already drafted as one
block. An index in front of each slice, saying what it may call, makes duplication hard instead
of merely discouraged.

## What it does, and what it does not

| Does | Does not |
|---|---|
| Decide the batch boundaries | Write the tasks |
| Write the index of the plan folder | Write the code |
| Give every shared rule an owner | Review (that is `/dev-loop:plan-revision`) |
| Create the batch files, headed and empty | Replace `/dev-loop:plan-drafting` |

**It composes, it does not compete.** `/dev-loop:plan-drafting` works *inside* this shape.

## Input

1. **An approved spec.** The normal way in.
2. **A monolithic plan already written.** Cut it — second-best, since the writing already
   happened in one pass; say so. **Work resumes on the folder that comes out**: it's the plan
   from here on, the monolithic file is starting material, not a second source of truth.
3. **Nothing.** Ask for the spec rather than inventing the scope.

**Open the project too.** Assign owners against what the code already has — an existing type,
a module with a similar rule, a declared convention (`CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING`)
— or this skill invents owners that don't exist. Run these searches with `Explore`
(`model: haiku`), several at once, inside the agents-per-wave cap in
`${CLAUDE_PLUGIN_ROOT}/references/limits.md`.

## Workflow

### Step 1 — The shared vocabulary, before the boundaries

Start here, not with the batches: boundaries drawn after understanding what crosses the work
end to end, or they cut whole things in half.

Collect:

- **The types and data** more than one part of the work touches.
- **Rules with more than one reader** — a judgement, derivation or formatting used by two
  screens, flows or commands. Unowned, each one is a duplication waiting to happen.
- **The invariants between surfaces** — "these two screens cannot say different things about
  the same fact". Missing from the spec is a finding to report, not a hole to fill in silence.
- **Decisions the project already took** — conventions, existing helpers, mechanisms to reuse —
  named by name and path.

Assign **an owner** to each: which module, type or file holds it. Where it has no home yet,
say so; Step 2 places it.

### Step 2 — The boundaries

Cut the work into slices. `${CLAUDE_PLUGIN_ROOT}/references/plan-folder.md` states the two
non-negotiable cutting criteria (a batch must pass verification alone; units touching the same
file stay together), the shared-foundations rule (Step 1's homeless entries are born before
their readers), and the self-check against the cut — apply them as written there.

### Step 3 — Write the folder

`${CLAUDE_PLUGIN_ROOT}/references/plan-folder.md` holds the folder convention, the index's
three things and why, the batch-file template (headed and empty: delivers, inherits, leaves to
later batches), and how a monolithic plan's starting material carries into a batch header —
apply it as written there.

**Folder or one file** is decided by that reference's "When a plan becomes a folder" section,
not by the threshold alone. When the plan stays one file, say so and write
`<plan folder>/<name>.md` from the single-file template the same reference holds. That's a
delivery, not a refusal to act.

### Step 4 — The questions

Before asking anything, apply the filter in `${CLAUDE_PLUGIN_ROOT}/references/asking.md`:
close what reading or searching can close, citing the source; only what depends on the user's
intent becomes a question, in one block — and a number with no stated provenance is a finding
there too, not a question.

Two questions are typically this skill's, and genuinely the user's: **where a boundary falls**
when two cuts are both defensible, and **who owns a rule** when the project has no obvious
home for it.

### Step 5 — Delivery

```
## Plan shape — N batches

**Folder:** [path]

### The shared vocabulary
- [rule/type] -> owned by [where] — called by batches [N, M]
- [rule with no home] -> to be created in batch [NN, the first that uses it]

### The batches
- **01 — [name]** · delivers: [...] · closes with: [...]
- **02 — [name]** · inherits: [...] · delivers: [...]

### Open questions
- [if there are any: the shape is not decided until they are answered]

### Next
`/dev-loop:plan-drafting <folder>`
```

**With the shape decided, invoke `/dev-loop:plan-drafting` on the folder.** With questions
still open, stop and say so: the shape isn't decided until they're answered.

## Rules of behaviour

- **Do not write the tasks.** That trade belongs to `/dev-loop:plan-drafting`.
- **Folder or one file: plan-folder.md's "When a plan becomes a folder" decides.**
- **Do not invent owners.** No home yet → say so and name the batch that creates it, never
  attribute it to a module that doesn't fit — a lying index is worse than none.
- **Never loosen the verification criterion to make a batch close.** Change the cut instead.
