# Criteria for a prose-only diff

The criteria a `dev-loop:reviewer` judges a diff against when it changes only prose: markdown,
instructions, configuration text. There is nothing to run and nothing to mutate, so tests and
code revision have nothing to hold on to. What can still break is an instruction that an agent
will follow.

Judge the diff, and read the rest of the repository only to check it against.

1. **Contradiction.** A changed rule says one thing and another file, or another section of the
   same file, still says the other. Quote both lines.
2. **Two readings.** An instruction an agent could follow in two ways that lead to different work:
   an exception stated in one place and missing where the rule is applied, a condition with no
   outcome for one of its cases, a step with two points in time.
3. **The same rule twice.** A rule, a rationale or a number restated where it could be cited from
   the place that owns it. The copies agree today and drift at the first edit.
4. **Broken reference.** A cited file, section, name or entry that does not exist, or no longer
   says what the citation claims.
5. **Declared limits.** Anything the project caps or checks mechanically — file sizes, byte
   budgets, versions that must match — and that the diff pushes past or out of step.

A finding outside these five does not belong in the return: wording taste is not a finding.
