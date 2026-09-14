# Asking

The shape of a question put to the user, and of the answer that comes back. It holds for any
object under work — a spec, a plan folder, a single batch file, a diff — and for anyone who
works on one: the main thread, an agent, a forked skill.

## Who owns the question

A review that asks everything stops being read, and whoever uses it starts answering "yes,
fine" with their eyes closed — the same damage as the questions never asked, paid for with
more effort. Before every question, decide who it belongs to:

- **You answer it by reading.** It is in the code, in the project's conventions, in the other
  documents covering the same area. Go read, close the finding yourself, and cite the source
  in the report so the user can contradict it.
- **You answer it by searching.** It is a fact about the world: a standard, a platform limit,
  a physical constant, the documented behaviour of an API. **Actually go and search**, and
  bring the source back. A plausible invented figure in place of a real one is the worst
  defect this work can produce, because it passes inspection wearing the look of something
  that was verified.
- **The user answers it.** It depends on their intent, their priority, or on something they
  know about their own context that no document contains. Only these become questions.

A number without a stated provenance is not a question either: every threshold, window or
limit has to be a measurement, a cited standard, or a choice declared as such — and when it
is none of those, **it is a finding, not a requirement** — something to raise, not to ask, and
not something the work is bound by.

## Who may ask, and how a question travels

- An agent and a forked skill **cannot ask the user**. They stop and return
  `status: question`, with the questions in the four-line form below and whatever state they
  need in order to resume.
- The **main thread** is the only place a question reaches the user. It applies the filter
  above to everything that comes back: the ones that close by reading or searching it closes
  itself, on its own or with a read-only search agent; the rest it collects and asks in one
  block.
- **Resuming is not the same for both.** An agent is resumed with SendMessage, so it keeps its
  own context; if it can no longer be resumed, a new one is launched with the answers and the
  state written to disk. A forked skill is resumed by invoking it again with the answers and
  its state passed in the arguments.
- **Before stopping for a question, finish the work that does not depend on the answer.** A
  stop that also blocks independent work costs twice. The one exception: inside a batch, the
  steps of the batch procedure — the executor's work, then the tests, then the code review,
  then the check of the closing criteria, then the wrap-up — do not advance while a question is
  open, because an answer can undo the step that would have run next.

## The four lines of a question

Questions are asked **in one block**, never one at a time: whoever answers sees the whole
picture and decides coherently, instead of discovering on the third round that the first
answer was wrong. Each one in four blunt lines:

- **Where I stopped** — the exact point: the section, the task, or the file and line, and what
  it says there.
- **What is missing** — the question, in one line.
- **The options** — two or three, each with its cost in half a line. No option without a
  stated consequence: if the alternatives are equivalent it is not a question, it is a choice
  you can make yourself.
- **What I recommend, and why the choice is yours** — the recommendation first, then what makes
  the choice impossible to deduce from what is already written.

No preambles, no courtesies, no recap of what the user just said. Every line that carries
neither a fact nor a consequence comes out.

## When only part of the block comes back

The user may answer some of the questions and not the others. That is a normal answer, not an
incomplete one, and it is handled the same way whatever the object is:

- **Apply what has been decided.** The answers that arrived are settled: carry them into the
  object, and record them where the decisions of that object live.
- **The rest stays open.** An unanswered question is not closed by assumption, by a default, or
  by picking the recommended option on the user's behalf.
- **Nothing is declared approved** while a question is open — not the document, not the batch,
  not the review. An approval with half the answers in hand is the failure this rule exists to
  prevent.
- **The open ones come back in the next block of questions**, together with anything new that
  has come up since. They are not re-asked one at a time, and they are not dropped because they
  were already asked once.
