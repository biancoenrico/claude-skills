# Reviewing in groups, and the seams between them

This file applies to any object too large to review in one sitting: a long single document,
or a folder of numbered files that together make up one piece of work. Nothing below depends
on which of the two you have in front of you — where the two shapes differ, both are spelled
out.

## The observable signal that a single pass is not enough

**The depth of a review falls with the size of the pass, not with the size of the document.**
Over thousands of lines a single pass walks through all of them and looks at none: it is the
same arithmetic by which one code review over thousands of lines finds less than a handful of
short ones.

The signal is observable and it is about the pass, not about the object:

- you reach the end of the document and cannot say, without scrolling back, what the earlier
  part decided;
- you find yourself judging a section by what it says about itself, because the sections it
  has to agree with are no longer in mind;
- for a folder, a file cites a shared rule and you cannot tell from memory whether the file
  that owns that rule says the same thing.

Any one of those means the object does not fit in one pass, and the review goes group-wise.

A **unit** is one numbered piece of the object: a section, a task, a requirement. The word is
used that way throughout this file.

**The grouping threshold is an indication, not a mechanical cut.** As a rough indication,
a document past **500 lines** or **8 units** is usually already group-wise work. That figure
comes from the author's own review skills and is offered as an indication, not as a declared
number: it is not one of the values in `${CLAUDE_PLUGIN_ROOT}/references/limits.md`, and the
fact that it lands on eight like the batching threshold declared there is a coincidence of two
unrelated decisions.

What makes the call is cohesion, and the signal above. The criterion is that the object *does
not fit in one pass*, and that depends on how dense the material is, not on how many pieces it
is cut into: twenty thin sections read in one go, six dense ones do not. A document whose parts
are **distinct by subject** is already telling you where the groups are.

## How the groups are cut

1. **Cut for cohesion, not for length.** A group is the set of units that talk about the same
   thing and that can be judged without knowing the answers of the other groups. Cutting a
   rule in half is worse than not cutting at all.
2. **A group is a subject, not a quota.** Groups of very different sizes are fine; groups that
   are even in size but split one subject across them are not.
3. **A unit belongs to exactly one group.** A unit that seems to belong to two is a unit whose
   subject is not settled — note it, put it in one group, and let the seam pass catch what the
   other side expected of it.
4. For a folder, the cut is usually already made: **one file is one group**, because the files
   were cut by the same criterion. Merge two files into one group only when neither can be
   judged without the other, and say so in the report.

## What each group gets

- **A whole pass, not a skim** — every check the review normally runs, applied to that group.
- **Its own reviewer.** Groups do not read what the other groups write, so they are reviewed
  **in parallel**: one reviewer per group, launched together, under the agents-per-wave cap in
  `${CLAUDE_PLUGIN_ROOT}/references/limits.md`; beyond it, in waves.
- **Its own iteration budget.** The revision iteration cap in
  `${CLAUDE_PLUGIN_ROOT}/references/limits.md` counts per group, not per document.

**The report accumulates.** Finding numbers keep running across groups, and one report comes
out at the end — not one per group.

## The seam pass, after the fixes

Seams are where the most expensive defects live, because neither side contains them: two
groups that state the same rule in different words, two that contradict each other, two that
both create the thing the other assumed was already there. No review of a single group can see
them.

**The seam pass runs last, and it runs on the fixed text.** Fixes applied inside a group move
its boundary: a rule reworded to close an ambiguity can stop agreeing with its neighbour, and a
seam checked before the fixes is a seam checked on text that no longer exists. So: all groups
reviewed, all fixes applied, then the seams.

Treat the seams as one more group, with its own pass and its own findings, numbered in the same
running sequence.

### At a seam between adjacent sections of one document

- **The same rule stated twice.** If the two statements disagree, it is a contradiction; if they
  agree, it is still a finding — two copies that agree today diverge at the first edit, because
  neither knows the other exists. The fix is to keep one and have the other refer to it, never
  to reword the two into a match.
- **The same term used with two meanings**, or two terms used for one thing, across the
  boundary.
- **A fact shown on two surfaces.** Where two sections describe the same fact reaching the
  reader by different routes, the document must declare the invariant instead of leaving it to
  be inferred.
- **A handover with no other side.** One section ends by passing something on; check that the
  next one takes delivery of exactly that, under that name.

### At a seam between adjacent files of a folder

- **The index tells the truth.** Every shared rule the index declares has a real declared
  owner, and the files that use it *call* it instead of re-deriving it. Every declared
  dependency is consistent with the order of the files.
- **Nothing shared lives outside the index.** If two files need the same thing and the index is
  silent, that thing is about to be written twice, by two runs that will never see each other.
  It is a duplication finding, not a style note.
- **Each file closes on its own.** The closing criterion the index declares for a file is
  verifiable on that file alone, without waiting for the ones after it.
- **The foundations come first.** A rule two files need is created before both of them, so the
  second has something to call rather than something to invent.

## When the groups cannot be cut

The object is genuinely indivisible, or there is no time: run one pass concentrated on the
load-bearing decisions and on the seams, and leave the rest at surface depth.

**Then say in the report which parts were looked at lightly.** Partial coverage that is written
down is information; the same coverage left unsaid is a review lying about its own worth.
