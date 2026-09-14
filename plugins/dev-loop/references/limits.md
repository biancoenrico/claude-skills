# Declared numbers

Every figure this plugin commits to lives here, one entry per number, and nowhere else. A
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
  is a copy to be removed.
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
  which counts iterations per group against this cap.
- **Where it comes from:** the specification, where it is the ceiling on review iterations and
  one of the points at which a fork skill stops and hands the question back.

## The agents-per-wave cap

- **Name:** the agents-per-wave cap
- **Value:** 6
- **Searchable form:** `6 agents per wave`
- **Who reads it:** every skill that fans work out to several agents at once; beyond the cap the
  fan-out proceeds in waves.
- **Where it comes from:** the specification's rule on parallelism, where it is stated as a
  declared choice rather than a measured limit.

## The I4 re-entry cap

- **Name:** the I4 re-entry cap
- **Value:** 2
- **Searchable form:** `2 I4 re-entries`
- **Who reads it:** the skill that executes a plan batch by batch, which counts re-entries
  within a single batch. On the third the batch stops and the question goes to the user.
- **Where it comes from:** the specification, which allows at most two I4 re-entries per batch
  and says the cap is tighter than the revision iteration cap because each re-entry redoes both
  the tests and the review.

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
  The cap is set at two **by declared analogy with the I4 re-entry cap**: it is the same shape
  of problem, a round that redoes work already done and that, left uncapped, keeps redoing it
  for as long as answers keep arriving. The two stop the same way, on the third round, and
  anyone re-reading this entry should be able to see that the reasoning is an analogy and not a
  requirement.
