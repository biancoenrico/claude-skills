# claude-skills

A plugin marketplace of skills for [Claude Code](https://claude.com/claude-code).

| Plugin | Skill | What it does |
|---|---|---|
| [`git-flow`](plugins/git-flow/skills/git-flow/SKILL.md) | `/git-flow:git-flow` | Drives the `git flow` CLI (AVH Edition): install, init, full command reference with exact flags, branching model and workflow recipes. |

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

Each plugin ships one skill. Claude invokes a skill on its own when its `description`
matches what you are doing; you can also call it explicitly by its namespaced name,
for example `/git-flow:git-flow`.

## License

MIT
