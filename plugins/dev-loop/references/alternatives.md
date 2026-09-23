# Weighing the alternatives

**Pick the variant by the object under review:** a document that decides *what* to build takes the
product pass; one that decides *how* to build it takes the construction pass. A review covering
both a spec and its plan runs both, one per object, never stretched over two.

Both passes answer the same question — **is this the right road?** — not the completeness
question.

---

## The product pass: the mechanism, the data, the way in

Run on a spec, a requirements document, an architecture note — anything that decides what the
system does.

**Load-bearing decisions here are product and domain decisions:** the mechanism chosen, where the
data comes from, where it is kept, how the user reaches it.

**Open the project first.** Read the conventions files at the root — `CLAUDE.md`, `AGENTS.md`,
`CONTRIBUTING` — and keep Grep over the shared helpers, where a mechanism likely sits; without
that, alternatives come out abstract — noise. Code out of reach: **say so**, the pass stays
uncovered, not assumed done.

For every load-bearing decision, ask three questions:

1. **Why this one, and not another?** No stated reason is a finding: it must carry the reason, not
   just the conclusion.
2. **What other roads reach the same end?** Two or three, **concrete for this project**: a tool the
   stack already has, a mechanism the code uses elsewhere, a platform API that already does it. An
   alternative that cannot be used here is not an alternative — it is noise.
3. **Is one of them materially better on a criterion the document itself states?** Not different —
   better, on the yardstick already chosen: less code to maintain, fewer things that can break. Not
   nameable in half a line, not there.

---

## The construction pass: the shape, the order, the tools

Run on a plan, a batch folder, a migration or rollout document — anything that decides how the work
gets done. The spec says *what* to build; the plan chooses *how*, weighed the same way.

**Load-bearing decisions here are construction decisions:** the structure chosen, the task order,
the tooling. The best yardstick is **less**: fewer tasks, less new code, fewer things that can
break.

Same three questions, read against the build:

1. **Why this shape, and not another?** An order with no reason is one nobody can defend when a
   task slips — the reason belongs in the document.
2. **What other ways get the work done?** Two or three, concrete for this repository: a library the
   project already depends on, a generator or script that exists, a sequence that lets two batches
   run side by side. Name them against this codebase, or leave them out.
3. **Is one of them materially better on the yardstick the plan itself declares?** Fewer tasks,
   fewer moving parts, a shorter path to the first green check. Half a line, or no advantage.

---

## What holds in both passes

**Evidence, not an impression.** "This might be better" is not a finding: an advantage needs a
measurement, platform documentation, a project precedent, or a citable source — and when the fact
is public and unknown, look it up. A plausible claim left unverified is worse than silence.

**When the alternative holds up, it becomes a question, not a rewrite.** Use the four-line form in
`${CLAUDE_PLUGIN_ROOT}/references/asking.md`: the spot, the roads and their cost, the recommended
one, and why the call stays with the user. Nothing gets rewritten on this pass alone.

**When the chosen road holds, say so** — a load-bearing decision confirmed, with its reason written
down, is a result of the review, not a non-event.

**A pass you could not run is reported, not omitted:** no access to the code or the spec the plan
is built on, or alternatives that depend on an unanswered decision — each goes in the report as an
uncovered area, so the reader knows what the approval covers.
