# Audit criteria

Same principle and catalogue as writing: `${CLAUDE_PLUGIN_ROOT}/skills/test-writing/catalog.md`.
Judgement arrives **afterwards** — nothing rewritten or deleted, only findings; deleting is for
whoever asked.

Calibration comes first, unchanged (`${CLAUDE_PLUGIN_ROOT}/skills/test-writing/SKILL.md` Step 1):
without it, every finding is air.

**Precondition:** suite red now ⇒ stop, mutation against red proves nothing.

## The checks

Reading first, a suite run last: arrive with few candidates.

| # | check | class |
|---|---|---|
| 1 | **Reaches production code?** Follow indirection (helpers, clients) at least one level | `NO-REACH` |
| 2 | **Ours or the platform's?** | `PLATFORM` |
| 3 | **Name promises the body?** A precise line/rule name promotes it to the mutation check | `NAME-OVERSELLS` |
| 4 | **Fails on any environment?** Literal-only assertions, a per-env branch asserting what that environment does, copied production expressions | `TAUTOLOGY` |
| 5 | **If red, where's the fix?** Always test code ⇒ a harness verification script | `SELF-TEST` |
| 5b | **Asserts on infra state** (schema, config, env, filesystem) as premise, not output? | `INFRA` |

## Check 6 — the mutation

**A reviewer does not run check 6** (no Edit or Write): the skill runs it, with the mutation
script, on candidates left standing after the reading checks.

Mutate the line the test claims to cover, run the suite filtered — three outcomes, the third worth
most:

- red ⇒ **no finding**, and say so — a result;
- green while others fall ⇒ doesn't cover its claim: `SURVIVES-MUTATION`;
- **nothing falls** ⇒ covered by nobody, name hiding the fact: `UNCOVERED` — the most valuable
  finding here.

**The test case decides whether this check says anything**: a one-element list passes any
separator (use two); a two-branch condition satisfied by both tells them apart from nothing —
build the case **so the mutation crosses it**.

### Exit codes

One mutation per call, invoked as in `${CLAUDE_PLUGIN_ROOT}/skills/test-writing/SKILL.md` Step 6
(test command unfiltered to relaunch a survivor). Every code has a behaviour:

| exit | what the skill does |
|---|---|
| 10 | caught: confirm via the output tail it's the target assertion, then continue |
| 11 | survived: relaunch unfiltered — others red ⇒ `SURVIVES-MUTATION`, none ⇒ `UNCOVERED`, the relaunch's own exit read by these two outcomes and not by this table (write mode rewrites the test to call the code; here, the finding) |
| 12 | no verdict: one relaunch; repeats ⇒ not run |
| 3 | refused (live lock, untracked/changed file, `<find>` missing/repeated): nothing mutated — finding, not run |
| 4 | **restore impossible/failed** — see below |
| 5 | orphan marker restored: relaunch the **same** mutation, now clean |
| 2 | bad arguments (`<find>` = `<replace>`): not the script's fault — finding, not run, reformulated |
| 1 | internal script error: finding, not run |

**Exit 4 alone stops the skill**: the file stays mutated, nothing committed or restored by hand
(whoever fixes it removes the marker), and the return is `status: question` with the mutated
file, the two copies' paths, and the marker in `state`.

## Structural findings

Not from the table above:

- **`CEREMONY`** — N near-identical tests differing only in data; fix: the table plus completeness
  check of `${CLAUDE_PLUGIN_ROOT}/skills/test-writing/SKILL.md` Step 4.
- Tests with no assertions.
- Tests asserting more than their axis (SKILL.md Step 4, "assert the axis, not the world").

## Two rules of severity

- **No class, no report** — among what wasn't verified.
- **A false positive costs more than a false negative**: a good test gets deleted, unnoticed until
  needed.

## Shape of the audit report

```
### Findings: N  <one count per class>
### [<CLASS>] <file>::<test>
- **What it asserts:** …
- **Proof:** <mutation performed and outcome, or the fact read — file and name of what was read>
- **What to do with it:** <delete | rewrite calling X | table plus completeness check | cover the
  line>

### Recognised and left alone
<cases that look like findings and aren't, with the reason>
```

This section **is not an ornament**: without it, "not found" and "checked, fine" look alike, and
the examination gets redone.

## Before hand-rolling a mutator, check one exists

Hand mutation proves one finding, a few lines; measuring the whole suite is **mutation testing**
(real tools: Infection–PHP, Stryker–JS/.NET, mutmut/cosmic-ray–Python, PIT–Java) — look before
hand-rolling, unless the suite launches from an app entrypoint instead of the standard runner,
which defeats them.

**Coverage** counts lines *executed*; mutation, lines *asserted* — twenty tests hitting a line none
assert on show 100% covered, yet uncovered.
