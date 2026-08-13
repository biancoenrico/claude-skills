# claude-skills

Skills for [Claude Code](https://claude.com/claude-code).

| Skill | What it does |
|---|---|
| [`git-flow`](skills/git-flow/SKILL.md) | Drives the `git flow` CLI (AVH Edition): install, init, full command reference with exact flags, branching model and workflow recipes. |

## Install

Copy a skill into your skills directory — personal:

```bash
mkdir -p ~/.claude/skills
cp -r skills/git-flow ~/.claude/skills/
```

…or per project, so the team gets it from the repo:

```bash
mkdir -p .claude/skills
cp -r skills/git-flow .claude/skills/
```

Claude Code picks up `SKILL.md` files from those directories at startup and invokes a
skill when its `description` matches what you are doing.

## License

MIT
