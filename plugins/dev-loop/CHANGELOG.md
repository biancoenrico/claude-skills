# Changelog

Kept in the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) shape, one section per
release, newest first; the plugin follows [semantic versioning](https://semver.org/).

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
