---
name: plan-revision
description: Iteratively reviews an implementation plan — sprint, migration, rollout, refactor — until it can be executed step by step: no broken dependency, no unexecutable step, no coverage gap, no unmitigated risk, no duplication it is about to have rewritten.
when_to_use: Whenever there is a plan to review, validate or make executable — "review this plan", "check the order of the steps", "is this plan executable as it stands?" — or a plan file or a folder of batch files is handed over. Not for reviewing a specification, which is /dev-loop:spec-revision.
argument-hint: "[path to the plan file or folder] [path to the reference spec]"
effort: xhigh
---

# plan-revision

Review an implementation plan, round after round, until it can be executed top to bottom without
a block, an ambiguity or a broken dependency.

The point is not to judge *whether* something should be built — a specification review does that
— but to guarantee that whoever picks the plan up can walk it without stopping to ask "and how is
this done?", or discovering that step 5 needed something created only at step 9. A plan with its
steps in the wrong order is worse than no plan, because it gives a false sense of readiness.

You orchestrate. The judging is done by `dev-loop:reviewer` agents, one per batch or group,
against the criteria file this skill owns; the writing is done here, on the main thread.

## 1 — What you receive

In order of priority: an explicit path; a folder, when the plan is already cut into batch files;
the last plan-shaped file discussed in the conversation; the text pasted inline. A reference
specification may come with it, and it is what enables the coverage check. If nothing at all is
there, ask the user where the plan is rather than inventing one.

**On a folder, pick the index by the rule** in
`${CLAUDE_PLUGIN_ROOT}/references/plan-folder.md`: which file counts as the index of a numbered
folder, which one wins when there are several, and when the choice has to be declared in the
report. That rule is what keeps folders written before this plugin readable. Nothing else from
that file concerns this skill.

This skill checks **how the work gets built**. Checking **what has to be built** is
`/dev-loop:spec-revision`.

## 2 — Frame the plan

Identify the **type** (sprint plan, implementation plan, migration, rollout, refactor), the
**granularity** (high-level tasks, detailed tickets, atomic steps), the **stack and constraints**
declared, and the **structure** already in place (phases, milestones, stated dependencies).

The framing matters because the same defect weighs differently by type: an ambiguity that is
tolerable in a high-level sprint plan blocks a list of atomic steps somebody will follow to the
letter.

**If the plan touches a repository, open it.** Announced duplication cannot be judged from the
document alone — it asks what the project already has. Read the conventions kept at the
repository root and keep Grep within reach over the shared helpers. If the code is out of reach,
say so: that dimension stays uncovered, and the plan is reviewed knowing it rather than believing
it approved.

## 3 — A monolithic plan too large to execute

A single-file plan past the batching threshold in
`${CLAUDE_PLUGIN_ROOT}/references/limits.md` — read the value there — or with no verifiable point
before its end, is not something this skill cuts up. **Do not create a folder and do not write
batch files.** Raise it as a finding and send the user to `/dev-loop:plan-batching`, which owns
the shape of a plan. The review resumes on the folder that comes out of it.

A folder already cut into batches is reviewed here as it stands, seams included.

## 4 — Cut into groups

On a single file under the threshold, the grouping is yours to make, and the signal that says one
pass is not enough, the way the cut is made and what each group is entitled to are held by
`${CLAUDE_PLUGIN_ROOT}/references/large-docs.md`.

On a folder the cut is already made: **one batch file is one group.**

**A plan under the small document threshold** in `${CLAUDE_PLUGIN_ROOT}/references/limits.md` —
read the value there, counting every batch file of a folder together — is **one group**, folder
or not, and gets **one reviewer**, which also takes the alternatives pass (step 6). The seams and
the coverage still get their own pass after the fixes, under the rule in step 6.

## 5 — Open the ledger

The review keeps its record beside the object, and where it sits depends on the shape: a single
file gets `<name>.review.md` next to it; a folder gets one `review.md` inside it, shared by every
batch. The rest — what it records, and what to do when a file is already at that path — is held
by `${CLAUDE_PLUGIN_ROOT}/references/ledger.md`.

**Only this thread writes it.** Reviewers return findings; the rows, the IDs and the states are
yours.

## 6 — Fan out to the reviewers

One `dev-loop:reviewer` per batch, or per group, launched in parallel, plus one dedicated
reviewer for the alternatives.

Every reviewer receives:

- the path of its criteria file, `${CLAUDE_PLUGIN_ROOT}/skills/plan-revision/criteria.md`, in the
  full form the agent itself requires — the reason a relative path is refused lives there and is
  not restated here;
- the object it judges — its batch file, or its range of tasks;
- the reference specification, where one exists;
- the ledger, when one exists.

The alternatives reviewer receives `${CLAUDE_PLUGIN_ROOT}/references/alternatives.md` on top, and
judges the load-bearing construction decisions rather than one group. Under the small document
threshold there is no separate one: the single reviewer receives both files.

When the alternatives pass runs again, and which fixes start a next iteration, are held by
`${CLAUDE_PLUGIN_ROOT}/references/ledger.md`; the single reviewer follows the same rules.

How many may run at once is the agents-per-wave cap in
`${CLAUDE_PLUGIN_ROOT}/references/limits.md`; beyond it, fan out in waves. What comes back, and
what to do when nothing does, are held by
`${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`.

**After the fixes**, one more reviewer on the seams and on coverage against the specification —
not before, because the fixes move the seams. It runs only when there is something for it to
judge: **two batch files or more**, or **a reference specification**. A single file with no
specification has no seam and nothing to cover.

## 7 — Questions

Sort what comes back before any of it reaches the user: which questions close by reading, which
close by searching, which are genuinely the user's, and the four blunt lines each one takes are
held by `${CLAUDE_PLUGIN_ROOT}/references/asking.md`.

Close the first two kinds yourself — `Explore` with `model: haiku` for the quick lookups — and
cite what settled them. Collect the rest and put them in one block.

## 8 — Fixes, iteration, and the way out

Reviewers have no `Edit` and no `Write`: the fixes are yours. 🔵 findings you apply and move on.
🔴 and 🟠 get a concrete proposal — the reordered sequence, the missing task placed where it
belongs, the mitigation step — applied straight away when the fix is obvious and does not change
the approach, and shown first when it introduces a choice that is not trivial.

**Preserve the original intent.** Reorganise and clarify; do not redesign the approach. An
approach you think does not hold becomes a question with its options and their cost, never a
rewrite made quietly. Every task you add carries its reason into the ledger, so the user can see
why it appeared.

A fix the user turns down goes back to the text it had, is recorded as `rejected` with the user's
own reason, and does not come back.

Fresh reviewers on the next round go **only to the groups that moved**; what moves a group, and
when a round has no next one, is held by `${CLAUDE_PLUGIN_ROOT}/references/ledger.md`. Carry on
until one of three exits fires:

- **Approved** — nothing 🔴 or 🟠 left, **and no question open**. An open question is the exact
  point at which execution will stop; declaring the plan ready does not remove it, it moves it
  further along, where answering also means undoing code written on the wrong assumption.
- **Accepted with reservations** — only 🟡/🔵 remain and the user chooses to accept them.
- **Waiting on decisions** — the questions are on the table, at the cheapest moment those answers
  could possibly arrive.

How many rounds you may take unaided is the revision iteration cap in
`${CLAUDE_PLUGIN_ROOT}/references/limits.md` — read it there, do not write the number here. Two
rules give the budget its meaning: **questions do not consume it**, since a round spent asking
brings in information that was not there before; and **when the answers arrive the counter
restarts** on the area they touch. A partial answer is used for what it says: apply what was
decided, leave the rest open, declare nothing approved.

**What comes out:** the reviewed plan, plus a short summary — the changes applied, the tasks
added with the reason for each, the assumptions made, the residual risks knowingly accepted, and
the points left open. The ledger stays where it is; whether it gets committed is the project's
call.
