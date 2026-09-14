---
name: comment-writing
description: Decides whether a comment is needed at all and, when it is, writes it short and useful. Covers class and file comments, function comments, and the rare ones inside a function. It also runs in review mode over comments that are already there. It writes no external documentation and hunts no bugs.
when_to_use: Commenting or documenting code just written, and reviewing the comments of a diff. Triggers - "comment this class", "add the docblocks", "explain this method", "are these comments needed", "drop the useless comments", "these comments are too wordy", "go over the comments in the diff".
argument-hint: <paths, a diff or a range; plus the batch file of the plan, and "review" for review mode>
effort: high
---

# comment-writing

Writes the comments of a piece of code. The real work is not writing them: it is **deciding which
ones exist**, and not writing the others.

It is a generic skill: it does not know which language or which project it is running in, and it
brings no conventions of its own. It reads them (Step 1) and adapts.

`/dev-loop:code-revision` delegates its comment phase here, and the criteria live only here so that
there are never two copies to keep aligned. In writing mode it is also used on its own, while the
code is being written.

## The failure it exists to avoid

A missing comment gets noticed and added. What does not get noticed is the opposite: the comment
**that is there and says nothing**. Preambles, paraphrases of the line below, docblocks that copy
the signature, ornamental banners, comments added for symmetry because "the other methods have
one".

They cost three times. They are read — doubling the lines to understand for zero information. They
are maintained — and since nobody updates a paraphrase, after three changes it **lies**, and a
reader believes the comment instead of the code. And above all they **take the place**: a block that
is already commented looks documented, so the *why* that was needed there never gets written by
anyone.

Hence the order: **first decide whether the comment pays its rent, then write it short, and at the
end prove that without it something would be lost.**

## Input and scope

In order of priority: an explicit target in the arguments (paths, a diff, a range); otherwise
`git diff HEAD`, plus the branch range when an upstream exists. If there is no target at all, ask
what is to be commented rather than inventing a scope.

## Two modes, one measure

| | **writing** (default) | **review** |
|---|---|---|
| **When** | code just written, to be commented | comments already there |
| **Looks for** | the few points that deserve a comment | comments that say nothing, or that lie |
| **Succeeds when** | every comment written has passed the cutting proof | every comment left has passed the same proof |

The measure is the same and only the direction changes: in writing you decide *before*, in review
you verify *after*. They are one skill because two copies of the same criterion would diverge the
first time somebody touched one.

## The principle: a comment pays its rent

> **The question, for every comment you are about to write or are reading:** what is lost if I
> delete it?

If the answer is **readable in the lines below**, it is not a comment: it is noise, and the right
choice is not to write it. If you cannot phrase the answer, the comment has no content — it has the
shape of one.

A comment is not free and is not decoration. It is one more line to read now and to keep true
forever. It is gladly paid for information the code **cannot** carry; it is not paid for information
the code carries already.

**Corollary that holds for the whole skill: never comment for aesthetics**, for symmetry, to fill an
empty docblock, or because "a class without a comment looks unfinished".

The three altitudes — class/file, function, inside the function — the nine reference rules, the nine
shapes that look like comments and are not, the shapes that do pay the rent, and the form of what
survives all live in `${CLAUDE_PLUGIN_ROOT}/skills/comment-writing/catalog.md`.

## Workflow — writing mode

### Step 1 — Read the conventions before writing a line

From the project (`CLAUDE.md`/`AGENTS.md`, including the ones nested in the directories you touch)
and from the neighbouring files: the language of the prose, mandatory docblocks and their format,
documentation generators or analysers that read the annotations, style and width. **They win over
any preference of this skill.** Declare them in one line.

### Step 2 — List the candidates, by altitude

Go through the target and write down the list of candidate points (class/file, functions, internal
points) **before** writing any of them. It is the pass nobody does on their own: decided by hand
while writing, the comment always gets born. The shapes and the merit criteria to judge them by are
in `${CLAUDE_PLUGIN_ROOT}/skills/comment-writing/catalog.md`.

### Step 3 — The existence gate, one by one

**Two questions, in this order, and the second commands.** They are asked before writing a word of
the comment — not while writing it, because by then it exists and removing it costs.

1. **Does this comment have a reason to exist?** Write in half a line what is lost without it. If
   you cannot phrase it, the comment has no content: it has the shape of one.
2. **Would somebody reading the code afterwards understand it anyway?** Not "understand the whole
   system": understand *this point*, with the surrounding lines in front of them and the names that
   are there.
   - **Yes, they would → it does not get written.** This is the normal answer, and it is why the
     default of this skill is silence.
   - **No, they would not → it gets written**, and that is the only case that goes on to Step 4.

The second question is answered **by looking**, not from memory: reread the five lines above and the
five below. Whoever has just written the code knows things that are written down nowhere, and to
them the comment always looks necessary — which is exactly the condition in which the comment too
many is born.

The list from Step 2 records every rejection with the answer to question 2, and no rejection needs
more justification than that.

### Step 4 — Write only the survivors, then pass them through the humanizer

In the form the catalogue sets out, inside the conventions from Step 1. Docblocks imposed by the
project are written even when they say little, but they stay short.

Then **rewrite every comment with `humanizer:humanizer`**, before Step 5 — **if it appears among the
available skills**. If it is not there, the rewrite is skipped and **the report says so** in one
dedicated line.

**It is a pen, not a linter.** It is not used to mark which paragraphs violate which pattern, nor to
count the occurrences of a tic in the file: you take the comment and have it rewritten the way one
developer would write it for another opening that file today. The tics go as a consequence. Used as
a linter it produces a list of findings, a discussion about exceptions, and in the end nothing
rewritten — which is how this step gets skipped without looking skipped.

Three errors that neutralise it:

1. **The blanket exemption.** "These contrasts are all justified", "these dashes are the project's
   style". One comment is judged at a time: a category exempted wholesale is a rewrite that did not
   happen.
2. **The wrong sample.** Taking as "the project's voice" prose written by this same run. It is
   circular, and it always confirms. A baseline is measured on code or commit messages **preceding**
   this work.
3. **The policy asked of the user.** If a question of form can be settled by looking at what
   actually happens on the reader's screen, it is settled and that is that: `**bold**` inside a `//`
   is rendered by nobody, so it is two asterisks in the middle of a sentence.

The humanizer runs **only on prose**. Everything under "what is not touched" stays intact. If after
the rewrite a comment says something different from before, that is an error of the pass, not an
improvement: it changes the form, not the information.

**On a large target, work in batches** of a few files at a time, reading the whole text of every
comment. One file at a time gets rewritten; twenty-five files together get skimmed, and that is
where the judgement goes back to being done by eye.

### Step 5 — The gates

Four different questions, and a comment passes all of them or it does not go out:

0. Step 3, question 2 — **without me, is it understood anyway?** If yes, the other three are not
   even asked: the comment does not exist.
1. **The cutting proof** — does it carry information?
2. **The new reader's proof** — who is it talking about? The chronicle of a refactor sails through
   the first one.
3. **The fidelity proof** — has something been lost on the way? It applies to the *diff*, not to the
   single comment, and it exists because the second one, alone, pushes you to cut more than you
   should.

The three proofs, the five checks that feed them with their recipes, what a false positive looks
like for each, and the cases where a check cannot run are held by
`${CLAUDE_PLUGIN_ROOT}/skills/comment-writing/gates.md`. Run them over the paths under examination:
against a base reference in review mode and without one in writing mode, with the tense patterns of
the prose language established in Step 1, and with the `process-ref` term list extended as below.
Whatever did not run goes into the verifications section of the report, with the details in that
file.

**The term list of `process-ref`**, built at every invocation and deleted at the end, in every exit
path:

- **Where the terms come from:** the shared vocabulary of the plan's index. **The index is derived
  from the path of the batch file**, which arrives in the arguments — plan-execution passes it, and
  in its comment phase code-revision passes it on. Take its directory and look there for the index
  by the rule in `${CLAUDE_PLUGIN_ROOT}/references/plan-folder.md`.
- **Format:** one term per line, nothing else — no comments, no headers — so that the list can be
  fed to a fixed-string search directly.
- **Where it lives:** under `<git-dir>/devloop-comment-gates/`, the same convention as the mutation
  script, which keeps its copies there. The plugin's working files stay in one place, out of
  `git status` and **never inside the user's working tree**. The name carries the **PID**, so a file
  left behind by a killed process is recognisable as an orphan instead of being confused with the
  one in use.
- **When it cannot be done:** "unreachable" means **no batch file path in the arguments**, or **no
  index file in its directory**. Then the base list of terms is all there is, and **the report says
  so**, in one line: it is a declared degradation, not a silence. Those terms matter because they are
  the names *the plan* uses, not the code, and that is exactly what a new reader cannot resolve.

**The new reader, for real.** This is the one skill that launches a `dev-loop:reviewer` as a fresh
reader: hand it `catalog.md` and `gates.md` — with the paths in the form prescribed by
`agents/reviewer.md`, which owns that rule — together with the comments under examination, and ask
for its judgement on the new reader's proof over comments it is seeing for the first time. That is
exactly what whoever has just written the code cannot do in their head. The reviewer changes
nothing: its findings come back here, and this skill decides.

When a *why* is not known and cannot be deduced, it is not invented: the form of the question is
held by `${CLAUDE_PLUGIN_ROOT}/references/asking.md`.

### Step 6 — Verify and report

The project's lint, build or static analyser: a malformed docblock or a broken delimiter breaks the
file even if "you only touched comments". Then the report, whose template lives beside the
verifications it lists, in `${CLAUDE_PLUGIN_ROOT}/skills/comment-writing/gates.md`.

## Workflow — review mode

Steps 1, 5 and 6 unchanged. In between:

**Step 2′ — Fix the scope.** The comments **touched or introduced by the diff**. The pre-existing
ones stay out (they are somebody else's code, not the work under review) **unless** the user
explicitly asks for a historical clean-up, or they have become **false because of the diff**: those
are corrected anyway, because it is the diff that broke them.

**Step 3′ — Before the verdict, the existence gate.** Every comment in scope goes through the two
questions of Step 3, **including the ones you are about to rewrite**. A comment that already exists
seems to have earned its place, and review tends to file it instead of questioning it: that is how a
useless comment survives five reviews, getting more beautiful each time. Rephrasing is easier than
removing, and it is done **after** deciding that the comment stays.

**Step 3″ — One verdict per comment**, with the reason in half a line:

- **Kept** — it pays its rent as it stands.
- **Rewritten** — the information is needed, the form is not: ceremony, wordiness, it explained the
  *what*, or it reads as generated. In that last case the rewrite is the humanizer's, with the same
  limits as Step 4.
- **Corrected** — it was false or stale.
- **Brought to the present** — it was the chronicle of a refactor or an averted incident: the live
  constraint it contained is kept, the story is thrown away. It is the verdict most often forgotten,
  because those comments already look good. **It holds only if the constraint, on its own, passes
  Step 3′**: often it does not, the chronicle was the whole content, and the right verdict is
  "removed".
- **Removed** — one of the shapes of the catalogue.
- **Promoted to code** — it was a crutch: rename or extract, and the comment disappears. If the
  operation is not trivial and safe it is not forced: it becomes an open point.

When in doubt **about the form** — the information is needed and you are unsure whether it is worth
a rewrite — rewrite. When in doubt **about the existence** the opposite holds: if Step 3′ could not
say what is lost by removing it, it goes. They are two different doubts pulling opposite ways, and
confusing them produces the rephrased comment that should not have been there: it reads better than
the previous one, and for that reason it lasts longer.

And never delete a comment because it is long: the content is judged, not the length.

## What is not touched

- **Legal headers and licences.**
- **Semantically active annotations**: `@deprecated`, types read by analysers or IDEs, linter
  directives, pragmas, docstrings from which documentation is generated or types are derived. They
  are not prose: they are code in disguise.
- **Docblocks imposed by the conventions**: they get shortened, not deleted.
- **Comments outside the scope** in review mode, and anything inside third-party code or `vendor/`.

## Rules of behaviour

- **Do not comment for aesthetics, for symmetry or to fill.** It is the one rule with no exceptions.
- **Do not use a comment to patch unclear code.** Rename, extract, or raise it.
- **Do not touch the code** beyond the trivial, safe promotions of Step 3″: this skill writes
  comments, it does not rewrite logic. If commenting well would require changing the code, say so as
  an open point.
- **Do not widen the scope** in review: the historical clean-up of a file inflates the diff and hides
  the real changes.
- **Do not invent the why.** If the reason for a choice is not known — not in the code, not in the
  plan — it is not deduced: it is asked, or the comment is not written. An invented why is a comment
  that is false from day one.
- **Do not justify the change you have just made.** The comment describes the thing that is there,
  not the route that produced it.
- **Trace the rejections**, not only the comments written: the value of this skill is more in the
  ones that are not there.
