# The catalogue of shapes that pass for tests and are not

The question for any assertion:

> **If this assertion failed, who would you open the bug against** — this repository, or the
> language, the framework, a library?

Against the second, it is not your test. Recognising the shape stops these — each looks reasonable
up close.

## 1. The platform

Asserting the language's semantics (comparisons, conversions, floating point), or the framework's
(ORM saves, router routes, serializer serializes).

> Seen in the wild: asserting a loose empty-string-vs-zero comparison false, in a test named after
> the line performing it — break that line and the test stays green.

*Thin boundary:* **how we use** the platform is ours — "our model, saved, writes these columns"
proves our model; "the ORM can INSERT" proves the ORM.

## 2. The test harness

Tests for one's own factories, builders, assertions, fixtures, seed data.

> Seen in the wild: test methods that each set one state on a factory and read back the column it
> just wrote.

The harness **verifies itself through use**: a broken builder reds out every test using it at
once — production code can break silently.

**Carve-out, not permission:** **rejection branches** (misuse only) escape self-verification — but
existing isn't enough: ask *what happens if broken?*

- **Noisy error** ⇒ **no test**: use catches it too, worse diagnostics only.
- **Nothing happens** (nobody crosses that path) ⇒ **no test**: it guards an unmade mistake,
  provable only by deleting the guard, which shows existence not need — the guard stays, the
  **test** doesn't.
- **False green** (bad value passes, later tests rot) ⇒ **cover it**: the only payoff case.

**Measured, not guessed**: neutralise the rejection, run the suite, see what goes red — only its
own test ⇒ case two. On a real harness with five branches: two died with a database error, one was
unreachable on the schema, **two produced a single red — their own** — none to cover. Expect the
exception nearly always empty.

## 3. Lint in disguise

Naming conventions, formatting, folder structure, a file's presence: run constantly to answer the
same question — review work, not suite work.

## 4. The state of the infrastructure

Asserting on the database, schema, env vars, filesystem or config as a **premise**.

> Seen in the wild: inserting a row and asserting every column filled, off the real schema — a
> NOT NULL migration breaks it, a fix belonging in the harness, not production.

Schema, config, lookup tables **are data, not code we wrote**, except as the **output** of the
code under test — a migration producing the column proves the migration. As a **premise**, never.

## 5. The copied production expression

Recognised only while writing: it names the covered line but copies its logic instead of calling
it — the copies diverge and nothing goes red.

> Seen in the wild: hand-retyping the production split-and-lookup on a comma-separated list. The
> separator changed and **every** test stayed green — nobody covered that line, and the test named
> after it hid the fact.

## 6. The round trip onto itself

The test writes with its own tools and reads back without production code running in between.

## 7. The occasion instead of the behaviour

The test exists because something happened — version bump, refactor, ticket — its name carrying
the occasion, not the behaviour. The ticket or refactor that brought you here belongs in the
commit message, not in the test's name or comment. A test says function X, given inputs, gives Y —
**the run says whether, not the comment**: a run's outcome in a comment goes stale unnoticed.

> Seen in the wild: "one test per point the new major version changes semantics", and "measured on
> both runtimes, identical" — the first justifies coverage by date, the second bakes a run's
> outcome into the comment, stale by the next change.

**It's about "whether", not the writing.** A test written because something changed has no reason
yet — ask what behaviour matters, skip it if none comes.

*Thin boundary:* a harness built **to** compare environments may speak of them, and so may the
project's documentation; a single test must not.
