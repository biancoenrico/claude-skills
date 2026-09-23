# The three proofs, and the five checks that feed them

The gates a comment must pass to stay, the recipes finding candidates, and the report format.

## The cutting proof

For every surviving comment, one line: **without this comment what is lost is:** _[the
information]_ — readable anyway in the surrounding lines, and the comment is deleted, however well
written or freshly typed. Like proving a test by mutation: a freshly written comment proves someone
wrote it, not that it's needed — the difference shows only when you try removing it.

## The new reader's proof

Applies to every comment. The cutting proof asks whether it carries information; this one asks
**who it is talking about**: reread it as someone who cloned the repository this morning, never
having seen an earlier version — **every sentence that reads as incomprehensible, or asks them to
imagine how it was before, is chronicle and gets rewritten in the present.** Whoever just made the
change can't run this in their head, since the previous version is still there — hence the four
memory-independent checks below.

**In tests the name goes too:** a test already declares what it proves through its path and name, so
pointing back at the code under test adds nothing — what's left is the case: inputs, outcome, what
would break. **Corollary, itself a gate:** a case needing a pointer to code means the test is wrong
or unnecessary — the remedy is in the test, not the comment.

## The fidelity proof

Born out of the second: cutting chronicle can carry away a fact hidden in the same sentence, the
symmetrical failure once the blindness is cured. **No measured number and no name may disappear
from a comment without being said again elsewhere or declared stale in writing.** Line numbers are
the exception and do come out, but the case they pointed at doesn't: the number goes, the method's
or constant's name takes its place.

Facts can't be reproduced from memory — a measured result proves a check is needed, and without it
what's left is an assertion, so deleting it with its chronicle is a net loss. A fact tied to
something gone is reformulated as a measurement or declared stale in the report — never dropped in
silence.

## The five checks

Each check has a fixed name, labelling its findings. A finding is one line, four fields:
`file:line:check:text` — **a split rule, not a field count**: the first three `:` separate the
fields, everything after is text, so a comment with its own colon ("TODO: review this") stays
whole. **Rule governing all five: the recipe proposes, the judgement is the skill's** — a grep hit
is a candidate, never a verdict. Run all five in one shell command, output under `=== name ===`
headers — independent, each a round trip to the model.

### `process-ref` — references to the process

Terms living in a plan or conversation, not the repository ("batch 09", "decision D1") —
unresolvable in six months, belonging in a commit or ticket, never a comment.

```bash
grep -rniE 'batch [0-9]|decision [a-z0-9]|after the review|decisione [a-z0-9]|dopo la revisione|come deciso' \
  <target> --include='*.<ext>'
```

**Extend with the plan's vocabulary** — what a new reader can't resolve, reachable via the plan's
index, otherwise the base list is all there is, and the report says so. False positive: a class
actually called `Batch`.

### `missing-name` — names cited that no longer exist

Every class, method or constant cited must be findable, or it talks about something deleted.

```bash
grep -rhoE '`[A-Za-z_][A-Za-z0-9_:]+(\(\))?`|[A-Za-z_][A-Za-z0-9_]*::[a-z_]+\(\)' <target> \
  | tr -d '`' | sed 's/()$//' | sort -u \
  | while read -r n; do git grep -qF "$n" || echo "MISSING: $n"; done
```

The `Class::method()` form is added by hand: a plain regex over `[A-Za-z0-9_:]` misses parentheses
inside backticks, exactly where renamed methods hide. *Limits:* `git grep` sees only **tracked**
files, so an unadded file's name reads as missing (a name just written is that false positive); a
hit on its own comment line is the comment finding itself. Catches dead references only — chronicle
names vanished things **in prose**, no backticks to catch; `process-ref` and rereading count there.

### `line-ref` — the line number, never cited

A line moves at the first extracted method or schema change — the comment stays behind, and a
reader who trusts it finds something else there. The real damage: comments scattered in unrelated
files need updating too. **In the number's place goes the case, described.**

```bash
grep -rnE '[A-Za-z_][A-Za-z0-9_/]*\.[A-Za-z0-9]+:[0-9]+|`:[0-9]+' <target>
```

Every line gets rewritten, no exception for a citation still correct today — it can't notice when
it stops being so. False positive: `something:NN` that isn't a file and line (a URL with a port, a
timestamp, a version range).

### `tense` — past and conditional

A comment describing the system speaks in the present. Every past or conditional verb is a
candidate averted incident or diary, reread for *which moment it's about* — if the new reader can't
place it, rewrite in the present or cut it.

```bash
grep -rniE '(was|were|had|would|could|should|might|previously|formerly)' <target> --include='*.<ext>'
grep -rniE '(era|erano|aveva|avevano|fu|furono|sarebbe|avrebbe|potrebbe|dovrebbe|veniva|venivano|precedenza)' \
  <target> --include='*.<ext>'
```

The same words appear in legitimate prose too ("otherwise it returns null" is a contract, not an
incident), so **the grep proposes, the rereading disposes**. Limit: English/Italian patterns only;
elsewhere **the check is skipped**, and the report says so.

### `lost-fact` — the facts a diff drops

The check behind the fidelity proof, the only one needing a base reference: working tree comments
against `<ref>`'s, reporting every number and name the base carried that's gone.

```bash
d=$(git diff -U0 <ref> -- <target>)
comm -23 \
  <(printf '%s\n' "$d" | grep -E '^-[[:space:]]*(\*|//|#)' | grep -ohE '[0-9]+([.,][0-9]+)?%?|[A-Za-z_]+\.[a-z]+:[0-9]+' | sort -u) \
  <(printf '%s\n' "$d" | grep -E '^\+[[:space:]]*(\*|//|#)' | grep -ohE '[0-9]+([.,][0-9]+)?%?|[A-Za-z_]+\.[a-z]+:[0-9]+' | sort -u)
```

Needs process substitution — bash, not plain POSIX; without it, write the sorted lists to files and
`comm` those instead. Every line out is a fact the diff drops without replacing: it goes back in,
or the report says why not (some false positives occur, cheaper than a lost fact).

**The `lost-fact` line field is `base@NN`** (line NN in `<ref>`), `@` replacing `:` since a fourth
`:` would break the split rule above.

## When a check does not run

Each of these is a declared degradation, never silence: prose in another language (`tense`
skipped); outside a git repository (`missing-name`, `lost-fact` can't run, the other three do); an
unresolvable base reference (`lost-fact` doesn't run; corrected once, else declared a limit); an
extension with no known comment syntax (not read, and named). Not run is reported as not run, never
as clean.

## The report

Only sections with at least one item.

```
## Comment writing — [writing | review]

**Scope:** [files/diff/range] · **Conventions:** [prose language, docblocks]
**Balance:** written N · rewritten N · corrected N · **brought to the present N** · removed N ·
discarded up front N · promoted to code N

### Written / rewritten
**[CMT-001]** file:line — [class | function | inline] · **without it, lost:** [information] ·
**text:** [the comment, or its gist]

### Removed / discarded
**[CMT-002]** file:line — **Reason:** [paraphrase | ceremony | ornament | working note | stale |
diary | crutch]

### Promoted to code
**[CMT-003]** file:line — [renamed X to Y | extracted Z] — no longer needed

### Open points
- [crutches not extracted since the operation wasn't trivial, with the reason]

### Verifications
- [syntax check/linter outcome] · [gates: existence gate, process-ref, missing-name, line-ref,
  tense, lost-fact — any not run, with why] · [facts removed and not put back, with why — empty if
  none]
```

Sequential codes (`CMT-001`, `CMT-002`…) so each entry can be cited later.
