# The remedy ladder, and the patterns at the top of it

Opened when a remedy is about to climb as far as a design pattern, and handed alongside
`smells.md` when the family under review leads there.

The thresholds here say whether a pattern is the **right shape** for the problem in front of
you. They do not say whether the problem has earned a remedy at all: that is weighed afterwards,
by the pain gate in Phase 3 of the skill that opened this file.

## The ladder

```
rename  →  extract method / variable  →  extract class / parameter object  →  GoF pattern
```

You climb **one rung at a time**, only when the rung below does not solve it, **and you say so**
in the finding. Half of all smells die on the first rung: the structure was right and the name
was wrong.

Three questions close most of them without a pattern at all:

1. Would a better **name** do it?
2. Would an **extraction** do it?
3. **Does the framework already do it?**

A pattern that duplicates a mechanism the framework already offers is debt, not structure.

## First tier — the twelve that pay off most often

The middle column says when the pattern is the right shape. The right-hand column is the one
that does the work.

| Pattern | Needed when | Too much if |
|---|---|---|
| **Value Object** | a primitive carries a meaning and the validation is scattered | the value has no rules of its own |
| **Strategy** | the same switch over a type in several places, growing | there are two variants and they have not changed in years |
| **State** | a state machine written as nested conditionals | there are two states |
| **Template Method** | same skeleton, different steps | **the framework already does it** with its own hooks |
| **Factory Method** | construction varies and the caller must not know how | it builds one class |
| **Builder** | a constructor with too many optional parameters | three parameters and no illegal combination |
| **Decorator** | behaviours that stack, the alternative being combinatorial subclasses | there is a single decoration |
| **Adapter** | an external interface that is incompatible or unstable | the outside never changes |
| **Facade** | a complex subsystem always used the same way | it only forwards — that is a Middle Man |
| **Observer** | several independent parties interested in one event | there is one interested party |
| **Chain of Responsibility** | a pipeline of handlers with conditions | two handlers, in a fixed order |
| **Command** | actions to queue, replay or undo | there is nothing to queue and nothing to undo |

## Second tier — the rest of the catalogue

The other GoF patterns exist and are worth knowing: one you do not know is one you will not
propose on the day it fits. They sit in a second tier because in an **ordinary line-of-business
application** the bar for proposing them is **higher, not lower**. Almost all of them come out
of problems — hierarchies that explode, tree-shaped data, memory pressure, polymorphic traversal
— that an application of that shape does not have.

| Pattern | Needed when | Why it usually is not needed here |
|---|---|---|
| **Abstract Factory** | families of objects that must stay consistent with each other (several drivers, several suppliers) | there is one family: it is a Factory Method in disguise |
| **Prototype** | copying an expensive or complex-stated object without depending on its class | most languages copy shallowly out of the box, and the data lives in rows |
| **Bridge** | two dimensions varying independently (abstraction × implementation) | the second dimension is nearly always imaginary, and it collapses into Strategy |
| **Composite** | tree structures handled uniformly (menus, categories, bills of material) | if the data is not a tree it is complexity for free |
| **Flyweight** | very many near-identical objects that will not fit in memory | a problem of scale that does not arise here |
| **Proxy** | controlling access: lazy loading, caching, permissions, logging around an object | the framework already offers hooks and caching |
| **Iterator** | exposing a traversal without showing the structure underneath | the language already has iteration built in — use it rather than reinventing it |
| **Mediator** | many objects talking to each other in a mesh | in an MVC application the controller already **is** the mediator |
| **Memento** | undoing or restoring a previous state | when versioning is genuinely needed it is usually a table, not an object |
| **Visitor** | new operations over a stable hierarchy without touching it | the hierarchy here is not stable, and double dispatch reads badly |

Proposing one of these carries an extra threshold, and it is a threshold **of the pattern**:
name **which of the problems in the middle column has already happened here**. That is the claim
to bring; the evidence behind it is weighed by Phase 3, not here.

## Three standing warnings

- **Singleton: almost never.** It introduces global state, wedges the tests, and modern
  frameworks already ship a container or a loader that does the job better.
- **Repository / Gateway over a model that already is one.** In an MVC framework the model is
  already the gateway to the data. A repository on top of it is a layer that carries nothing.
- **No pattern that duplicates a framework mechanism.** Where the framework has the hook, use the
  hook. The abstraction that merely resembles it is debt wearing the look of structure.

## Tools, where a project already has them

Measuring beats guessing, but **nothing gets installed without asking**: use what the project
already declares — its dependency file, its CI configuration. By category, with one example
apiece, deliberately from different ecosystems:

- **Complexity analyser** — cyclomatic and cognitive complexity, long methods, god classes
  (Radon, in Python).
- **Static analyser** — types, unreachable branches, dead parameters (PHPStan, in PHP).
- **Clone detector** — duplication across files and the hotspots it clusters in (jscpd, in
  JavaScript).
- **Automated refactoring tool** — for mechanical, large-scale migrations (OpenRewrite, in
  Java). Useful for a migration; never the source of a design decision.

A tool reports the **symptom**. The pain is brought by whoever brings the finding.

## Measuring churn

Churn is how often the files of a zone actually change. It is a measurement, so it is taken with
a command rather than remembered. `<zone>` is a git pathspec — a directory, or a glob — handed
to `git log` unchanged; quote it, or the shell expands it before git ever sees it.

```sh
git -c core.quotepath=false log --no-renames --format= --name-only \
    --since='12 months ago' -- '<zone>' |
  awk 'NF { count[$0]++ } END { for (p in count) printf "%d\t%s\n", count[p], p }' |
  LC_ALL=C sort -k1,1nr -k2,2 | head -n 20
```

`count<TAB>path`, most-changed first, the last twelve months and the first twenty files. Ties
break on the path in byte order, so two runs over the same repository print the same thing.
`core.quotepath=false` keeps a path outside ASCII from coming back escaped and unusable.
`--no-renames` is deliberate: rename detection is a per-repository setting, and a count that
changes with the reader's git configuration is not evidence.

Two edge cases, both of which change what the numbers mean:

- **A path that no longer exists in the working tree.** It still counts as history — it says the
  zone was worked over — but it is not a target. Test it with `[ -e "$path" ]` against the
  repository root and mark it, rather than letting a vanished file be proposed for a remedy.
- **A shallow or truncated clone.** `git rev-parse --is-shallow-repository` prints `true`, and
  every count below is then a **floor, not a total**. Say so where the numbers are used: a
  truncated history quietly makes a busy file look untouched.

Outside a git repository there is no churn to measure. That is not a zero — it is a measurement
that is unavailable, and it is declared as such.
