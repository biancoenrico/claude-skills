# Plan folder

Four things live here, and each one is quotable on its own: how to find the index of a
numbered folder, how a plan that is too big for one pass becomes a folder, the template of a
batch file, and the template of a plan that stays a single file.

The threshold above which work gets split into batches is not written here. It is one of the
plugin's declared numbers: read it by name — the batching threshold — from
`${CLAUDE_PLUGIN_ROOT}/references/limits.md`, and never copy its value into this file or into
a skill.

## Which file is the index of a numbered folder

A folder whose files are numbered — `00-`, `01-`, `02-`, … — carries its index in the `00-`
file. Read that one first: it says what the folder is, what order the rest is in, and which
vocabulary the numbered files share.

- Folders written by this plugin name it `00-index.md`.
- **Any `00-*.md` file counts as the index.** Folders written before this plugin exists use
  other names for it, in other languages, and they stay readable because of this rule.
- **If more than one `00-*.md` is present, `00-index.md` wins.** Otherwise take the first in
  alphabetical order.
- **Declare the choice in the report** whenever the winner was not the only candidate, naming
  the file you read. Whoever reads the report can then see that a second `00-` file exists and
  was passed over — silently picking one of two is how a folder ends up read twice in two
  different ways.
- If there is no `00-*.md` at all, the folder has no index. Say so instead of promoting the
  lowest-numbered file to the role: a numbered file is content, and reading it as an index
  invents structure that nobody wrote.

## When a plan becomes a folder

The section above is about reading a folder. This one is about making one.

A plan is executed in sequence, and the longer the sequence, the more whoever walks it loses
sight of their own earlier work: by task 12 the decisions of task 3 are no longer in memory,
only a summary of them is. That is not laziness — it is the reason the same rule gets written
twice by the person who had already written it. A shorter document is not enough. The work has
to be **cut into slices that close by themselves**.

Above the batching threshold, or whenever completion cannot be verified before the very end,
the plan becomes a folder with the same name the file would have had:

```
<where-the-plan-goes>/<plan-name>/
  00-index.md
  01-<first-slice>.md
  02-<second-slice>.md
  …
```

**`00-index.md` is the piece that makes the rest work**, and without it this convention
recreates between the batches the very seams it was meant to remove. It holds three things,
and nothing else:

1. **The order of the batches and the dependencies between them** — who cannot start before
   whom, and why.
2. **The shared vocabulary and its owners** — the types, the rules with more than one reader,
   the invariants between surfaces, and **where each one lives**. A rule that appears here with
   an owner gets *called* by the later batches, not rewritten.
3. **What counts as the end of a batch** — the verification the project uses (tests, build,
   checks), passed by that batch **on its own**.

Two cutting criteria, and neither is negotiable:

- **A batch is a batch only if it can pass the verification alone.** If it needs the next one
  in order to build, it is half a batch, and it goes back together with its twin. A slice that
  does not close is not a slice, it is a pause.
- **Units that touch the same file stay in the same batch.** Split apart, the second one works
  on code it did not write and has not read.

**Shared foundations go in the first batch.** If two batches need the same rule, that rule is
created *before* both of them, so the second has something to call instead of something to
invent. It is the only order that makes duplication hard rather than merely discouraged.

**Applying the split is part of the work**, not a suggestion: write the files, with the index
filled in and the batches numbered. Advice to split left as words is advice nobody carries out.

## The template of a batch file

A batch file opens with a header, carries the tasks in the middle, and ends with the place
where execution writes. The header and the closing section are fixed; only the tasks change
from one batch to the next.

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
```

**The "starting material" line.** When the input was a monolithic plan that was sent back to be
cut into batches — a plan already written, then judged too big to execute — that line carries
its path and the sections of it that belong to this batch. The skill that cuts the folder
writes the line; without it, whoever drafts the tasks re-derives from the spec work that had
already been written once, and the second version disagrees with the first.

**When the plan starts from scratch there is no such input, and the line stays empty.** Keep
the line in the file with nothing after it rather than deleting it: an empty line says the
input was a spec, a missing line says nobody looked. Whoever drafts the tasks reads the empty
line and works from the spec and the index, without going to look for a source document that
does not exist.

**`## Progress` is the place execution writes, and it is the only one.** One line per step of
the batch procedure, appended in order and never rewritten. The content of those lines — which
steps leave one, what each says, what makes a line count as done and what cancels it — belongs
to the batch procedure, not to this template; the template owns the place, so that every batch
file has it in the same spot and no run has to invent one.

**`## State` is the place a stopped forked skill leaves what it needs in order to restart.**
When a forked skill returns `status: question`, the main thread writes its `state` here, under
a sub-heading naming the skill that produced it, and leaves it there until that skill has been
invoked again and finished. More than one may sit there at once. It stays in the file rather
than in the conversation because the session that asked the question may not be the session
that receives the answer.

**Only the main thread writes into a batch file.** Executors, reviewers and forked skills
return their work; they do not edit the folder.

## The template of a plan that stays one file

Below the batching threshold there is no folder: the plan is one file,
`<plan folder>/<name>.md`. It is at once the plan and its only batch file, so whatever writes
into a batch file writes into this one — which is why the two places below are not optional.

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
```

The header carries the closing criteria and the verification command because there is no index
to hold them: in a folder those belong to `00-index.md`, and here the file is its own index.
The tasks are written empty and filled in afterwards, exactly as in a folder.

**`## Progress` and `## State` mean here what they mean in a batch file**, and for the same
reason: the single file is treated as one batch. If the places are not in the file, execution
invents them, and two runs write in two different spots — after which resuming means guessing
which of the two is the real record.
