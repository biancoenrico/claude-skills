---
name: spec-revision
description: Reviews a spec, round after round, until every scenario has a written answer.
when_to_use: A spec or requirements doc to review, validate or make implementable, or one handed over. Not plans, that's /dev-loop:plan-revision.
argument-hint: "[path to the spec]"
effort: xhigh
---

# spec-revision

Review a technical specification, round after round, until it can be implemented without
guessing: free of contradictions, ambiguities, and gaps that would force an implementer to
invent an answer.

You orchestrate; `dev-loop:reviewer` agents judge, one per group, against the criteria file this
skill owns. The writing happens here, on the main thread.

## 1 — What you are given

Priority order: an explicit path, the last spec-shaped file discussed, or text pasted inline. If
none, ask the user rather than invent the content.

This skill checks **what has to be built**; **how it gets built** is `/dev-loop:plan-revision`.

## 2 — Frame the document

Before criticising, understand the **type** (API, feature, architecture, functional
requirements), the **project context** (stack, domain, constraints) and the **current
structure** (sections, format, detail level).

This framing matters because the same sentence weighs differently by type: "fast" is a tolerable
ambiguity in a vision note and a blocker in an API spec with latency requirements.

**If the document builds inside an existing project, open it, read its conventions, and keep
Grep on the shared helpers.** If the code is out of reach, **say so in the report**: that part
stays uncovered, approved knowing it rather than believing it done.

## 3 — Cut into groups

A document too large for one sitting is reviewed group by group — the signal, the cut, and what
each group is entitled to are held by `${CLAUDE_PLUGIN_ROOT}/references/large-docs.md`; read it
before you cut.

A document that fits in one pass is one group, and the rest of this procedure is unchanged.

**Under the small document threshold** in `${CLAUDE_PLUGIN_ROOT}/references/limits.md`, it is one
group with **one reviewer**, who also takes the alternatives pass (step 5).

## 4 — Open the ledger

The review keeps a record at `<name>.review.md` beside the document — shape and reuse rules
held by `${CLAUDE_PLUGIN_ROOT}/references/ledger.md`. The first iteration creates it with the
groups just cut; later ones continue it. An unusable ledger — unparseable, or naming a different
object — is renamed, not repaired, and the report says where it went.

**Only this thread writes the ledger.** Reviewers return findings; the rows, IDs and states are
yours.

## 5 — Fan out to the reviewers

One `dev-loop:reviewer` per group, launched in parallel, plus one dedicated reviewer for the
alternatives.

Each reviewer gets its criteria file path
(`${CLAUDE_PLUGIN_ROOT}/skills/spec-revision/criteria.md`, full form — reason is the agent's
own), the group it judges (named by section range), and the ledger when one exists.

The alternatives reviewer also gets `${CLAUDE_PLUGIN_ROOT}/references/alternatives.md`, judging
the document's load-bearing decisions rather than a group. Under the small document threshold
there is no separate one: the single reviewer takes both files and the same ledger-held rules on
when that pass reruns.

The agents-per-wave cap in `${CLAUDE_PLUGIN_ROOT}/references/limits.md` bounds how many run at
once; beyond it, fan out in waves. What comes back, and what to do when nothing does, are held
by `${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`.

## 6 — Questions

Everything that comes back is filtered before it reaches the user: what closes by reading, what
by searching, what is genuinely the user's, and the four-line shape each takes — held by
`${CLAUDE_PLUGIN_ROOT}/references/asking.md`.

Close the reading and searching ones yourself — `Explore` with `model: haiku` for quick lookups —
citing the source so the user can contradict it. Collect the rest in one block.

## 7 — Apply the fixes

Reviewers have no `Edit` and no `Write`: the fixes are yours.

- **🔵 and ⚪** — apply them and carry on.
- **🔴 and 🟠** — propose the specific correction. Where you have enough context to settle it
  without ambiguity, apply it and **record the assumption in the ledger**, so the user can
  contradict it.

Two rules govern writing here:

- **Do not change the intent, and do not keep quiet about it.** A fix corrects an error; it does
  not redesign. A better road becomes a question, never a silent rewrite.
- **Every change leaves a trace.** Each applied fix carries its reason and the assumptions used
  to settle it into the ledger.

A fix the user turns down is restored to its original text, recorded as `rejected` with the
user's own reason, and never proposed again.

## 8 — Seams, and going round again

**The seams are looked at after the fixes**, never before. On the next iteration, launch fresh
reviewers **only on the groups that moved** — what moves a group, and when a round has no next
iteration, is held by `${CLAUDE_PLUGIN_ROOT}/references/ledger.md`.

Carry on until one of three exits fires:

- **Approved** — no 🔴 and no 🟠 left, **and no question open**: an open question blocks approval
  however clean the rest is.
- **Accepted with reservations** — only 🟡/🔵/⚪ remain and the user accepts them.
- **Waiting on decisions** — the questions are on the table; not a failure, the review's
  product.

The revision iteration cap in `${CLAUDE_PLUGIN_ROOT}/references/limits.md` bounds how many
rounds you take on your own. **Questions do not consume it**, and **when the answers arrive the
counter starts again** on the area they touch.

A partial answer is used for what it says: apply what was decided, leave the rest open, and
declare nothing approved.

## 9 — What comes out

The reviewed specification, plus a short summary: the changes applied, the assumptions made, and
the points deliberately left open with the reason for each.

The ledger stays where it is, as the record of why a finding was turned down and what was assumed
along the way. Whether it gets committed is the project's call.
