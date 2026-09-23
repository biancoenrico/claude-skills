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

The 500-line / 8-unit grouping figure is the author's own review-skill heuristic, offered as a
rough indication rather than a declared number — it is not one of the values in `limits.md`, and
its landing on eight alongside the batching threshold is a coincidence of two unrelated
decisions, not a shared origin.

## references/ledger.md

The ledger's four kinds of record exist so that iterations, findings, assumptions and questions
outlive the session that produced them, and outlive the review itself: without a `rejected`
finding's reason recorded in the user's own words, the next reviewer sees a bare refusal with no
ground and simply raises the same thing again. Questions are exempt from the iteration counter
because a round spent asking and waiting is bringing in information that was not there before,
not polishing what is already known — it is arguably the most valuable kind of round, not the
cheapest one. Finding IDs stay stable once assigned because other artifacts — a report, a batch
file, a commit message — point at them by number, and renumbering would break every one of those
references. The seam pass runs only after fixes have settled because consistency between groups
can only be judged once the groups have stopped moving. A ledger that no longer parses or no
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
how the same folder ends up read two different ways by two different readers. The "first batch
that uses it" phrasing, rather than "batch 01", matters because the two readings diverge as soon
as the actual first reader is the third batch: dropping a shared rule into batch 01 just because
it is shared leaves it sitting unused for two batches, while the wrong intuition still sounds
right. The starting-material line, and the convention of leaving it present but empty when there
is no such source, exist so nobody re-derives a spec's own work a second time, and so an empty
line reads as "the input was a spec" rather than "nobody looked."
