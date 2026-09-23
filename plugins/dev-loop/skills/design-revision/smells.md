# Code smells, by family

design-revision's smell catalogue and reviewer criteria.

## What you judge, and what comes back

Judge **one family only** — the one named — over the zone and map handed to you; change nothing.

Return in the shape of `${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`. **No dumps** — no file
contents, no output beyond the proving line.

**Count and show — don't decide what's touched.** That's for whoever launched you, against
evidence you don't hold; a filtered pass comes back short, with nothing to show for it.

## Search by observable signal

Every entry carries the **signal** that finds it and the **remedy** answering it: search the
signal, not the feeling — taste buries what matters.

Remedies name a ladder rung — rename, extract method/variable, extract class/parameter object,
pattern (ladder + thresholds in `patterns.md`).

## Finding format

```
[DSG-NNN] <Smell> — <file>:<line>
  Occurrences: <where, how many> — counted, not estimated
  Signal:      <the observable thing that found it>
  Remedy:      <first choice, and which rung of the ladder>
```

`DSG-` + three digits. **Occurrences are counted** — file and line each; "about a dozen" isn't a
count.

## The families

| Family | Smell | Signal | Remedy |
|---|---|---|---|
| Bloater | Long Method | too long / mixed abstraction levels | Extract method; replace a temporary with a query |
| " | Large Class | too many responsibilities, fields only half the methods use | Extract class |
| " | Primitive Obsession | primitive carries meaning, validation scattered | **Value Object** |
| " | Long Parameter List / Data Clumps | same params travel together | Parameter object, extract class |
| OO abuse | Switch Statements | switch/if over a type, repeated, growing | Strategy or State |
| " | Temporary Field | filled only sometimes | Extract class |
| " | Refused Bequest | ignores half its inheritance | Composition over inheritance |
| Change preventer | Divergent Change | one class, unrelated reasons to change | Split by reason |
| " | Shotgun Surgery | touches the same files every time | Gather changes together |
| Dispensable | Duplicate Code | same logic, 3+ places | Extract it |
| " | Dead Code | unreached/unused/uncalled | Delete it |
| " | Lazy Class | no longer earns its file | Fold into caller |
| " | Speculative Generality | see below | see below |
| Coupler | Feature Envy | uses another's data more than its own | Move to the data |
| " | Message Chains | `a.b().c().d()` chain | Hide the delegate |
| " | Middle Man | only forwards | Cut it out |

## Speculative Generality, said plainly

An abstraction with one implementer, a factory for one class, an interface nothing else
implements, indirection "for when we need it" — a **dispensable**, on the defect side, not the
cure side. Hardest to see: it looks like craftsmanship, so nobody reports it, and it never repays
its cost — one file, one indirection, one jump per read, each time.

Cured by **taking away**: collapse into the implementer, drop the parameter, remove the layer.
Anticipated pain isn't evidence — anticipation produced the smell.

Report with the same three lines: where it is, implementers/callers (counted), the deletion that
answers it.

## Public references

- Code smells: <https://refactoring.guru/refactoring/smells>
- Design pattern catalogue: <https://refactoring.guru/design-patterns/catalog>
