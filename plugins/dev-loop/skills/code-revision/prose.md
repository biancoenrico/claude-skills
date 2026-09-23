# Prose-only diff criteria

What a `dev-loop:reviewer` checks in a prose-only diff (markdown, instructions, config): nothing
runs, so only a followed instruction can break. Judge the diff; read the repo only to check it.

1. **Contradiction.** A changed rule says one thing, another file/section says the other —
   quote both.
2. **Two readings.** An instruction two agents could read differently: an exception missing
   where applied, a condition with no outcome for one case, a step with two points in time.
3. **The same rule twice.** A rule, rationale or number restated where it could cite its owning
   file — copies drift at the first edit.
4. **Broken reference.** A cited file, section, name or entry gone, or not saying what cited.
5. **Declared limits.** Caps or mechanical checks — sizes, budgets, versions — pushed past or
   out of step.

A finding outside these five does not belong in the return: wording taste is not a finding.
