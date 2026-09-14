# What comes back from an agent

The shape of the return that an agent, or a skill running in a fork, hands to whoever launched
it. Whoever launched it is the only reader: it is not a report for the user, and it is not a
place to think out loud. Everything the caller needs in order to decide what happens next is in
these fields, and nothing that is not in these fields survives the return.

The two halves of this file belong together. The first says what a return looks like; the second
says what to do when one does not arrive, or arrives in a shape that cannot be read. A return
that does not fit the fields below is not a return to be interpreted — it is a failure, and it
is handled by the second half.

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

The fields in that order, with those names. A caller reads them by name, so a renamed or
reordered field is the same defect as a missing one.

- **`status` and `summary` — everyone.** Every agent and every forked skill fills both, whatever
  its job. `status` is what the caller branches on; `summary` is at most five lines and says what
  was done, not how it felt.
- **`findings` — the reviewer**, in the format of the criteria file it was handed: it does not
  invent a format of its own. A forked skill puts its own report here.
- **`commits` — whoever commits**, which is the executor and a forked skill that commits. Sha and
  subject, one per line. An agent that commits nothing leaves it empty rather than explaining
  that it committed nothing.
- **`deviations` — the executor.** Where the batch file said one thing and the work turned out to
  need another, and why reality was right. A batch that is always guessed correctly was not
  executed.
- **`criteria_evidence` — the executor.** One line per closing criterion: the criterion, the
  command run, the outcome. Reds are reported here too, not hidden behind a green summary.
- **`test_targets` — the executor**, which neither writes nor repairs tests: it lists the batch's
  test tasks and any existing test that a deliberate change has broken, and leaves them to the
  skill that owns tests.
- **`notes_for_batches` — the executor and the drafter.** Each note names the batch file where
  its remedy belongs, so the caller can file it there instead of holding it in its head.
- **`state` — a forked skill and the executor**, whenever `status` is `question`. See below.
- **`questions` — whoever returns `status: question`**, in the form held by
  `${CLAUDE_PLUGIN_ROOT}/references/asking.md`. An agent and a forked skill cannot ask the user;
  this field is how a question travels to someone who can.
- **`blocked_by` — whoever returns `status: blocked`.** What is missing, named precisely enough
  that the caller can go and get it: an access, a datum, an environment, a decision that belongs
  somewhere else.

Fields that do not apply to the job are left out, not filled with a placeholder saying they do
not apply.

### The state of whoever stopped

**Whoever stops puts in `state` what it needs in order to start again.** A skill running in a
forked context is picked up again by invoking it a second time with the state it returned —
that is the only route back in (the specification calls this invariant I3). A fork does not see
the conversation and gets no context back for free on that second invocation, so anything it
worked out and would otherwise have to work out again belongs in this field — the lists it had already decided, the iteration it had reached, the findings it had
already discarded, the point it had reached in its own procedure. The caller writes that state
where the work of that object is recorded, and passes it back in the arguments when it invokes
the skill again. An executor that is resumed is handed the same thing.

A `state` that only says "resumed halfway" costs the next invocation everything that came before
it. The test is blunt: hand the field to someone who was not there, and ask whether they could
carry on from it.

## No dumps

**No file contents, and no command output beyond the single line that proves a finding.** A
return quotes a path and a line number, not the function around it; it quotes the one failing
assertion, not the test runner's whole log. The caller can read the file itself, and a return
that pastes it in spends the caller's context on something it already had.

The same goes for the reasoning: the return says what was concluded and what proves it, not the
route taken to get there.

## When nothing comes back

An agent can fail, be interrupted, or return something that cannot be read. All three are the
same case, and whoever launched it handles them the same way:

1. **Look before relaunching.** `git status` and the diff say where the work stopped and what
   already exists on disk. A relaunch that does not know this redoes work that is already done,
   or undoes it.
2. **Relaunch once**, with the error and the partial state — what was already produced, and where
   it stopped. Once, not until it works: an agent that fails twice on the same input is failing
   for a reason the third attempt will not fix either.
3. **On the second failure, carry on yourself from that state.** The work does not stop and does
   not wait: whoever launched the agent does the remaining work directly, starting from what the
   agent left behind.
4. **Declare the degraded mode in the report.** It has to say that the work was done without the
   agent, from which point, and what the agent had left behind when it stopped. Work done in the
   degraded mode that is not declared as such reads later as work that went normally, and nobody
   goes back to look at it.

This rule lives here and not inside any one skill because every skill that launches someone uses
it — whoever runs a review, whoever has a plan drafted, whoever has a batch executed. A skill
cites it; no skill owns it.

## A malformed return is a failure, not a puzzle

A return whose fields are missing, renamed, reordered, or unreadable is treated as a failed
agent, and goes through the rule above from its first step. It is never salvaged by guessing:
not by reading a `status` out of the prose, not by taking the summary as the findings, not by
assuming that a missing `questions` field means there were none.

The reason is that a caller which interprets a broken return acts on something the agent never
said, and there is nothing in the record afterwards to show that it did. A relaunch costs one
agent; a return read out of a shape that was never agreed costs whatever gets built on top of
it. That is why the field format and the never-arrives rule share this file: they are two halves
of the same contract, and the second is what happens when the first is not honoured.
