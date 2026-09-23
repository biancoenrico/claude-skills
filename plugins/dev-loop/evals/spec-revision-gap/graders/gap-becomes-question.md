---
type: llm
---

PASS if the response raises, as an open question to the user, that the spec never says what
happens when the `from`..`to` range is very large (no maximum span, no truncation, no rejection
of a wide range).

Offering options for that question, and saying which one it would pick, still counts as asking,
as long as the decision is left to the user and the spec is not changed to adopt it.

FAIL if the response invents and states an answer for that case on its own — a maximum range, a
truncation rule, a rejection — instead of asking, or if it never raises the gap at all.
