# What comes back from an agent

The shape of the return an agent, or a forked skill, hands to whoever launched it — the only
reader, not the user. Everything the caller needs to decide what happens next is in these fields;
nothing else survives the return.

## The fields, and who fills each one

```
status: done | question | blocked
summary: <at most 5 lines>
findings: <in the format of the criteria received>            (reviewer; a forked skill: its report)
commits: <sha and subject>                                    (executor, forked skill)
deviations: <where the plan did not get it right, and why>    (executor)
criteria_evidence: <criterion → command → outcome, reds included> (executor)
test_targets: <the batch's test tasks; existing tests broken by a deliberate change> (executor)
notes_for_batches: <note → the batch file where its remedy belongs> (executor, drafter)
state: <what it takes to start again>                         (forked skill and executor, when status is question)
questions: <in the four-line form>                            (when status is question)
blocked_by: <what is missing>                                 (when status is blocked)
```

That order, those names — a renamed or reordered field is as broken as a missing one. `status` and
`summary` are filled by everyone; `summary` says what was done, not how it felt. `commits` is one
entry per line, empty if none. `test_targets`
is the executor's, who neither writes nor repairs tests. `questions` uses the four-line form in
`${CLAUDE_PLUGIN_ROOT}/references/asking.md` — the only route to the user, since neither an agent
nor a forked skill can ask directly. `blocked_by` names what is missing, precisely enough for the
caller to go get it. Fields that do not apply are left out, not filled with a placeholder.

### The state of whoever stopped

**`state` holds what it takes to start again.** A forked skill is resumed only by reinvoking it
with the state it returned (I3) — it gets nothing else back, so anything worked out belongs here:
lists decided, iteration reached, findings discarded, point reached in procedure. The caller keeps
that state where the work is recorded and passes it back on reinvocation; a resumed executor gets
the same treatment.

Test: a `state` saying only "resumed halfway" is not enough — hand it to someone who was not
there and ask whether they could carry on from it.

## No dumps

**No file contents, no command output beyond the single line that proves a finding**: a path and
line number, not the function around it; the one failing assertion, not the whole log. Same for
reasoning — what was concluded and what proves it, not the route taken.

## When nothing comes back

Failing, being interrupted, and returning something unreadable are the same case, handled the
same way:

1. **Look before relaunching** — `git status` and the diff show what already exists.
2. **Relaunch once**, with the error and the partial state.
3. **On the second failure, carry on yourself** from that state.
4. **Declare the degraded mode**: work done without the agent, from which point, and what the
   agent left behind.

## A malformed return is a failure, not a puzzle

Missing, renamed, reordered, or unreadable fields make a return a failed agent, handled by the
steps above from the first step. Never salvaged by guessing: not a `status` read out of the
prose, not the summary taken as findings, not a missing `questions` assumed to mean none.
