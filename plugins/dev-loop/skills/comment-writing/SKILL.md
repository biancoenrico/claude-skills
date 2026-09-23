---
name: comment-writing
description: Decides whether a comment is needed, then writes it short — class, function and inline alike — or reviews existing ones. No external docs, no bug hunting.
when_to_use: Commenting code just written, or reviewing comments in a diff. Triggers - "comment this class", "explain this method", "are these comments needed". Below the small batch threshold, follow this file inline instead of invoking it.
argument-hint: <paths, diff or range; plan batch file; a why from the conversation; "review" for review mode>
effort: medium
context: fork
agent: general-purpose
---

# comment-writing

Writes the comments of a piece of code. The real work is **deciding which ones exist**, not writing
the others.

Generic — no conventions of its own, reads the project's in Step 1. `/dev-loop:code-revision`
delegates its comment phase here for one copy of the criteria; in writing mode it also runs alone
while the code is written.

**Runs in a fork**, so its instructions and whatever it loads stay out of the caller's context and
it never sees the conversation: the scope, and any *why* known only there, arrive in the arguments.
Inside the loop there is no such argument — the whys it may use are what the code, the batch file
and the plan already carry. Every question is handed back: `status: question` per
`${CLAUDE_PLUGIN_ROOT}/references/agent-return.md`, report in `findings`, resume needs in `state`.

**Below the small batch threshold** in `${CLAUDE_PLUGIN_ROOT}/references/limits.md` — measured with
`sh ${CLAUDE_PLUGIN_ROOT}/scripts/devloop-diffsize --with-tests` over the scope — the caller follows
this file **inline**: a fork and a reviewer cost more than a handful of comments. Inline, whys may
also come from the conversation, a question goes to the user via
`${CLAUDE_PLUGIN_ROOT}/references/asking.md`, and the point reached feeds the caller's `state`.

## The failure it exists to avoid

A missing comment gets noticed and added; what doesn't is the opposite — the comment **that is
there and says nothing** (the catalogue's shapes, below). It costs three times: read for zero
information; maintained until, unupdated, it **lies**; and it **takes the place** of the *why* the
block actually needed.

Hence the order: **decide whether the comment pays its rent, write it short, and prove at the end
that without it something would be lost.**

## Input and scope

Priority: an explicit target in the arguments, else `git diff HEAD` plus the branch range when an
upstream exists. No target → hand back the question instead of inventing a scope.

## Two modes, one measure

**Writing** (default) looks at code just written for points deserving a comment. **Review** looks at
comments already there for ones that say nothing or lie. Both succeed when every comment in scope
passes the cutting proof — writing decides *before*, review verifies *after*. One skill: two copies
of the same criterion would diverge at the first touch.

## The principle: a comment pays its rent

Every comment answers, written or read: **what is lost if I delete it?** Readable below → noise.
Unphraseable → no content, only the shape of one.

Full principle, altitudes, reference rules, shapes and forms:
`${CLAUDE_PLUGIN_ROOT}/skills/comment-writing/catalog.md`.

## Workflow — writing mode

### Step 1 — Read the conventions before writing a line

From the project (`CLAUDE.md`/`AGENTS.md`, nested ones included) and neighbouring files: prose
language, mandatory docblocks and format, generators or analysers reading the annotations, style,
width. **They win over any preference of this skill.** Declare them in one line.

### Step 2 — List the candidates, by altitude

List the candidate points (class/file, functions, internal points) **before** writing any — decided
by hand while writing, the comment always gets born. Shapes and merit criteria:
`${CLAUDE_PLUGIN_ROOT}/skills/comment-writing/catalog.md`.

### Step 3 — The existence gate, one by one

**Two questions, the second commands.** Asked before writing a word of the comment, not while
writing it — by then it exists and removing it costs.

1. **Does this comment have a reason to exist?** Half a line on what is lost without it — the
   principle above.
2. **Would somebody reading the code afterwards understand it anyway?** Not the whole system —
   *this point*, with the surrounding lines and names in front of them.
   - **Yes → not written** (the default).
   - **No → written**, the only case going on to Step 4.

Answered **by looking**, not memory: reread the five lines above and below — whoever just wrote the
code always finds the comment necessary, exactly why the comment too many gets born.

The Step 2 list records every rejection with question 2's answer — no rejection needs more.

### Step 4 — Write only the survivors, then pass them through the humanizer

In the catalogue's form, inside the Step 1 conventions. Project-imposed docblocks get written even
when they say little, but stay short.

Then **rewrite every comment with `humanizer:humanizer`**, before Step 5 — **if it's among the
available skills**; otherwise skip it, **the report says so** in one line.

**It is a pen, not a linter.** Not for flagging which paragraphs violate which pattern or counting
tics: rewrite the comment the way one developer would for another opening the file today, tics gone
as a consequence. As a linter it produces findings, a debate, and nothing rewritten — how this step
gets skipped without looking skipped.

Three errors that neutralise it: **the blanket exemption** (exempting a whole category instead of
judging one comment at a time); **the wrong sample** (this run's own prose as "the project's voice"
is circular — the baseline **precedes** this work); **the policy asked of the user** (settle a form
question by what renders on-screen, not by asking).

Runs **only on prose**; "what is not touched" stays intact. A rewrite changing what a comment says,
not just its form, is an error of the pass.

**On a large target, batch** a few files at a time, reading every comment's full text; twenty-five
at once, skim by eye instead.

### Step 5 — The gates

Four questions; a comment passes all or stays out:

0. Step 3, question 2 — **without me, understood anyway?** Yes → doesn't exist, other three unasked.
1. **The cutting proof** — does it carry information?
2. **The new reader's proof** — who is it talking about?
3. **The fidelity proof** — lost anything on the way? Applies to the *diff*, not the single
   comment — the second proof alone pushes past what should be cut.

The three proofs, checks, recipes, false positives, and when a check cannot run:
`${CLAUDE_PLUGIN_ROOT}/skills/comment-writing/gates.md`. Run over the paths under examination —
against a base reference in review mode, without one in writing mode, Step 1's prose language for
`tense`, `process-ref`'s terms extended below. Whatever didn't run goes into the verifications.

**`process-ref` terms** get a second, fixed-string pass, `grep -rniF -e <term> …`; no file written.
Source: the plan index's shared vocabulary via the batch file path in the arguments
(plan-execution passes it, code-revision passes it on) and
`${CLAUDE_PLUGIN_ROOT}/references/plan-folder.md`. Unreachable → the base list is all there is,
**declared in the report**.

**The new reader, for real.** The one skill launching a `dev-loop:reviewer` as a fresh reader: hand
it `catalog.md`, `gates.md` (paths per `agents/reviewer.md`) and the comments, judging them seeing
them for the first time. Changes nothing; findings come back for this skill to decide. **Not
launched below the threshold, forked or not, nor when no comment survived.**

An unknown, undeducible *why* is not invented: ask via
`${CLAUDE_PLUGIN_ROOT}/references/asking.md`.

### Step 6 — Verify and report

The project's syntax check or linter on touched files, not the whole build — a malformed docblock
breaks the file even for "only comments" changed. Report template:
`${CLAUDE_PLUGIN_ROOT}/skills/comment-writing/gates.md`.

## Workflow — review mode

Steps 1, 5 and 6 unchanged. In between:

**Step 2′ — Fix the scope.** Comments **touched or introduced by the diff**; pre-existing ones stay
out (somebody else's code) **unless** the user asks for a historical clean-up, or they became
**false because of the diff** — corrected anyway.

**Step 3′ — Before the verdict, the existence gate.** Every comment in scope, **including ones about
to be rewritten**, goes through Step 3's two questions — an existing comment seems to have earned
its place, and review tends to file rather than question it, how a useless one survives five
reviews, more beautiful each time. Rephrasing happens **after** deciding it stays.

**Step 3″ — One verdict per comment**, reason in half a line:

- **Kept** — pays its rent as is.
- **Rewritten** — needed but ill-formed (catalogue's paraphrase/ceremony, or reads as generated) —
  humanizer rewrites it, Step 4's limits apply.
- **Corrected** — false or stale.
- **Brought to the present** — catalogue shapes 8–9: keep the live constraint, discard the story.
  **Holds only if that constraint alone passes Step 3′** — often not, and the verdict is "removed".
- **Removed** — one of the catalogue's shapes.
- **Promoted to code** — a crutch: rename or extract; not forced unless trivial and safe — an open
  point otherwise.

Doubt about **form** → rewrite. Doubt about **existence** (Step 3′ found no answer) → it goes.
Confusing the two produces the rephrased comment that reads better and lasts longer for it. Never
delete a comment for being long: content is judged, not length.

## What is not touched

- **Legal headers and licences.**
- **Semantically active annotations** (`@deprecated`, analyser/IDE types, linter directives,
  pragmas, generated-doc or type-inferring docstrings) — code in disguise, not prose.
- **Docblocks imposed by the conventions** — shortened, not deleted.
- **Comments outside the scope** in review mode, third-party code, `vendor/`.

## Rules of behaviour

- **No comments for aesthetics, symmetry or filler.** No exceptions.
- **No comment to patch unclear code.** Rename, extract, or raise it.
- **No code changes** beyond Step 3″'s trivial, safe promotions — an open point instead.
- **No widening the scope** in review, per Step 2′.
- **No invented why**, per Step 5 — ask, or don't write it.
- **No justifying the change just made.** Describe what's there, not its route.
- **Trace the rejections**, not only what's written: value here is mostly in comments not there.
