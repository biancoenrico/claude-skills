# What makes a comment worth its rent

The criteria a comment is judged against: the nine reference rules, the nine shapes that look like
comments and are not, the shapes that do pay the rent, and the form of the ones that survive.

The question behind all of it, for a comment about to be written and for one being read:

> **What is lost if I delete it?**

If the answer is **readable in the lines below**, it is not a comment, it is noise. If the answer
cannot be phrased at all, the comment has no content — it has the shape of one.

**The rent is paid in readability, and the bill belongs to the whole file.** A comment too many
does not only cost the lines it occupies: it lowers the credit of all the others. Where comments
are rare, a reader stops at each one knowing something is in it; where they are dense, they skip
all of them — including the one that would have saved them the day.

The operational corollary is that **the context counts as much as the line**. The same sentence
pays its rent inside a thirty-line method and does not pay it inside a fifteen-command script,
where the sequence is already the explanation. If the neighbouring lines have reasons just as
strong and sit there mute, this one is not special.

## Three altitudes, three different jobs

| Level | What it has to add | Default |
|---|---|---|
| **Class / file / module** | what it is for, and when somebody ends up inside it | **present**, if the project's conventions call for it — but short |
| **Function / method** | the contract the signature does not state | **only if** the signature is not enough, or the conventions impose it |
| **Inside the function** | a dynamic the code does not tell | **none** |

### Class, file, module — complementary to the name

The name says *what it is called*. The comment says **what it is for**, in one or two lines of
plain language, the way it would be explained out loud to a colleague opening the file for the
first time. Where the project calls for it, one more line says *when* somebody puts their hands in
it: who uses it, how it is reached, what makes it change.

It does not repeat the name, does not list the methods (they are read by scrolling), does not open
with ceremony.

```
❌  /**
     * Class OrderDocumentManager
     *
     * This class handles the handling of order documents.
     * It provides methods for insertion, modification and deletion.
     */

✅  /**
     * Holds together the files hanging off an order (delivery notes, proofs of delivery,
     * tickets). Every upload in the orders area goes through here: this is where it is
     * decided where the file lands and which order it stays attached to.
     */
```

### Function or method — what the signature does not say

A docblock that rewrites the signature (`@param int $id The id`) is ceremony. What is needed is
what the signature **cannot** say: units and formats of the values, side effects, what happens on
error (exception? null? neutral value?), preconditions, edge cases, cost where it matters.

Where the project imposes a docblock on every method, that constraint wins: it gets written,
**short**, and the mandatory lines are not padded with prose.

### Inside the function — the default is silence

A comment in the middle of the code is justified only when it helps to understand a **dynamic**
the lines do not tell: why that order, why that value, what breaks if you touch it, which external
constraint forces it. Everything else — "loops over the elements", "if empty it returns" — is the
line below, said twice.

If the comment is there to explain **what** a block does because the block is unreadable, the
correction is not the comment: it is a better name or an extraction (see the crutch, shape 4).

## The nine reference rules

Source: [Best practices for writing code comments](https://stackoverflow.blog/2021/12/23/best-practices-for-writing-code-comments/)
(Stack Overflow Blog, 2021). In operational form:

1. **A comment does not duplicate the code.** `i = i + 1; // adds one to i` is deleted, always.
2. **A good comment does not excuse unclear code.** The code gets fixed first.
3. **If you cannot write a clear comment, the problem is the code.** The struggle to explain it is
   the symptom, not the cause.
4. **A comment removes confusion, it does not add it.** A cryptic annotation is worse than
   nothing.
5. **Non-idiomatic code gets a comment.** If something is done in a strange way, the reason
   belongs right there.
6. **Copied code carries the link to its source.** A reader has to be able to get back to the
   context and to the corrections.
7. **External references go where they are used** (standards, RFCs, a vendor's documentation, a
   ticket): next to the line they concern, not at the top of the file.
8. **A bugfix gets a comment**, with the reference to the issue: it is how anyone tells whether
   the patch is still needed. **The comment carries the constraint, the link carries the
   incident** — "this version of the library returns the date without a timezone (#412)", not
   "without this the date came out wrong". Rule 8 says to leave a trace, not to tell what
   happened: that account belongs in the issue, where it has a date, an author and a state.
9. **The incomplete is marked** by the project's convention (`TODO`/`FIXME` plus a reference), so
   the debt is visible instead of hidden.

Rules 5–9 say when a comment **pays its rent**; rules 1–4 say when it does not.

## The catalogue of shapes that look like comments and are not

**The principle alone does not stop them:** whoever writes them believes the principle and writes
them anyway, because every case looked at closely seems reasonable. What stops them is
**recognising the shape**.

1. **The paraphrase.** Says the line below in other words. `// increments the counter` over
   `$count++`.
2. **The ceremony.** Preambles and formulas: "This method is responsible for…", "Function that
   serves to…", the docblock that copies the signature and the types, `@return bool Returns a
   boolean`. Remove the preamble and the fact remains — or nothing remains, and then it was only
   preamble.
3. **The ornament.** Banners, rows of dashes, `// --- END OF CLASS ---`, and the comment put there
   for symmetry because the others have one. It is aesthetics, and aesthetics is exactly what this
   work does not do.
   - **Before calling a recurring form an ornament, count it in the code this work did not
     write.** A row of dashes appearing 969 times across 174 files, framework included, is not
     decoration: it is the house style, and the project's conventions win over any preference
     brought in from outside. Removing it leaves two halves of the same project written in two
     different ways.
   - `git grep -c '<the form>' <base-branch> -- <production directories>` answers in a second, and
     the answer does not depend on anyone's taste. The same caution as the wrong sample applies:
     the baseline is measured on code **preceding** the work in hand, never on what has just been
     produced.
   - What stays an ornament is what does not pass that test: the banner invented for the occasion,
     the comment put there for symmetry, the frame around a sentence that stands perfectly well on
     its own.
4. **The crutch.** Explains *what* an unreadable block does. The remedy is renaming or extracting;
   where the extraction is trivial and safe it is done, otherwise it is raised as an open point
   rather than forced.
5. **The working note.** `// TODO come back to this`, `// old version below`, blocks of
   commented-out code, notes to the reviewer. They belong to the process, not to the result: what
   is really needed goes into an issue, dead code is deleted (there is git).
6. **The stale comment.** Describes a behaviour that no longer exists. It is **the most damaging**
   of the catalogue, because a reader trusts it instead of the code. If the information is still
   needed it is corrected, otherwise it goes.
7. **The diary.** A changelog inside the file: dates, authors, "modified for ticket X". `git log`
   says it, and says it up to date.
8. **The defence of the refactor.** It is the diary disguised as a design rationale, and it is
   **the shape that survives more reviews than any other**, because it reads beautifully: dense
   prose, an apparent "why", often a precise number. But the subject is not the thing in front of
   you — it is the *change* that produced it, and whoever writes it is justifying their own work
   to a reviewer who is no longer there.
   - "This lives here and no longer inside X", "It was copied in four classes", "There used to be
     two", "It is the half that Y was missing", "It was born against Z, which a later batch
     deleted", "They used to live in a constant of W".
   - It costs double the others: it takes the place of the description that was needed **and** it
     ages badly, because it names things that no longer exist.
   - **The remedy is not to delete and be done.** Almost always the chronicle wraps a live
     constraint: the constraint is kept, in the present tense, and the story is thrown away. "It
     was born against the corpus, which a later batch deleted: … Today it stays for a different
     reason: the recorded expectations name the identifiers that come out of here" → "The recorded
     expectations name the identifiers that come out of here: moving the offset regenerates all of
     them".
9. **The averted incident.** Tells of a failure — real or imagined — instead of the property that
   keeps it away. "Otherwise it broke", "without this line the workers stayed on the old code",
   "not before, or the cache deletes it", "so it does not happen again". A reader has never seen
   that failure and has no way of knowing whether it existed at all, whether it was observed or
   merely feared, and whether the thing that caused it still exists.
   - It is **the twin of the defence of the refactor**, and they are told apart by the subject:
     there it is the change, here it is the disaster. The two often turn up together, because they
     come from the same gesture — whoever has just fixed something writes about the relief, not
     about the thing.
   - **The conditional is the signal**: "would delete", "would leave", "would end up". A property
     of the system is stated in the present indicative, because it is true now; an incident needs
     a verb form that holds it at a distance.
   - **The remedy is the same as shape 8: keep the mechanism, throw away the disaster.** Almost
     always the sentence contains a real one, and that is the half that is needed.

```yaml
❌  tool cache-clear
    # After cache-clear, not before: the restart signal lives in the cache, and a plain
    # purge would delete it, leaving the workers on the old code without anyone
    # noticing.
    tool workers-restart

⚠️  tool cache-clear
    # The restart signal lives in the cache: cache-clear deletes it, so workers-restart
    # goes after.
    tool workers-restart

✅  tool cache-clear
    tool workers-restart
```

**The second is better than the first and is still not enough**, and that is the error this entry
exists to stop: the natural correction of a narrated incident is to rewrite it as a property, and
rewriting is a gesture made without going back to the gate before it. But the real question stays
the one about the rent, and here neither of the two pays it.

Look at the lines around: the cache clear sits after the migration step for reasons just as good,
and has no comment; the directory creation sits before everything for reasons just as good, and
has no comment. **In a deployment script the order of the operations is the content**, and every
line sits where it sits because that point in the sequence is the only one where it makes sense.
Annotating one alone makes the others look interchangeable: it says something false about the rest
of the file, not only about itself.

## The shapes that do pay the rent

- **The why** of a non-obvious choice: why this algorithm, this order, this default. It **has to
  hold up empirically**: it is a property of the system *as it is now*, which a reader can check by
  opening the code, a library's documentation or the configuration. A why that is only true as
  history — "because it went wrong once" — is not a why, it is a memory, and a memory belongs in
  the commit or the ticket.
- **The external constraint** that explains an oddity: a known bug in a library, a regulatory
  requirement, the contract of a service, compatibility with a legacy system.
- **The trade-off** accepted knowingly, with its known limit.
- **The trap**: what breaks if somebody "simplifies" that line. These are the comments that save
  more time than any other.
- **Non-idiomatic code**, with the reason why it is not.
- **The source** of copied code (a link) and **external references** next to the line that uses
  them.
- **The bugfix** with its issue reference, and the **known limit** marked by convention.

## The form: how what survives gets written

- **Short.** One or two lines for a class, one for an inline comment. If five are needed, either it
  is documentation (and belongs elsewhere) or it is the code that is wrong.
- **Open on the fact**, not on a preamble. First useful word, not "This".
- **Plain language**, present tense, active voice. The way it would be said to a colleague, not
  written in a manual.
- **Do not repeat the name** of the thing being commented: the reader has just read it.
- **One comment, one fact.** Two different facts are two comments, in two different places.
- **The language of the prose is decided by the project**: `CLAUDE.md`/`AGENTS.md` if they say so,
  otherwise the language of the comments already in the file. **Names stay the ones in the code**
  and are not translated even inside the comment.
- **It has to read like one developer explaining a thing to another.** That is the measure, and it
  comes before every other item on this list: if a colleague reads it once and has understood, the
  comment is finished.
