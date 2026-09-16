---
name: test-writing
description: Decides what deserves a test and writes it, or judges whether the tests already there prove anything. Isolates the unit and its seams, separates the logic written here from the platform's, writes down what gets covered and what does not before writing a line, and closes by proving through mutation that every test can go red.
when_to_use: Writing, adding or completing tests for a target; in audit mode, judging an inherited suite. Triggers - "write the tests for X", "cover this module", "the tests are missing", "do these tests prove anything", "clean up the tests". Not for hunting bugs in production code.
argument-hint: <targets - paths, a class, a module; or base..HEAD; plus the batch file of the plan and any state from an earlier run>
effort: high
context: fork
agent: general-purpose
background: false
---

# test-writing

Writes the tests for a piece of code. The real work is not writing them: it is **deciding which**,
and discarding the ones that look like tests and are not.

A battery of green tests says nothing about the value of the battery. Tests that prove the
language, the framework or the harness always pass, cost maintenance at every refactor and — the
worst damage — **take the place** of the test that was needed: whoever looks for "who covers X"
finds a file named after X, and stops looking.

Hence the order: **first decide what to cover and write it down; then write the code; at the end
prove that every test can fail.**

It is invoked by `/dev-loop:plan-execution`, and the step after it is `/dev-loop:code-revision`.

## Step 0 — The scope, and it comes first

This skill runs in a fork: **it does not see the conversation**, and nothing about the target
reaches it for free. The scope arrives **spelled out in the arguments** — paths, `base..HEAD`,
targets, the batch file of the plan.

With no arguments, fall back to `git diff HEAD`, plus the branch range when an upstream exists. If
that too is empty, **do not invent a scope**: return `status: question` in the shape held by
`${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`, asking what is to be covered.

## Step 0b — Repair before mutation

If the arguments carry `test_targets` — existing tests that a deliberate change has broken — those
get repaired **before any other work and before any mutation**. Mutating against a red baseline
means nothing.

The repair touches **the tests only**. If the red depends on production code, this skill does not
modify it: it declares the fact and hands the question back.

**Deleting a test is not repairing it.** A test is deleted **only** when the batch file received in
the arguments explicitly declares that the behaviour is being removed. In every other case return
`status: question`, with the test in question in `state`. The reason is worth stating: removing
coverage stays anchored to what the plan has already decided, not to the judgement of a fork that
cannot see the conversation. **The batch file path arrives in the arguments** — plan-execution
passes it. If it is not there, the authorisation does not exist and `status: question` always
applies.

## The principle: you test the behaviour of the code written here

> **The question, for every test you are about to write:** if this assertion failed, who would you
> open the bug against — this repository, or the language, the framework, a library?

Against the second, it is not your test: delete the line before writing it. The principle alone
does not stop the shapes that break it, because each one looked at closely seems a reasonable
exception. What stops them is recognising the shape, and the shapes are catalogued in
`${CLAUDE_PLUGIN_ROOT}/skills/test-writing/catalog.md`.

## Step 1 — Calibrate on the project, not on your habits

**Assume nothing.** Establish from the facts of the repository, and state it in two lines:

1. **Language, version and syntax constraints** — from the manifest (`composer.json`,
   `package.json`, `pyproject.toml`, `go.mod`…). A low minimum version forbids modern syntax:
   violating it breaks the build, not the style.
2. **The test runner and how it is launched**, including **how it filters** so a part of the suite
   can be run: in the manifest's scripts, in the `Makefile`/`Taskfile`, in the CI configuration, in
   a `run.sh`. The mutation step needs it, and without it that step does not close.
3. **Where the tests live**, and with what correspondence to the code: a mirror of the tree, next
   to the file, one flat directory.
4. **The house conventions, read off the tests already there.** They are the most authoritative
   source available: how tests are named, how state is prepared, how they are isolated from each
   other, which doubles are used, what gets asserted. **A new test that clashes with the ones
   around it is a badly written test, even if on its own it would be faultless.**
5. **The project's instructions** — `CLAUDE.md`/`AGENTS.md`/`CONTRIBUTING`, and in particular any
   document of suite rules: that wins over any general good practice.
6. **The boundary of the platform** — the dependencies declared in the manifest are the list of
   what does **not** get tested.

If the project has no tests yet, take the conventions from the ecosystem of the language and the
framework — and **search for them** instead of recalling them: a framework's good practices change
between major versions, and the official testing guide is a citable source. Declare that you are
founding the convention, because you are founding it for everyone after you.

## Step 2 — Isolate the unit and its seams

Draw the boundary **before reading in depth**, or you end up testing half the system:

- **The public surface** of the unit: what a user of it can call. That is where you go in; private
  methods are exercised through those, never head-on.
- **The collaborators**, and for each the decision: **real or double?** The criterion is not
  convenience — it is *what happens if you leave it real*. Double whatever leaves the process or the
  control of the test: network, clock, randomness, filesystem, queues, external services, the real
  payment. Everything else stays real: a double too many proves your mock behaves as instructed.
- **The seams** — the points where a collaborator can be substituted without rewriting the unit.
  **Introducing a seam is a change to production code: this skill does not make it.** It becomes a
  question, handed back.
- **The starting state**: what has to exist for the unit to be exercisable, and who builds it.
  Reuse the data builders the project already has; do not invent parallel ones.

The product of this step is **the list of boundaries**, not a test.

## Step 3 — Decide what deserves a test, in writing and before writing

**It is the step that makes the difference, and the one that gets skipped.** Produce two lists:

**To cover** — one behaviour per line, with the **case** in one sentence, the **line or rule** of
production code that decides it, and **what breaks** if that behaviour changes silently.

Look for the behaviours where they actually live: the **branches** of the logic written here, and
for each branch the pair — the case that fires it **and** the case that does not, since a negative
assertion on its own stays green even when the branch does not exist; the **boundaries** — the
first, the empty, the absent, the value exactly on the threshold, the duplicate; the **domain
invariants** the code enforces and no schema knows about; what the code **rejects**, and with which
message, when the message is a contract; the **effects** that are not the return value: what gets
written, queued, emitted.

**Not to cover, and why** — it is the half that makes the first one useful, and the one nobody
writes. Into it go the shapes of the catalogue — **go through it entry by entry, not from memory**,
at `${CLAUDE_PLUGIN_ROOT}/skills/test-writing/catalog.md` — plus everything already covered
elsewhere (say *where*). An empty "not to cover" list is almost always the sign that this step was
not done.

**Done when:** both lists exist and every entry of the first names the line or the rule it pins
down. If the user has to choose something — an ambiguous behaviour, a seam to introduce — it is
**now** that it is asked, not once the tests are written.

**The two lists are the `state` of the return.** If this skill stops here, they go into the `state`
field so that the next invocation restarts from them and from the commits already made.

## Step 4 — Choose the structure

With the list in hand the shape almost follows. The recurring decisions:

- **One test per behaviour, not per method.** The name says the behaviour in the language of the
  domain and **promises exactly what the body does**: a name promising more hides a gap, because
  whoever searches for coverage finds it and stops looking.
- **Cases identical in form and different in data ⇒ a table**, with the language's own mechanism
  (parameterisation, data provider, table-driven). And **together with the table, the completeness
  check** that fails when a new case has not been added to it — enumerating the source, by
  reflection, over the type. Without that second half you have only shortened a file: case N+1 goes
  on not existing until somebody remembers to write it.
- **Arrange — act — assert**, separate and visible. One action per test.
- **Assert the axis, not the world.** Twenty fields asserted where the intent is a single axis make
  the test fail for reasons that are beside the point, and whoever reads the red does not know what
  actually changed.
- **Assert a value, not a shape.** Asserting the computed amount proves the calculation happened;
  asserting that the result is an array with a `price` key passes identically when the code left by
  the back door returning zero. Where production **exits politely** instead of rejecting — a
  fallback, an empty list, a zero — that is the only assertion that notices: choose a value that
  *exists only* if the right branch was walked.
- **No dependency on order** and no state surviving between tests: repeating one test in isolation
  has to give the same outcome.
- **Determinism.** Time, randomness and generated identifiers are pinned or declared volatile.
- **Fixtures are built by composition**, not by copying a forty-field literal.

And the rule that governs them all: **if the project already does otherwise and it works, do it the
project's way.** Good practices are for choosing where there is no precedent.

## Step 5 — Write

One block at a time, following the list from Step 3. Respect the comment language, style and
version constraints established in Step 1. Do not widen the perimeter: if while writing you find a
behaviour that belonged on the list, **add it to the list** and say so, instead of slipping it in.

**The name and the comment say the behaviour, not the occasion.** "With empty-string fields it
writes NULL" stands on its own; "the point the new version could have altered" ages with the
migration and does not say what happens. The ticket, the feature or the refactor that brought you
there belong in the commit message, not in the test.

**And the comment explains, it does not point.** No line numbers, no paths, and not even the name of
the method under measurement: the test's path and its own name say that already. If the case cannot
be explained without pointing at a piece of code, stop: **that test is wrong or unnecessary.**

And an outcome obtained by running the suite is not written into a comment: "measured on both
environments, identical" is made false by the first change without anything noticing.

If making something testable requires touching production code, **stop and ask** (see below): a
change to code that ships is not a detail of writing tests.

Check that the suite is green with the project's tools before Step 6.

## Step 6 — Prove them red. A test never seen red is not finished

A freshly green test proves nothing: it proves that it passes. It has to pass **for the right
reason**, and the only way to know is to see it fail.

The safety of the mutation — the copy, the restore, one mutation at a time, a clean tree at the end
— is guaranteed by the script, and is not repeated here. What stays with you:

- **Choose the test case so that the mutation crosses it.** If the logic splits a list, a
  one-element list passes with any separator and the test stays mute: it takes a list of two. If a
  condition has two branches, a case satisfying both does not tell them apart.
- **Filter the command to the target test file**, not the whole suite: every mutation reruns it.
  Only a survivor earns a whole-suite run, to tell a weak test from a line no test intercepts.
- **Check the command is green without the mutation before mutating.**
- **Read the tail of the output** to confirm that what fails is the assertion of the target test,
  and not compilation, test collection or configuration.

The invocation, one mutation per call:

```sh
sh ${CLAUDE_PLUGIN_ROOT}/scripts/devloop-mutate <file> <find> <replace> -- <filtered test command>
```

Break the production line in its **meaning**, not in its syntax: a parse error fails everything and
proves nothing.

Every exit code of the script has a behaviour, and the table of all eight is in
`${CLAUDE_PLUGIN_ROOT}/skills/test-writing/audit.md`.

**Exit 4 is the only one that stops this skill.** The production file is left mutated in the working
tree, and this is the skill that commits the tests: on exit 4 **nothing is committed**, **nothing is
restored by hand** — the marker is removed by whoever fixes the file — and the return is
`status: question` with the mutated file, the paths of the two copies and the marker in `state`. A
forked skill does not send questions to the user: it hands them back.

**The `state` covers this step too.** An interruption arrives when part of the mutations has already
passed, and the commits do not record which. Into `state` go **the list of mutations already tried
with their outcome** and, after an exit 4, the line "tree dirty from mutation, see marker". Without
them a resume redoes them all and the first call exits 3 without the skill knowing why.

If the suite is not runnable, Step 6 **is not done**: declare it, and say that the tests delivered
were not seen to fail. Do not fake the proof.

## Audit mode

The criteria live in `${CLAUDE_PLUGIN_ROOT}/skills/test-writing/audit.md`. What this skill does:

- launch **one `dev-loop:reviewer` per test file** on the reading checks, handing it the paths of
  `catalog.md` and `audit.md` — in the form prescribed by `agents/reviewer.md`, which owns that rule
  — together with the file to judge. The fan-out proceeds in waves, up to the agents-per-wave cap
  named in `${CLAUDE_PLUGIN_ROOT}/references/limits.md`;
- once the fan-out is back, run the mutation check itself on the candidates left standing. The
  reviewer cannot: it mutates files, and a reviewer has neither Edit nor Write;
- carry any question that comes back in the form held by
  `${CLAUDE_PLUGIN_ROOT}/references/asking.md`.

## When it is time to ask

**Questions are the exception.** The code is there: almost every doubt has an answer two greps away,
and going to read it is the work. Three cases remain:

- making something testable requires **modifying production code** — that change is made by the
  executor or the main thread, never by this skill;
- the correct behaviour is **ambiguous** and the code does not say (is it a bug or is it intended?);
- an entry on the "to cover" list costs disproportionately and has to be **decided** rather than
  endured.

The form of the question is held by `${CLAUDE_PLUGIN_ROOT}/references/asking.md`.

## The return

In the shape held by `${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`: the report in `findings`,
the commits in `commits`, the state in `state`. The report, compactly:

```
### Calibration
Language/version · runner and filter · where the tests live · conventions taken from <where>

### Covered: N
| behaviour | line/rule that decides it | seen red |

### Deliberately not covered: N
| what | why: platform / harness / already covered by <where> |

### Gaps found while writing
<lines no test intercepts, found by mutation: the most valuable result>

### Verifications
Suite: <outcome>. Mutations run, and any declared not run, with their exit.

### Open points
<decisions left to the user>
```

## Rules of behaviour

- **Do not write a test before writing the list.** Skipping Step 3 is how batteries of tests that
  prove nothing are born: you start from methods instead of behaviours, and cover the language.
- **Do not declare finished what you have not seen fail.**
- **Do not test other people's code.** Frameworks, libraries, the language: assumed working.
- **Do not double for convenience.** Every double is justified by what would happen with the real
  collaborator.
- **Do not touch production code to make a test pass.** A failing test is saying something: read it
  before silencing it.
- **Do not chase a coverage percentage.** It measures lines executed, not behaviours pinned down,
  and rises nicely with tests that assert nothing.
- **Report the negative results.** "I mutated these six lines and the tests caught them all" is
  worth as much as a test written, and stops somebody redoing the examination.
