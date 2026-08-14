# git-flow — a Claude Code skill for the gitflow branching model

Teaches [Claude Code](https://claude.com/claude-code) to drive the `git flow` CLI
(AVH Edition) instead of improvising raw git commands: Vincent Driessen's branching
model, with `main` and `develop` as long-lived branches and short-lived feature,
bugfix, release, hotfix and support branches.

## Install

```
/plugin marketplace add biancoenrico/claude-skills
/plugin install git-flow@claude-skills
```

## Use

Claude invokes the skill on its own whenever the work involves gitflow branching —
starting a feature, finishing a release, cutting a hotfix, or any `git flow` command.
You can also call it explicitly:

```
/git-flow:git-flow
```

Then just ask in plain language:

- "start a feature for the login rewrite"
- "finish this release and tag 1.4.0"
- "I need a hotfix on production"
- "how do I share a feature branch with a colleague?"

## What it covers

- **Preflight** — detect whether `git flow` is installed, and install it per platform
  (Debian/Ubuntu, macOS Homebrew, Windows, source) including the GNU `getopt` step macOS
  needs; then `git flow init` and its branch/prefix configuration.
- **The model** — which branch a given piece of work starts from and merges back into,
  so features never land straight on `main`.
- **Command reference** — `feature`, `bugfix`, `release`, `hotfix` and `support`, each
  with the exact flags that matter (`-F`, `-k`, `-S`, `--no-ff`, `-m`, `-p`, …), plus
  `config` and `log`.
- **Recipes** — publish and pull a shared feature branch, cut a release with a version
  bump and changelog, ship a hotfix that also lands back in `develop`.
- **Gotchas** — the failure modes that bite in practice, and where the model stands
  today versus trunk-based development.

Full skill source: [`skills/git-flow/SKILL.md`](skills/git-flow/SKILL.md).

## License

MIT
