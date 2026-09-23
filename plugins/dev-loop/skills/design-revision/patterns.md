# The remedy ladder

Opened when a remedy nears a pattern, alongside `smells.md`. Thresholds say whether it's the
**right shape**, not whether it earned a remedy — Phase 3's gate weighs that.

## The ladder

```
rename  →  extract method / variable  →  extract class / parameter object  →  GoF pattern
```

Climb **one rung at a time**, only when the rung below fails, **and say so**: half of all smells
die on the first rung — structure right, name wrong.

Three questions close most without a pattern: better **name**? an **extraction**? **does the
framework already do it**? **No pattern duplicating a framework mechanism** — use the hook; a
resembling abstraction is debt wearing structure's look, not structure.

## First tier

| Pattern | When | Skip if |
|---|---|---|
| **Value Object** | primitive + meaning, scattered validation | no rules of its own |
| **Strategy** | switch over a type, in several places, growing | 2 variants, static for years |
| **State** | state machine, nested conditionals | 2 states |
| **Template Method** | same skeleton, diff steps | framework already does it |
| **Factory Method** | construction varies, caller unaware how | builds one class |
| **Builder** | ctor w/ many optional params | 3 params, no illegal combo |
| **Decorator** | stacking behaviours vs combinatorial subclasses | single decoration |
| **Adapter** | external interface, incompatible/unstable | outside never changes |
| **Facade** | complex subsystem, same usage always | only forwards — Middle Man |
| **Observer** | several parties, one event | one interested party |
| **Chain of Responsibility** | handler pipeline, conditions | 2 handlers, fixed order |
| **Command** | queue/replay/undo | nothing to queue/undo |

## Second tier

Worth knowing — one you don't know, you won't propose. Bar's **higher** here: most solve problems
(exploding hierarchies, tree data, memory pressure, polymorphic traversal) an ordinary app lacks.
Proposing one needs naming which "when" problem already happened — the claim; Phase 3 weighs the
evidence.

| Pattern | When | Skip because |
|---|---|---|
| **Abstract Factory** | families of objects staying consistent | 1 family: Factory Method in disguise |
| **Prototype** | copying an expensive or complex-stated object, class-independent | languages copy shallowly; data's in rows |
| **Bridge** | two dimensions varying independently | 2nd usually imaginary — collapses into Strategy |
| **Composite** | tree structures, handled uniformly | non-tree data = complexity for free |
| **Flyweight** | many near-identical objects, memory-heavy | a scale problem that does not arise here |
| **Proxy** | access control: lazy load, cache, perms, logging | framework already offers hooks/caching |
| **Iterator** | traversal w/o exposing structure | language already has iteration |
| **Mediator** | many objects in a mesh | in MVC the controller **is** the mediator |
| **Memento** | undoing/restoring a state | versioning is usually a table |
| **Visitor** | new ops over a stable hierarchy | hierarchy isn't stable; double dispatch reads badly |

## Warnings and tools

- **Singleton: almost never** — global state, wedged tests; frameworks ship a better
  container/loader.
- **Repository/Gateway over a model that's already one** — in MVC the model is the gateway; a
  layer on top carries nothing.

Measuring beats guessing, but **nothing installs without asking**: use what the project
declares. One per category, different ecosystems:

- **Complexity analyser** — cyclomatic/cognitive complexity, long methods, god classes (Radon).
- **Static analyser** — types, unreachable branches, dead parameters (PHPStan).
- **Clone detector** — duplication and its hotspots (jscpd).
- **Automated refactoring tool** — mechanical, large-scale migrations (OpenRewrite); never a
  design decision.

A tool reports the **symptom**; the pain comes from whoever finds it.

## Measuring churn

How often a zone's files change — a command, not memory. `<zone>`: a git pathspec passed
unchanged to `git log`; quote it or the shell expands it.

```sh
git -c core.quotepath=false log --no-renames --format= --name-only \
    --since='12 months ago' -- '<zone>' |
  awk 'NF { count[$0]++ } END { for (p in count) printf "%d\t%s\n", count[p], p }' |
  LC_ALL=C sort -k1,1nr -k2,2 | head -n 20
```

`count<TAB>path`, most-changed first, 12 months, top 20; ties break on path byte order.
`core.quotepath=false` keeps non-ASCII paths readable; `--no-renames` is deliberate — rename
detection is per-repo, so a shifting count isn't evidence.

Three edge cases:

- **A path gone from the working tree** counts as history, not a target: test `[ -e "$path" ]`
  against the repository root, mark it — no remedy there.
- **A shallow/truncated clone** (`git rev-parse --is-shallow-repository` = `true`) makes every
  count a **floor, not a total**: a busy file can look untouched. Say so where the numbers are
  used.
- **Outside a git repository**, churn is unavailable, not zero — say so.
