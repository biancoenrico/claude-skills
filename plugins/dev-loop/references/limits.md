# Declared numbers

Every figure this plugin commits to lives here, one entry per number, and in no other prose. A
skill or an agent that needs one **names the entry and reads the value from here**; it never
writes the figure into its own text. Two copies of a number agree on the day they are written
and drift at the first change, and nothing in the plugin would notice.

This file does not explain the machinery a number belongs to. Each mechanism is described in
its own file, and that file cites the entry by name.

## How an entry is built

Each entry carries five fields:

- **Name** — what a skill calls it. Citations use the name, never the digits.
- **Searchable form** — the exact string to grep for. It is the check that the number really
  does live in one place: a grep for a bare `8`, `5`, `6` or `2` catches every date, exit code
  and section number, while a grep for `6 agents per wave` catches a duplicate and nothing
  else. Each form below appears verbatim in this file, and a hit anywhere else under the plugin
  is a copy to be removed. **The one exception is a test that enforces a number**: a test
  asserting the value is the check that keeps the entry honest, not a second statement of it,
  so it may carry the digits. Nothing else may.
- **Value** — the number itself.
- **Who reads it** — the parts of the plugin the number concerns. Anything not listed can pass
  over the entry.
- **Where it comes from** — the decision behind it, so that whoever re-reads it can tell a
  specification requirement from a choice made while planning.

## The batching threshold

- **Name:** the batching threshold
- **Searchable form:** `8 units of work`
- **Value:** 8
- **Who reads it:** the skill that decides whether a plan is cut into batch files or stays a
  single file; the plan-folder conventions cite it by name.
- **Where it comes from:** the specification, which sets the threshold at eight units of work
  and calls it the only such value in the whole plugin.

## The revision iteration cap

- **Name:** the revision iteration cap
- **Value:** 5
- **Searchable form:** `5 iterations`
- **Who reads it:** every skill that reviews something and can go round again — the revision
  skills and the fork skills that iterate over their own findings — plus the review ledger,
  which counts iterations per group against this cap. **What an iteration is, what does not
  consume the budget, and what happens at the cap** live with the counter, in
  `${CLAUDE_PLUGIN_ROOT}/references/ledger.md`.
- **Where it comes from:** the specification, where it is the ceiling on review iterations and
  one of the points at which a fork skill stops and hands the question back.

## The correctness round cap

- **Name:** the correctness round cap
- **Value:** 2
- **Searchable form:** `2 correctness rounds`
- **Who reads it:** the code revision skill, which counts its `/code-review` rounds on one batch
  against this cap instead of the revision iteration cap. The cleaning phase is a single pass and
  never counts.
- **Where it comes from:** **a choice made to speed the loop up, not a line of the
  specification.** A batch is small and its diff is fresh: a second round checks the fixes of the
  first, and what survives two rounds needs a human decision more than a third one. Code review
  runs once per batch, so the plan and spec revision cap was costing its price on every batch.

## The small batch threshold

- **Name:** the small batch threshold
- **Value:** 50
- **Searchable form:** `50 changed lines`
- **Who reads it:** the code revision skill, which below the threshold folds correctness and
  cleaning into a single `/code-review` pass. Changed lines are added plus removed, as
  `git diff --shortstat base..HEAD` counts them, tests excluded.
- **Where it comes from:** **a choice made to speed the loop up, not a line of the
  specification.** Below this size the correctness round and the cleaning round read the same
  handful of lines twice, and `/code-review` already reports cleanups alongside bugs.

## The agents-per-wave cap

- **Name:** the agents-per-wave cap
- **Value:** 6
- **Searchable form:** `6 agents per wave`
- **Who reads it:** every skill that fans work out to several agents at once; beyond the cap the
  fan-out proceeds in waves.
- **Where it comes from:** the specification's rule on parallelism, where it is stated as a
  declared choice rather than a measured limit.

## The unplanned-change re-entry cap

- **Name:** the unplanned-change re-entry cap
- **Value:** 2
- **Searchable form:** `2 unplanned-change re-entries`
- **Who reads it:** the skill that executes a plan batch by batch. A production change the
  batch did not foresee is made by the executor, and after each one the batch starts again from
  its test step; this cap counts those restarts within a single batch. On the third the batch
  stops and the question goes to the user. (The specification calls this mechanism I4.)
- **Where it comes from:** the specification, which allows at most two such re-entries per
  batch and says the cap is tighter than the revision iteration cap because each re-entry
  redoes both the tests and the review.

## The drafting round cap

- **Name:** the drafting round cap
- **Value:** 2
- **Searchable form:** `2 drafting rounds`
- **Who reads it:** the skill that drafts the batch files, which counts how many times the
  questions-to-index-to-resume round repeats within one drafting run. On the third it stops and
  the question goes to the user.
- **Where it comes from:** **a choice made while planning, not a line of the specification.**
  The specification describes the round — the drafters ask, the answers go into the index once
  the fan-out is closed, the drafters resume — but never says how many times it may repeat.
  The cap is set at two **by declared analogy with the unplanned-change re-entry cap**: it is
  the same shape of problem, a round that redoes work already done and that, left uncapped,
  keeps redoing it for as long as answers keep arriving. The two stop the same way, on the
  third round, and
  anyone re-reading this entry should be able to see that the reasoning is an analogy and not a
  requirement.

## The session map budget

- **Name:** the session map budget
- **Value:** 1200
- **Searchable form:** `1200 bytes`
- **Who reads it:** whoever edits the text between the `session-map` markers in
  `${CLAUDE_PLUGIN_ROOT}/references/loop.md`, which the session hook prints at session start
  and after every compaction. The map has to stay small enough to be repeated for free.
  `tests/session-map_test.sh` measures the shipped map and fails when it goes over — it is the
  one place in the plugin allowed to carry the digits.
- **Where it comes from:** the specification, which caps the injected map at 1200 bytes.
  Bytes, not characters: a character count depends on the locale of whoever runs the suite,
  and the budget has to mean the same thing everywhere.

## The skill file cap

- **Name:** the skill file cap
- **Value:** 17500
- **Searchable form:** `17500 characters`
- **Who reads it:** whoever writes or extends a `SKILL.md` in this plugin. A skill past the cap
  moves material into a file under `references/` and cites it, rather than growing.
- **Where it comes from:** the specification, which sets it as the ceiling on the size of a
  single skill file.
