# Code smells, by family

The catalogue design-revision searches with, and the criteria file handed to each reviewer of
the smell pass.

## What you are judging, and what comes back

Judge **one family of smells only** — the one named in the request — over the zone you were
handed, reading it with the map that came with it. You change nothing: not a rename, not a
comment, not a note in a scratch file.

Return in the shape held by `${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`, with your
findings in the format below. **No dumps**: no file contents, and no command output beyond the
single line that proves a finding.

**Count and show. Do not decide whether anything gets touched.** Whether a finding earns a
remedy is settled after you return, by whoever launched you, against evidence you are not
holding. A pass that filters its own findings comes back short, and nothing afterwards shows
that it did.

## The principle: search by observable signal

Every entry below carries the **signal** that finds it and the **first-choice remedy** that
answers it. Search for the signal, not for the feeling: a finding with nothing observable behind
it is a difference of taste, and taste buries the findings that matter.

The remedies name a rung of the remedy ladder — rename, extract method or variable, extract
class or parameter object, design pattern. The ladder and the pattern thresholds live in
`patterns.md`, next to this file.

## The format of a finding

The same for every family:

```
[DSG-00N] <Smell> — <file>:<line>
  Occurrences: <where, how many> — counted, not estimated
  Signal:      <the observable thing that found it>
  Remedy:      <first choice, and which rung of the ladder it sits on>
```

The code is a running number, `DSG-` and three digits. **Occurrences are counted**: a list of
places, each with file and line. An estimate (“about a dozen”) is worth nothing to whoever reads
it, because the count is the number the decision turns on.

## Bloaters — grown past their size

- **Long Method** — it does not fit on one screen, or it holds more than one level of
  abstraction inside. → Extract method; replace a temporary with a query.
- **Large Class** — too many responsibilities; fields that only half the methods use.
  → Extract class.
- **Primitive Obsession** — strings and integers carrying a meaning of their own (codes, amounts,
  identifiers, formatted references) with the validation scattered around them.
  → **Value Object**, the most profitable remedy in the catalogue.
- **Long Parameter List** / **Data Clumps** — the same three or four parameters travelling
  together everywhere. → Parameter object, extract class.

## Object-orientation abuses

- **Switch Statements** — the same `switch` or `if` chain over a type, repeated in several
  places, growing with every feature. → Polymorphism: Strategy or State.
- **Temporary Field** — fields filled only under certain circumstances and empty the rest of the
  time. → Extract class.
- **Refused Bequest** — the subclass ignores half of what it inherits. → Composition in place of
  inheritance.

## Change preventers — the costly ones, because they tax every future change

- **Divergent Change** — one class that changes for unrelated reasons. → Split it by reason for
  change.
- **Shotgun Surgery** — one change that always touches the same handful of files. → Gather what
  changes together.

## Dispensables

- **Duplicate Code** — the same logic in three places. → Extract it.
- **Dead Code** — a branch nothing reaches, a parameter nobody passes, a method nobody calls.
  → Delete it.
- **Lazy Class** — a class that no longer earns the file it lives in. → Fold it back into its
  caller.
- **Speculative Generality** — see below; it has its own section because it is the one this
  catalogue exists for.

## Couplers

- **Feature Envy** — a method that uses another object's data more than its own. → Move it to
  where the data is.
- **Message Chains** — `a.b().c().d()`, the caller walking a structure it should not know.
  → Hide the delegate.
- **Middle Man** — a class that only forwards. → Cut out the middle man.

## Speculative Generality, said plainly

An abstraction with a single implementer. A factory that builds one class. An interface nothing
else implements. A layer of indirection “for when we need it”. It is a **dispensable**, and it
belongs on the defect side of the catalogue, not on the cure side.

It is worth saying in full because it is the hardest of the lot to see: it looks like
craftsmanship, so nobody reports it, and it never repays the cost it adds — one more file, one
more indirection, one more mental jump on every read.

It is also the one smell cured by **taking away**. The remedy is deletion: collapse the
abstraction into its single implementer, drop the parameter nobody passes, remove the layer.
Anticipated pain is not evidence of anything — anticipation is exactly what produced the smell.

Report it with the same three lines as the rest: where the abstraction is, how many implementers
or callers it actually has (counted), and the deletion that would answer it.

## Public references

- Code smells: <https://refactoring.guru/refactoring/smells>
- Design pattern catalogue: <https://refactoring.guru/design-patterns/catalog>
