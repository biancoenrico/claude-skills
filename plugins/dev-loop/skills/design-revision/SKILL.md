---
name: design-revision
description: Looks at a branch's code shape — not correctness, not tidiness, but structure — and applies the smallest remedy that holds.
when_to_use: Before closing a branch, on inherited code, before a big refactor, or: 'this is duplicated everywhere', 'this switch keeps growing'. Not correctness (`/code-review`) or diff polish (`/simplify`).
argument-hint: "[standard|high] [audit] [path]"
---

# design-revision

## The two failures this exists to prevent

The first shows: duplicated logic, a growing switch, a class that knows everything, a method that
only forwards.

The second does not show — it looks like craftsmanship: **a pattern put where there was no pain**,
the Speculative Generality smell (a Dispensable, `smells.md`, which says why it never repays its
cost and why nobody reports it).

**It works harder at stopping the second than the first: default is not to touch, and "left" is a
legitimate outcome — often the best one.**

## Inputs

It runs as loop step 7 (`${CLAUDE_PLUGIN_ROOT}/references/loop.md`), after
`/dev-loop:plan-execution`, or when the user runs it directly before closing a branch; it calls
`/dev-loop:test-writing` when the zone has no net. In order of priority:

1. **Explicit target** — a path, a module, a class.
2. **The branch against its base** — `git diff <base>...HEAD` **plus the zone it runs through**:
   structure is judged on the surrounding code, not the diff alone.
3. **Work just done** in the conversation.

If the branch is huge or straddles unrelated areas, **narrow it and say so**: one zone done well
beats three brushed past.

## Two levels, plus a modifier

`audit` is not a third level (see `argument-hint` for usage); it combines with either of the two.

|  | `standard` (default) | `high` |
|---|---|---|
| **Searches for** | smells with pain already behind them | everything improvable |
| **Who chooses** | the skill, within Phase 5's limits | the **user**, item by item |
| `audit` | applies and asks nothing — report only | same |

**`high` widens the search, not the permissions** — every safeguard below still applies.

Level choice: explicit argument → project default → `standard`. **The report's first line declares
both** the level and the modifier, even when there is none (`standard`, no audit) — the only line
that tells a reader whether anything was touched. **Don't raise it yourself** — if "seen and left"
clusters in one area, say so and propose `high` over that area, in one line, at the end of the pass.

## Phase 1 — Local knowledge

**Never skipped**: proposing structure blind is guessing, paid for downstream.

Launch one `Explore` per question, five in parallel (`model: haiku`), under the agents-per-wave
cap (`${CLAUDE_PLUGIN_ROOT}/references/limits.md`).

1. **Boundaries and callers** — what the branch touches, who else uses it, searched not
   remembered: used once vs twenty times aren't refactored alike.
2. **What the platform already offers** — hooks, base classes, template methods: the right road
   is the existing hook, not a resembling abstraction.
3. **Conventions and constraints** — `CLAUDE.md` / `AGENTS.md`, nested included: style, language,
   above all its **version** — a remedy in syntax the project can't run is no remedy.
4. **The history** — what changes constantly vs what nobody touches, churn list already in hand
   (below): nothing hurts, nothing gets redesigned, where hands don't go.
5. **The net** — tests present, green or not.

Close with the **map, in half a page**: if you cannot say **who calls what**, go back and read.

### Churn, measured before the fan-out

The main thread runs the churn recipe
(`${CLAUDE_PLUGIN_ROOT}/skills/design-revision/patterns.md`) once, over the Phase 1 zone, feeding
point 4's Explore.

Three rules on reading it, the caller's rather than the recipe's:

- **List and warnings don't mix**: counts feed the map; a warning — truncated history above all —
  goes to the report's Hotspot line, a declared limit that changes the Phase 3 verdict.
- **A path that no longer exists is not a target**, only history.
- **Outside a git repository there is no churn.** Say so — the other two evidence forms stand.

## Phase 2 — One reviewer per smell family

Launch `dev-loop:reviewer` once per family in
`${CLAUDE_PLUGIN_ROOT}/skills/design-revision/smells.md`, five in parallel, under the
agents-per-wave cap (`${CLAUDE_PLUGIN_ROOT}/references/limits.md`). Each gets the Phase 1 map, the
zone, and that path as criteria; a family leading to a pattern also gets `patterns.md`'s path
(same directory).

Reviewers modify nothing and return in the shape of
`${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`: they count and show, Phase 3 decides.

## Phase 3 — The pain gate

For **every** smell, three lines; missing any one, **it does not get touched**:

1. **Occurrences** — where, with file and line. Counted, not estimated.
2. **Pain that has already happened** — the evidence.
3. **Cost of the remedy** — files, callers, test surface.

**Pain that has already happened** is one of three, shown not narrated:

- **Three real occurrences** — the refactoring literature's rule of three, not a plugin figure.
- **A place that already hurt** — a bug from there, a five-file change, an unwritable test.
- **Churn** — the Phase 1 measurement, not intuition.

**Anticipated** pain is never evidence, at either level — that is Speculative Generality
(`smells.md`).

| | `standard` (default) | `high` |
|---|---|---|
| **Gate** | decides: no evidence, no remedy | sorts: every item leaves labelled |
| **Evidence that suffices** | any of the three above — 3 occurrences, 1 documented pain, or measured churn | any, including none — the label says so |
| **Without evidence** | "seen and left", with the count | enters the menu as **shape only**, recommendation: leave |

What fails the gate is **"seen and left"**, with its count — what the next pass checks against the
rule of three.

## Phase 4 — The remedy, climbing from the lowest rung

Climb the ladder by the rule in `${CLAUDE_PLUGIN_ROOT}/skills/design-revision/patterns.md`, which
also holds the pattern thresholds, opened where a remedy nears a pattern. Don't count lines as a
victory — fewer lines with three more indirections is a loss.

## Phase 5 — Apply, with the net

- **Net first.** No tests over the behaviour about to move → `/dev-loop:test-writing` first:
  without a net it's rewriting, not refactoring.
- **One remedy at a time**, isolated from other work, verified before the next, in separable
  commits.
- **Behaviour doesn't change** — if it does, it's a modification, back to the normal loop.
- **Past a certain size, propose instead of applying** — many files, a public contract, a zone
  the branch never touched.

| | `standard` (default) | `high` |
|---|---|---|
| **Applies without asking** | rungs 1–2 (rename, extract method/variable) inside the zone | **nothing** |
| **Proposes** | class extractions, value objects, patterns, or outside callers | **everything**, in the menu |
| **Then** | reports what it did | applies the selection, one remedy at a time |

Under `audit`, nothing applies or is asked. **A wholesale rewrite is never this skill's call** —
even picked from the menu, split it first.

## The menu, at `high`

Ordered by benefit vs cost, pain first. Each item (`[DSG-NNN] <Smell> — <location>`) carries five
fields, or the menu hands the user your work: **Evidence** (label · count) · **Remedy** (rung +
pattern if any) · **Cost** (files, callers, tests) · **Benefit** · **Recommendation**
(APPLY/leave + reason).

Four evidence labels: **documented pain** (defect, five-file change, unwritable test) ·
**repetition** (≥3 occurrences) · **signal** (2 occurrences plus churn) · **shape only** (no
evidence yet). **Shape only** defaults to **leave**, written as such: a menu where everything
looks worth doing is a shopping list, not a choice.

Past ~15 items, group by theme — module or smell: 15 decisions get made, 40 do not. This skill's
own threshold, not the plugin's.

Then **stop and ask in one block**, in the shape held by
`${CLAUDE_PLUGIN_ROOT}/references/asking.md`: items, your recommendation, the user's choice. Apply
only what's selected, one at a time, verifying between; the rest goes to "seen and left" with its
reason.

## What is not touched

- **Code outside the zone** nobody asked to redesign — a remedy demanding it is proposed, not
  applied.
- **Third-party dependencies, generated code, framework mechanisms** — no duplicate on top of one.
- **Public contracts** — APIs, signatures other systems use, persisted formats — without the
  user's decision.
- **Database schema and migrations** — another loop entirely.

## The report

The model below is in English; at runtime, write it in the plugin user's language.

```
## Design Revision — [zone / branch]

**Level:** standard | high · audit or no audit — [why: argument / default / fallback]

### Map (Phase 1)
- **Zone:** [files/modules] · **External callers:** [who]
- **Platform offers:** [hooks/base classes]
- **Constraints:** [language version, conventions]
- **Hotspots (churn):** [most-changed files; declared limits]
- **Net:** [tests present/absent, outcome]

**Balance:** applied N · proposed N · seen and left N

### Applied
**[DSG-001]** [Smell] — file:line
- **Occurrences:** [where, how many] · **Pain:** [evidence]
- **Remedy:** [rung; pattern + why rung below failed]
- **Checks:** [tests, lint/build]

### Proposed
**[DSG-002]** [Smell] — **Cost:** [files, callers, tests] — **Alternative:** [cost of doing nothing]

### Seen and left
**[DSG-003]** [Smell] — occurrences: 2 of 3 — **Reason:** [no pain / untouched for years / cost > benefit]
```

At `high`, **Proposed** is the menu, before any application; **Applied** fills only after
selection.

**This skill writes no working file and keeps no review ledger.** "Seen and left" counts feed the
next pass's rule of three; they live in the report, kept by whoever receives it — nobody looks on
disk.
