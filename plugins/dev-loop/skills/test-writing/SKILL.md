---
name: test-writing
description: Decides what deserves a test and writes it, or judges whether existing tests prove anything, then proves every test can go red by mutation.
when_to_use: Writing or completing tests for a target, or auditing an inherited suite. Triggers: "write the tests for X", "cover this module", "clean up the tests". Not for hunting production bugs.
argument-hint: <targets: paths, a class, or base..HEAD; plus batch file, calibration, prior state>
effort: high
context: fork
agent: general-purpose
background: false
---

# test-writing

Writes the tests for a piece of code. The real work is deciding **which**, discarding what looks
like a test and is not — it hides a gap and costs upkeep every refactor.

Hence the order: **decide what to cover and write it down; write the code; then prove every test
can fail.**

Invoked by `/dev-loop:plan-execution` and the bounded path, next `/dev-loop:code-revision`; and by
`/dev-loop:design-revision` when a zone about to move has no net, next the refactor. **On
a small bounded diff the main thread follows this file inline** instead of forking: scope is
`base..HEAD`; calibration comes from the branch worklog; `status: question` or hand-back is a user
question per `${CLAUDE_PLUGIN_ROOT}/references/asking.md`; `state` goes into the worklog;
production stays untouched though the main thread owns it; the report keeps every section with
content.

## Step 0 — The scope

Forked, this skill **does not see the conversation**: the scope is **spelled out in the
arguments** — paths, `base..HEAD`, targets, the batch file.

With none, fall back to `git diff HEAD` plus the branch range if an upstream exists. Still empty ⇒
**do not invent a scope**: return `status: question` (shape of
`${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`), asking what to cover.

## Step 0b — Repair before mutation

`test_targets` — tests broken by a deliberate change — get repaired **before any other work or
mutation**: mutating against red means nothing. Repair touches **tests only**; production-code red
gets declared and handed back, not modified.

**Deleting a test is not repairing it**: delete one **only** when the batch file declares the
behaviour removed, else return `status: question` with the test in `state`. No batch file path, no
authorisation.

## The principle

For every test about to be written: if it failed, would the bug go against this repository or
against the platform? Against the platform, delete the line. The question, its rationale and the
shapes it catches: `${CLAUDE_PLUGIN_ROOT}/skills/test-writing/catalog.md`.

## Step 1 — Calibrate on the project

**Gather in few calls**: manifest, runner config, test tree and a neighbouring test in one
composed command; the Step 2 unit the same way.

**A calibration in the arguments is taken as given** — check its filtered command is green, read
the neighbouring test it names, go to Step 2. Without one, **assume nothing**, and state in two
lines:

1. **Language, version, syntax** from the manifest — a low minimum forbids modern syntax.
2. **The runner and its filter** — Step 6 needs it.
3. **Where the tests live**, and their correspondence to the code.
4. **House conventions read off existing tests** — naming, setup, isolation, doubles, assertions.
   **A test clashing with its neighbours is badly written even if faultless.**
5. **The project's own instructions** (`CLAUDE.md`/`AGENTS.md`/`CONTRIBUTING`) win over general
   practice.
6. **The platform boundary**: manifest dependencies are what does **not** get tested.

With no tests yet, take conventions from the ecosystem — **search, don't recall** — and declare
you are founding the convention.

## Step 2 — Isolate the unit and its seams

Draw the boundary **before reading in depth**, or you end up testing half the system:

- **The public surface**: what a caller can reach; private methods are exercised through it, never
  head-on.
- **The collaborators**: **real or double?** The criterion is not convenience — it is **what
  happens if you leave it real**. Double whatever leaves the process or its control (network,
  clock, randomness, filesystem, queues, external services); else stays real, or the double just
  proves it obeys you.
- **The seams**, where a collaborator can be substituted without rewriting the unit.
  **Introducing one is a production change this skill does not make** — hand it back as a
  question.
- **The starting state** the unit needs to run: reuse the project's data builders, never parallel
  ones.

The product is **the list of boundaries**, not a test.

## Step 3 — What deserves a test

**The step that gets skipped.** Produce two lists; if the batch file
lists what its tasks are verified by, start there: bind each entry to its line, add what the code
needs beyond it, and report the changes.

**To cover** — one behaviour per line: the **case** in one sentence, the **line or rule** that
decides it, **what breaks** if it changes silently. Look for the **branches** (the case that fires each **and** the
one that does not — a lone negative assertion stays green even without the branch); the
**boundaries** (first, empty, absent, on threshold, duplicate); the **domain invariants** no
schema knows about; what the code **rejects**, with which message when it is a contract; the
**effects** that are not the return value.

**Not to cover** — go through `${CLAUDE_PLUGIN_ROOT}/skills/test-writing/catalog.md` **entry by
entry, not from memory**, plus what's covered elsewhere (say *where*); an empty list usually means
this step was skipped.

**Done when** both lists exist and every "to cover" entry names the line or rule it pins down.
Ambiguous behaviours or a seam get asked **now**, not after tests exist.

**If this skill stops (`status: question`), the two lists go into `state`** — a resumed invocation
restarts from them and the commits already made.

## Step 4 — Choose the structure

With the list in hand the shape almost follows:

- **One test per behaviour, not per method**, named for it in **the language of the domain** — it
  must **promise exactly what the body does**, or it hides a gap behind a name that looks like
  coverage.
- **Identical-form, different-data cases ⇒ a table**, in the runner's own mechanism, **plus a
  completeness check** that fails when a case is missing — enumerated by reflection or over the
  type, else case N+1 stays uncovered until remembered.
- **Arrange — act — assert**, separate and visible; one action per test.
- **Assert the axis, not the world**: twenty fields for one axis fail for reasons beside the
  point.
- **Assert a value, not a shape**: a shape passes even when production **exits politely** instead
  (fallback, empty list, zero) — only a value existing *iff* the right branch ran will notice.
- **No dependency on order**, no state surviving between tests: repeating one test in isolation has
  to give the same outcome; **determinism** — time, randomness, generated identifiers pinned or
  declared volatile.
- **Fixtures built by composition**, not a copied forty-field literal.

Governing all: **if the project does otherwise and it works, do it that way** — good practice is
only for where there is no precedent.

## Step 5 — Write

One block at a time, per the Step 3 list, within Step 1's constraints. A behaviour found while
writing is **added to the list** and declared, not slipped in.

Name and comment say the behaviour, not the occasion, and carry no run's outcome:
`${CLAUDE_PLUGIN_ROOT}/skills/test-writing/catalog.md` §7.

**The comment explains, it does not point**: no line numbers, paths, or method names — the test's
name says that. Unexplainable without pointing at code ⇒ wrong or unnecessary.

Testability that needs a production-code change means **stop and ask**: not a detail of writing
tests. A red test against production is read, never silenced by editing production. Check the
suite green with the project's tools before Step 6.

## Step 6 — Prove them red

A freshly green test proves only that it passes — **for the right reason** only if seen to fail.
The mutation's own safety (copy, restore, one at a time, a clean tree at the end) is the script's
job. What stays with you:

- **Choose the case so the mutation crosses it** (the list/branch criterion is worked out in full
  in `${CLAUDE_PLUGIN_ROOT}/skills/test-writing/audit.md`).
- **Filter to the target test file**: every mutation reruns it; check it's green unmutated first.

One mutation per call:

```sh
sh ${CLAUDE_PLUGIN_ROOT}/scripts/devloop-mutate <file> <find> <replace> -- <filtered test command>
```

Break the line's **meaning**, not its syntax: a parse error fails everything and proves nothing.
Every exit code's behaviour — including the one that stops this skill and how to read the output
tail — is tabulated in `${CLAUDE_PLUGIN_ROOT}/skills/test-writing/audit.md`.

**`state` covers this step too**: an interruption can land mid-mutation with the commits silent on
which passed. Into it go the mutations tried with their outcome, plus, after an exit 4 (the one that
leaves the file mutated, see `audit.md`), "tree dirty from mutation, see marker" — without them a resume redoes everything blind.

If the suite is not runnable, Step 6 **is not done**: declare it, say the tests were not seen to
fail. Do not fake the proof.

## Audit mode

Criteria: `${CLAUDE_PLUGIN_ROOT}/skills/test-writing/audit.md`. Launches **one `dev-loop:reviewer`
per test file** on the reading checks, handing it `catalog.md` and `audit.md` per
`agents/reviewer.md`, fanning out in waves up to the agents-per-wave cap in
`${CLAUDE_PLUGIN_ROOT}/references/limits.md`; once back, runs the mutation check on the candidates left standing after the reading checks;
carries any question per `${CLAUDE_PLUGIN_ROOT}/references/asking.md`.

## When to ask

**Questions are the exception**: most doubts have an answer two greps away. Three remain:
testability needs **modifying production code** (executor or main thread, never this skill); the
behaviour is **ambiguous** and the code does not say; a "to cover" entry costs disproportionately
and must be **decided**, not endured. Form: `${CLAUDE_PLUGIN_ROOT}/references/asking.md`.

## The return

Shape: `${CLAUDE_PLUGIN_ROOT}/references/agent-return.md` (`findings`/`commits`, plus `state` on
`status: question`). The
report, compactly:

```
### Calibration
Language/version · runner and filter pattern · where the tests live · neighbouring test file · comment language · instruction files read

### Covered: N
| behaviour | line/rule that decides it | seen red |

### Deliberately not covered: N
| what | why: platform / harness / already covered by <where> |

### Changed from the plan
<entries added, dropped, reworded>

### Gaps found while writing
<lines no test intercepts, found by mutation: the most valuable result>

### Verifications
Suite: <outcome>. Mutations run, and any declared not run, with their exit.

### Open points
<decisions left to the user>
```

**Report negative results** too: six lines mutated and caught is worth as much as a test written.
**No coverage percentage**: it counts lines executed, not behaviours pinned down.
