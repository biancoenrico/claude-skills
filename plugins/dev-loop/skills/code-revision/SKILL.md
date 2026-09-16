---
name: code-revision
description: Reviews the code of one batch until it is at once correct and clean, with /code-review for correctness bugs, then one /simplify pass for reuse, simplification, efficiency and altitude, and finally handing the comments to /dev-loop:comment-writing. It verifies code already written; it does not review a spec or a plan.
when_to_use: A batch has just been implemented and its diff needs checking before the next one starts. Triggers - "review what was written", "check and clean up the changes", "run code-review and simplify", "clear out the useless comments", "I have finished implementing, go over it".
argument-hint: <scope - paths, base..HEAD, a branch or a range; plus the batch file of the plan and any state from an earlier run>
effort: high
context: fork
agent: general-purpose
background: false
---

# code-revision

Reviews the code of a batch until it is at once **correct** (no bugs) and **clean** (no avoidable
duplication, complexity or waste), with its comments cut back to the ones that earn their place.

It runs **on one batch**, not on a whole branch, and it is invoked by `/dev-loop:plan-execution`
once the batch's tests are green.

Three categories of problem escape whoever has just written the code: the **bugs** (unhandled edge
cases, null dereferences, off-by-one, regressions), the **quality defects** (logic duplicated in
three places, derivable state, fragile special cases) and the **wrong or superfluous comments**
(paraphrases of the code, working notes, explanations that have become false). Finding them now,
while the diff is small and fresh, costs a fraction of finding them in production or in somebody
else's review.

This skill does not reinvent the analysis: it orchestrates the tools that already exist —
`/code-review` for correctness, `/simplify` for quality, `/dev-loop:comment-writing` for the
comments.

## Step 1 — Determine and declare the scope

This skill runs in a fork: **it does not see the conversation**. The scope arrives **spelled out in
the arguments** — paths, `base..HEAD`, a branch or a range, plus the batch file of the plan.

With no arguments, fall back to `git diff HEAD` plus the branch range when an upstream exists. If
that too is empty, **do not invent a scope**: return `status: question` in the shape held by
`${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`.

Fix the diff under review and declare it in one line: which files, how many lines, where they come
from. Note also whether the changes are **committed or in the working tree**: it changes how the
diffs for the later phases are generated (a range of commits versus `git diff HEAD`).

Declare its size in that same line, against the small batch threshold in
`${CLAUDE_PLUGIN_ROOT}/references/limits.md`. Below it, Phases A and B become **one** `/code-review`
pass at the level Phase A picks: apply what it returns under the rules of both phases, the Phase A
re-run included, and check lint and build once for both.

## The order of the phases: correct first, then clean, comments last

The order is not arbitrary. You hunt the **bug first** and clean up **afterwards** because there is
no sense investing in tidying code that a bugfix might rewrite: you would file it twice. And because
a correctness fix sometimes introduces duplication or complexity that the cleaning phase then
absorbs. The **comments come last** for the same reason squared: a comment describes one specific
piece of code, so for as long as that code can still change — for a fix or for a cleanup — any work
on the comments is provisional. Worse, a cleanup that moves or extracts code leaves behind comments
describing a version that no longer exists.

1. **Phase A — Correctness:** `/code-review`, re-run only while its fixes need checking.
2. **Phase B — Cleaning:** one `/simplify` pass.
3. **Phase C — Comments:** one final pass, delegated to `/dev-loop:comment-writing`.

Cleaning touches code already verified correct: if a cleanup changes behaviour in a non-trivial
way, go briefly back to Phase A on that point.

## Phase A — Correctness

Run `/code-review` over the scope at `medium`. Raise it to `high` only for concurrency, security,
money or data-loss paths, or a diff spanning several subsystems; `max` only when the arguments ask for it.
Declare the level chosen and why.

Classify the findings that come back by severity:

- **Critical** — breaks the feature, introduces a regression, a vulnerability, data loss.
- **Important** — a real bug to be corrected, with circumscribed impact.
- **Minor** — a marginal correctness defect or a rare edge.

**The degree of autonomy follows the severity**, because fixing a null check and changing the
semantics of a method do not deserve the same level of confirmation:

- **Critical / Important** — propose the concrete correction. Apply it straight away if it is
  obvious and does not change the behaviour the spec or the plan expects; **note the assumption
  made**. If the fix introduces a non-trivial choice (it changes a contract, a visible behaviour, a
  design decision), ask before applying it.
- **Minor** — apply it directly and carry on.
- A finding that **contradicts what the plan or the spec requires** is a decision for the user:
  present the finding next to the text of the plan and ask which one wins. Do not settle it quietly
  one way or the other.

After the fixes, check the code is still valid with the project's tools (`php -l`, `node --check`, a
linter, the build) before going on.

Re-run `/code-review` **only if this round applied a Critical or Important fix**, and **only over
what the fixes changed** rather than the whole scope: a fix can introduce a problem, but the lines
it did not touch were already reviewed. A round that applied only Minors, or nothing, closes Phase
A. The rounds are capped by the correctness round cap in
`${CLAUDE_PLUGIN_ROOT}/references/limits.md`. Residual Minors the user chooses to accept do not
block Phase B; record them.

## Phase B — Cleaning

Unless Step 1 folded this phase into Phase A, and only once correctness is closed, run `/simplify`
over the scope. Apply the quality fixes it returns
(reuse, simplification, efficiency, altitude), skipping the ones that would change behaviour or that
fall outside the diff under review — note the skips instead of forcing them.

Safety rule: if a cleanup touches a point non-trivially (it changes behaviour, not only form),
**revalidate it with a mini round of Phase A** on that point before accepting it. That round counts
against the correctness round cap; with the cap spent, skip the cleanup and note it. Cleaning must
not reintroduce bugs.

**The boundary with `/dev-loop:design-revision`:** Phase B files **inside the diff**. A duplication
that runs outside the diff, a switch that has been growing for three sprints, a class that knows too
much — those are structure, not filing: they are **noted** in the report and left to
`/dev-loop:design-revision`, which runs once before the branch is closed. Chasing them here inflates
the batch and settles them on a sample too small to decide from.

**One pass, not a loop.** `/simplify` nearly always finds something more, so "until it runs empty"
does not converge; a cleanup that the first pass opened is structure and belongs to
`/dev-loop:design-revision`. Re-check lint and build.

## Phase C — Comments

Once correctness and cleaning are closed, the code has its final shape: only now does looking at its
comments make sense. **Run `/dev-loop:comment-writing` in review mode** over the same scope.

**Skip it when the diff, as Phases A and B left it, adds, modifies or makes false no comment**, and
declare the reason in the report: a skipped Phase C is closed. Before declaring none, look at the
comments next to the changed hunks — a comment the diff has made false still counts.

The criteria — what is kept, what is rewritten, what is deleted, the cutting proof — live there and
**are not copied here**: two copies would diverge the first time somebody touched one. This phase
does three things:

- hand the skill the right scope: **only the comments touched or introduced by the diff** (the
  pre-existing ones are somebody else's code, out of review — except those the diff has made false);
- hand it the project constraints read in Step 1 (language of the prose, docblocks imposed by the
  conventions, active annotations not to be touched) **and the path of the batch file**, which this
  skill already has in its arguments. Without it that skill cannot find the index of the plan, and
  the degradation it declares for that case becomes the normal, silent case;
- carry its balance into the comments section of this iteration's report.

If it returns open points (typically a crutch that ought to be extracted, but not trivially), do not
force them here: they end up among the open points of the final output.

After the changes, re-check lint and build: Phase C touches only comments, but a malformed docblock
or a broken delimiter breaks the file all the same.

## Exit conditions

Exit when one of these fires:

- **Approved** — Phase A is closed with no Critical or Important left, Phase B is closed — folded
  into Phase A below the small batch threshold counts — **and** Phase C is closed.
- **Accepted with reservations** — only Minors remain, and the user chooses to accept them.
- **External block** — a problem emerges that needs a decision which is not yours (a contradiction
  with the plan, a design choice, missing external information): stop and hand the question back.

At the cap on Phase A rounds (see Phase A), a clean last round closes Phase A like any other. Only
when the last allowed round leaves a Critical or Important fix open or unchecked, consolidate the
state and hand the question back. Never drop Phase C in silence because the cap was reached.

## When it is time to ask, and the state that goes with it

**Questions are the exception, not a stage.** Unlike a spec or a plan, **the code is there**: almost
every doubt already has an answer two greps away, and going to read it is the work. If you are
asking more than one or two on a batch, you are almost certainly asking things the code answers on
its own.

Three cases stay: the fix changes a visible behaviour; the finding contradicts the spec or the plan;
something is needed that no file contains. There, stopping is right — settling it quietly takes the
decision away from the user **and** the awareness of having taken it. The form of the question is
held by `${CLAUDE_PLUGIN_ROOT}/references/asking.md`.

A forked skill cannot ask the user: it returns `status: question`. When it does, the `state` field
carries **the current phase (A, B or C), the current iteration and the last code used, the
correctness rounds already spent, the findings already applied with their sha, and the findings
already discarded with the reason**. The phase is not a
detail: without it, a stop halfway through Phase B makes the resume redo the whole of Phase A;
without the rounds spent, the resume starts the cap afresh; and without the shas of what was
applied, the resume does not know what is already in the branch.
The shape of the return is held by `${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`.

If `Skill` or `Agent` are not available, this skill runs in the main thread with no other
difference.

## The report

One per iteration — a `/code-review` round, the `/simplify` pass or the comment pass — so the rounds
can be compared at a glance. Include only the sections with at
least one item.

```
## Code revision — iteration N (phase: correctness | cleaning | comments)

**Scope:** [files / range / working tree]
**Tool:** /code-review (effort: X) | /simplify | /dev-loop:comment-writing
**State:** changes applied | approved

### Problems found: X
- Critical: N   Important: N   Minor: N          (phase A)
- Quality fixes applied: N   Skips: N            (phase B)
- Comments removed: N   Rewritten: N   Kept: N   (phase C)

### Correctness findings
**[BUG-001]** [short title] — file:line
- **Problem:** … **Impact:** what breaks, and when
- **Fix:** [applied, and how | proposed, awaiting confirmation]

### Quality cleanups (phase B)
**[CLN-001]** [title] — file:line — [what was made cleaner]

### Comment work (phase C)
**[CMT-001]** [removed | rewritten | corrected] — file:line — **Reason:** …

### Skips, with the reason
- [finding not applied, and why: changes behaviour / out of scope / false positive / structure,
  left to design-revision]
```

Use sequential codes (`BUG-001`, `CLN-002`, `CMT-003`…) so every item can be cited in later
iterations.

The final output is the same shape, compacted: what was corrected in Phase A, what was cleaned in
Phase B, the balance of Phase C, the verifications run with their outcome, and the open points left
to the user.

## Rules of behaviour

These exist because the main risk of an automated review is making the code worse: declaring it
sound when it is not, or filing it until it loses its shape.

- **Do not skip Phase A.** Cleaning code not yet verified correct is work at risk.
- **Do not declare it sound without proof.** A phase closes only after any re-run the procedure calls
  for and after checking lint and build. No success claim without the evidence of
  the command run.
- **Do not change the intent of the code.** Fixes correct bugs and tidy form; they do not redesign
  the feature. If you think the design is wrong, say so as an open point.
- **Do not hide a finding under a cleanup.** A bug masked by a simplification is worse than a
  visible bug. Keep them apart: correct first, clean after.
- **Do not do Phase C by hand.** The criteria for comments live in `/dev-loop:comment-writing`;
  redoing them from memory here applies an old version of them. That holds even when the comments
  touched are two.
- **Trace every intervention.** Every fix and every skip is justified in the report.
- **Respect the project's constraints.** Style, language version, commit conventions, files not to
  be touched: read them from the project's instructions before applying a fix.
