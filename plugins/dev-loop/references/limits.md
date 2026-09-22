# Declared numbers

Every figure this plugin commits to lives here, one entry per number, and nowhere else. A skill
or agent that needs one **names the entry and reads the value from here** — it never writes the
figure into its own text. Two copies of a number agree the day they're written and drift at the
first change, with nothing in the plugin to notice.

This file does not explain the machinery a number belongs to; each mechanism is described in its
own file, which cites the entry by name.

## How an entry is built

Each entry carries four fields:

- **Name** — what a skill calls it. Citations use the name, never the digits.
- **Searchable form** — the exact string to grep for: a bare `8`, `5`, `6` or `2` catches every
  date, exit code and section number, while `6 agents per wave` catches only a duplicate. Each
  form appears verbatim here; a hit elsewhere in the plugin is a copy to remove. **Exception:** a
  test enforcing a number may carry the digits — nothing else may.
- **Value** — the number itself.
- **Who reads it** — the parts of the plugin the number concerns; anything not listed can pass
  over the entry.

| Name | Searchable form | Value | Who reads it |
|---|---|---|---|
| the batching threshold | `8 units of work` | 8 | The skill deciding whether a plan is cut into batch files or stays a single file; the plan-folder conventions cite it by name. |
| the revision iteration cap | `3 iterations` | 3 | The spec and plan revision skills (another review round) and the review ledger (counts iterations per group against this cap). What an iteration is, what's exempt, and the cap's outcome live with the counter in `${CLAUDE_PLUGIN_ROOT}/references/ledger.md`. |
| the small document threshold | `150 lines` | 150 | The spec and plan revision skills: below it, one reviewer covers the object as one group instead of fanning out. Lines count over the whole object — the document, or every batch file of a plan folder together. |
| the correctness round cap | `2 correctness rounds` | 2 | The code revision skill, counting its `/code-review` rounds on one batch against this cap instead of the revision iteration cap. |
| the small batch threshold | `50 changed lines` | 50 | Below it: the code revision skill folds correctness and cleaning into one `/code-review` pass; the bounded path writes tests inline instead of forking test-writing; comment-writing runs inline with no fork or reviewer. Changed lines: added plus removed in the diff, test files excluded. |
| the agents-per-wave cap | `6 agents per wave` | 6 | Every skill that fans work out to several agents at once; beyond the cap the fan-out proceeds in waves. |
| the unplanned-change re-entry cap | `2 unplanned-change re-entries` | 2 | The skill executing a plan batch by batch: an unforeseen production change from the executor restarts it from its test step; this cap counts the restarts, and the third stops it for the user. (Spec mechanism I4.) |
| the drafting round cap | `2 drafting rounds` | 2 | The skill drafting batch files, counting how many times the questions-to-index-to-resume round repeats in one drafting run; the third stops it for the user. |
| the session map budget | `1200 bytes` | 1200 bytes (not characters — locale-dependent otherwise; must mean the same thing everywhere) | Whoever edits the `session-map` markers in `${CLAUDE_PLUGIN_ROOT}/references/loop.md`, printed at session start and after compaction; kept small enough to repeat for free, enforced by `tests/session-map_test.sh`, which fails over budget. |
| the skill file cap | `17500 characters` | 17500 | Whoever writes or extends a `SKILL.md` here. Past the cap, material moves into a file under `references/` and gets cited instead of the skill growing. |
