# Claude Code Skills — a plugin marketplace

Skills and plugins for [Claude Code](https://claude.com/claude-code), installable in one
command as a plugin marketplace.

| Plugin | Skill | What it does |
|---|---|---|
| [`git-flow`](plugins/git-flow/) | `/git-flow:git-flow` | A Claude Code skill for the **gitflow** branching model: drives the `git flow` CLI (AVH Edition) — install, init, full command reference with exact flags, and workflow recipes. |

## Install

Add the marketplace once:

```
/plugin marketplace add biancoenrico/claude-skills
```

Then install whichever plugin you want:

```
/plugin install git-flow@claude-skills
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

Each plugin ships one skill. A skill is a Markdown file Claude loads on demand: Claude
invokes it on its own when its `description` matches what you are doing, and you can
also call it explicitly by its namespaced name, for example `/git-flow:git-flow`.

## License

MIT
