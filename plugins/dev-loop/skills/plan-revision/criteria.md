# Criteria for reviewing an implementation plan

The yardstick a reviewer applies to its slice of the plan. Nothing here says what to launch or
when — this file is judgement, only judgement.

## What you judge, and what you hand back

You judge the group you were pointed at — batch file, task range, or the whole plan in one pass.
Changing nothing and pasting nothing back is `dev-loop:reviewer`'s own rule
(`${CLAUDE_PLUGIN_ROOT}/agents/reviewer.md`); describe the remedy in the finding instead of
editing.

Return shape: `${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`, `findings` in the format set
out below.

## The decisions still to be taken

A plan stalls when **whoever executes it meets a choice nobody made** — a fork the document
leaves uncovered, not a technical obstacle. Unstopped, somebody chooses alone, in a hurry, and it
sticks.

**For every task**, ask: *what will whoever executes this have to decide?* Check each decision
is already taken — spec, plan, or project conventions. Ones that aren't become findings now, not
stops later.

Where they hide:

- **Verbs with no object.** "Handle the errors", "validate the input", "update the interface"
  each hide a decision as a chore: *which* errors, shown how? *Which* rules, and what happens to
  whoever breaks them?
- **Behaviour at the boundaries**, where the specification has not already fixed it: the first
  element, the empty list, the value exactly equal to the threshold.
- **Collisions between tasks.** Two tasks touch the same file or state: which wins, in what
  order? Unsaid, whoever arrives second decides, reading code they did not write.
- **Criteria of doneness.** A task with no verifiable "done" forces whoever executes it to invent
  one, and nobody will know if it was right. A check on the finished text or code is the
  exception — it belongs in the index's end-of-batch criteria
  (`${CLAUDE_PLUGIN_ROOT}/references/plan-folder.md`), not the task.
- **Technical choices left to the executor** — which library, which data structure, where the
  new file goes. Some are harmless and stay open, but ones the project has already settled
  elsewhere get **named**, not rediscovered.

**The target isn't "never stop"** — impossible, something always turns up while writing. Stop
**only** for what nobody could have known beforehand, never for a decision that sat there
waiting for weeks.

## The seven dimensions

Ordered by severity: the 🔴 groups block execution, the 🟡 and 🔵 ones only slow it down.

### 🔴 Sequence and dependency errors

**Never skip the dependencies** — a finding here outranks everything else in the report.

Step B depending on step A, with A after B; tasks assuming components nobody has created yet;
circular dependencies; prerequisites or setup the work needs that the plan omits.

### 🔴 Steps that cannot be executed

Descriptions too vague to start without further clarification; steps needing a decision nobody
has taken; actions depending on external information the plan never references.

### 🟠 Coverage gaps

Specification requirements, where available, with no task against them; testing, validation or
rollback left unplanned; a task adding logic with no verifying behaviour, or an untested
behaviour with no reason given; missing data migration, environment configuration or deployment;
technical documentation not scheduled.

### 🟠 Unmitigated risks

High-risk steps with no fallback; destructive operations (delete, migration, schema change) with
no backup and no way back; dependencies on external systems with no contingency.

### 🟠 Announced duplication

**The one dimension you can't judge by reading: open the code.** The other six look inside the
document; duplication looks at what the plan is about to rewrite from scratch — the repository
has the answer.

- **A rule with several readers and no owner** — two-plus tasks need the same judgement,
  derivation or formatting, with no declared **owner**: the first task writes it, the second
  copies it, and the day it changes, one copy stays behind.
- **A helper that already exists.** A task introduces a formatting, a conversion, a component or
  a utility the project already has in house. Grep for it in the shared helpers and in the files
  adjacent to the area being touched.
- **A special case on top of a shared mechanism.** The plan adds a dedicated branch where the
  existing mechanism should have been generalised. It costs little now and costs again at every
  case that follows.

**Name the symbol, per the `DUP-` template below, or the finding gets deleted** — unnamed, it
isn't actionable. The cost isn't aesthetic: **copies diverge**, and the divergence is the defect.

### 🟡 Scope and estimate

Steps too wide for a single unit of work; completion criteria that cannot be verified; a
single-file plan too large for one go, or with no verifiable point before the end — the finding
isn't length, it's that nobody can say they're halfway; long plans with no intermediate review
checkpoint — one pass over thousands of lines finds less than several short ones, since findings
then get carried back onto code later tasks already wrote over.

### 🔵 Clarity and format

Ambiguous or non-self-explanatory titles; owners and responsibilities unassigned, where that
applies; inconsistent format between comparable tasks.

## Seam criteria for a plan folder

On a folder, the seam pass follows the general method in
`${CLAUDE_PLUGIN_ROOT}/references/large-docs.md`, and that file's file-to-file checks (index
tells the truth, nothing shared outside it, each batch closes alone, foundations come first)
apply here as written, batch file for file.

## Coverage against the specification

Where a spec is available, every requirement has at least one corresponding task; requirements
with none are reported as `GAP-SPEC-…`. This check catches a plan that is internally coherent yet
incomplete against what it was meant to deliver.

## The shape of a finding

Running codes per prefix, quotable across iterations: `SEQ-`, `EXEC-`, `GAP-`, `RISK-`, `DUP-`,
`SCOPE-`, `FMT-`, and `GAP-SPEC-` for an uncovered requirement.

```
[SEQ-001] <short title>
- Steps involved: step X, step Y
- Problem: <the broken dependency, precisely>
- Impact: <effect of the current order>
- Suggested fix: <right order, or restructuring>

[EXEC-001] <short title>
- Step: <reference>
- Problem: <why it can't execute as-is>
- Suggested fix: <what makes it executable>

[GAP-001] <short title>
- Missing area: <testing / rollback / deployment / configuration / …>
- Impact: <consequence of its absence>
- Suggested fix: <step to add>

[RISK-001] <short title>
- Step at risk: <reference>
- Risk: <description>
- Suggested mitigation: <fallback or checkpoint>

[DUP-001] <short title>
- Tasks involved: <references>
- About to be rewritten: <the rule, helper or mechanism>
- Where it already lives: `path/file.ext:line` — <name of the existing symbol>, or
  "nowhere: it gets created once and called from both"
- Suggested fix: <who owns the rule, who calls it>
```

`SCOPE-` and `FMT-` follow the same shape: position, problem, suggested fix.

## Three rules of judgement

- **Don't inflate the plan.** Add only tasks strictly needed to make it executable, never a
  nice-to-have — every extra task is work somebody has to do.
- **Don't assume an implicit stack.** A task needing an unnamed technology gets raised, not
  assumed — the silent assumption is itself a defect of the plan.
- **Don't ask for reuse in the abstract.** "Reuse the existing code" is not a finding — it cannot
  be verified and it cannot be violated. See naming the symbol, above.

## The ledger

Reading it first, and treating a `rejected` finding as closed, is `dev-loop:reviewer`'s own rule
(`${CLAUDE_PLUGIN_ROOT}/agents/reviewer.md`); format: `${CLAUDE_PLUGIN_ROOT}/references/ledger.md`.

## Alternatives are not judged here

A separate pass judges whether the chosen way of building is right: that reviewer also gets
`${CLAUDE_PLUGIN_ROOT}/references/alternatives.md`, construction variant.

Its findings use the fields above with **their own prefix, `ALT-`** — none of the seven
dimensions covers "a materially better way to build this," and without a prefix such a finding
could not be quoted across iterations. What becomes of a valid alternative is settled in that
file, not here.
