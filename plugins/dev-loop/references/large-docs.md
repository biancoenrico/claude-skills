# Reviewing in groups, and the seams between them

Covers any object too large for one sitting: a long document, or a folder of numbered files
forming one piece of work — where the two differ, both are spelled out below.

## The signal that one pass is not enough

**Review depth falls with the pass's size, not the document's.** The signal is observable and
it is about the pass, not the object:

- you reach the end and cannot say, without scrolling back, what the earlier part decided;
- you judge a section by what it says alone, since the sections it must agree with are no
  longer in mind;
- for a folder, a file cites a shared rule and you cannot recall whether the owning file says
  the same thing.

Any one of those means the review goes group-wise.

A **unit** is one numbered piece of the object — a section, task or requirement.

**The grouping threshold is an indication, not a mechanical cut** — a document past **500
lines** or **8 units** is usually already group-wise work. This is *not* the declared batching
threshold in `${CLAUDE_PLUGIN_ROOT}/references/limits.md`, even though both land on eight.

What makes the call is cohesion and the signal above, not unit count — how dense the material
is. Parts **distinct by subject** already show where the groups are.

## How the groups are cut

1. **Cut for cohesion, not for length.** A group is units that talk about the same thing and can
   be judged without the other groups' answers. Cutting a rule in half is worse than not
   cutting at all.
2. **A group is a subject, not a quota.** Groups of very different sizes are fine; groups even
   in size that split one subject are not.
3. **A unit belongs to exactly one group.** A unit that seems to belong to two has an unsettled
   subject — note it, put it in one group, and let the seam pass catch what the other side
   expected of it.
4. For a folder the cut is already made: **one file is one group**, since the files were cut by
   the same criterion. Merge two into one group only when neither can be judged without the
   other, and say so in the report.

## What each group gets

- **A whole pass, not a skim** — every check the review normally runs, applied to that group.
- **Its own reviewer**, since groups do not read each other's output: one per group, launched
  together under the agents-per-wave cap in `${CLAUDE_PLUGIN_ROOT}/references/limits.md`, in
  waves beyond it.
- **Its own iteration budget**, as `references/ledger.md` defines it.

**The report accumulates.** Finding numbers run across groups; one report comes out at the end,
not one per group.

## The seam pass

Seams hold defects no single group's review can see: a rule restated differently, two groups
contradicting each other, or each assuming the other already built something.

**The seam pass runs last, after all fixes are applied** — a fix inside a group can move its
boundary, so a seam checked earlier checks text that no longer exists.

Treat the seams as one more group: its own pass, findings numbered in the same running
sequence.

### Seams between adjacent sections

- **The same rule stated twice.** Disagreement is a contradiction; agreement is still a finding
  — copies that agree today diverge at the next edit, since neither knows the other exists.
  Keep one, have the other refer to it; never reword both into a match.
- **The same term used with two meanings**, or two terms used for one thing, across the
  boundary.
- **A fact shown on two surfaces.** Where two sections state the same fact by different routes,
  the document must declare the invariant instead of leaving it inferred.
- **A handover with no other side.** One section ends by passing something on; the next must
  take delivery of exactly that, under that name.

### Seams between adjacent files

- **The index tells the truth.** Every shared rule the index declares has a real owner, and
  files that use it *call* it instead of re-deriving it; every declared dependency matches the
  order of the files.
- **Nothing shared lives outside the index.** If two files need the same thing and the index is
  silent, it will be written twice, by runs that never see each other — a duplication finding,
  not a style note.
- **Each file closes on its own.** The closing criterion the index declares for a file is
  verifiable on that file alone, without waiting for the ones after it.
- **The foundations come first.** A rule two files need is created before both, so the second
  calls it rather than invents it.

## When the groups cannot be cut

The object is indivisible, or there is no time: run one pass on the load-bearing decisions and
the seams, and leave the rest at surface depth.

**Then say in the report which parts were looked at lightly** — partial coverage written down
is information; left unsaid, it is a review lying about its own worth.
