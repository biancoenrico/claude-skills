---
name: code-revision
description: Reviews a batch's code until correct and clean, comments trimmed to size; not a spec or plan review.
when_to_use: A batch's diff needs checking before the next starts. Triggers - "review what was written", "check and clean up the changes", "run code-review and simplify", "clear out the useless comments", "finished implementing, go over it".
argument-hint: <scope: paths, base..HEAD, a branch or ranges; the plan's batch file; resume state>
effort: high
context: fork
agent: general-purpose
background: false
---

# code-revision

Orchestrates `/code-review`, `/simplify` and `/dev-loop:comment-writing` instead of reinventing
the analysis. Runs **on one batch**, invoked by `/dev-loop:plan-execution` once its tests are
green; scope may carry several ranges when the last batch pays deferred reviews
(`${CLAUDE_PLUGIN_ROOT}/references/deferred-review.md`).

## Step 1 — Determine and declare the scope

Runs in a fork, **not seeing the conversation**: the scope is **spelled out in the arguments** —
paths, `base..HEAD`, a branch or ranges, plus the plan's batch file.

No arguments: fall back to `git diff HEAD` plus the branch range when an upstream exists. Still
empty: **do not invent a scope** — return `status: question` per
`${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`.

Declare in one line: which files, where from, whether **committed or working tree** (later phases
diff a commit range or `git diff HEAD` accordingly, and with several ranges diff and read every
one together), and — from `${CLAUDE_PLUGIN_ROOT}/scripts/devloop-diffsize` (never
`--with-tests`) — its size against the small batch threshold in
`${CLAUDE_PLUGIN_ROOT}/references/limits.md`:

- **ranges, or `-- <path>...`:** `sh ${CLAUDE_PLUGIN_ROOT}/scripts/devloop-diffsize <range...>
  [-- <path>...]`.
- **a branch:** `sh ${CLAUDE_PLUGIN_ROOT}/scripts/devloop-diffsize $(git merge-base <base>
  <branch>)..<branch>` — never `<branch>..<branch>`, never the whole history.
- **no scope:** sum `sh ${CLAUDE_PLUGIN_ROOT}/scripts/devloop-diffsize` (working tree vs `HEAD`)
  and, with an upstream, `sh ${CLAUDE_PLUGIN_ROOT}/scripts/devloop-diffsize @{upstream}..HEAD`
  (or its resolved name); no upstream, only the first.

Below threshold, `limits.md` folds Phases A and B into one `/code-review` pass — apply what it
returns under both phases' rules (Phase A re-run included), lint/build checked once for both.

## Phase A — Correctness

Run `/code-review` at `medium` (`high` for concurrency, security, money, data-loss paths or
several subsystems; `max` only if the arguments ask); declare the level and why.

Severity: **Critical** (breaks the feature, a regression, a vulnerability, data loss),
**Important** (a real bug, limited impact), **Minor** (marginal, a rare edge).

**Autonomy follows severity:**

- **Critical / Important** — propose the fix; apply at once if obvious and behaviour-preserving
  per the spec or plan, **noting the assumption**; a non-trivial choice (contract, visible
  behaviour, design) needs asking first.
- **Minor** — apply and carry on.
- Contradicts the plan or spec — the user's call: present it against the plan's text, ask which
  wins, never quietly.

Check the code's still valid: `php -l`, `node --check`, a linter, the build.

Re-run `/code-review` **only if this round fixed a Critical or Important**, and **only over what
changed** (untouched lines were already reviewed); only-Minors or none closes Phase A. Rounds are
capped by the correctness round cap in `${CLAUDE_PLUGIN_ROOT}/references/limits.md`. Residual
Minors the user accepts don't block Phase B; record them.

## Phase B — Cleaning

Unless Step 1 folded it into Phase A, once correctness is closed, run `/simplify` over the scope,
applying the returned quality fixes (reuse, simplification, efficiency, altitude) and skipping
ones that change behaviour or fall outside the diff — note skips instead of forcing them.

**Safety rule:** a cleanup touching a point non-trivially (behaviour, not just form) gets a mini
Phase A round before acceptance, counted against the cap; cap spent, skip and note it. Cleaning
must not reintroduce bugs.

**Boundary with `/dev-loop:design-revision`:** Phase B files **inside the diff** only — a
duplication outside it, a switch grown over sprints, a class that knows too much is structure,
not filing: **note** it and leave it to `/dev-loop:design-revision`, run once before closing.

**One pass, not a loop.** `/simplify` nearly always finds more, so "until empty" never converges;
whatever the first pass opens is structure, for `/dev-loop:design-revision`. Re-check lint/build.

## Phase C — Comments

Once correctness and cleaning close, **run `/dev-loop:comment-writing` in review mode** over the
same scope; below threshold, read its `SKILL.md` and follow it inline instead — its questions and
point reached become this skill's own.

**Skip it when the diff, as Phases A and B left it, adds, modifies or falsifies no comment**,
declaring why — a skipped Phase C is closed. Check comments next to changed hunks first: one the
diff falsified still counts.

Its criteria — kept, rewritten, deleted, the proof — live there, not copied here. Hand it
**only comments touched or introduced by the diff** (pre-existing ones are somebody else's code,
except those falsified); the Step 1 constraints (prose language, docblocks, annotations not to
touch); and, per its argument-hint, **the batch file's path**, already in this skill's arguments
— plus this iteration's balance for the comments section.

Its open points (a crutch not trivially extracted) join the final output's, unforced; a
`status: question` from it becomes this skill's own, `state` folded into this skill's Phase C
state. Re-check lint and build after — a malformed docblock breaks the file too.

## Exit conditions

Exit on one of:

- **Approved** — Phase A closed with no Critical/Important left, Phase B closed (folding into A
  below threshold counts), **and** Phase C closed.
- **Accepted with reservations** — only Minors remain and the user accepts them.
- **External block** — a decision surfaces that isn't yours (plan contradiction, design choice,
  missing information): stop, hand the question back.

At the Phase A round cap, a clean last round still closes it; a Critical/Important still open or
unchecked after it hands the question back instead — never drop Phase C for reaching the cap.

## When to ask, and the state it carries

**Questions are the exception, not a stage**: **the code is there**, unlike a spec or plan —
almost every doubt is two greps away, and more than one or two per batch means asking what it
already answers.

Three cases stay: the fix changes visible behaviour; the finding contradicts the spec or plan;
something needed is in no file. There, stop: settling it quietly removes the decision, and the
awareness of it, from the user. It returns `status: question` instead, per
`${CLAUDE_PLUGIN_ROOT}/references/asking.md`.

Its `state` (shape: `${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`) carries **the current
phase (A/B/C), iteration, last code used, correctness rounds spent, findings applied with sha,
findings discarded with reason, and on a Phase C stop, comment-writing's `state` or the point
reached** — without the phase a resume redoes A from a B stop, without the rounds it restarts the
cap, without the shas it can't tell what's already in the branch.

No `Skill`/`Agent` available: runs in the main thread, unchanged.

## The report

One per iteration; include only non-empty sections.

```
## Code revision — iteration N (phase: correctness|cleaning|comments)
Scope: … | Tool: /code-review(effort:X)|/simplify|/dev-loop:comment-writing | State: applied|approved
Problems — Critical N/Important N/Minor N (A) · Fixes N/Skips N (B) · Removed N/Rewritten N/Kept N (C)

Correctness: [BUG-001] title — file:line — problem/impact — fix: applied(how)|proposed
Cleanups (B): [CLN-001] title — file:line — what got cleaner
Comments (C): [CMT-001] removed|rewritten|corrected — file:line — reason
Skips: finding — why: behaviour change|out of scope|false positive|structure→design-revision
```

Sequential codes (`BUG-001`, `CLN-002`, `CMT-003`…) so any item can be cited later. Final output:
same shape, compacted — what A corrected, B cleaned, C's balance, verifications with outcome,
open points for the user.

## Rules of behaviour

- **Don't skip Phase A:** cleaning unverified code is risky.
- **Don't declare it sound without proof.** A phase closes only after its re-runs and a lint/build
  check; no claim without the command's evidence.
- **Don't change the code's intent.** Fixes correct bugs and tidy form, not redesign; a wrong
  design is an open point, not a rewrite.
- **Don't hide a finding under a cleanup.** A masked bug is worse than a visible one.
- **Don't do Phase C from memory.** Criteria live in `/dev-loop:comment-writing`, read (inline,
  below threshold) and followed, never recalled.
- **Trace every intervention:** every fix and skip justified in the report.
- **Respect project constraints:** style, language version, commit conventions, files not to
  touch — read from project instructions first.
