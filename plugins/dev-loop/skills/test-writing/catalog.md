# The catalogue of shapes that pass for tests and are not

The principle that governs every entry below, and the question to put to any assertion you are
about to write or to judge:

> **If this assertion failed, who would you open the bug against** — this repository, or the
> language, the framework, a library?

Against the second, it is not your test. The principle on its own does not stop these shapes:
whoever writes them believes the principle and writes them anyway, because every single case,
looked at closely, seems a reasonable exception. What stops them is **recognising the shape**.
Learn the list, not the rule.

## 1. The platform

Asserting the semantics of the language (comparisons, conversions, ordering, floating point), or
that the framework does its job (the ORM saves, the router routes, the serializer serializes).

> Seen in the wild: an assertion that a loose comparison between an empty string and a string
> zero is false, inside a test named after the production line that performs that comparison.
> Break that line and the test stays green: it never touched it.

*The thin boundary:* verifying **how we use** the platform is ours. "Our model, when saved,
writes these columns" proves our model; "the ORM can do an INSERT" proves the ORM.

## 2. The test harness

Tests for one's own factories, builders, custom assertions, fixtures, seed data.

> Seen in the wild: a long series of test methods that each apply one state to a factory and then
> read back the column that state has just written.

**The reason it is safe not to test it, and it has to be understood or the rule does not hold:**
the harness **verifies itself through use**. If the data builder breaks, every test that uses it
goes red — immediately, noisily. A piece of production code can break where no test passes; the
harness cannot, every test goes through it by definition. Testing it is paying twice for the same
guarantee.

*The one possible carve-out, and it is not a permission — it is a criterion to be checked:* the
**rejection branches** of the harness, the ones that fire only when somebody misuses it, are
never crossed by use, so "it verifies itself" does not cover them.

**But existing is not enough to deserve a test.** The question is: *with that rejection broken,
what happens?*

- **A noisy error** (the insert fails, the process stops, the suite dies) ⇒ **no test.** Use
  catches it anyway, only with worse diagnostics. You lose a good message, not correctness.
- **Nothing happens** — no red anywhere, because *in current use nobody crosses that path* ⇒
  **no test.** It is a guard against a mistake nobody makes yet: its test can only fail if
  somebody deletes the guard, which proves the line exists, not that it is needed. The guard
  stays — it is the **test** that is not paid for.
- **A false green** (the wrong value passes and the tests carry on over rotten data) ⇒ **cover
  it**, and it is the only case where a test on the harness pays for itself.

**And the answer is measured, not guessed** — neutralise the rejection, run the suite, and
**look at what goes red**: if the only red is the test of that rejection, you are in the second
case, not the first. That is the distinction a count of failures does not give you.

Measured on a real harness with five rejection branches: two died with a database error, one was
unreachable on the current schema, and **two produced a single red — their own**. None to cover.
Expect the exception to be almost always empty.

## 3. Lint in disguise

Naming conventions, formatting, folder structure, the presence of a file. They run a thousand
times a day to answer the same question every time: that is review work, not suite work.

## 4. The state of the infrastructure

Asserting on what is in the database, the schema, the environment variables, the filesystem, the
configuration — as a **premise** for something else.

> Seen in the wild: a test that inserts a row and asserts that every shape of column has been
> filled, reading the real schema. Add a NOT NULL column with a migration and it goes red — and
> the correction belongs in the harness, never in production.

A schema, a configuration file, a lookup table **are not code we wrote**: they are data. *The one
legitimate case:* when that state is the **output** of the code under examination — proving that
a migration produced that column proves the migration, which is production code. As a
**premise**, never.

## 5. The copied production expression

The one you only recognise while writing, and the most insidious, because it *looks* targeted:
the test cites the line in its name and in its comment, but has copied its logic instead of
calling it. The two copies diverge and nothing goes red.

> Seen in the wild: a test re-typing by hand the production expression that splits a
> comma-separated list and looks for a member in it. The separator was changed in production and
> **every** test in the suite stayed green: that line was covered by nobody, and the test
> carrying its name was hiding the fact.

## 6. The round trip onto itself

The test writes with its own tools and reads back without the production code ever having run in
between.

## 7. The occasion instead of the behaviour

The test exists because something happened — a language version bump, a refactor, a feature
ticket — and the name and the comment carry the occasion instead of what the test pins down. A
test says that function X, with those inputs, gives Y. **Whether it manages that on this
environment is said by the run, not by the comment.**

> Seen in the wild: "one test for each point where the new major version of the language changes
> semantics", and "measured on both runtimes the value is identical". The first justifies the
> coverage with a date on the calendar; the second writes into the comment an outcome that is
> obtained by running the suite, and that goes stale the next day without anything going red.

**It counts for the "whether", not only for the how it is written.** If the reason you are
writing a test is that something changed, you do not have a reason yet: ask which behaviour is
worth pinning down, and if the answer does not come the test does not get written. The occasion
makes you look there; it does not justify the coverage.

*The thin boundary:* a harness that exists **in order** to compare two environments may speak of
them, because that is its job, and so may the project's documentation. It is the individual test
that must not.
