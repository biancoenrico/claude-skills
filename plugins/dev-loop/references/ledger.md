# Review ledger

The file a review keeps beside the document it is reviewing, carrying what previous iterations
decided so the next one does not start from nothing — the four kinds of record are listed below.

This file owns the **shape** of that record. What a reviewer should judge, and by which
measure, is not here: each skill keeps its own criteria in its own consulting file and hands
the path to the reviewer alongside this ledger.

## Where the ledger sits

Next to the reviewed object, never in a directory of its own:

- **a single document** — `<name>.review.md` beside it, where `<name>` is the document's file
  name without its extension.
- **a plan folder** — `<folder>/review.md`, inside the folder, next to the index. One ledger for
  the whole folder: the batches are the groups of that review, and they share one counter table.

One object, one ledger. A second review of the same document reopens the same file rather than
starting a parallel one.

## What the ledger records

Four things, and nothing else:

- **The groups, with their iteration counter.** One row per group — a section range of a long
  document, a batch file of a plan folder, or the whole object when it fits in one pass — with
  how many iterations that group has been through. The counter is per group, not per review:
  groups touched by fixes move on while the others stand still. The cap is a declared number,
  read from `${CLAUDE_PLUGIN_ROOT}/references/limits.md` under the revision iteration cap
  rather than kept as a figure in the ledger.

  **What the counter counts.** An iteration is one round of analysis-and-correction carried
  out under the review's own steam. **Questions do not consume the budget**: a round spent
  asking and waiting brings in information that was not there before, rather than polishing
  what is already known. When the answers come back, the counter restarts at zero on the
  groups those answers touch — an answer can open scenarios nobody had looked at yet.

  **What happens at the cap.** A group that reaches it does not go round again: consolidate
  the state in the ledger and ask the user how to proceed.
- **The findings.** Each one gets an **ID** that never gets reused inside the ledger, a one-line
  statement, the group it belongs to, and a **state**: `open` (raised, not yet dealt with),
  `fixed` (the object was changed, and the ledger says in which iteration), or `rejected` (the
  user decided it stands as it is). **A `rejected` finding carries the user's reason, in the
  user's own terms.**
- **The assumptions.** Anything the review closed by itself rather than asking: what was
  assumed, and what it was read from.
- **The questions, with their answers.** Every question put to the user, and the answer that
  came back, written where the next iteration will look for it. A question that has gone out
  and not yet been answered stays in the ledger unanswered.

## A ledger, laid out

The same skeleton for both positions, so two skills reading each other's ledgers find the same
headings in the same order. Copy it as it stands and fill the tables:

```markdown
# Review ledger — <name of the reviewed object>

**Object:** <path to the document or folder>
**Opened:** <date> · **Last iteration:** <date>

## Groups and iterations

| group | covers | iterations | last touched by |
|---|---|---|---|
| G1 | <sections, or the batch file> | 2 | fixes of iteration 2 |
| G2 | <sections, or the batch file> | 1 | — |
| seams | between-group consistency | 1 | after the iteration 2 fixes |

## Findings and their state

| ID | group | finding | state | iteration | note |
|---|---|---|---|---|---|
| F-001 | G1 | <one line> | fixed | 1 | <what changed> |
| F-002 | G2 | <one line> | rejected | 1 | user: <their reason, their words> |
| F-003 | G1 | <one line> | open | 2 | <what it is waiting on> |

## Assumptions closed by reading

| # | assumption | closed by reading |
|---|---|---|
| A-001 | <what was taken as given> | <source that settles it> |

## Questions and answers

| # | question | answer |
|---|---|---|
| Q-001 | <one line> | <the user's answer, or "open"> |
```

IDs stay stable once written. A finding that turns out to be two findings gets a new ID for the
second half; it does not renumber the first.

## How a reviewer is handed the ledger

- **Every reviewer receives it**, together with its criteria file and its slice of the object.
- **A `rejected` finding is not raised again.** If new evidence genuinely undercuts the reason it
  was rejected, it goes in as a **new finding that names the rejected ID and says what
  changed** — not as the old one re-opened.
- **The next iteration launches fresh reviewers only on the groups that moved** — those touched
  by a 🔴 or 🟠 fix or by an answer. A fix below 🟠 changes the wording, not the substance, and
  moves nothing: a round whose fixes were all below 🟠, with no answer arriving, has no next
  iteration and goes to the exits.
- **The alternatives pass runs on the first iteration only**, whether a dedicated reviewer or
  the single reviewer of a small document takes it. It runs again only when an answer from the
  user moves a load-bearing decision — a fix does not change the road taken, and a group nobody
  changed has already been judged, so re-reading it only buys a different wording of the same
  verdict. Fresh reviewers, not the previous ones resumed.
- **The seams come after the fixes, not before**: the seam pass reads the object once the
  groups have stopped moving, and gets its own row in the groups table.
- **Only the main thread writes the ledger.** Reviewers return findings, assumptions and
  questions in their report; the main thread turns them into rows, assigns the IDs and changes
  the states.

## Opening a ledger, and finding one already there

On the first iteration the ledger does not exist and gets created — headings in place and the
tables empty except for the groups the review has just cut.

If a file is already sitting at that path, it is read before anything is written to it, and
there are two ways it can be unusable:

- **it does not parse as a ledger** — the headings are gone or the tables are mangled;
- **it belongs to a different object** — its `Object:` line points elsewhere, which happens when
  a document is renamed or a folder is copied.

In both cases the old file is **renamed with a suffix** (`<name>.review.superseded-<date>.md`)
rather than deleted or edited into shape, and a fresh ledger is opened at the original path. Say
so in the report, with the path of the renamed file.

A ledger that reads correctly and names the right object is **never** restarted, however old it
is. It is continued.

## What becomes of it when the review ends

The ledger stays where it is: the next review of the same document opens this same file and
starts from what it says.

Whether it gets committed is the project's call, not this plugin's. A project that keeps its
working documents in the repository commits the ledger with the document; one that keeps them
out leaves the ledger out with them. Either way, do not delete it on the way out.
