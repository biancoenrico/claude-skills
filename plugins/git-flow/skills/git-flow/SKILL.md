---
name: git-flow
description: Use when working with git-flow branching — feature, bugfix, release, hotfix or support branches, any `git flow` command, gitflow init or config, or questions about the nvie branching model. Covers installation, initialization, the full AVH command reference with exact flags, and workflow recipes.
---

# git-flow

Drive the `git flow` CLI (AVH Edition) to manage Vincent Driessen's branching model:
two long-lived branches (`main`/`master` + `develop`) and short-lived feature,
bugfix, release, hotfix and support branches.

This skill assumes the `git flow` command. If it is missing, walk the user through
installing it (Step 1) rather than falling back to raw git commands.

## Step 1 — Preflight

Always start here. Two things must be true: git-flow is installed, and the repo is
initialized.

```bash
git flow version          # e.g. "1.12.3 (AVH Edition)"
```

**Not installed?** Guide the user through it — pick the line for their platform:

| Platform | Command |
|---|---|
| Debian / Ubuntu | `sudo apt-get install git-flow` |
| macOS (Homebrew) | `brew install git-flow-avh` |
| Windows | Included in Git for Windows ≥ 2.6.4 — install/update Git for Windows |
| Any Unix (source) | `wget -q https://raw.githubusercontent.com/petervanderdoes/gitflow-avh/develop/contrib/gitflow-installer.sh && sudo bash gitflow-installer.sh install stable; rm gitflow-installer.sh` |

macOS extra step — AVH needs GNU getopt:

```bash
brew install gnu-getopt
echo 'export FLAGS_GETOPT_CMD="$(brew --prefix gnu-getopt)/bin/getopt"' >> ~/.gitflow_export
```

Then re-run `git flow version` to confirm before going further.

Note: distro packages can lag. `apt` on older Ubuntu ships versions several years
old; the installer script gives the last released AVH build.

**Installed but repo not initialized?** Check first:

```bash
git config --get-regexp '^gitflow\.'
```

Empty output means no init. Then:

```bash
git flow init            # interactive: prompts for branch names and prefixes
git flow init -d         # non-interactive: accept all defaults
git flow init -d -f      # re-initialize, overwriting existing gitflow config
```

`git flow init` also works in an empty directory — it runs `git init` for you.

`init` flags: `-d` defaults · `-f` force · `-p` feature prefix · `-b` bugfix prefix ·
`-r` release prefix · `-x` hotfix prefix · `-s` support prefix · `-t` version tag
prefix · `--local` / `--global` / `--system` / `--file <path>` config location ·
`--showcommands` echo the underlying git commands.

Prefer `-d` in scripted or non-interactive contexts — plain `init` blocks on prompts.

## The model

| Branch | Starts from | Merges into | Default prefix | Lifetime |
|---|---|---|---|---|
| `master` (or `main`) | — | — | — | permanent, production |
| `develop` | — | — | — | permanent, integration |
| feature | `develop` | `develop` | `feature/` | until the feature ships |
| bugfix | `develop` | `develop` | `bugfix/` | until the fix lands |
| release | `develop` | `master` **and** `develop` | `release/` | until the version ships |
| hotfix | `master` | `master` **and** `develop` | `hotfix/` | until the patch ships |
| support | `master` | — | `support/` | long-lived maintenance line |

Version tags get the `gitflow.prefix.versiontag` prefix (empty by default, commonly `v`).

Choosing the branch type:

- Work planned for the next release → **feature**
- Bug in `develop` that is not yet in production → **bugfix**
- Stabilizing a version for shipping (bump version, changelog, last fixes) → **release**
- Bug already in production, must ship now → **hotfix**
- Maintaining an old released version → **support** (beta, see Gotchas)

## Command reference

Flags below are from AVH 1.12.3. `feature` and `bugfix` take identical subcommands
and flags — the only difference is the prefix and that bugfix is meant for defect work.

### feature / bugfix

```
git flow feature [list] [-h] [-v]
git flow feature start [-h] [-F] <name> [<base>]
git flow feature finish [-h] [-F] [-r] [-p] [-k] [-D] [-S] [--no-ff] <name|nameprefix>
git flow feature publish [-h] [<name>]
git flow feature track [-h] <name>
git flow feature pull [-h] <remote> [<name>]
git flow feature diff [-h] [<name|nameprefix>]
git flow feature checkout [-h] [<name|nameprefix>]
git flow feature rebase [-h] [-i] [-p] [<name|nameprefix>]
git flow feature delete [-h] [-f] [-r] <name>
git flow feature rename <new_name>
```

- `list` — `-v` verbose (shows base commit and divergence)
- `start` — `-F` fetch from origin first; `<base>` overrides `develop` as start point
- `finish` — `-F` fetch first · `-r` rebase instead of merging · `-p` preserve merges
  while rebasing · `--push` push after finish · `-k` keep branch · `--keepremote` /
  `--keeplocal` keep only that side · `-D` force-delete the branch · `-S` squash the
  branch into one commit · `--squash-info` add branch info to the squash message ·
  `--no-ff` never fast-forward the merge
- `publish` — push the branch to origin and set upstream, for collaboration
- `track` — create a local branch tracking an already-published one
- `pull` — fetch a collaborator's work; `-r` pull with rebase
- `rebase` — `-i` interactive · `-p` preserve merges
- `delete` — `-f` force · `-r` also delete the remote branch (drops work without merging)

### release

```
git flow release [list] [-h] [-v]
git flow release start [options] <version> [<base>]
git flow release finish [-h] [-F] [-s] [-u] [-m | -f] [-p] [-k] [-n] [-b] [-S] <version>
git flow release branch [-h] [-F] [-s] [-u] [-m] [-f] [-p] [-n] [-S] <version> [<name>]
git flow release publish [-h] <name>
git flow release track [-h] <name>
git flow release rebase [-h] [-i] [-p] [<name|nameprefix>]
git flow release delete [-h] [-f] [-r] <name>
```

- `start` — `-F` fetch first; `<base>` must be a commit on `develop`
- `finish` — merges into `master`, tags it, back-merges into `develop`, deletes the branch:
  - `-F` fetch first
  - `-s` sign the tag · `-u <key>` sign with a specific GPG key (implies `-s`)
  - `-m <msg>` tag message · `-f <file>` read the tag message from a file
  - `-T <name>` use a custom tag name
  - `-n` do not tag at all
  - `-b` no back-merge into `develop`
  - `--nodevelopmerge` do not merge the release branch into `develop`
  - `--ff-master` fast-forward `master` when possible
  - `-p` push everything afterwards · `--pushproduction` / `--pushdevelop` / `--pushtag`
    push only that piece
  - `-k` keep branch · `--keepremote` / `--keeplocal` · `-D` force delete
  - `-S` squash · `--squash-info` add branch info to the squash message
- `branch` — create a release branch from an arbitrary base without the full start flow
- `publish` / `track` — share a release branch so others can add release commits
- `delete` — `-f` force · `-r` also remote

`git flow release finish` tags automatically unless `-n` is given. If a tag message is
required and neither `-m` nor `-f` is supplied, git opens an editor — pass `-m` in
non-interactive contexts.

### hotfix

```
git flow hotfix [list] [-h] [-v]
git flow hotfix start [-h] [-F] <version> [<base>]
git flow hotfix finish [-h] [-F] [-s] [-u] [-m | -f] [-p] [-k] [-n] [-b] [-S] <version>
git flow hotfix publish [-h] <version>
git flow hotfix track [-h] <version>
git flow hotfix rebase [-h] [-i] [-p] [<name|nameprefix>]
git flow hotfix delete [-h] [-f] [-r] <name>
git flow hotfix rename <new_name>
```

Same flag set as `release finish`, including `-T`, `-n`, `-b`, `--keepremote`,
`--keeplocal`, `-D`, `--squash-info`. `start` branches from `master`; `<base>` must be
a commit on `master`.

### support

```
git flow support [list] [-h] [-v]
git flow support start [-h] [-F] <version> <base>
git flow support rebase [-h] [-i] [-p] [<name|nameprefix>]
```

`<base>` is required — usually the tag of the released version being maintained.
Support branches have no `finish`: they live on.

### config and log

```
git flow config [list]
git flow config set <option> <value>
git flow config base [<options>] <branch> [<base>]
git flow log
```

`config set`/`list` accept `--local`, `--global`, `--system`, `--file <path>`.
`config base` reads a branch's recorded base; `--set` writes it.
`git flow log` shows the current branch's commits relative to its base branch and
accepts `git log` arguments.

Underlying git config keys:

| Key | Meaning |
|---|---|
| `gitflow.branch.master` | production branch name |
| `gitflow.branch.develop` | integration branch name |
| `gitflow.prefix.feature` | feature prefix (`feature/`) |
| `gitflow.prefix.bugfix` | bugfix prefix (`bugfix/`) |
| `gitflow.prefix.release` | release prefix (`release/`) |
| `gitflow.prefix.hotfix` | hotfix prefix (`hotfix/`) |
| `gitflow.prefix.support` | support prefix (`support/`) |
| `gitflow.prefix.versiontag` | version tag prefix |
| `gitflow.origin` | remote name (default `origin`) |
| `gitflow.path.hooks` | hooks directory (default `.git/hooks`) |
| `gitflow.branch.<name>.base` | recorded base of a specific branch |

## Recipes

**Feature, solo**

```bash
git flow feature start payment-retry
# ...commits...
git flow feature finish payment-retry     # merges into develop, deletes branch
git push origin develop
```

**Feature, shared with others**

```bash
git flow feature start payment-retry
git flow feature publish payment-retry    # pushes and sets upstream
# collaborator:
git flow feature track payment-retry
# back on your side, pick up their commits:
git flow feature pull origin payment-retry
git flow feature finish payment-retry
```

**Release**

```bash
git flow release start 1.4.0
# bump version files, update changelog, last fixes — commit them
git flow release finish -m "Release 1.4.0" 1.4.0
git push origin develop master --tags
```

Use `git flow release finish -p ...` to have git-flow push `master`, `develop` and the
tag for you.

**Hotfix**

```bash
git flow hotfix start 1.4.1               # from master
# fix + version bump, commit
git flow hotfix finish -m "Hotfix 1.4.1" 1.4.1
git push origin develop master --tags
```

If a release branch is open, git-flow back-merges the hotfix into that release branch
instead of `develop`.

**Maintaining an old version**

```bash
git flow support start 1.2 v1.2.3
```

## Gotchas

- **`finish` is destructive by design.** It merges *and* deletes the branch, local and
  remote. Use `-k` (or `--keeplocal` / `--keepremote`) if the branch must survive.
- **`finish` does not push.** Nothing reaches the remote until `git push`, or unless
  `-p` / `--push` is passed. `git push --tags` (or `--follow-tags`) is what shares tags.
- **`release`/`hotfix finish` tag automatically.** Pass `-n` to skip tagging, `-T` to
  choose the tag name, `-m` to avoid an editor prompt.
- **`main` vs `master`.** `git flow init` guesses among the existing branches
  (`production`, `main`, `master`); on a repo that uses `main` accept the guess or set
  it explicitly. `git config --get gitflow.branch.master` shows what is configured.
- **Merge conflicts stop `finish` mid-way.** Resolve, `git add`, then re-run the same
  `git flow ... finish` command — it resumes.
- **A feature branch that lags behind `develop`** should be updated with
  `git flow feature rebase` (or a plain merge) before finishing.
- **`support` is beta.** The upstream docs say so; treat it as such.
- **Hooks and filters** live in `.git/hooks` (or `gitflow.path.hooks`), named
  `pre-flow-*`, `post-flow-*` and `filter-flow-*` — e.g. `post-flow-feature-finish`,
  `filter-flow-release-finish-tag-message`. Useful for enforcing naming or generating
  tag messages.
- **PR-based workflows.** If the team reviews via pull requests, `git flow feature
  publish` then open the PR, and let the platform merge it — running `finish` locally
  merges behind the reviewers' backs.

## Status of the model

Vincent Driessen added a note to the original 2010 post in 2020: git-flow suits
software with explicit versions and multiple supported versions in the wild. For
continuously delivered web apps a simpler model such as GitHub Flow usually fits
better. Use git-flow because the project versions and ships releases, not by default.

The AVH edition (`petervanderdoes/gitflow-avh`) is the de-facto implementation and is
what `apt`, Homebrew and Git for Windows install; its repository was archived in June
2023, so it is stable but no longer developed. The original `nvie/gitflow` is
unmaintained and lacks `bugfix`, `delete`, `rename`, hooks and several flags documented
above.

## Sources

- <https://nvie.com/posts/a-successful-git-branching-model/> — the original model
- <https://danielkummer.github.io/git-flow-cheatsheet/> — command cheatsheet
- <https://github.com/petervanderdoes/gitflow-avh> — AVH edition and its wiki
