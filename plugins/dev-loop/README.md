# dev-loop — a Claude Code development loop, in any project

Takes the loop that turns an idea into merged code — spec, plan, execution, tests, review —
and makes it something [Claude Code](https://claude.com/claude-code) carries into every
project on every machine, rather than a set of habits living in one person's `CLAUDE.md`.
Whoever reviews is never the context that wrote; independent work fans out to agents while
anything with a dependency stays in order; and the skills that talk to you keep working
after a compaction.

## Install

```
/plugin marketplace add biancoenrico/claude-skills
/plugin install dev-loop@claude-skills
```

**Requires Claude Code 2.1.251 or later** — the highest documented version among the fields
this plugin declares, set by the `SessionStart` hook with a `resume` matcher
(`hooks/hooks.json`). The next highest are `context: fork` (2.1.212) and `background:`
(2.1.186), both used by the two skills that run in a fork. Two caveats kept here on purpose:
the documentation gives no introducing version for the skill fields `name`, `description`,
`when_to_use` and `argument-hint`, nor for `effort` on skills and agents, so one of those
could raise the floor.

## Use

A `SessionStart` hook drops a short map into the session and repeats it after every
compaction, so Claude knows which path a piece of work belongs to before it starts: a
**spike** runs no loop, a **surgical** change that repeats a pattern already beside it is
made in the main thread with no agents, a **bounded** change goes straight to tests and
review, an **architectural** one earns the full sequence. Each path, and the rule that picks between
them, is written out once in
[`references/loop.md`](references/loop.md) — that file is the loop, and nothing else
restates it.

Skills fire on their own when what you are doing matches them, and you can always call one
by name:

```
/dev-loop:spec-revision docs/specs/rate-limiting.md
```

## The skills

| skill | what it is for |
|---|---|
| `/dev-loop:spec-revision` | Reviews a specification round after round until it can be implemented without guessing, with an answer written down for every scenario the system will meet. |
| `/dev-loop:plan-batching` | Decides the shape of a plan before anyone writes it: where the batch boundaries fall, what the batches share, who owns each shared rule. |
| `/dev-loop:plan-drafting` | Fills in the tasks of a plan whose shape is already decided, one drafter per batch file, in parallel. |
| `/dev-loop:plan-revision` | Reviews a plan until it can be executed step by step: no broken dependency, no unexecutable step, no coverage gap, no unmitigated risk. |
| `/dev-loop:plan-execution` | Runs a plan one batch at a time without asking permission at every step, and records in the batch file how it went. |
| `/dev-loop:test-writing` | Decides what deserves a test, writes it, and proves by mutation that it can go red. In audit mode it judges a suite it inherited. |
| `/dev-loop:code-revision` | Reviews the code of one batch until it is at once correct and clean, then hands the comments over to comment-writing. |
| `/dev-loop:comment-writing` | Decides whether a comment is needed at all and, when it is, writes it short and useful. |
| `/dev-loop:design-revision` | Looks at the shape of a branch — whether the structure holds — and straightens it with the smallest remedy that does. |
| `/dev-loop:backlog-writing` | Breaks a brief or an approved spec into stories and tasks sized in Fibonacci points, ready to be typed into a ticket system. |

## The agents

The skills launch these; you never have to. Each one gets a fresh context, which is the
point: judgement passes are worth more when the reader is not the writer.

- **`dev-loop:reviewer`** — a fresh-eyes judgement pass against the criteria file it is
  handed. Read-only: it reports findings and edits nothing.
- **`dev-loop:drafter`** — writes the content of a single batch file, inside the shape the
  plan index has already fixed, and touches no other file.
- **`dev-loop:executor`** — carries out one batch of a plan and commits the production code
  it wrote.

**A name collision is silent, so it is worth knowing about.** An agent of your own — in
`~/.claude/agents/` or in the project — named `reviewer`, `drafter` or `executor` takes
precedence over the plugin's, and the skills end up launching yours. Rename one of the two
if that is not what you want.

## The script

One executable ships with the plugin, and it is the one that touches your working tree:

```
sh ${CLAUDE_PLUGIN_ROOT}/scripts/devloop-mutate <file> <find> <replace> -- <command> …
```

It swaps one literal string in a tracked, unmodified file, runs your test command against
the mutation, and puts the file back on every path out — a passing command, a failing one,
an error, a `HUP`, an `INT` or a `TERM`. Its exit codes say whether the mutation was
caught, survived, or never got a verdict. `/dev-loop:test-writing` calls it to prove a test
can fail; you can run it by hand the same way, always by path, never as a bare command from
the `PATH`.

Two limits it states rather than hides. A signal that arrives **while your command is
running** does not interrupt the command: a non-interactive shell runs the handler only
once the foreground command returns, so the file stays mutated for as long as the command
takes. Put the deadline on the command, where it already works —
`sh … -- timeout 60 make test`. And a `SIGKILL` runs no handler at all, so the file stays
mutated; the original is under `<git-dir>/devloop-mutate/`, and the script says where.

## Companion plugins — recommended, never required

`plugin.json` declares no dependencies at all, deliberately: a missing dependency disables
the whole plugin, and dev-loop works on its own.

- **[superpowers](https://github.com/obra/superpowers)** — with it installed, its
  brainstorming skill classifies the work and dev-loop's precedence table
  ([`references/loop.md`](references/loop.md)) says which of the two steps wins at each
  overlap. Without it, Claude classifies with the rule in the same file.
- **[humanizer](https://github.com/blader/humanizer)** — `comment-writing` and
  `backlog-writing` pass their prose through it when it is available. Without it they skip
  the rewrite and say so in their report.

## License

MIT
