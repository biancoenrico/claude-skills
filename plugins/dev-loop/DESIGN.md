# Design notes

Maintainer-facing rationale for `plugins/dev-loop/references/`, moved out of the files the model
reads so it never enters a session's context. It holds no rule the model needs — only the
reasoning kept for whoever maintains the plugin, one section per source file.

## references/agent-return.md

The field order and naming are strict because the caller parses the return by name, not by
prose: a renamed or reordered field fails as silently as a missing one, and nothing else would
catch it. The "no dumps" rule is a context-economy argument — the caller can already read the
file or the log itself, so pasting it into the return spends the caller's budget on something it
already had, and the same logic covers reasoning: the return states the conclusion and its
proof, not the route taken to reach it.

The never-arrives procedure and the malformed-return rule share this file because they are two
halves of one contract — the shape a return must have, and what happens when that shape is not
honoured. A caller that tries to interpret a broken return acts on something the agent never
actually said, with nothing in the record afterward to show that it guessed: a relaunch costs
one agent, but building on top of a misread return costs whatever gets built on top of it. That
is also why the rule lives in a shared reference rather than inside any one skill — every skill
that launches something reads it, so no single skill should own it.

The `deviations` field rests on the premise that a batch executed faithfully will still diverge
from the plan somewhere; a batch that always matches the plan exactly was not really executed,
it was transcribed.

## references/alternatives.md

Both passes exist to answer one question — is this the right road — that a completeness check
never asks. A review that only patches the cracks in what is written takes the road already
chosen as a given: a well-written document built on the wrong approach passes with full marks,
and the bill arrives only once the thing is built, when changing road means undoing everything
already stacked on top of it. Reading the project's own conventions and helpers first matters
because without that knowledge the alternatives a pass proposes come out abstract, and abstract
alternatives read as noise rather than as real options.

## references/asking.md

The ownership filter (read it yourself, search for it, or ask) exists because a review that asks
everything stops being read: the user starts answering "yes, fine" with their eyes closed, which
does the same damage as the question never having been asked, just paid for with more of the
user's effort. Questions travel in one block, never one at a time, so whoever answers sees the
whole picture and decides coherently instead of discovering on a later round that an earlier
answer no longer holds. The one exception — batch-procedure steps do not advance while a
question is open — exists because an answer can undo whatever step would otherwise run next.

## references/deferred-review.md

Reviewing a batch "now" instead of deferring it is about the cost of waiting: a bug in a batch
that other batches build on becomes part of their foundation, their tests lock it in, and a
finding raised later against code that has since been rewritten on top of it is no longer the
same finding.

## references/large-docs.md

The 500-line / 8-unit grouping figure is the author's own review-skill heuristic, carried over
from how the author already worked rather than derived from anything in this plugin.

## references/ledger.md

The ledger's four kinds of record exist so that iterations, findings, assumptions and questions
outlive the session that produced them, and outlive the review itself: without a `rejected`
finding's reason recorded in the user's own words, the next reviewer sees a bare refusal with no
ground and simply raises the same thing again. Finding IDs stay stable once assigned because
other artifacts — a report, a batch file, a commit message — point at them by number, and
renumbering would break every one of those references. A ledger that no longer parses or no
longer names the right object is renamed rather than edited into shape, because a ledger that
vanishes silently takes its rejected findings with it, and the review ends up re-asking questions
that were already settled.

## references/limits.md

The fifth field of the old table, "Where it comes from", separated a specification requirement
from a choice made during planning, so a maintainer revisiting an entry later could tell which
kind of number they were looking at. Several entries trace to a deliberate choice made to speed
the loop up rather than to a line of the specification: the revision iteration cap (the spec set
it at five; once minor fixes stopped starting a round, what survives three needs a human
decision more than a fourth), the small document threshold, the correctness round cap, the small
batch threshold, and the drafting round cap — the last set by declared analogy with the
unplanned-change re-entry cap, both capping a round that redoes work already done and would
otherwise keep redoing it forever. The batching threshold, the agents-per-wave cap, the
unplanned-change re-entry cap, the session map budget, and the skill file cap all trace directly
to the specification instead.

## references/loop.md

The file opens by stating that it is the loop's only full description, so that skills naming
just the step before and after them do not each have to repeat the whole picture. The session
map carries a strict byte budget because it is printed at every session start and after every
compaction, so it has to stay small enough to be repeated for free — anything added between the
markers has to buy its room from something already there. The short-output rule for the main
thread matters because every turn of the conversation re-reads its whole context, so anything a
command prints gets paid for again on every turn after it.

## references/plan-folder.md

A plan is cut into batches because the longer a sequence runs, the more whoever walks it loses
sight of their own earlier decisions — by the twelfth task, the third task's reasoning survives
only as a summary of itself. That is not a lapse in discipline; it is why the same rule ends up
written twice by the person who already wrote it once, and a shorter document alone does not fix
it — the work has to be cut into slices that close by themselves. Any `00-*.md` file counts as
an index, not only `00-index.md`, because folders written before this plugin existed name that
role differently, in other languages, and this rule keeps them readable regardless. Declaring
the choice whenever more than one `00-` candidate exists matters because silently picking one is
how the same folder ends up read two different ways by two different readers.

## skills/backlog-writing/SKILL.md

The opening paragraph this file used to carry — that the hard part is not typing tickets but
deciding where the line falls between a story and its tasks, and what each one weighs — existed
to justify why a six-step skill is needed at all: done by feel, that line lands wherever a
sentence happened to end, producing tasks that are single actions, stories that are shapeless
containers, and estimates that are vibrations wearing Fibonacci numbers as a costume. The
sentence right after it drew the same judgement's parallel to `/dev-loop:plan-batching`, one
level higher: that skill decides how to slice the *execution* of already-defined work, this one
decides how to slice *the work itself* before anyone has defined it. Both are framing rather than
obligation, and the "Does / Doesn't" table already does the orientation work a reader needs, so
neither earns its place in a file the model reads every run.

The paragraph motivating the `humanizer:humanizer` pass argued that backlog prose is the one
output of this skill that *leaves*: it gets typed into the ticket system and read by the team
under the user's name, and it is short — exactly where model tics show most (not-X-but-Y
contrasts, closing fragments that restate the line above, triads of adjectives). Removing them
costs nothing while the text is still in chat, and a full rewrite of the folder plus the open
tickets once it has shipped. The operative half of the rule survives in the file (invoke the
skill if available; declare in the report when it is skipped); this is the half that only a
maintainer deciding whether the step is worth keeping needs to see.

## skills/comment-writing/gates.md

These five checks live in this file, spelled out as commands anyone can run by hand, for a
specific reason: a skill file has a character cap and a reference file does not, and the step
that invokes them cites this file rather than carrying the commands inline — not because a check
is mechanical, since the recipe only ever proposes and the judgement stays with the skill. An
earlier draft of the plugin shipped these checks as a shell script; the script was withdrawn.

Two of the "when a check does not run" cases used to be exit codes of that retired script; the
rule now stands on its own under "When a check does not run" in gates.md.

The `lost-fact` line marker is `base@NN` where the specification writes `base:NN`; the reason
lives under "The five checks" in gates.md.

## skills/plan-batching/SKILL.md

The rules of behaviour exist against a single failure mode: cutting for the sake of cutting. A
skill whose whole job is imposing structure has every incentive to find structure whether or not
the work needs it, and the failure mode is quiet — a folder with an index and a few near-empty
batch files reads as diligence, not waste, even though it costs more to navigate than the single
file it replaced. Each rule in the list is aimed at forcing the skill to justify a cut rather than
default to producing one.

## skills/plan-drafting/SKILL.md

Writing inside the fixed shape is what makes drafting parallel-safe in the first place: the shape
already says what each batch delivers, inherits and may call, so one writer per file needs no
coordination with the others. The index is the one thing that is not scoped to a single batch,
which is why touching it is reserved to this skill alone rather than left to whichever drafter
gets there first.

## skills/plan-execution/SKILL.md

The failure this skill exists to prevent is not a technical error: it is the loop fraying. A
batch closes, someone asks "shall I go on?", work restarts with half the context, the review
gets skipped as "small", and three batches later the closing criteria have become a memory —
each skipped step costs little alone, and the bill arrives all at once. That is also why the
autonomy section spells out exactly what is and is not asked: left implicit, autonomy becomes a
matter of mood, which is the same fraying under another name.

Offering `/dev-loop:plan-revision` before executing an unreviewed plan exists because finding a
plan's holes mid-execution is the most expensive way to find them — a batch already committed on
top of a bad assumption is no longer a hole, it is a foundation.

## skills/plan-revision/SKILL.md

The opening paragraph used to justify the whole skill by contrast with spec-revision: a plan
review is not about whether something should be built, only about whether whoever picks it up
can walk it without stopping to ask "and how is this done?" — a step needing something created
five tasks later is worse than no plan at all, because it fakes readiness instead of admitting
gaps. The body now states only the operative half of that ("this skill checks how the work gets
built") in step 1; the "why order matters more than existing" argument lives here instead of in
every session's context.

## skills/plan-revision/criteria.md

Sequence and dependency errors sit first among the seven dimensions, and outrank every other
finding in the report, because a wrong order is the one defect that only becomes visible once
execution has already started — by the time it shows up, redoing the work costs more than
getting the order right the first time would have. Every other dimension can be caught and fixed
on paper; this one is caught on paper or paid for in rework.

## skills/spec-revision/SKILL.md

The opening paragraph this trim removed argued that a specification's whole point is saying what
to build unambiguously: a document that contradicts itself, leaves terms open to two readings, or
announces sections nobody wrote produces divergent implementations, since everyone fills the
holes their own way and the defect only shows up once the work is done. Catching that on paper
costs a fraction of catching it in code — the entire reason this review runs before
implementation starts rather than being treated as optional polish.
