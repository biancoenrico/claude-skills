# Changelog

Kept in the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) shape, one section per
release, newest first; the plugin follows [semantic versioning](https://semver.org/).

## 1.5.0 — 2026-09-16

The main conversation holds less context, so each turn uses fewer tokens.

### Changed

- **`comment-writing` runs in a fork.** Its instructions, and the humanizer it loads, stay out of
  the caller's context. The scope and any reason known only from the conversation are passed as
  arguments, and questions go back to the caller.
- **The session map asks for short command output**: the tail of a test run and `diff --stat`
  in place of full outputs and full diffs.
- **A large conversation gets a `/compact` suggestion between batches.** Once it is past half of
  the context window, the batch summary suggests `/compact` or a fresh session. The batch files
  already hold what a resume needs.

## 1.4.0 — 2026-09-16

Writing tests for a small change takes less time.

### Changed

- **A small bounded diff gets its tests from the main thread.** Below the small batch threshold,
  the main thread follows `test-writing` inline instead of forking it, with the same steps: the
  list comes first, and every test is seen red.
- **The test calibration is worked out once per branch.** The runner, the filtered command and
  the test layout go into the branch worklog, or into the batch file where a plan first ran
  `test-writing`. Every later
  `test-writing` run receives them and skips its own calibration.
- **`test-writing` reads in fewer calls.** It gathers the manifest, the runner setup and a
  neighbouring test in one shell command, because each call is a round trip to the model.
- **`test-writing` no longer ends with a list of rules** that repeated its own steps.

## 1.3.0 — 2026-09-16

Specs and plans get through review faster.

### Changed

- **Small documents get one reviewer.** Below the small document threshold, a single reviewer
  checks both the criteria and the alternatives.
- **The alternatives pass runs on the first iteration.** It runs again only when an answer from
  the user moves a load-bearing decision.
- **A new round starts only after a 🔴 or 🟠 fix, or an answer.** A round whose fixes were all
  minor ends the review.
- **A plan's seam pass runs only with two batch files or more, or a reference specification.**
- **The revision iteration cap drops from five to three.**

## 1.2.0 — 2026-09-16

Small changes no longer go through the full loop.

### Added

- **A surgical path.** A change that mirrors a pattern already beside it, stays in one area
  and takes no new decision is made in the main thread with no agents: the area's tests run,
  and one test is added only when the change adds a branch of logic. When one of those
  conditions stops holding, the work moves up to the bounded path.

### Changed

- **Refactors go on the bounded path at least**, however small they are.

## 1.1.0 — 2026-09-16

A batch now goes through the loop faster.

### Changed

- **`code-revision` does fewer rounds.** `/code-review` starts at `medium` and runs again
  only after a Critical or Important fix, and then only over that fix. `/simplify` runs once.
- **Small batches get a single pass.** Below the small batch threshold, one `/code-review`
  covers both correctness and cleanup.
- **The comment pass is skipped** when the diff adds or changes no comment.
- **`executor` and `drafter` run on Sonnet**, and `reviewer`, `test-writing` and
  `code-revision` run at `high` effort instead of `xhigh`.
- **Mutations in `test-writing` run only the target test file**, and the whole suite only
  for a mutation that survives.
- **A prose-only change skips tests and code revision** on the bounded path: one
  `dev-loop:reviewer` checks it against the new `code-revision/prose.md` criteria instead.

## 1.0.0 — 2026-09-14

First release. Installing the plugin gives you:

### Added

- **Ten skills**, each callable as `/dev-loop:<name>` and fired on its own when the work
  matches: `spec-revision`, `plan-batching`, `plan-drafting`, `plan-revision`,
  `plan-execution`, `test-writing`, `code-revision`, `comment-writing`, `design-revision`,
  `backlog-writing`.
- **Three agents** the skills launch on their own — `dev-loop:reviewer`, a read-only
  fresh-eyes judgement pass; `dev-loop:drafter`, which writes one batch file of a plan; and
  `dev-loop:executor`, which carries out one batch and commits the production code.
- **`scripts/devloop-mutate`**, which swaps one literal string in a tracked file, runs a
  command against the mutation, and restores the file whatever happens — the proof that a
  test can go red.
- **A `SessionStart` hook** that puts a short map of the loop into the session and repeats
  it after every compaction.
