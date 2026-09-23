# Asking

The shape of a question and its answer — any object under work (spec, plan, batch, diff), and
whoever works it: main thread, agent, forked skill.

## Who owns the question

Before every question, decide who it belongs to:

- **You, by reading.** It's in the code, the conventions, or another doc on the same area — read
  it, close it, cite the source in the report so the user can contradict it.
- **You, by searching.** A fact about the world — standard, platform limit, physical constant,
  documented API behaviour. **Go search**, bring back the source.
- **The user.** It depends on their intent, priority, or context no document holds. Only these
  become questions.

A number with no stated provenance isn't a question either: a threshold, window or limit is a
measurement, a cited standard, or a declared choice — otherwise it **is a finding, not a
requirement**: raised, not asked, and not binding on the work.

## Who may ask, and how a question travels

- An agent or forked skill **cannot ask the user**: it stops, returning `status: question`, the
  four-line form below, and the state it needs to resume.
- The **main thread** is the only place a question reaches the user: it applies the filter above,
  closes what closes by reading or searching (itself or a read-only search agent), and collects
  the rest into one block.
- **Resuming differs by kind.** An agent resumes via SendMessage, keeping context; unresumable, a
  new one launches with the answers and state on disk. A forked skill resumes by re-invoking it
  with the answers and state as arguments.
- **Finish independent work before stopping for a question.** Exception: inside a batch, the
  procedure steps — executor, tests, code review, closing-criteria check, wrap-up — don't advance
  while a question is open.

## The four lines of a question

Asked **in one block**, never one at a time. Each one in four blunt lines:

- **Where I stopped** — the exact point: section, task, or file and line, and what it says there.
- **What is missing** — the question, in one line.
- **The options** — two or three, each with a half-line cost. No option without a stated
  consequence: equivalent alternatives are a choice, not a question.
- **What I recommend, and why the choice is yours** — the recommendation first, then why it can't
  be deduced from what's already written.

No preambles, no courtesies, no recap of what was just said. Every line without a fact or a
consequence comes out.

## When only part of the block comes back

A partial answer is normal, not incomplete, handled the same way whatever the object is:

- **Apply what's decided.** Carry the arrived answers into the object, record where its decisions
  live.
- **The rest stays open** — not closed by assumption, default, or picking the recommended option
  for the user.
- **Nothing is declared approved** while a question is open — not the document, the batch, or the
  review.
- **The open ones return in the next block**, with anything new since. Not re-asked one at a
  time, not dropped for having been asked once.
