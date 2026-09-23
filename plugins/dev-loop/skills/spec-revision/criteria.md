# Criteria for reviewing a specification

The yardstick a reviewer applies to its slice of a specification. Nothing here says what to
launch or when: this file is the judgement, and only the judgement.

## What you judge, and what you hand back

You judge the group you were pointed at — a section range, or the whole document when it fits
in one pass. What you judge and what you never touch: `${CLAUDE_PLUGIN_ROOT}/agents/reviewer.md`.
Your return takes the shape held by `${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`, with
`findings` in the format this file sets out below.

## The scenario grid

The five dimensions below catch what the specification **says badly**. This grid catches what it
**does not say at all** — the costlier half, since a hole cannot be spotted by re-reading: there
is nothing there to re-read. Whoever implements it fills the hole their own way, and the defect
surfaces once the work is done.

For **every behaviour** the specification describes, walk the eight cases and record what the
document answers. Answering nothing is a finding — never an assumption made on its behalf:

1. **The normal case** — what the document tells.
2. **The boundaries** — first, last, zero, full, threshold-equal. Does the threshold belong above
   or below it? Does "beyond" include the exact value?
3. **Not there yet** — what shows, and what gets decided, before the first measurement, save, or
   link.
4. **Arrives twice, or out of order** — duplicates, delays, inverted sequences. Does the last one
   count, the first, or both?
5. **Time** — what expires, what's remembered, what's forgotten, and **after how long**. A time
   window without a number is an ambiguity dressed up as a requirement.
6. **The user undoing** — cancel, correct, replace, start over. What survives the gesture, and
   what has to go with it.
7. **Two surfaces, one fact** — screens, notifications, exports. If they must agree, **the
   document must declare it as an invariant** rather than leave it inferred: the costliest hole
   here, born across two sections that neither contains.
8. **The failure** — the datum that never arrives, the service that doesn't answer, the
   permission denied. What the user sees, and what stays written.

**Proportion.** A small feature's grid is walked in two minutes, most cells "does not apply" —
write that down instead of skipping it: an inapplicable cell is a decision taken, a skipped one
is a hole that looks like one.

Grid findings fall under the five dimensions below — usually 🟠 (undefined behaviour) or 🟡
(gap). **The grid is a method, not a sixth category.**

## The five dimensions

Sift the document on five dimensions, by severity: the first two (🔴🟠) stop or misdirect the
implementation; the rest only add extra work.

### 🔴 Blocking errors

- Logical contradictions between sections
- Mutually exclusive requirements
- References to entities the document never defines
- Implicit assumptions that break the document if they turn out false

### 🟠 Critical ambiguities

- Technical terms used with more than one meaning
- Unspecified boundary conditions ("large", "fast", "often")
- Undefined behaviour for the edge cases
- Missing alternative flows (errors, exceptions)
- **The same rule stated twice, differently worded.** Whoever implements reads both and writes it
  twice — two copies that agree today, diverge at the next change, since neither knows the other
  exists. Already disagreeing, it's a contradiction (🔴); agreeing, it's this — holds even across
  different screens, flows or actors, since it's still one rule.

### 🟡 Completeness gaps

- Sections declared but never written
- External dependencies left undocumented
- Acceptance criteria absent or not verifiable
- Missing examples for complex requirements

### 🔵 Style and structure inconsistencies

- Non-uniform terminology for one concept
- Uneven level of detail between comparable sections
- Inconsistent formatting

### ⚪ Suggestions (non-blocking)

- Diagrams or examples that would help
- Sections that would read better reorganised
- Notes for later

## The shape of a finding

Running codes per prefix — `ERR-001`, `AMB-002`, `GAP-003`, `STY-004`, `SUG-005` — so every
finding is quotable in later iterations. Each one carries:

- **Position** — section and sentence, or file and line.
- **Problem** — what is wrong, precisely.
- **Impact** — where it is not obvious: what the implementation does wrong because of it. 🔴 and
  🟠 always carry it.
- **Suggested fix** — how to correct it.

```
[ERR-001] <short title>
- Position: section X.Y / line N
- Problem: <precise description>
- Impact: <why it blocks the implementation>
- Suggested fix: <how to correct it>
```

## Three rules of judgement

- **Do not invent a requirement.** Missing information is a gap to raise, not a guess to fill in.
  A visible hole is recoverable; a quietly plugged one is not.
- **Do not invent a number.** A missing threshold is either found — a measurement, a standard, a
  citable source — or raised as a finding. A plausible number is worse than a hole: the hole is
  visible, the plausible number passes review and reaches production.
- **A doubled rule is stated once, not aligned.** Keep one copy, have the other refer to it ("as
  described in §X") — never rewrite both into a match, since aligned copies are still two copies
  and the next change moves only one. Where the rule lives in the code isn't this document's
  business.

## The ledger

You also receive this document's ledger, when one exists — read it before the object. A finding
recorded as rejected is closed: the user already turned it down, and re-raising it spends their
attention on a decision already made. Format held by
`${CLAUDE_PLUGIN_ROOT}/references/ledger.md`.

## Alternatives are not judged here

Whether the chosen road is right is a separate pass. Its reviewer also gets
`${CLAUDE_PLUGIN_ROOT}/references/alternatives.md`, in its product variant, and works from
there.

Its findings use the fields above, with **their own prefix, `ALT-`** — no dimension above covers
"a materially better road", and without a prefix such a finding couldn't be quoted across
iterations. What becomes of a holding alternative is settled in that file, not here.
