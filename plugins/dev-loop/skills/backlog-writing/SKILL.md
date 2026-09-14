---
name: backlog-writing
description: Breaks a brief, an idea or an approved spec into stories and tasks sized in Fibonacci points, then writes them to `docs/backlog/` ready to be typed into a ticket system. A task is a conceptual operation, never a single action, and anything reaching 13 becomes a story that gets split.
when_to_use: When the user wants to plan, size, estimate, split or organise work into tickets — break this work up, how many story points, prepare the tickets, this task got too big — or simply describes a chunk of work and asks how to sequence it. Not for writing a spec or a plan, nor for executing one.
argument-hint: "[build|split] [target]"
effort: high
---

# backlog-writing

Turn a body of work into stories and tasks that a ticket system can hold, each one sized in
Fibonacci points.

The hard part is not typing tickets. It is **deciding where the line falls between a story and
its tasks, and what each one weighs**. Done by feel, the line lands wherever the sentence
happened to end: tasks that are single actions, stories that are shapeless containers, and
estimates that are vibrations wearing Fibonacci numbers as a costume.

That judgement is the same one `/dev-loop:plan-batching` applies to a plan, one level higher:
there you decide how to slice the *execution* of work already defined; here you decide how to
slice *the work itself*, before anyone has defined it.

## What it does, and what it doesn't

| Does | Doesn't |
|---|---|
| Cut work into stories and tasks | Write specs (`/dev-loop:spec-revision`) |
| Estimate in Fibonacci points | Write plans or batches (`/dev-loop:plan-batching`) |
| Promote to a story whatever overflows | Execute anything (`/dev-loop:plan-execution`) |
| Write `docs/backlog/` | Talk to a ticket system — tickets are typed in by hand |

**The backlog says *what* and *how big*. The plan says *how*.** A story from the backlog, when
its turn comes, walks the loop on its own. This skill sits upstream of all of it.

## Language of the output

The text of this skill is English. What lands in the backlog follows a single boundary, and it
runs between prose and names.

- **It is prose, so it follows the project's documents.** Story and task titles, descriptions,
  the scope and the anchors in the index. Work the language out from the documents that are
  already there; if the project has none, **ask** — it is not something to assume. This is the
  half that goes through the rewrite of Step 6, because it is the half the team re-reads.
- **It is a name, so it is English, always.** The story file slugs, the folder name, and the
  index name, which is `00-index.md` — fixed, not a per-project choice. The same holds for
  anything that is a name in the code.

So a slug names its subject **in English** while its title lives in the documents' language, and
a reworded title never renames the file.

## Inputs and modes

Two modes:

1. **Build** (default) — a brief, an idea or an approved spec becomes a backlog.
2. **Split** — a task that outgrew 13 points gets re-cut in place, inside the backlog that
   already exists.

Accepted inputs: a spoken brief, an approved spec, an existing backlog to extend. With no scope
at all, **ask instead of inventing one** — a backlog built on a guessed scope is worse than no
backlog, because it looks decided.

**Always open the project too.** Estimation anchors are fished out of the code and out of git
history. Without them the skill produces numbers with nothing to compare against, which is the
worst defect it can have.

## Workflow

### Step 1 — Fish out the anchors

Points are **relative**. That is the whole reason Fibonacci is used instead of hours: a 5 means
“clearly bigger than that 3 we did, clearly smaller than that 8”. Absolute scales drift between
projects and between months; anchors don't.

**Fish them from outside the work you are about to estimate** — branches already merged, tickets
already closed. An anchor taken from the same body of work calibrates the ruler against the
thing being measured, and every estimate then comes out self-confirming: it feels rigorous and
proves nothing.

Look for **two or three pieces of work already finished, of visibly different sizes**. Fan the
search out to one read-only `Explore` per family of source, each with `model: haiku`:

- merged branches and what one of them actually contained;
- plan folders already executed;
- closed tickets and changelog entries.

Keep the fan-out under the agents-per-wave cap held in
`${CLAUDE_PLUGIN_ROOT}/references/limits.md`; the figure lives there.

Inside an executed plan folder, the index is recognised by the rule in
`${CLAUDE_PLUGIN_ROOT}/references/plan-folder.md` — those folders may predate this plugin and
their index may not be named the way one would be named today.

For each anchor write down: what it was called, what it actually included, and the points it
gets. If the project never used points, **assign them here** — that is the calibration, and it
is the moment to say so out loud rather than pretend the numbers came from somewhere.

If the project is new and there is nothing to fish, fall back to an absolute rubric (`1` a
touch-up, `3` one module, `5` one module with its tests, `8` several modules) and **declare the
fallback in the index**, so a later reader knows those estimates carry less weight.

### Step 2 — Cut into stories and tasks

A **task** passes all three of these:

1. **It is a conceptual operation, not an action.** If the title names a file or a line, the
   task is too small — it belongs *inside* the description of the task that contains it.
   “Speed up the order list” is a task; “add an index on the date column” is one of its details.
2. **It closes on its own.** When it ends, something is verifiable — not “half of the refactor”.
3. **It weighs less than 13.**

A **story** is a coherent slice of value made of **2-6 tasks**. Past six it is an epic, and an
epic gets split into several stories *before* anything is estimated. **An epic is not an
artifact**: it has no file and no folder. It is the signal that the cut was wrong, and what
survives on disk are the stories that come out of it.

**Points live on the tasks; the story carries their sum.**

### Step 3 — Estimate against the anchors

Before comparing, ask four questions about the task. They are not added up — a score built from
four invented numbers is just a fifth invented number wearing a lab coat. They frame the
comparison:

- how many **unknowns** — not how much work, but how much you don't know yet;
- how much **surface** it touches;
- how many **tests** it needs written;
- how many **external dependencies** (APIs, third parties, migrations).

Then place it: bigger than the 3-anchor, smaller than the 8-anchor → 5.

**13 is not an estimate, it is a signal.** A task never ends up worth 13: when it gets there it
becomes a story and gets split. And for “close to 13”: **if you hesitate between 8 and 13, it's
13** — promote it. The useful scale for a task is `1, 2, 3, 5, 8`.

### Step 4 — Split what overflows

Cut **vertically**: by scenario, by surface, by entity, by phase. Never horizontally by layer —
model / controller / view produces slices that fail test 2, because none of the three closes on
its own.

Preferred axes, in order:

1. by **scenario** — the normal case first, the edge cases after;
2. by **surface** — one screen, one endpoint, one command;
3. by **entity or data type**;
4. by **phase** — reading before writing.

**Anti-rule: never “code first, tests later”.** Tests belong to the task that generates them, so
that the task can close on its own. A standalone testing task is legitimate only against **code
that already exists**: coverage debt, an audit of an inherited suite.

### Step 5 — Ask, in one block, before writing anything

Put the whole cut **and** the points in chat first — stories, their tasks, the number next to
each — and write files only after approval. The user knows their own project's weights better
than any anchor does, and a disagreement is usually about three numbers out of twelve.
Re-discuss those three; don't redo the whole thing.

Ask about the anchors in the same block: they are the assumption everything else rests on. The
questions go in the four-line shape held by `${CLAUDE_PLUGIN_ROOT}/references/asking.md`, in one
block, before a single file is touched.

### Step 6 — Write the folder

```
docs/backlog/
  00-index.md
  01-billing-module.md
  02-invoicing-coverage.md
```

`docs/backlog/` is **one living folder**: a later brief adds stories to it and continues the
numbering, instead of opening a second backlog. Closed stories stay where they are — the ticket
system is what says which work is done. If the project keeps its documents somewhere other than
`docs/`, follow the project.

Slugs are English and name the **subject**, not the verb, so rewording a title later doesn't
rename the file and break every link to it. Titles and descriptions are in the documents'
language. The example below belongs to a project whose documents are in French:

```markdown
# Story: Teste le module de facturation   [8]
Ticket: PRJ-42 · État: en cours

Deux lignes: à quoi sert la story, pourquoi maintenant.

## Enregistre les scénarios de facturation   [5]
Ticket: PRJ-43 · État: fait

Ce qui change, et où le travail s'arrête si ce n'est pas évident. 1-3 lignes. Pas de «comment».

## Ajoute les remises et les arrondis   [3]
Ticket: — · État: à faire

...
```

**A blank line always separates the metadata line from the description**, on tasks as well as on
stories. Markdown folds consecutive lines into one paragraph, so without it the rendered ticket
reads `État: à faire Ce qui change…` and the status runs into the first sentence.

Four states — to do, in progress, done, cancelled — written in the documents' language and kept
to those four. The ticket-system key goes next to the state once the ticket exists; until then,
a dash.

### How titles and descriptions are written

A ticket is read in a list, at speed, by someone deciding whether it is theirs. That reader is
served by plain words and hurt by elegant ones, so:

- **Imperative verb first, then the object.** «Teste le module de facturation», not
  «Caractérisation du flux de facturation». A nominalisation turns an action into an
  abstraction, and an abstraction cannot be finished.
- **Plain words over precise-sounding ones.** If a word would look out of place spoken aloud to
  a colleague, it is the wrong word.
- **Descriptions carry the same voice**: one to three lines, verb first. Say what changes, and
  where the boundary isn't obvious, say where the work stops. No *how* — that is the plan's job
  — and no lists of files, which go stale the moment someone renames one.
- **Dissolve the exit criterion into the prose. Never stamp it as a labelled line.** A standing
  formula in the same position on every task turns into wallpaper by the fourth ticket, and the
  reader stops seeing the one line that actually differs. Write it as part of the sentence
  instead. Where the title already fixes the boundary, say nothing — a criterion that restates
  its own title is noise.

When several tasks in a story share the **same** boundary, write it once in the story and leave
it out of the tasks. Repeating it under each one looks like rigour and adds nothing.

**Run every title and description through `humanizer:humanizer` before writing the files, if it
appears among the available skills.** If it does not, the rewrite is skipped and **the report
says so**, in a line of its own — a skipped step that goes undeclared reads later as a step that
ran.

The reason it is worth the detour: backlog prose is the one part of this work that **leaves**. It
gets typed into the ticket system and read by the team, under the user's name. It is also short,
which is where model habits show most — not-X-but-Y contrasts, closing fragments that restate the
line above, triads of adjectives in a row. They cost nothing to remove while the text is still in
chat, and cost a rewrite of the whole folder plus the open tickets afterwards.

**`00-index.md` holds four things and nothing else**, because every extra line is material that
will drift away from the story files:

1. **The scope** — what is in, and what is deliberately out.
2. **The estimation anchors**, or the declaration that the absolute rubric was used.
3. **The list of stories** with their points and the dependencies between them.
4. **The total.**

No state in the index: state lives in the story files, and kept in two places it would disagree
with itself.

## Split mode

A task that grew past 13 while it was being worked on doesn't need a new backlog, only a re-cut.
Steps 4 and 5 are the whole job: split it along a vertical axis, re-estimate the pieces against
the same anchors already in the index, and put the proposal in chat before touching a file.

The index of a backlog that predates this plugin may not carry the name a new one would get;
recognise it with the rule in `${CLAUDE_PLUGIN_ROOT}/references/plan-folder.md`, and say in the
report which file you took as the index. A **new** index is always written as `00-index.md`.

Then place the result. If the pieces still belong together, the task **becomes a story**: it
moves out into its own numbered file, the tasks that came out of it live inside, and the old
heading disappears from the story that used to hold it. If the pieces belong to stories that
already exist, they move there instead. Either way, update the points and the totals in the
index — a backlog whose index disagrees with its stories stops being read.

Say plainly which tickets this invalidates: the user types them in by hand, so a split means one
ticket to close or rename and two to open, and they need to know that without going and diffing
the files.

## The second truth

Tickets are typed into the ticket system **by hand**; this skill exports nothing and the files
carry no machine-readable metadata.

The files still carry state next to each task, by explicit choice. That is a second truth sitting
beside the ticket system and it can drift: **when they disagree, the ticket system wins.** The
files own the *definition* — title, description, points — not the progress.
