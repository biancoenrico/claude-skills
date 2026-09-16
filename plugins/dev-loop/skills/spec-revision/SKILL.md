---
name: spec-revision
description: Iteratively reviews a technical specification — API spec, feature spec, architecture note, functional requirements — until it is implementable without guesswork, with an answer written down for every scenario the system will meet.
when_to_use: Whenever there is a spec or requirements document to review, validate or make implementable — "review this spec", "is this specification complete?", "are there contradictions in these requirements?" — or a spec file is handed over. Not for reviewing an implementation plan, which is /dev-loop:plan-revision.
argument-hint: "[path to the spec]"
effort: xhigh
---

# spec-revision

Review a technical specification, round after round, until it can be implemented without
stopping to guess: free of contradictions, of ambiguities, and of gaps that would force whoever
implements it to invent an answer.

The point is that the document says *what* to build unequivocally. A specification that
contradicts itself, leaves terms open to two readings, or announces sections nobody wrote
produces divergent implementations: everyone fills the holes their own way, and the defect shows
up once the work is done. Finding those on paper costs a fraction of finding them in code.

You orchestrate. The judging is done by `dev-loop:reviewer` agents, one per group, against the
criteria file this skill owns; the writing is done here, on the main thread.

## 1 — What you are given

In order of priority: an explicit path; the last specification-shaped file discussed in the
conversation; the text pasted inline. If none of the three is there, ask the user where the
specification is rather than inventing its content.

This skill checks **what has to be built**. Checking **how it gets built** is
`/dev-loop:plan-revision`.

## 2 — Frame the document

Before criticising, understand what is in front of you: the **type** (API spec, feature spec,
architecture, functional requirements), the **project context** (stack, domain, stated
constraints) and the **current structure** (sections present, format, level of detail).

This framing matters because the same sentence weighs differently by type: "fast" is a tolerable
ambiguity in a vision note and a blocker in an API spec with latency requirements.

**If the document describes something to be built inside an existing project, open the project.**
Read the conventions it keeps at its root and keep Grep within reach over the shared helpers. If
the code is out of reach, **say so in the report**: that part of the review stays uncovered, and
the document is approved knowing it rather than believing it done.

## 3 — Cut into groups

A document too large for one sitting is reviewed group by group. The signal that tells you it is
one, how the cut is made, and what each group is entitled to are held by
`${CLAUDE_PLUGIN_ROOT}/references/large-docs.md`. Read it here, before you cut.

A document that fits in one pass is one group, and the rest of this procedure is unchanged.

**A document under the small document threshold** in `${CLAUDE_PLUGIN_ROOT}/references/limits.md`
— read the value there — is one group and gets **one reviewer**, which also takes the
alternatives pass (step 5).

## 4 — Open the ledger

The review keeps a record beside the document it reviews, at `<name>.review.md`. Its shape, what
goes in it, and what to do when a file is already sitting at that path are held by
`${CLAUDE_PLUGIN_ROOT}/references/ledger.md`. The first iteration creates it with the groups you
have just cut; every later one continues the same file. An unusable ledger — one that does not
parse, or one that names a different object — is renamed rather than repaired, and the report
says where it went.

**Only this thread writes the ledger.** Reviewers return findings; the rows, the IDs and the
states are yours.

## 5 — Fan out to the reviewers

One `dev-loop:reviewer` per group, launched in parallel, plus one dedicated reviewer for the
alternatives.

Each reviewer receives:

- the path of its criteria file, `${CLAUDE_PLUGIN_ROOT}/skills/spec-revision/criteria.md`. The
  full form is required, and why a relative one is refused is held by the agent itself — do not
  restate it here;
- the object it judges — its group, named by section range;
- the ledger, when one exists.

The alternatives reviewer receives `${CLAUDE_PLUGIN_ROOT}/references/alternatives.md` on top of
that, and judges the load-bearing decisions of the document rather than a group of it. Under the
small document threshold there is no separate one: the single reviewer receives both files.

When the alternatives pass runs again, and which fixes start a next iteration, are held by
`${CLAUDE_PLUGIN_ROOT}/references/ledger.md`; the single reviewer follows the same rules.

How many may run at once is the agents-per-wave cap in
`${CLAUDE_PLUGIN_ROOT}/references/limits.md`: read the value there instead of writing a number
into this file, and beyond it fan out in waves. What comes back, and what to do when nothing
does, are held by `${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`.

## 6 — Questions

Everything that comes back gets filtered before it reaches the user: which questions you close by
reading, which you close by searching, which are genuinely the user's, and the four blunt lines
each one takes are held by `${CLAUDE_PLUGIN_ROOT}/references/asking.md`.

The ones that close by reading or searching you close yourself — `Explore` with `model: haiku`
for the quick lookups — citing the source so the user can contradict it. The rest you collect and
put in one block.

## 7 — Apply the fixes

Reviewers have no `Edit` and no `Write`: the fixes are yours.

- **🔵 and ⚪** — apply them and carry on.
- **🔴 and 🟠** — propose the specific correction. Where you have enough context to settle it
  without ambiguity, apply it and **record the assumption in the ledger**, so the user can
  contradict it.

Two rules govern the act of writing here:

- **Do not change the intent, and do not keep quiet about it.** A fix corrects an error; it does
  not redesign the document. A better road becomes a question, never a silent rewrite — the
  rewrite takes the decision away from the user **and** the awareness of having taken it.
- **Every change leaves a trace.** Each applied fix carries its reason into the ledger, together
  with the assumptions used to settle it. That is what makes a decision this thread took alone
  contradictable.

A fix the user turns down is restored to the text it had, recorded as `rejected` with the user's
own reason, and never proposed again: a review that re-raises what was already discarded teaches
the user to skip its findings.

## 8 — Seams, and going round again

**The seams are looked at after the fixes**, never before: a rule reworded to close an ambiguity
can stop agreeing with its neighbour, and a seam checked earlier is a seam checked on text that
no longer exists.

On the next iteration, launch fresh reviewers **only on the groups that moved**. What moves a
group, and when a round has no next iteration at all, is held by
`${CLAUDE_PLUGIN_ROOT}/references/ledger.md`.

Carry on until one of three exits fires:

- **Approved** — no 🔴 and no 🟠 left, **and no question open**. A specification with an open
  question is not approved however clean the rest is: that is precisely where the implementation
  will stop, and calling it ready only moves the stop further along, where it costs more.
- **Accepted with reservations** — only 🟡/🔵/⚪ remain and the user chooses to accept them.
- **Waiting on decisions** — the questions are on the table. Not a failure of the review: its
  product.

How many rounds you may take on your own is the revision iteration cap in
`${CLAUDE_PLUGIN_ROOT}/references/limits.md` — read it there, do not write the number here. Two
rules give that budget its meaning: **questions do not consume it**, since a round spent asking
brings in information that was not there before; and **when the answers arrive the counter starts
again** on the area they touch, because an answer can open scenarios nobody had looked at.

A partial answer is used for what it says: apply what was decided, leave the rest open, and
declare nothing approved.

## 9 — What comes out

The reviewed specification, plus a short summary: the changes applied, the assumptions made, and
the points deliberately left open with the reason for each.

The ledger stays where it is, as the record of why a finding was turned down and what was assumed
along the way. Whether it gets committed is the project's call.
