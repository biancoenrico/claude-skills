# What makes a comment worth its rent

The criteria a comment is judged against: the nine reference rules, the nine shapes that look like
comments and aren't, the shapes that do pay rent, and the form of what survives.

The question behind all of it, written or read: **what is lost if I delete it?** Readable below →
noise. Unphraseable → no content, only the shape of one.

**The rent is paid in readability, and the bill belongs to the whole file.** A comment too many
doesn't just cost its own lines: it lowers the credit of all the others. Where comments are rare, a
reader stops at each one knowing something is in it; where dense, they skip all of them, including
the one that would have saved them the day.

**Context counts as much as the line.** The same sentence pays its rent in a thirty-line method and
doesn't in a fifteen-command script, where the sequence is already the explanation — reasons just
as strong sit mute in the neighbouring lines too.

## Three altitudes, three different jobs

| Level | Adds | Default |
|---|---|---|
| **Class/file/module** | what it's for, when to touch it | **present** if conventions call for it — short |
| **Function/method** | the contract the signature omits | **only if** the signature falls short, or conventions impose it |
| **Inside the function** | a dynamic the code doesn't tell | **none** |

**Class, file, module — complementary to the name.** The name says *what it's called*; the comment
says **what it's for**, as explained out loud to a colleague opening the file for the first time —
plus, where conventions call for it, *when* somebody puts their hands in it. No repeating the name,
listing methods (read by scrolling), or opening with ceremony.

**Function or method — what the signature does not say.** A docblock rewriting the signature
(`@param int $id The id`) is ceremony. Needed: units, formats, side effects, error behaviour
(exception? null? neutral value?), preconditions, edge cases, cost. A project-mandated docblock is
written **short**, mandatory lines unpadded.

**Inside the function — the default is silence.** Justified only for a **dynamic** the lines don't
tell: why that order, why that value, what breaks if touched, which external constraint forces it.
Everything else ("loops over the elements", "if empty it returns") is the line below, said twice.
Explaining **what** an unreadable block does calls for a better name or extraction (the crutch,
shape 4), not a comment.

## The nine reference rules

Source: [Best practices for writing code comments](https://stackoverflow.blog/2021/12/23/best-practices-for-writing-code-comments/)
(Stack Overflow Blog, 2021). In operational form:

1. **No duplicating the code** — `i = i + 1; // adds one to i` is deleted, always.
2. **No excusing unclear code** — fix the code first.
3. **A comment you can't write clearly means the code is the problem.**
4. **Removes confusion, doesn't add it** — a cryptic annotation is worse than nothing.
5. **Non-idiomatic code gets a comment**, the reason right there.
6. **Copied code carries the link to its source**, reaching the context and later corrections.
7. **External references sit where used** (standards, RFCs, vendor docs, a ticket), not the top of
   the file.
8. **A bugfix gets a comment** with its issue reference — how anyone tells whether the patch is
   still needed. **The comment carries the constraint, the link carries the incident** — "this
   version of the library returns the date without a timezone (#412)", not "without this the date
   came out wrong": a trace, not an account, which belongs in the issue (date, author, state).
9. **The incomplete is marked** by convention (`TODO`/`FIXME` plus a reference) — debt visible, not
   hidden.

Rules 5–9 say when a comment **pays its rent**; 1–4 say when it doesn't.

## The catalogue of shapes that look like comments and are not

**The principle alone doesn't stop them:** whoever writes one believes the principle and writes it
anyway, since each case looked at closely seems reasonable. What stops them is **recognising the
shape**.

1. **The paraphrase** — the line below in other words: `// increments the counter` over `$count++`.
2. **The ceremony** — preambles and formulas ("This method is responsible for…", `@return bool
   Returns a boolean`): remove the preamble and the fact remains, or nothing does.
3. **The ornament** — banners, dash rows, `// --- END OF CLASS ---`, symmetry filler: aesthetics,
   which this work doesn't do. But **count it in code this work didn't write first**: hundreds of
   occurrences, framework included, is house style, not decoration, and conventions win (`git grep
   -c '<the form>' <base-branch> -- <production directories>`, baseline **preceding** the work).
   What fails that test stays an ornament.
4. **The crutch** — explains *what* an unreadable block does. Remedy: rename or extract; forced only
   when trivial and safe, otherwise an open point.
5. **The working note** — `// TODO come back to this`, old code, reviewer notes: belongs to the
   process, not the result — needed items go to an issue, dead code is deleted (there's git).
6. **The stale comment** — a behaviour that no longer exists, **the most damaging** shape since a
   reader trusts it over the code. Corrected if still needed, otherwise gone.
7. **The diary** — a changelog inside the file (dates, authors, "modified for ticket X"); `git log`
   already says it, up to date.
8. **The defence of the refactor** — the diary disguised as design rationale, **the shape that
   survives more reviews than any other** since it reads beautifully. The subject isn't the thing in
   front of you but the *change* that produced it, justified to a reviewer no longer there ("It was
   born against Z, which a later batch deleted"). Costs double: replaces the needed description
   **and** ages badly, naming things gone. **Remedy: not deletion** — the chronicle almost always
   wraps a live constraint; keep that, present tense, throw away the story: "It was born against
   the corpus, which a later batch deleted: … Today it stays because the recorded expectations name
   the identifiers that come out of here" → "The recorded expectations name the identifiers that
   come out of here: moving the offset regenerates all of them".
9. **The averted incident** — a failure, real or imagined, instead of the property keeping it away
   ("Otherwise it broke", "so it does not happen again"). The reader never saw that failure and
   can't tell if it existed, was feared, or if its cause still exists. **Twin of the defence of the
   refactor**, told apart by subject — there the change, here the disaster; the **conditional is
   the signal** ("would delete", "would leave"), since a real property is stated in the present
   indicative, true now. **Same remedy as shape 8**: keep the mechanism, discard the disaster — the
   sentence almost always contains a real one. Rewriting the incident as a property is better but
   **still not enough**: it skips going back to the rent question, which a property doesn't
   automatically pay either.

## The shapes that do pay the rent

- **The why** of a non-obvious choice (algorithm, order, default) — **must hold up empirically**, a
  property of the system *as it is now*, checkable in the code, a library's docs or the
  configuration. True only as history ("it went wrong once") is a memory, not a why — commit or
  ticket.
- **The external constraint**: a known library bug, a regulatory requirement, a service's contract,
  legacy compatibility.
- **The trade-off** accepted knowingly, with its known limit.
- **The trap** — what breaks if someone "simplifies" that line; saves the most time of any comment.
- **Non-idiomatic code**, with the reason why.
- **The source** of copied code (a link) and **external references** next to the line using them.
- **The bugfix** with its issue reference, and the **known limit** marked by convention.

## The form: how what survives gets written

- **Short** — one or two lines for a class, one inline; five needed means documentation belongs
  elsewhere, or the code is wrong.
- **Opens on the fact**, not a preamble — first useful word, not "This".
- **Plain language**, present tense, active voice, as said to a colleague, not a manual.
- **No repeating the name** commented — the reader just read it.
- **One comment, one fact** — different facts, different comments, different places.
- **Prose language per the project** (`CLAUDE.md`/`AGENTS.md`, else the file's existing comments);
  **names stay as in the code**, never translated.
- **Reads like one developer explaining a thing to another** — the measure before all the rest: a
  colleague who reads it once and understands means the comment is finished.
