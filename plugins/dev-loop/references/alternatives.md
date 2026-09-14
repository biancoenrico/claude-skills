# Weighing the alternatives

**Pick the variant by the object under review: a document that decides *what* to build takes the
product pass; a document that decides *how* to build it takes the construction pass.** A review that
covers a spec and the plan built on it runs both, one per object, never one pass stretched over two.

Both passes answer the same awkward question — **is this the right road?** — which is not the
question a completeness check answers. A review tends to skip it, because a written document has a
gravity of its own: you read what is there, you patch the cracks, and the road already taken is
taken as given. A well-written document on the wrong approach passes a review with full marks, and
the bill arrives once the thing is built, when changing road also means undoing everything stacked
on top of it.

---

## The product pass: the mechanism, the data, the way in

Run this one on a spec, a requirements document, an architecture note — anything that decides what
the system does.

**Load-bearing decisions here are product and domain decisions:** the mechanism chosen, where the
data comes from, where it is kept, how the user reaches it.

**Open the project first.** This pass needs to know what the project already has — a mechanism used
elsewhere, a stated convention, a platform constraint — and without that knowledge it produces
abstract alternatives, which are noise. Read the conventions files the project keeps at its root and
keep Grep within reach. If the code is out of reach, **say so**: that pass stays uncovered, and the
document gets approved knowing it rather than believing it done.

For every load-bearing decision, ask three questions:

1. **Why this one, and not another?** If the document does not say, that is a finding: a decision
   with no discarded alternatives was not taken, it was suffered. It has to carry the reason, not
   only the conclusion.
2. **What other roads reach the same end?** List them for real, two or three, and **concrete for
   this project**: a tool the stack already has, a mechanism the code uses elsewhere, a platform API
   that already does that work. An alternative that cannot be used here is not an alternative, it is
   noise.
3. **Is one of them materially better on a criterion the document itself states?** Not *different*:
   *better*, and on the yardstick already chosen — less code to maintain, less consumption, fewer
   steps for the user, fewer things that can break. If the advantage cannot be named in half a line,
   it is not there.

---

## The construction pass: the shape, the order, the tools

Run this one on a plan, a batch folder, a migration or rollout document — anything that decides how
the work gets done.

The spec says *what* to build; the plan chooses *how*, and that choice gets weighed like any other,
rather than taken as sound because it is written down.

**Load-bearing decisions here are construction decisions:** the structure chosen, the order of the
tasks, the tooling. The best yardstick is **less**: fewer tasks, less new code, fewer things that
can break.

Same three questions, read against the build:

1. **Why this shape, and not another?** A plan that gives an order without a reason has an order
   nobody can defend when a task slips. The reason belongs in the document.
2. **What other ways get the work done?** Two or three, concrete for this repository: a library the
   project already depends on, a generator or a script that exists, a sequence that lets two batches
   run side by side instead of one after the other. Name them against this codebase, or leave them
   out.
3. **Is one of them materially better on the yardstick the plan itself declares?** Fewer tasks,
   fewer moving parts, a shorter path to the first green check. Half a line, or it is not an
   advantage.

---

## What holds in both passes

**Evidence, not an impression.** "This might be better" is not a finding. An advantage is held up by
a measurement, by platform documentation, by a precedent in the project, or by a citable source —
and when the fact is public and you do not know it, **go look it up**. The rule for numbers applies
here too: a plausible claim left unverified is worse than silence.

**When the alternative holds up, it becomes a question, not a rewrite.** Use the four-line form in
`${CLAUDE_PLUGIN_ROOT}/references/asking.md`: the exact spot, the roads with what each costs, the
one you recommend, and why the call stays with the user. Nothing gets rewritten on the strength of
this pass alone.

**When the chosen road holds, say so.** A load-bearing decision confirmed, with its reason now
written down, is a result of the review and not a non-event: the next time somebody wonders whether
another way would have been better, the answer is already there.

**A pass you could not run is reported, not omitted.** No access to the code, no access to the spec
the plan is built on, a decision whose alternatives depend on something nobody has answered yet —
each of those goes in the report as an uncovered area, so the reader knows what the approval covers.
