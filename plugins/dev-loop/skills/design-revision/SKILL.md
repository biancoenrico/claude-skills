---
name: design-revision
description: Looks at the shape of a branch's code — not whether it works, not whether it is tidy line by line, but whether the structure holds — and straightens it with the smallest remedy that does. Local knowledge first, then the smell catalogue, a design pattern only where the pain already happened.
when_to_use: Before closing a branch, on inherited code, before a big refactor, or when the user says this logic is duplicated everywhere, this switch grows every sprint, can the structure be simplified, does a pattern belong here. Not bug hunting (`/code-review`), not line-by-line polish of the diff (`/simplify`).
argument-hint: "[standard|high] [audit] [path]"
effort: xhigh
---

# design-revision

Looks at the **shape** of the code: how it is divided, who knows what, what repeats, what will
force five files open next time. And where it needs it, straightens it — with the **smallest**
remedy that solves the problem, which is almost never a design pattern.

## The two failures this exists to prevent

The first one shows: the same logic in three places, the switch that grows every sprint, the
class that knows everything about everyone, the method that only passes the ball along.

The second one does not show, because it looks like craftsmanship: **the pattern put where there
was no pain**. Strategy with one implementation. A factory building one class. An interface with
one implementer. A layer of abstraction “for when we need it”. These never repay what they cost
— one more file, one more indirection, one more mental jump on every read — and unlike a smell
nobody reports them, because they have the look of code done well.

**This skill works harder at stopping the second than at finding the first. The default is not
to touch anything.**

## Who calls it, and who it calls

`/dev-loop:plan-execution` calls it once the batches are finished, or the user calls it directly
before closing a branch. It calls `/dev-loop:test-writing` when the zone it is about to move has
no net under it.

## Inputs

In order of priority:

1. **An explicit target** — a path, a module, a class.
2. **The current branch against its base** — `git diff <base>...HEAD` **plus the zone that diff
   runs through**. Structure is not judged on a diff; it is judged on the code the diff lives in.
3. **The work just done** in the conversation.

If the branch is huge or straddles unrelated areas, **narrow it and say so**: one zone looked at
properly beats three brushed past.

## Two levels, plus a modifier

```
design-revision [standard | high] [audit] [target]
```

`audit` is not a third level. It combines with either of the two, and the two are what you
choose between.

- **`standard`** (the default) — the pain gate **decides**: no evidence, no remedy. It applies
  rungs 1 and 2 of the ladder by itself inside the branch's zone, and proposes the rest.
- **`high`** — searches for **every** design improvement available in the zone, including the
  ones the gate would throw out at `standard`; the gate becomes an **ordering**, not a veto.
  **Nothing is touched before the user has chosen**, not even a trivial rename.
- **`audit`** (modifier) — `standard audit`, `high audit`: applies nothing, asks nothing,
  produces only the report. `high audit` is the complete picture of what could be done,
  typically over freshly inherited code.

|  | `standard` (default) | `high` |
|---|---|---|
| **What it searches for** | smells with pain already behind them | everything improvable: proven smells, fragile shapes, structural opportunities |
| **Role of the gate (Phase 3)** | **decides**: no evidence, no remedy | **sorts**: the evidence becomes a label, not a veto |
| **Who chooses** | the skill, within the limits of Phase 5 | the **user**, item by item |
| **When it applies** | during the pass | only after the selection |
| **What to expect** | few, targeted remedies | a long list, and half an hour of decisions |

**`high` widens the search, not the permissions.** Local knowledge, the test net before any
remedy, unchanged behaviour, no pattern duplicating the framework, one remedy at a time with a
verification in between: identical at both levels.

Choosing the level, in order: the explicit argument → a default declared by the project's
instructions → `standard`. **The first line of the report declares both** the level and the
modifier, even when there is no modifier (`standard`, no audit): it is the only line that tells
a reader whether anything was touched.

**Do not raise the level on your own.** If the “seen and left” findings cluster in one area, say
so in one line and propose `high` over that area.

## Phase 1 — Local knowledge

**The step that is never skipped.** Proposing structure without knowing who calls what is
guessing, and a guessed refactor is paid for downstream.

Launch one `Explore` per question, five of them in parallel, each with `model: haiku`. Five is
under the agents-per-wave cap held in `${CLAUDE_PLUGIN_ROOT}/references/limits.md`.

1. **Boundaries and callers** — what the branch touches, and who else uses those classes and
   methods. Searched for, not remembered: something used in one place and something used in
   twenty do not get refactored the same way.
2. **What the platform already offers** — hooks, base classes, template methods, helpers,
   framework conventions. The right road is usually the hook that exists, not the abstraction
   that resembles it.
3. **Conventions and constraints** — `CLAUDE.md` / `AGENTS.md`, nested ones included: style,
   language, and above all the **version of the language**. A remedy that uses syntax the project
   cannot run is a remedy that does not exist.
4. **The history** — what changes constantly, what nobody has touched in years, with the churn
   list already in hand (below). Where nobody puts their hands, the structure hurts nobody, and
   it does not get redesigned.
5. **The net** — does that zone have tests, and are they green.

The phase closes with the **map declared in half a page**, and with a stop: if you cannot say
**who calls what**, you are not ready to move anything. Go back and read.

### Churn, measured before the fan-out

The main thread runs the churn recipe held in
`${CLAUDE_PLUGIN_ROOT}/skills/design-revision/patterns.md` once, over the same zone as the rest
of Phase 1, so the map and the churn talk about the same perimeter. The list goes to the Explore
of point 4 already made; nobody measures it twice.

Three rules about reading it, and they belong to the caller:

- **The list and the warnings do not mix.** The counts feed the map; a warning — a truncated
  history, most of all — goes to the report's Hotspot line as a declared limit. A partial clone
  that hides the history changes the Phase 3 verdict, so it cannot be left sitting among the data.
- **A path that no longer exists is not a target.** It counts as history, saying the zone was
  worked over, but no remedy gets proposed on a file that is gone.
- **Outside a git repository there is no churn.** Say so: the churn form of evidence is
  unavailable for this pass, and the other two forms still stand.

## Phase 2 — One reviewer per smell family

Launch `dev-loop:reviewer` once per family of
`${CLAUDE_PLUGIN_ROOT}/skills/design-revision/smells.md`, five in parallel — again under the
agents-per-wave cap of `${CLAUDE_PLUGIN_ROOT}/references/limits.md`. Each one gets the Phase 1
map, the zone, and the full path of `smells.md` as its criteria file; a reviewer whose family
leads to a pattern gets `${CLAUDE_PLUGIN_ROOT}/skills/design-revision/patterns.md` as well.

Reviewers modify nothing and return in the shape of
`${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`. They count and show; the deciding is Phase 3
and it belongs to the main thread.

## Phase 3 — The pain gate

For **every** smell that came back, three lines. If all three cannot be filled in, **it does not
get touched**:

1. **Occurrences** — where, with file and line. Counted, not estimated.
2. **Pain that has already happened** — the evidence.
3. **Cost of the remedy** — how many files, how many callers to update, how much test surface.

**Pain that has already happened** means one of three things, and they get shown, not narrated:

- **Three real occurrences.** Twice you put up with it, the third time you extract it — the rule
  of three from the refactoring literature, not a figure of this plugin.
- **A place that has already hurt** — a bug that came out of there, a change that touched five
  files, a test nobody manages to write.
- **Churn** — the measurement from Phase 1, not intuition.

**Anticipated** pain is never evidence, at either level. That is speculative generality, which is
a smell, catalogued among the defects.

| | `standard` (default) | `high` |
|---|---|---|
| **The gate** | **decides**: no evidence, no remedy | **sorts**: every item leaves with its evidence label |
| **Evidence that suffices** | three occurrences, or one documented pain | any, including none — but the label says so |
| **Outcome without evidence** | “seen and left”, with the count | enters the menu as **shape only**, recommendation: leave |

What does not pass the gate is recorded as **“seen and left”** with its occurrence count. That
line is what tells the next pass whether three has been reached.

## Phase 4 — The remedy, climbing from the lowest rung

Climb from the lowest rung, one rung at a time, only when the rung below does not solve it, and
say which rung you stopped on. The ladder, the pattern tables and their thresholds are in
`${CLAUDE_PLUGIN_ROOT}/skills/design-revision/patterns.md` — open it here, at the point where a
remedy is about to become a pattern.

## Phase 5 — Apply, with the net

- **The net comes first.** If the zone has no tests covering the behaviour about to move,
  `/dev-loop:test-writing` runs first. Refactoring without a net is not refactoring; it is
  rewriting and hoping.
- **One remedy at a time**, verified before the next, in separable commits. Five remedies at once
  produce a diff nobody really reviews.
- **Behaviour does not change.** If it changes it is not a refactor, it is a modification, and it
  goes round the normal loop.
- **Past a certain size you propose instead of applying**: many files, a public contract, a zone
  the branch never touched.

| | `standard` (default) | `high` |
|---|---|---|
| **Applies without asking** | rungs 1–2 (rename, extract method or variable) inside the branch's zone | **nothing** |
| **Proposes** | class extractions, value objects, patterns, anything touching callers outside the zone | **everything**, in the menu |
| **Then** | reports what it did | applies the selection, one remedy at a time |

Under `audit` nothing is applied and nothing is asked, at either level. **A wholesale rewrite is
never a decision of this skill** — at no level, and not even when the user selected it from the
menu. If an item has grown that far, go back and split it.

## The menu, at `high`

Ordered by benefit against cost, the items with documented pain at the top. Five things per item,
and without the fifth the menu hands the user work that is yours:

```
[DSG-007] Primitive Obsession — the account reference travels as a string in 9 places
  Evidence:   documented pain (a defect from an unnormalised reference) · 9 occurrences
  Remedy:     Value Object (rung 3 — extract method is not enough: the validation sits in 4 places)
  Cost:       1 new class, 9 callers, 3 tests to extend
  Benefit:    the validation stops being copied; the next format change happens in one place
  ▶ Recommendation: APPLY — this is the place that has already hurt
```

The four evidence labels: **documented pain** (a defect, a commit that touched five files, a test
that cannot be written) · **repetition** (three occurrences or more) · **signal** (two occurrences
plus churn) · **shape only** (no evidence: it could be done, nothing has happened). On
**shape only** items the default recommendation is **leave**, and it gets written: a menu where
everything looks worth doing is not a choice, it is a shopping list.

Past about fifteen items, group them by theme — by module, or by smell — and present the groups.
Fifteen decisions get made, forty do not. That threshold is this skill's own, not a figure of the
plugin.

Then **stop and ask in one block**, in the four-line shape held by
`${CLAUDE_PLUGIN_ROOT}/references/asking.md`: the items, what you recommend, and that the choice
is the user's. Apply only what was selected, one at a time, with the verification in between.
What was not selected goes to “seen and left” with its reason.

## What is not touched

- **Code outside the zone** that nobody asked to have redesigned — if the remedy demands it, it
  is a proposal, not an application.
- **Third-party dependencies and generated code.**
- **Framework mechanisms**: no duplicate gets built on top of one.
- **Public contracts** — APIs, signatures other systems use, persisted formats — without the
  user's decision.
- **Database schema and migrations**: another loop entirely.

## The report

The model below is in English; at runtime it is written in the language of whoever is using the
plugin.

```
## Design Revision — [zone / branch]

**Level:** standard | high [· audit] — [why: explicit argument, project default, fallback]

### Map (Phase 1)
- **Zone:** [files/modules] · **External callers:** [who]
- **The platform already offers:** [relevant hooks/base classes]
- **Constraints:** [language version, conventions]
- **Hotspots (churn):** [most-changed files; any declared limit on the measurement]
- **Net:** [tests present/absent, outcome]

**Balance:** applied N · proposed N · seen and left N

### Applied
**[DSG-001]** [Smell] — file:line
- **Occurrences:** [where, how many] · **Pain:** [evidence]
- **Remedy:** [rung; if a pattern, which one and why the rung below was not enough]
- **Checks:** [tests, lint/build]

### Proposed (the user decides)
**[DSG-002]** [Smell] — **Cost:** [files, callers, tests] — **Alternative:** [do nothing, and what that costs]

### Seen and left
**[DSG-003]** [Smell] — occurrences: 2 of 3 — **Reason:** [gate not passed: no pain / area untouched for years / cost > benefit]
```

At `high` the **Proposed** section is the menu, it comes before any application, and **Applied**
fills up only after the user's selection.

**This skill writes no working file and keeps no review ledger.** The occurrence counts under
“seen and left” are the memory that makes the rule of three fire on the next pass, and they live
in the report: whoever receives it is the one who keeps them. Nobody should go looking for them
on disk.

## Rules of behaviour

- **No pattern without proven pain.** The default is not to touch, and “left” is a legitimate
  outcome — often the best one.
- **Refactoring does not change behaviour.** If it does, it changes loop.
- **Do not fight the framework.** Before abstracting, look for the abstraction that is already
  there.
- **Do not redesign while solving something else.** One remedy at a time, isolated, verified.
- **The name comes before the pattern.** Half of all smells die with a rename.
- **Do not count lines as a victory.** Fewer lines with three more indirections is a loss.
- **`high` widens the search, not the permissions.**
- **At `high` nothing is applied before the choice.** Getting the trivial renames in early takes
  away the user's picture of the starting state.
- **Every menu item carries a recommendation.** A list without one is the work bounced back.
- **Do not raise the level on your own.** Propose it in one line at the end of the pass.
- **Record what you left**, with the occurrence counts.
