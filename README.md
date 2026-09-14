# Claude Code Skills — a plugin marketplace

Skills and plugins for [Claude Code](https://claude.com/claude-code), installable in one
command as a plugin marketplace.

| Plugin | Skills | What it does |
|---|---|---|
| [`git-flow`](plugins/git-flow/) | `/git-flow:git-flow` | A Claude Code skill for the **gitflow** branching model: drives the `git flow` CLI (AVH Edition) — install, init, full command reference with exact flags, and workflow recipes. |
| [`dev-loop`](plugins/dev-loop/) | [10 skills](plugins/dev-loop/README.md#the-skills) | The development loop carried into any project: spec revision, plan batching, drafting, revision and execution, test writing, code, comment and design revision, backlog writing — with fresh-eyes reviewer agents. |

## Install

Add the marketplace once:

```
/plugin marketplace add biancoenrico/claude-skills
```

Then install whichever plugin you want:

```
/plugin install git-flow@claude-skills
/plugin install dev-loop@claude-skills
```

Browse and manage everything with `/plugin`. If the install summary says
`Run /reload-plugins to activate.`, run that command.

## Update

```
/plugin marketplace update claude-skills
```

Claude Code also refreshes marketplaces in the background, so you normally get new
versions without doing anything.

## How it works

A plugin ships one skill or a whole set of them, and may bring agents, hooks and
executables along. A skill is a Markdown file Claude loads on demand: Claude invokes it on
its own when its `description` matches what you are doing, and you can also call it
explicitly by its namespaced name, for example `/git-flow:git-flow` or
`/dev-loop:spec-revision`.

## License

MIT
