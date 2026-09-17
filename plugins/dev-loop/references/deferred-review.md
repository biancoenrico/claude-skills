# Deferred review

This file owns one rule of the batch procedure: which batches are reviewed at their own step 4,
and which wait for the last batch. `/dev-loop:plan-execution` applies it; `/dev-loop:code-revision`
receives the scope it produces. Neither copies it.

## Now or later

A batch is reviewed **now** when a later open batch in the index builds on it:

- the index's dependencies name it;
- a later batch's `Inherits:` line names an entry that the index says this batch owns;
- a later batch's tasks touch a file this batch changes.

The reason is the cost of waiting. A bug in a batch others build on becomes their base, their
tests lock it in, and a finding on code rewritten since is no longer the same finding.

A batch none of these hold for is a **leaf**, and its step 4 writes `code-revision deferred @<sha>`
instead of reviewing. **When the index leaves any of the three unclear, review now.**

A cancel marker in a leaf (`back to test-writing`, `restart from test-writing`) cancels its
`code-revision deferred` line like any other step 4 line; the new round writes it again.

## Who pays

**An unpaid deferral** is a `code-revision deferred` line not cancelled and with no
`code-revision in NN` line after it.

**The last open batch in the index** pays them, whatever batch or folder the run was handed:
its step 4 always reviews now, in one pass over its own `base..HEAD` plus, per unpaid deferral,
the range from that batch's `base` to its latest valid `criteria ok` sha. A single-file plan is
its own last batch.

If a range end no longer resolves — a rebase, a reset, an amend — the base-recovery procedure of
step 1 applies to it as to a batch base: no guessing, the question goes to the user.

**Order of the lines**, so that a resume cannot lose them: first `code-revision in NN @<sha>` in
each paid batch file, NN being the last batch, then `code-revision @<sha>` in the last batch. A
resume that finds the last batch's step 4 undone recomputes the unpaid deferrals from the
definition above, so batches already marked are not reviewed twice.

**The last batch's step 5** walks the index's criteria and, in addition, the criteria of its own
of every batch paid in that pass: the review may have changed their code.

**When no open batch is left** — the last one was cancelled after leaves had deferred — the
unpaid deferrals are debt under step 2 of plan-execution: review them in one pass, walk the
criteria as above, and only then is the plan closed.
