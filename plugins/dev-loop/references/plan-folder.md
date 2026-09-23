# Plan folder

Four things live here, each quotable on its own: finding a numbered folder's index, when a
plan becomes a folder, the batch-file template, and the single-file plan template.

The threshold above which work gets split into batches is not written here. It is one of the
plugin's declared numbers: read it by name — the batching threshold — from
`${CLAUDE_PLUGIN_ROOT}/references/limits.md`, and never copy its value into this file or into
a skill.

## Which file is the index of a numbered folder

A folder whose files are numbered — `00-`, `01-`, `02-`, … — carries its index in the `00-`
file. Read it first: it states the folder's purpose, the order of the rest, and the shared
vocabulary.

- Folders written by this plugin name it `00-index.md`.
- **Any `00-*.md` file counts as the index.**
- **If more than one `00-*.md` is present, `00-index.md` wins.** Otherwise take the first in
  alphabetical order.
- **Declare the choice in the report** whenever the winner was not the only candidate, naming
  the file read.
- If there is no `00-*.md` at all, the folder has no index. Say so instead of promoting the
  lowest-numbered file to the role: a numbered file is content, not an index.

## When a plan becomes a folder

The section above is about reading a folder. This one is about making one.

Above the batching threshold, or whenever completion cannot be verified before the very end,
the plan becomes a folder with the same name the file would have had:

```
<where-the-plan-goes>/<plan-name>/
  00-index.md
  01-<first-slice>.md
  02-<second-slice>.md
  …
```

**`00-index.md` is the piece that makes the rest work**: it holds three things and nothing
else — extra material drifts until nobody can tell which version counts:

1. **The order of the batches and their dependencies** — who cannot start before whom, and why.
2. **The shared vocabulary and its owners** — the types, rules read by more than one batch,
   invariants between surfaces, and **where each lives**. A rule with an owner here is
   *called* by later batches, not rewritten.
3. **What counts as the end of a batch** — the project's verification (tests, build, checks),
   passed by that batch **on its own**.

Two cutting criteria:

- **A batch is a batch only if it can pass the verification alone.** If it needs the next one
  to build, it is half a batch, and goes back together with its twin.
- **Units that touch the same file stay in the same batch.** Split apart, the second works on
  code it did not write or read.

**Shared foundations go in the first batch that uses them.** If two batches need the same rule,
it is created *before* both, so the second calls it instead of inventing it.

**"The first batch that uses it", not "batch 01".** A rule dropped into batch 01 just because
it is shared can sit unused for batches. Where a rule has no home yet, the index says it is
created **once** — the first batch that uses it, never the second.

**Then check the cut against itself.** If two batches need the same thing not in the first of
them, the cut is wrong, not the index — move the boundary rather than writing the rule twice.

**Applying the split is part of the work**, not a suggestion: write the files, index filled in
and batches numbered.

## The template of a batch file

A batch file opens with a header, carries the tasks in the middle, and ends with the place
execution writes. Header and closing section are fixed; only the tasks change from one batch
to the next.

```markdown
# NN — <batch name>

**Delivers:** what exists at the end of this batch that did not exist before.

**Inherits:** the vocabulary entries and artefacts it takes from earlier batches, named as the
index names them.

**Leaves to the following batches:** what this batch deliberately does not do, and which batch
picks it up.

**Starting material:** the path of the already-written plan this batch is cut from, and the
sections of it that belong here.

## Tasks

### NN.1 — <title>
…

## Progress

## State

## Calibration
```

**The "starting material" line.** When the input was a monolithic plan sent back to be cut into
batches, it carries that plan's path and the sections belonging to this batch — written by the
skill that cuts the folder.

**When the plan starts from scratch there is no such input, and the line stays empty.** Keep
the line with nothing after it rather than deleting it: an empty line says the input was a
spec, a missing line says nobody looked. Whoever drafts the tasks reads the empty line and
works from the spec and the index, without going to look for a source document that does not
exist.

**`## Progress` is the place execution writes its steps**; `## State` and `## Calibration` are
the only other two. One line per step of
the batch procedure — the executor's work, then the tests, then the code review, then the check
of the closing criteria, then the wrap-up — appended in order and never rewritten. The content
of those lines — which
steps leave one, what each says, what makes a line count as done and what cancels it — belongs
to the batch procedure, not to this template; the template owns the place, so that every batch
file has it in the same spot and no run has to invent one.

**`## State` is the place a stopped forked skill leaves what it needs in order to restart.**
When a forked skill returns `status: question`, the main thread writes its `state` here, under
a sub-heading naming the producing skill, until that skill is invoked again and finishes. More
than one may sit there at once. It stays in the file, not the conversation, because the asking
session may not be the one that answers.

**`## Calibration` holds the test calibration** from the plan's first test-writing report,
copied into the batch file that received it, passed to every later test-writing run.

**Only the main thread writes into a batch file.** Executors, reviewers and forked skills
return their work rather than edit the folder.

## The template of a plan that stays one file

Below the batching threshold there is no folder: the plan is one file,
`<plan folder>/<name>.md`, at once the plan and its only batch file — whatever writes into a
batch file writes into this one.

```markdown
# <plan name>

**Closing criteria:** what has to be true for this plan to be done — one line per criterion.

**Verification command:** the command that proves it, exactly as it is typed.

**Starting material:** the path of an already-written plan this one is drawn from, and its
sections. Empty when the plan starts from a spec.

## Tasks

### 1 — <title>
…

## Progress

## State

## Calibration
```

The header carries the closing criteria and verification command because there is no
index — in a folder they belong to `00-index.md`; here the file is its own index. Tasks are
written empty, filled in afterwards, as in a folder.

**`## Progress`, `## State` and `## Calibration` mean here what they mean in a batch file**, for
the same reason: the single file is treated as one batch.
