---
type: llm
---

PASS if the response raises, as an open question to the user, that the spec never says what
happens when the `from`..`to` range is very large (no maximum span, no truncation, no rejection
of a wide range).

FAIL if the response invents and states an answer for that case on its own — a maximum range, a
truncation rule, a rejection — instead of asking, or if it never raises the gap at all.
