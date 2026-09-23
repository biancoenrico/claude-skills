---
type: llm
---

PASS if the response reports the off-by-one bug in `running_total.py` at the `while` loop
condition (line 4, `while i <= n:`), naming both that file and that line.

FAIL if the response does not name `running_total.py`, does not name the line with the loop
condition, or does not identify the bound as wrong.
