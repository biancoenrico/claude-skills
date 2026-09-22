# Deferred review

This file owns which batches are reviewed at their own step 4 and which wait for the last batch.
`/dev-loop:plan-execution` applies the rule; `/dev-loop:code-revision` receives the scope it
produces — neither copies it.

## Now or later

A batch is reviewed **now** when a later open batch in the index builds on it:

- the index's dependencies name it;
- a later batch's `Inherits:` line names an entry the index says this batch owns;
- a later batch's tasks touch a file this batch changes.

A batch none of these hold for is a **leaf**: its step 4 writes `code-revision deferred @<sha>`
instead of reviewing. **When the index leaves any of the three unclear, review now.**

A cancel marker in a leaf (`back to test-writing`, `restart from test-writing`) cancels its
`code-revision deferred` line like any step 4 line; the new round writes it again.

## Who pays

**An unpaid deferral** is an uncancelled `code-revision deferred` line with no later
`code-revision in NN` line.

**The last open batch in the index** pays them, whatever batch or folder the run was handed: its
step 4 reviews, in one pass, its own `base..HEAD` plus each unpaid deferral's `base` to its
latest valid `criteria ok` sha. A single-file plan is its own last batch.

If a range end no longer resolves, step 1's base-recovery procedure applies as to a batch base:
no guessing — ask the user.

**Line order**, so a resume cannot lose them: `code-revision in NN @<sha>` (NN the last batch) in
each paid batch file first, then `code-revision @<sha>` in the last batch. A resume finding the
last batch's step 4 undone recomputes the unpaid deferrals from the definition above, so marked
batches are not reviewed twice.

**The last batch's step 5** walks the index's criteria plus its own for every batch paid in that
pass.

**When no open batch is left** — the last one was cancelled after leaves had deferred — the
unpaid deferrals are debt under plan-execution's step 2: review them in one pass, walk the
criteria as above, then close the plan.
