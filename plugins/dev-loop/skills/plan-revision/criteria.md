# Criteria for reviewing an implementation plan

The yardstick a reviewer applies to the slice of a plan it was handed. Nothing here says what to
launch or when: this file is the judgement, and only the judgement.

## What you judge, and what you hand back

You judge the group you were pointed at — a batch file, a range of tasks, or the whole plan when
it fits in one pass. **You change nothing.** Where you would have edited, describe the remedy
inside the finding and leave the decision to the caller.

Your return takes the shape held by `${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`, with
`findings` in the format this file sets out below.

**Nothing gets pasted back.** No file contents, and no command output past the one line that
proves a finding. Whoever launched you has the plan open already.

## The decisions still to be taken

A plan stalls in execution for one reason: **whoever executes it meets a choice nobody made.**
Not a technical obstacle — those happen and get solved by writing — but a fork that needs to know
what the user wants, and that the document does not cover. That is where the work stops, and if
it does not stop it is worse: somebody chooses alone, in a hurry, and the choice sticks.

So, **for every task**, ask: *what will whoever executes this have to decide?* Then check that
each of those decisions is already taken — in the specification, in the plan, or in the project's
conventions. The ones that are not become findings now, not stops later.

Where they hide:

- **Verbs with no object.** "Handle the errors", "validate the input", "update the interface":
  each holds a decision dressed up as a chore. *Which* errors, and shown how? *Which* validation
  rules, and what happens to whoever breaks them?
- **Behaviour at the boundaries**, where the specification has not already fixed it: the first
  element, the empty list, the value exactly equal to the threshold.
- **Collisions between tasks.** Two tasks touch the same file or the same state: which one wins,
  and in what order do they land? If the plan does not say, whoever arrives second decides,
  reading code they did not write.
- **Criteria of doneness.** A task with no verifiable way of calling itself finished forces
  whoever executes it to invent one, and nobody will ever know whether it was the right one. A
  check on the finished text or code is the exception: it belongs in the index's end-of-batch
  criteria (`${CLAUDE_PLUGIN_ROOT}/references/plan-folder.md`), not in the task.
- **Technical choices left to the executor.** Which library, which data structure, where the new
  file goes. Some are harmless and stay open — but the ones the project has already settled
  elsewhere get **named**, not rediscovered.

**The target is not "never stop"**, which does not exist: something always turns up while writing
the code. The target is to stop **only** for what nobody could have known beforehand, and never
for a decision that had been sitting there, waiting, for weeks.

## The seven dimensions

Ordered by severity: the 🔴 groups block execution, the 🟡 and 🔵 ones only slow it down.

### 🔴 Sequence and dependency errors

**Never skip the dependencies.** The wrong order is the costliest defect there is: it only shows
up once execution has started, when redoing the work costs more than it would have. That is why
this dimension comes first and why a finding here outranks everything else in the report.

- Step B depends on step A, and A comes after B
- Tasks that assume components nobody has created yet
- Circular dependencies
- Prerequisites or setup the work needs and the plan does not include

### 🔴 Steps that cannot be executed

- Descriptions too vague to be started without further clarification
- Steps that need a decision nobody has taken
- Actions that depend on external information the plan never references

### 🟠 Coverage gaps

- Requirements of the specification, where one is available, with no task against them
- Testing, validation or rollback unplanned
- A task that adds logic without the behaviours it is verified by, or an untested behaviour
  with no reason given
- Data migration, environment configuration, deployment missing
- Technical documentation not scheduled

### 🟠 Unmitigated risks

- High-risk steps with no fallback
- Destructive operations (delete, migration, schema change) with no backup and no way back
- Dependencies on external systems with no contingency

### 🟠 Announced duplication

**This is the one dimension that cannot be judged by reading the plan: you open the code.** The
other six look for defects *inside* the document; this one looks for what the plan is about to
have rewritten from scratch, and the answer is in the repository.

- **A rule with several readers and no owner.** Two or more tasks need the same judgement, the
  same derivation or the same formatting, and the plan does not say **where it lives** and who
  calls it. A plan that describes the same display rule in two places has already decided on the
  duplication without noticing: whoever executes the first task writes it, whoever executes the
  second copies it, and the day the rule changes one of the two copies stays behind.
- **A helper that already exists.** A task introduces a formatting, a conversion, a component or
  a utility the project already has in house. Grep for it in the shared helpers and in the files
  adjacent to the area being touched.
- **A special case on top of a shared mechanism.** The plan adds a dedicated branch where the
  existing mechanism should have been generalised. It costs little now and costs again at every
  case that follows.

**The finding names the symbol.** Either it names what already exists and where it sits, or it
says outright that it does not exist and has to be created once and called from both places.
Without the name the finding is not actionable and gets deleted rather than left standing. The
cost is not aesthetic: it is that **copies diverge**, and the divergences are the defects.

### 🟡 Scope and estimate

- Steps too wide for a single unit of work
- Completion criteria that cannot be verified
- A single-file plan too large to be executed in one go, or with no verifiable point before the
  end. The finding is not the length: it is that nobody can say they are halfway.
- Long plans with no intermediate review checkpoint. This is the defect that presents the whole
  bill at once: one review over thousands of lines finds less than several short ones, because by
  then every finding has to be carried back onto code that later tasks have already written over.

### 🔵 Clarity and format

- Ambiguous or non-self-explanatory titles
- Owners and responsibilities unassigned, where that applies
- Inconsistent format between comparable tasks

## Seam criteria for a plan folder

When the object is a folder of batch files, three checks specialise the seam pass. The general
method — why seams are judged last, and on the fixed text — is not restated here: it is held by
`${CLAUDE_PLUGIN_ROOT}/references/large-docs.md`.

1. **The index tells the truth.** Every shared rule the index declares has a real declared owner,
   and the batches that use it *call* it rather than re-deriving it. Every declared dependency is
   consistent with the order of the files.
2. **Nothing shared lives outside the index.** If two batches need the same thing and the index
   is silent, that thing is about to be written twice, by two runs that will never see each
   other. It is a duplication finding, not a style note.
3. **Each batch closes on its own.** The closing criterion the index declares for a batch is
   verifiable on that batch alone, without waiting for the ones after it.

## Coverage against the specification

Where a specification is available, every requirement in it has at least one corresponding task
in the plan. Requirements with none are reported as `GAP-SPEC-…`. This is the check that stops a
plan from being internally coherent and yet incomplete against what it was meant to deliver.

## The shape of a finding

Running codes per prefix, so that every finding is quotable in the iterations that follow:
`SEQ-`, `EXEC-`, `GAP-`, `RISK-`, `DUP-`, `SCOPE-`, `FMT-`, and `GAP-SPEC-` for a requirement
left uncovered.

```
[SEQ-001] <short title>
- Steps involved: step X, step Y
- Problem: <the broken dependency, precisely>
- Impact: <what happens if executed in the current order>
- Suggested fix: <the right order, or the restructuring>

[EXEC-001] <short title>
- Step: <reference>
- Problem: <why it cannot be executed as it stands>
- Suggested fix: <what makes it executable>

[GAP-001] <short title>
- Missing area: <testing / rollback / deployment / configuration / …>
- Impact: <the consequence of its absence>
- Suggested fix: <the step to add>

[RISK-001] <short title>
- Step at risk: <reference>
- Risk: <description>
- Suggested mitigation: <fallback or checkpoint>

[DUP-001] <short title>
- Tasks involved: <references>
- About to be rewritten: <the rule, the helper or the mechanism>
- Where it already lives: `path/file.ext:line` — <name of the existing symbol>, or
  "nowhere: it gets created once and called from both"
- Suggested fix: <who owns the rule and who calls it>
```

`SCOPE-` and `FMT-` follow the same shape: position, problem, suggested fix.

## Three rules of judgement

- **Do not inflate the plan.** Add only the tasks strictly needed to make it executable, never a
  nice-to-have. Every extra task is work somebody will have to do.
- **Do not assume an implicit stack.** If a task needs a technology the plan never names, raise
  it rather than take it for granted — the silent assumption is itself a defect of the plan.
- **Do not ask for reuse in the abstract.** "Reuse the existing code" is not a finding: it cannot
  be verified and it cannot be violated. See the rule on naming the symbol, above.

## The ledger

You also receive the ledger of this review when one exists for this object. Read it before the
object. A finding it records as rejected is closed — the user has already turned it down — and
raising it again spends their attention on a decision they have made. Its format is not restated
here: it is held by `${CLAUDE_PLUGIN_ROOT}/references/ledger.md`.

## Alternatives are not judged here

Whether the chosen way of building is the right one is a separate pass. The reviewer that runs it
is handed `${CLAUDE_PLUGIN_ROOT}/references/alternatives.md` as well, in its construction
variant, and works from there.

Its findings use the fields above but carry **their own prefix, `ALT-`**. None of the seven
dimensions covers "there is a materially better way to build this", and without a prefix of its
own such a finding could not be quoted from one iteration to the next. What becomes of an
alternative that holds up is settled in that file, not repeated here; the consequence for this
format is the prefix.
