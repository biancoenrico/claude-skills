---
name: plan-revision
description: Reviews an implementation plan until it can be executed, step by step, defect-free.
when_to_use: Reviewing or validating a plan file or batch folder, or checking it is executable. Not a spec review, see /dev-loop:spec-revision.
argument-hint: "[plan path] [spec path]"
---

# plan-revision

Reviews an implementation plan, round after round, until executable top to bottom: no block, no
ambiguity, no broken dependency.

You orchestrate: `dev-loop:reviewer` agents judge, one per batch/group, against its criteria; you
write, main thread.

## 1 — What you receive

Priority: explicit path; folder already cut into batches; last plan-shaped file discussed; text
pasted inline. A reference spec, if given, enables the coverage check. Nothing given: ask, don't
invent.

**On a folder, index per the rule in** `${CLAUDE_PLUGIN_ROOT}/references/plan-folder.md`.

Checks **how the work gets built**; **what** gets built is `/dev-loop:spec-revision`.

## 2 — Frame the plan

Identify **type** (sprint, implementation, migration, rollout, refactor), **granularity** (tasks,
tickets, atomic steps), declared **stack/constraints**, and existing **structure** (phases,
milestones, dependencies).

The framing matters: the same defect weighs differently by type — an ambiguity tolerable in a
sprint plan blocks an atomic-step list followed to the letter.

**Touches a repository → open it.** Duplication can't be judged from the document alone — read
root conventions, keep Grep on shared helpers. Code out of reach: say so; stays uncovered,
approved knowing it, not believing it.

## 3 — A monolithic plan too large to execute

Past the batching threshold (`${CLAUDE_PLUGIN_ROOT}/references/limits.md`), or with no
verifiable point before its end, a single-file plan is not cut up here. **No folder, no batch
files** — raise a finding, send the user to `/dev-loop:plan-batching`; review resumes on the
folder it produces.

A folder already cut into batches is reviewed as it stands, seams included.

## 4 — Cut into groups

Single file under threshold: grouping is yours (signal, cut, entitlements:
`${CLAUDE_PLUGIN_ROOT}/references/large-docs.md`). Folder: already cut, **one batch file is one
group.**

**Under the small document threshold** (`${CLAUDE_PLUGIN_ROOT}/references/limits.md`, batch
files counted together): the whole thing is **one group, folder or not**, with **one reviewer**,
also taking the alternatives pass (step 6); seams and coverage still get their own pass after
fixes, when step 6's condition holds.

## 5 — Open the ledger

Location, contents, conflicts, who writes it: `${CLAUDE_PLUGIN_ROOT}/references/ledger.md`.

## 6 — Fan out to the reviewers

One `dev-loop:reviewer` per batch or group, in parallel, plus one for the alternatives. Each
gets its criteria file (full path,
`${CLAUDE_PLUGIN_ROOT}/skills/plan-revision/criteria.md`), its object — batch or task range —
the reference spec and ledger, where they exist.

The alternatives reviewer also gets `${CLAUDE_PLUGIN_ROOT}/references/alternatives.md`, judging
load-bearing decisions, not one group; when it reruns: `${CLAUDE_PLUGIN_ROOT}/references/ledger.md`.
Under the small document threshold the single reviewer gets both criteria.md and alternatives.md,
under the same rerun rule.

Agents-per-wave cap: `${CLAUDE_PLUGIN_ROOT}/references/limits.md`; beyond it, more waves. Returns,
and what to do when none comes: `${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`.

**After the fixes**, one more reviewer checks seams and spec coverage — never before, fixes move
seams. Only with **two batch files or more** or **a reference spec**; neither: no seam, nothing
to cover.

## 7 — Questions

Sort before reaching the user: closes by reading, by searching, or is genuinely the user's —
four-line shape for each: `${CLAUDE_PLUGIN_ROOT}/references/asking.md`.

Close the first two yourself — `Explore`, `model: haiku`, for quick lookups — citing what settled
them. Collect the rest into one block.

## 8 — Fixes, iteration, and the way out

No `Edit`/`Write` for reviewers: fixes are yours. 🔵 apply and move on; 🔴/🟠 get a concrete
proposal — reordered sequence, missing task placed, mitigation step — applied at once if obvious
and unchanged in approach, else shown first.

**Preserve intent**: reorganise and clarify, never redesign. A doubted approach is a question
with its options and cost, never a quiet rewrite. Added tasks carry their reason into the ledger.

A rejected fix reverts to its text, recorded `rejected` with the user's reason, and returns
only as `${CLAUDE_PLUGIN_ROOT}/references/ledger.md` allows.

Next round's reviewers go **only to groups that moved**
(`${CLAUDE_PLUGIN_ROOT}/references/ledger.md`: what moves one, when a round has none). One of
three exits:

- **Approved** — no 🔴/🟠, **no open question**: one left open while declaring the plan ready
  only moves the stop along, where the answer also undoes code built on a wrong assumption.
- **Accepted with reservations** — only 🟡/🔵 remain, user accepts.
- **Waiting on decisions** — questions on the table, at the cheapest point an answer could
  arrive.

Revision iteration cap: `${CLAUDE_PLUGIN_ROOT}/references/limits.md` bounds unaided rounds.
What consumes it: `${CLAUDE_PLUGIN_ROOT}/references/ledger.md`, "What the counter counts". A
partial answer applies what's decided, leaves the rest open, approves nothing.

**Output:** reviewed plan plus a summary — changes applied, tasks added with reasons,
assumptions, accepted risks, open points. Ledger stays; committing it is the project's call.
