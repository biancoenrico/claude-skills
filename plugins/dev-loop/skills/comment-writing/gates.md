# The three proofs, and the five checks that feed them

The gates a comment passes before it is allowed to stay, the recipes that find the candidates, and
the shape of the report that declares what ran.

**Why the recipes live here and not in the skill file.** Not because a check is mechanical: a
recipe proposes, the judgement is the skill's. They live in this file because a skill file has a
character cap and a reference file does not, and because the step that uses them cites this file
instead of carrying the commands in the middle of a procedure. An earlier draft of this plugin
shipped these five checks as a shell script; the script was withdrawn, and the plugin now ships a
single script, for mutation. What survives of it is below, as commands anybody can run by hand.

## The cutting proof

For every comment that survives, one line:

> **without this comment what is lost is:** _[the information]_

And that information **must not be readable in the lines the comment accompanies**. If it is, the
comment is deleted — even if it is beautiful, even if it has just been written.

It is the analogue of proving a test by mutation: a freshly written comment proves that somebody
wrote a comment, not that the comment is needed. The difference only shows when you try taking it
away.

## The new reader's proof

The second gate, and it applies to **every** comment, in writing as in review. The cutting proof
asks whether the comment carries information; this one asks **who it is talking about**.

> Reread the comment as somebody who cloned the repository this morning and has never seen any
> previous version of this file. **Every sentence they find incomprehensible, or that asks them to
> imagine how it was before, is chronicle and gets rewritten in the present.**

Whoever has just made the change cannot run this proof in their head: they hold the previous
version in mind, so the sentence sounds sensible and passes. It takes checks that do not depend on
memory, and the four below are those checks.

**In tests it tightens further, and the name goes too.** A test already declares what it proves,
through a path mirroring the file under test and through its own name: a comment adding "see
`Orders_model::get_list()`" says nothing the reader does not already have in front of them. What is
left to the comment is the case: what happens, with which inputs, and what would break.

**The corollary is itself a gate, and it is worth keeping:** if the case cannot be explained
without pointing at a piece of code, the test is wrong or unnecessary. Either it proves something
with no behaviour of its own to tell, or it is named after the line instead of the behaviour, and
in both cases the remedy is in the test, not in the comment.

## The fidelity proof

The third gate, and it is born out of the second. When you go looking for chronicle you find it
*inside* a sentence, and the natural gesture is to delete the sentence — carrying away the fact
that sentence contained. It is the symmetrical failure of the blindness, and it arrives as soon as
the blindness is cured: first everything was kept, now too much is cut.

> **No measured number and no name may disappear from a comment without being said again
> elsewhere or declared stale in writing.**

Line numbers are the exception and do come out, but **the case they pointed at does not**: if a
comment cited a file and a line to say "this is where the price is frozen", the number goes and the
sentence stays, with the name of the method or the constant in the line's place.

Facts are the part of a comment nobody can reproduce from memory: "fourteen tests out of fourteen
stayed green" is the proof that the check is needed, and without it what is left is an assertion.
Deleting it together with the piece of chronicle around it is a net loss: the chronicle was the
garnish, the measurement was the substance.

When a fact really is tied to something that no longer exists, the choice is still explicit: either
it is reformulated as a measurement, or it is declared stale in the report. Never let it drop in
silence.

## The five checks

Each check has a fixed name. The name is how a finding is labelled, so that a reader of the report
can tell which gate raised it.

A finding is written on one line, four fields:

```
file:line:check:text
```

**The rule is a split rule, not a field count:** the first three `:` separate the fields and
everything after the third one is the text. A comment carrying a colon of its own ("TODO: review
this") therefore arrives whole, while a reader counting four fields would cut it in half.

**And the rule that governs all five: the recipe proposes, the judgement is the skill's.** A line
that comes out of a grep is a candidate, never a verdict.

**Run the five in one shell command**, each output under its own `=== name ===` header. Every
separate call is a round trip to the model, and the checks do not depend on one another.

### `process-ref` — references to the process

Terms that live in a plan or in a conversation, not in the repository: "batch 09", "decision D1",
"the closing criterion of batch 05", "level 1", "the corpus", "after the review". Whoever opens the
file cannot resolve them, and in six months nobody can. They belong in a commit or a ticket, never
in a comment.

The base list, English and Italian:

```bash
grep -rniE 'batch [0-9]|decision [a-z0-9]|after the review|decisione [a-z0-9]|dopo la revisione|come deciso' \
  <target> --include='*.<ext>'
```

**Extend it with the vocabulary of the plan.** Those are the names *the plan* uses, not the code,
and they are exactly what a new reader cannot resolve. Where the plan's index is reachable, its
shared vocabulary is the source of the extra terms; where it is not, the base list above is all
there is, and the report says so.

*What a false positive looks like:* a comment citing a real, resolvable thing whose name happens to
match — a class actually called `Batch`, a numbered decision recorded in the repository itself.

### `missing-name` — names cited that no longer exist

Every class, method or constant cited has to be findable in the repository; if it is not, the
comment is talking about something that has been deleted.

```bash
grep -rhoE '`[A-Za-z_][A-Za-z0-9_:]+(\(\))?`|[A-Za-z_][A-Za-z0-9_]*::[a-z_]+\(\)' <target> \
  | tr -d '`' | sed 's/()$//' | sort -u \
  | while read -r n; do git grep -qF "$n" || echo "MISSING: $n"; done
```

The `Class::method()` form is included by hand: with the parentheses inside the backticks a regular
expression over `[A-Za-z0-9_:]` alone does not see it, and that is precisely where renamed methods
hide.

*Two declared limits.* `git grep` only sees **tracked** files: a name that so far lives in a file
nobody has added yet reads as missing, and a finding on a name just written is that false positive.
And a hit whose own line is a comment is not an occurrence of the name in the code — the same
comment, or another one, found itself.

**This check alone is not enough, and it is worth knowing before trusting it.** Measured on a suite
full of chronicle it gave **zero** results, while `process-ref` gave fourteen. The chronicle of a
refactor names the vanished things **in prose** — "it used to live inside the orders seeder" —
without backticks, so no search over names sees it. `missing-name` serves dead references, which
are a different defect; for chronicle what counts are `process-ref` and the rereading.

### `line-ref` — the line number, never cited

A line moves at the first extracted method, the first line added above, the first schema change:
the comment stays behind on its own, and a reader trusts it, opens that line and finds something
else. The worst damage is not the wrong comment. It is that whoever touches a file finds themselves
having to update comments scattered elsewhere, in files that have nothing to do with their change.

**In the number's place goes the case, described.**

```bash
grep -rnE '[A-Za-z_][A-Za-z0-9_/]*\.[A-Za-z0-9]+:[0-9]+|`:[0-9]+' <target>
```

Every line that comes out gets rewritten. **There is no "the citation is correct, so it stays"
variant:** it was correct this morning, and the comment has no way of noticing when it stops being
so.

*What a false positive looks like:* a URL with a port, a timestamp, a version range — anything
where `something:NN` is not a file and a line.

### `tense` — the past and the conditional

A comment describing the system speaks in the present. Every verb in the past or the conditional is
a candidate averted incident or a candidate diary: not automatically to be deleted, but to be
reread asking *which moment it is talking about*. If it talks about a moment the new reader cannot
place, it is rewritten in the present or it goes.

```bash
grep -rniE '(was|were|had|would|could|should|might|previously|formerly)' <target> --include='*.<ext>'
grep -rniE '(era|erano|aveva|avevano|fu|furono|sarebbe|avrebbe|potrebbe|dovrebbe|veniva|venivano|precedenza)' \
  <target> --include='*.<ext>'
```

The same words turn up in legitimate prose too — "otherwise it returns null" describes a contract,
not an incident — so **the grep proposes and the rereading disposes**. The measure is the averted
incident of the catalogue: the subject is the property, not the disaster.

*The declared limit:* the patterns exist for English and Italian only. On prose in any other
language **the check is skipped**, and the report says it was.

### `lost-fact` — the facts a diff drops

The check behind the fidelity proof, and the only one that needs a base reference: it compares the
comments of the working tree against the comments of `<ref>`, and reports every number and every
name the base carried and the working tree no longer carries anywhere.

```bash
d=$(git diff -U0 <ref> -- <target>)
comm -23 \
  <(printf '%s\n' "$d" | grep -E '^-[[:space:]]*(\*|//|#)' | grep -ohE '[0-9]+([.,][0-9]+)?%?|[A-Za-z_]+\.[a-z]+:[0-9]+' | sort -u) \
  <(printf '%s\n' "$d" | grep -E '^\+[[:space:]]*(\*|//|#)' | grep -ohE '[0-9]+([.,][0-9]+)?%?|[A-Za-z_]+\.[a-z]+:[0-9]+' | sort -u)
```

That recipe wants a shell with process substitution — bash, not a plain POSIX shell; where there is
none, write the two sorted lists to a pair of files and run `comm` over those.

Every line that comes out is a fact the diff removes and does not put back: either it goes back in,
or the report says why it no longer holds. There are some false positives — a figure reformulated in
words is the common one — and they cost less than a lost fact.

**The line field of a `lost-fact` finding is written `base@NN`** — line NN in the `<ref>` version.
The specification writes it `base:NN`; this plugin changed it to `base@NN`, a deviation already
declared where the format was defined, because a fourth `:` inside the line field breaks the split
rule above. `base:NN` appears in this file only in this sentence, never as a format to read.

## When a check does not run

The judgement has to know when a gate was not exercised, so each of these goes in the report as a
declared degradation rather than passing in silence:

- **Prose in a language other than English or Italian** — `tense` is skipped; there are no patterns
  for it.
- **Outside a git repository** — `missing-name` and `lost-fact` cannot run at all; the other three
  do.
- **A base reference git cannot resolve** — `lost-fact` does not run. The invocation is corrected
  once; if it still will not resolve, the fact goes in the report as a declared limit, not ignored.
- **A file whose extension carries no comment syntax anyone here knows** — it is not read, and it is
  named.

Two of these cases used to be exit codes of a script that no longer ships. What matters is the same:
a check that did not run is reported as not run, never as clean.

## The report

Include only the sections with at least one item.

```
## Comment writing — [writing | review]

**Scope:** [files / diff / range]
**Conventions:** [language of the prose, mandatory docblocks, anything else from the calibration]

**Balance:** written N · rewritten N · corrected N · **brought to the present N** · removed N ·
discarded up front N · promoted to code N

### Written / rewritten
**[CMT-001]** file:line — [class | function | inline]
- **Without it, what is lost:** [information]
- **Text:** [the comment, or its gist]

### Removed / discarded
**[CMT-002]** file:line — **Reason:** [paraphrase | ceremony | ornament | working note | stale |
diary | crutch]

### Promoted to code
**[CMT-003]** file:line — [renamed X to Y | extracted Z] — the comment is no longer needed

### Open points
- [crutches not extracted because the operation was not trivial, with the reason]

### Verifications
- [syntax check or linter on the touched files, and the outcome]
- [the gates: existence gate, process-ref, missing-name, line-ref, tense, lost-fact — and any that
  did not run, with why]
- [facts removed and not put back, each with why it no longer holds — empty if none]
```

Sequential codes (`CMT-001`, `CMT-002`…) so that every entry can be cited later.
