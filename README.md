# gswitch

Bookmark branches you're actively working on and switch between them instantly with fuzzy search.

```
$ gs
  feat/PARA-123/new-dashboard
  feat/PARA-456/api-refactor
> fix/PARA-789/login-bug
  Switch to branch · ctrl-x: untrack
```

## Why

Git repos accumulate branches. `git branch` lists everything. `gswitch` only shows the ones you're currently working on — per repo, instantly searchable.

## Requirements

- `git`
- [`fzf`](https://github.com/junegunn/fzf)
- zsh

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/alberthassey/gswitch/main/install.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/alberthassey/gswitch.git
cd gswitch
./install.sh
exec zsh
```

## Commands

| Command | Description |
|---|---|
| `gs` | Open fuzzy picker to switch to a tracked branch |
| `gs <query>` | Open picker pre-filtered with query; auto-selects if only one match |
| `gsadd` | Start tracking the current branch |
| `gsadd <branch>` | Start tracking a specific branch |
| `gsrm` | Stop tracking the current branch |
| `gsrm <branch>` | Stop tracking a specific branch |

Inside the `gs` picker:

| Key | Action |
|---|---|
| `Enter` | Switch to selected branch |
| `ctrl-x` | Untrack selected branch (list stays open) |
| `ctrl-c` / `Esc` | Cancel |

## WIP flow

When switching away from a branch with uncommitted changes, `gs` prompts you to create a WIP commit:

```
Working tree is dirty. Run gwip before switching? [Y/n]
```

Answering `Y` stages all changes and commits them as `--wip-- [skip ci]`. When you switch back to that branch, `gs` automatically detects the WIP commit and resets it, restoring your working tree exactly as you left it.

This integrates with the `gwip` / `gunwip` aliases from [oh-my-zsh's git plugin](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git).

## Tab completion (zsh)

`gs <tab>` completes from your tracked branches for the current repo. Substring matching is enabled, so `gs para<tab>` matches `feat/PARA-123/anything`.

## Data storage

Tracked branches are stored in:

```
~/.local/share/gswitch/<repo-hash>/branches
```

Each repo gets its own file. The hash is derived from the repo's root path, so branches are scoped per project.
