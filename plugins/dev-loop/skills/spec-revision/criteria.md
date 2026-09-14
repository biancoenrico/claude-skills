# Criteria for reviewing a specification

The yardstick a reviewer applies to the slice of a specification it was handed. Nothing here
tells anyone what to launch or when: this file is the judgement, and only the judgement.

## What you judge, and what you hand back

You judge the group you were pointed at — a section range, or the whole document when it fits
in one pass. **You change nothing.** Where you would have edited, describe the remedy inside the
finding and let the caller decide.

Your return takes the shape held by `${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`, with
`findings` in the format this file sets out below.

**Nothing gets pasted back.** No file contents, and no command output past the one line that
proves a finding. Whoever launched you has the document open already.

## The scenario grid

The five dimensions below catch what the specification **says badly**. This grid catches what it
**does not say at all**, and that is the half that costs more: a hole cannot be spotted by
re-reading, since there is nothing there to re-read. Whoever implements it fills the hole their
own way, and the defect surfaces once the work is done.

For **every behaviour** the specification describes, walk the eight cases and write down what the
document answers. Where it answers nothing, that is a finding — never an assumption made on the
document's behalf:

1. **The normal case** — the one the document tells.
2. **The boundaries** — the first, the last, zero, full, equal-to-the-threshold. Does the
   threshold belong to what sits above it or to what sits below? When the document says "beyond",
   is the exact value in or out?
3. **The datum that is not there yet** — what gets shown and what gets decided before the first
   measurement, the first save, the first link.
4. **The datum that arrives twice, or out of order** — duplicates, delays, inverted sequences.
   Does the last one count, the first one, or both?
5. **Time** — what expires, what is remembered, what is forgotten, and **after how long**. Every
   time window without a number is an ambiguity dressed up as a requirement.
6. **The user undoing** — cancel, correct, replace, start over. What survives the gesture and
   what has to be withdrawn along with it.
7. **Two surfaces showing the same fact** — screens, notifications, exports. Do they have to say
   the same thing? If so, **the document has to declare it as an invariant** rather than leave it
   to be inferred: this is the hole that produces two implementations of one rule, one per
   surface, and the day one of them changes the two contradict each other. It is the costliest
   defect this grid exists to catch, because it is born across two sections and neither of them
   contains it.
8. **The failure** — the datum that never arrives, the service that does not answer, the
   permission denied. What the user sees, and what stays written.

**Proportion.** On a small feature the grid is walked in two minutes and nearly every cell is
"does not apply". Write that down instead of skipping it: a cell declared inapplicable is a
decision taken, a cell skipped is a hole that looks like one.

The findings the grid produces are classified into the five dimensions below — usually 🟠
(undefined behaviour) or 🟡 (gap). **The grid is a method, not a sixth category.**

## The five dimensions

Sift the document on five dimensions, ordered by severity: the first two (🔴🟠) stop or misdirect
the implementation, the rest only make it harder work.

### 🔴 Blocking errors

- Logical contradictions between sections
- Mutually exclusive requirements
- References to entities the document never defines
- Implicit assumptions that invalidate the document if they turn out false

### 🟠 Critical ambiguities

- Technical terms used with more than one meaning
- Unspecified boundary conditions ("large", "fast", "often")
- Undefined behaviour for the edge cases
- Missing alternative flows (errors, exceptions)
- **The same rule stated twice, in two places and in different words.** This is not an innocuous
  repetition and it is not a matter of style: whoever implements reads two passages and writes
  the thing twice — two copies that agree today and diverge at the first change, since neither
  knows the other exists. If the two statements already disagree, it is a contradiction (🔴); if
  they agree, it is this. It holds even when the two places describe different screens, flows or
  actors — the rule is still one rule.

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

Running codes per prefix — `ERR-001`, `AMB-002`, `GAP-003`, `STY-004`, `SUG-005` — so that every
finding is quotable in the iterations that follow. Each one carries:

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

- **Do not invent a requirement.** Where information is missing, raise the gap rather than fill
  it with an undeclared guess. A visible hole is recoverable; a hole quietly plugged is not.
- **Do not invent a number.** If a threshold is needed and is not there, either you find it — a
  measurement, a standard, a citable source — or it becomes a finding. A plausible number is
  worse than a hole: the hole is visible, the plausible number passes the review and reaches
  production.
- **A doubled rule is stated once, not aligned.** Having found two copies of one rule, the
  correction is to keep one and have the other refer to it ("as described in §X"), never to
  rewrite the two into a match: two aligned copies are still two copies, and the next change
  moves only one of them. Where the rule lives in the code is not this document's business.

## The ledger

You also receive the ledger of this review when one exists for this document. Read it before
the object. A finding it records as rejected is closed — the user has already turned it down — and raising it
again spends their attention on a decision they have made. Its format is not restated here: it is
held by `${CLAUDE_PLUGIN_ROOT}/references/ledger.md`.

## Alternatives are not judged here

Whether the road chosen is the right one is a separate pass. The reviewer that runs it is handed
`${CLAUDE_PLUGIN_ROOT}/references/alternatives.md` as well, in its product variant, and works
from there.

Its findings use the fields above but carry **their own prefix, `ALT-`**. None of the five
dimensions covers "there is a materially better road", and without a prefix of its own such a
finding could not be quoted from one iteration to the next — which is exactly what the ledger
requires. What becomes of an alternative that holds up is settled in that file, and is not
repeated here; the consequence for this format is the prefix.
