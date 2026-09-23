---
name: backlog-writing
description: Breaks a brief or spec into stories and tasks sized in Fibonacci points, written to `docs/backlog/` for a ticket system.
when_to_use: Planning, sizing, splitting or organising work into tickets. Not for a spec or a plan.
argument-hint: "[build|split] [target]"
effort: high
---

# backlog-writing

Turn a body of work into stories and tasks that a ticket system can hold, each one sized in
Fibonacci points.

## What it does, and what it doesn't

| Does | Doesn't |
|---|---|
| Cut work into stories and tasks | Write specs (`/dev-loop:spec-revision`) |
| Estimate in Fibonacci points | Write plans or batches (`/dev-loop:plan-batching`) |
| Promote to a story whatever overflows | Execute anything (`/dev-loop:plan-execution`) |
| Write `docs/backlog/` | Talk to a ticket system — tickets are typed in by hand |

**The backlog says *what* and *how big*. The plan says *how*.** A story, once its turn comes,
walks the loop on its own; this skill sits upstream of all of it.

## Language of the output

The text of this skill is English. The output splits along one boundary: prose vs. names.

- **Prose follows the project's documents.** Story and task titles, descriptions, the scope and
  the anchors in the index. Work the language out from documents already there; if none exist,
  **ask**. This is the half that goes through the humanizer rewrite in Step 6 — it's what the
  team re-reads.
- **Names are English, always.** The story file slugs, the folder name, and the index name,
  which is `00-index.md` — fixed, not a per-project choice. Same for any name in the code.

## Inputs and modes

Two modes:

1. **Build** (default) — a brief, an idea or an approved spec becomes a backlog.
2. **Split** — a task that reached 13 points gets re-cut in place, inside the backlog that
   already exists.

Accepted inputs: a spoken brief, an approved spec, an existing backlog to extend. With no scope
at all, **ask instead of inventing one** — a guessed scope looks decided, which is worse than no
backlog.

**Always open the project too.** Anchors are fished from the code and git history; without them
the numbers have nothing to compare against — the skill's worst defect.

## Workflow

### Step 1 — Fish out the anchors

Points are **relative**: a 5 means "clearly bigger than that 3 we did, clearly smaller than that
8". Absolute scales drift between projects and months; anchors don't.

**Fish them from outside the work you are about to estimate** — branches already merged, tickets
already closed. An anchor taken from inside the work calibrates the ruler against the thing it
measures: the estimate then comes out self-confirming, feeling rigorous and proving nothing.

Look for **two or three pieces of work already finished, of visibly different sizes**. Fan the
search out to one read-only `Explore` per family of source, each with `model: haiku`:

- merged branches and what one of them actually contained;
- plan folders already executed;
- closed tickets and changelog entries.

Keep the fan-out under the agents-per-wave cap in `${CLAUDE_PLUGIN_ROOT}/references/limits.md`.

Inside an executed plan folder, the index is recognised by the rule in
`${CLAUDE_PLUGIN_ROOT}/references/plan-folder.md` — older folders may name it differently.

For each anchor write down: what it was called, what it actually included, and the points it
gets. If the project never used points, **assign them here** and declare that calibration.

If the project is new and there is nothing to fish, fall back to an absolute rubric (`1` a
touch-up, `3` one module, `5` one module with its tests, `8` several modules) and **declare the
fallback in the index**.

### Step 2 — Cut into stories and tasks

A **task** passes all three of these:

1. **It is a conceptual operation, not an action.** If the title names a file or a line, the
   task is too small — it belongs *inside* the description of the task that contains it.
   "Speed up the order list" is a task; "add an index on the date column" is one of its details.
2. **It closes on its own.** When it ends, something is verifiable — not "half of the refactor".
3. **It weighs less than 13.**

A **story** is a coherent slice of value made of **2-6 tasks**. Past six it's an epic, split into
several stories *before* anything is estimated. **An epic is not an artifact** — no file, no
folder — it signals the cut was wrong, and only the stories that come out of it survive on disk.

**Points live on the tasks; the story carries their sum.**

### Step 3 — Estimate against the anchors

Ask four questions about the task — not to add up (a score built from four invented numbers is
just a fifth invented one), but to frame the comparison:

- how many **unknowns** — not how much work, but how much you don't know yet;
- how much **surface** it touches;
- how many **tests** it needs written;
- how many **external dependencies** (APIs, third parties, migrations).

Then place it: bigger than the 3-anchor, smaller than the 8-anchor → 5.

**13 is not an estimate, it is a signal.** A task never ends up worth 13: when it gets there it
becomes a story and gets split. Close to 13: **if you hesitate between 8 and 13, it's 13** —
promote it. The useful scale for a task is `1, 2, 3, 5, 8`.

### Step 4 — Split what overflows

Cut **vertically**: by scenario, by surface, by entity, by phase. Never horizontally by layer —
model / controller / view produces slices that fail test 2, because none closes on its own.

Preferred axes, in order:

1. by **scenario** — the normal case first, the edge cases after;
2. by **surface** — one screen, one endpoint, one command;
3. by **entity or data type**;
4. by **phase** — reading before writing.

**Anti-rule: never "code first, tests later".** Tests belong to the task that generates them, so
that the task can close on its own. A standalone testing task is legitimate only against **code
that already exists**: coverage debt, an audit of an inherited suite.

### Step 5 — Ask, in one block, before writing anything

Put the whole cut **and** the points in chat first — stories, their tasks, the number next to
each — and write files only after approval. The user knows the project's weights better than any
anchor; a disagreement is usually about three numbers out of twelve — re-discuss those, not the
whole thing.

Ask about the anchors in the same block, in the four-line shape held by
`${CLAUDE_PLUGIN_ROOT}/references/asking.md`, before a single file is touched.

### Step 6 — Write the folder

```
docs/backlog/
  00-index.md
  01-billing-module.md
```

`docs/backlog/` is **one living folder**: a later brief adds stories to it and continues the
numbering, instead of opening a second backlog. Closed stories stay where they are — the ticket
system says which work is done. Follow the project if it keeps documents somewhere other than
`docs/`.

Slugs are English and name the **subject**, not the verb, so a reworded title never renames the
file. Titles and descriptions are in the documents' language — here, French:

```markdown
# Story: Teste le module de facturation   [8]
Ticket: PRJ-42 · État: en cours

Deux lignes: à quoi sert la story, pourquoi maintenant.

## Enregistre les scénarios de facturation   [5]
Ticket: PRJ-43 · État: fait

Ce qui change, et où le travail s'arrête si ce n'est pas évident. 1-3 lignes. Pas de «comment».

## Ajoute les remises et les arrondis   [3]
Ticket: — · État: à faire
```

**A blank line always separates the metadata line from the description**, on tasks as well as on
stories: Markdown folds consecutive lines into one paragraph, so without it `État: à faire` runs
into the first sentence.

Four states — to do, in progress, done, cancelled — written in the documents' language and kept
to those four. The ticket-system key goes next to the state once the ticket exists; until then,
a dash.

### How titles and descriptions are written

A ticket is read in a list, at speed, by someone deciding whether it is theirs, so:

- **Imperative verb first, then the object.** «Teste le module de facturation», not
  «Caractérisation du flux de facturation» — a nominalisation cannot be finished.
- **Plain words over precise-sounding ones.** If a word would look out of place spoken aloud to
  a colleague, it is the wrong word.
- **Descriptions carry the same voice**: one to three lines, verb first. Say what changes, and
  where the boundary isn't obvious, say where the work stops. No *how* — that is the plan's job
  — and no lists of files, which go stale the moment someone renames one.
- **Dissolve the exit criterion into the prose. Never stamp it as a labelled line.** A repeated
  formula turns into wallpaper by the fourth ticket — write it into the sentence instead. Where
  the title already fixes the boundary, say nothing.

When several tasks in a story share the **same** boundary, write it once in the story and leave
it out of the tasks.

**Run every title and description through `humanizer:humanizer` before writing the files, if it
appears among the available skills.** If it does not, the rewrite is skipped and **the report
says so**, in a line of its own.

**`00-index.md` holds four things and nothing else**:

1. **The scope** — what is in, and what is deliberately out.
2. **The estimation anchors**, or the declaration that the absolute rubric was used.
3. **The list of stories** with their points and the dependencies between them.
4. **The total.**

No state in the index: state lives in the story files.

## Split mode

A task that reached 13 doesn't need a new backlog, only a re-cut. Steps 4 and 5 are the whole
job: split along a vertical axis, re-estimate against the same anchors already in the index, and
put the proposal in chat before touching a file.

A backlog that predates this plugin may not name its index the way a new one would; recognise it
with the rule in `${CLAUDE_PLUGIN_ROOT}/references/plan-folder.md`, and say in the report which
file you took as the index. A **new** index is always written as `00-index.md`.

If the pieces still belong together, the task **becomes a story**: its own numbered file, the
tasks live inside, and the old heading disappears from the story that used to hold it. If they
belong to stories that already exist, they move there instead. Either way, update the points and
totals in the index.

Say plainly which tickets this invalidates: the user types them in by hand, so a split means one
ticket to close or rename and two to open.

## The second truth

Tickets are typed into the ticket system **by hand**; this skill exports nothing and the files
carry no machine-readable metadata.

The files still carry state next to each task. That is a second truth beside the ticket system,
and it can drift: **when they disagree, the ticket system wins.** The files own the
*definition* — title, description, points — not the progress.
