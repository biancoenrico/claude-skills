# dev-loop

**Requires Claude Code 2.1.251 or later** — the highest documented version among the fields
this plugin actually declares, set by the `SessionStart` hook with a `resume` matcher
(`hooks/hooks.json`). The next highest are `context: fork` (2.1.212) and `background:`
(2.1.186), both used by the two skills that run in a fork.

Two caveats, kept here on purpose: the documentation gives no introducing version for the
skill fields `name`, `description`, `when_to_use` and `argument-hint`, nor for `effort` on
skills and agents, so one of those could raise the floor; and this figure is a starting
value, re-verified against the finished plugin before release.
