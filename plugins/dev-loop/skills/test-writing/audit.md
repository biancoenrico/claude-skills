# Audit criteria — tests that already exist

Same principle as writing tests and the same catalogue of shapes, at
`${CLAUDE_PLUGIN_ROOT}/skills/test-writing/catalog.md`. The only difference is that the judgement
arrives **afterwards**: nothing is rewritten and nothing is deleted here, the output is findings.
Deleting is a decision for whoever asked for the audit.

The calibration pass comes first, unchanged — language and version, the runner and how it filters,
where the tests live, the conventions read off the tests already there, the project's own
instructions, the boundary of the platform. Without calibration every finding is air.

**The precondition: is the suite green right now?** If it is red, stop. Against a red baseline a
mutation means nothing, and a finding drawn from one is worthless.

## The checks, in this order

The order is the order of the costs: the first ones are reading, the last one costs a run of the
suite. Arrive there with few candidates.

| # | check | class |
|---|---|---|
| 1 | **Does it reach our production code?** Follow the indirection — helpers, scenarios, clients — *at least one level* before concluding | `NO-REACH` |
| 2 | **Is the subject ours or the platform's?** (the question of the principle) | `PLATFORM` |
| 3 | **Does the name promise what the body does?** If it names a precise line or rule, promote it to the mutation check | `NAME-OVERSELLS` |
| 4 | **Could it fail on any environment?** Assertions computed out of literals alone; branches on the environment where each branch asserts what that environment does; copied production expressions | `TAUTOLOGY` |
| 5 | **If it went red, where would the fix go?** Always and only in the test code ⇒ it is a verification script for the harness | `SELF-TEST` |
| 5b | **Does it assert on the state of the infrastructure** — schema, configuration, environment, filesystem — as a premise and not as the output of the code under examination? | `INFRA` |

## Check 6 — the mutation, and who does not run it

**A reviewer does not run check 6.** It mutates a file, and a reviewer has neither Edit nor Write:
it is a reading pass. The check belongs to the skill, which runs it with the plugin's mutation
script on the candidates left standing once the reading checks are done.

The mutation breaks the production line the test claims to cover and runs the suite under the
project's filter. Three outcomes, and the third is worth more than the other two:

- the test goes red ⇒ **no finding**, and say so: it is a result;
- it stays green while others fall ⇒ it does not cover what it claims: `SURVIVES-MUTATION`;
- **nothing falls at all** ⇒ that line is covered by nobody, and the test carrying its name was
  hiding the fact: `UNCOVERED`. It is the most valuable finding available here.

### The exit codes of the mutation script

The script is invoked one mutation per call, `sh ${CLAUDE_PLUGIN_ROOT}/scripts/devloop-mutate <file>
<find> <replace> -- <filtered test command>`, and unfiltered only to relaunch a survivor. Every code
has a behaviour, and none is excluded.

| exit | what the skill does |
|---|---|
| 10 | mutation caught: confirm from the output tail that what fails is the assertion of the target test, then move to the next mutation |
| 11 | mutation survived: relaunch the same mutation with the unfiltered suite — something else goes red ⇒ `SURVIVES-MUTATION`, nothing does ⇒ `UNCOVERED` — the relaunch's own exit is read by these two outcomes, not by this table. In write mode the test then gets rewritten calling the code instead of repeating it; here that is the finding |
| 12 | no verdict: **one** relaunch of the same mutation; if it repeats, the mutation is declared not run in the report |
| 3 | refused (live lock, file untracked or different from `HEAD`, `<find>` missing or repeated): nothing was mutated — a finding in the report, mutation declared not run |
| 4 | **restore impossible or failed** — see below |
| 5 | an orphan marker was restored: relaunch the **same** mutation, which now starts clean |
| 2 | wrong arguments, `<find>` equal to `<replace>` included — that is a badly chosen mutation, not a fault of the script: a finding in the report, mutation declared not run, and the mutation is reformulated |
| 1 | internal error of the script: a finding in the report, mutation declared not run |

**Exit 4 is the only one that stops the skill.** The production file is left mutated in the working
tree: nothing is committed, nothing is restored by hand — the marker is removed by whoever fixes the
file — and the return is `status: question` with the mutated file, the paths of the two copies and
the marker in `state`.

**The choice of the test case decides whether this check says anything.** If the logic splits a
list, a one-element list passes with any separator and the test stays mute: it takes a list of
two. If a condition has two branches, a case that satisfies both does not tell them apart. The
case is built **so that the mutation crosses it**.

## Structural findings

These carry no class from the table above and are reported as structure:

- **`CEREMONY`** — N nearly identical tests differing only in their data. A finding of this class
  always names the **complete** landing shape: the table *plus* the completeness check that fails
  when a new case has not been added to it, enumerating the source by reflection, over the type.
  Without that second half the finding only shortens a file, and case N+1 goes on not existing
  until somebody remembers to write it.
- Tests with no assertions at all.
- Tests asserting twenty fields where the intent is a single axis: they fail for reasons that have
  nothing to do with the intent, and whoever reads the red does not know what actually changed.

## Two rules of severity

- **A finding without its class is not reported.** It goes among the things that were not
  verified.
- **A false positive costs more than a false negative.** A wrong finding gets a good test deleted,
  and nobody notices until it was needed.

## The shape of the audit report

```
### Findings: N          <one count per class>
### [<CLASS>] <file>::<test>
- **What it asserts:** …
- **Proof:** <the mutation performed and its outcome, or the fact read — with file and the name
  of what was read>
- **What to do with it:** <delete | rewrite calling X | bring to a table with a completeness
  check | actually cover the line>

### Recognised and left alone
<the cases that look like findings and are not, with the reason>
```

The last section **is not an ornament**: without it a reader cannot tell "it was not found" from
"it was looked at and it is fine", and next time round somebody redoes the same examination.

## Before writing your own mutator, look whether one exists

Mutation by hand serves to **prove a specific finding**, a few chosen lines. If the target is
"measure how much the whole suite asserts", that is **mutation testing**, and it is a technique
with real tools — Infection (PHP), Stryker (JS/.NET), mutmut and cosmic-ray (Python), PIT (Java).
Look for one for the project's language and check whether it hooks into the runner **before**
proposing anything hand-made. The typical obstacle: if the suite is not launched from the standard
runner but from an application entrypoint, those tools do not find it — and then, and only then,
targeted mutation by hand is the way.

Two measures that resemble each other and are not the same: **coverage** counts the lines
*executed*, mutation counts the ones *asserted*. A line crossed by twenty tests that none of them
asserts on shows as 100% covered and is uncovered.
