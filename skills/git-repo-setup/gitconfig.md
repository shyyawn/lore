# Machine gitconfig

Repo files never replace this. Only touch **global** config when the user
asked to set up Git **on this machine**. For a project, prefer
`git config --local` if a setting must live with the worktree (rare).

Check `git config --global --list` and `git --version` first. Do not overwrite
`user.name` / `user.email` that are already set.

Needs Git **2.45+** (`init.defaultRefFormat`). Prefer **2.50+**.

## Identity (required)

```bash
git config --global user.name "Their Name"
git config --global user.email "them@example.com"
```

Use the address the forge verifies. GitHub noreply is fine:
`123456+user@users.noreply.github.com`.

## New-repo defaults

```bash
git config --global init.defaultBranch main
git config --global init.defaultRefFormat reftable
```

Do **not** set `init.defaultObjectFormat sha256`. GitHub, GitLab, and Gitea
still serve sha1 remotes; a sha256 local repo will not push.

`reftable` is local ref storage (Git 2.45+; Git 3.0 default). Push is
unaffected. If an old GUI or libgit2 cannot open the repo, re-init that
clone with `--ref-format=files`. Do not migrate existing remotes.

## SSH commit signing (2026 default)

SSH keys you already use for `git@` remotes. Not GPG unless the repo
already requires it.

```bash
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

Allowed signers (local verify):

```bash
# ~/.ssh/allowed_signers  — email, then the public key line
them@example.com namespaces="git" ssh-ed25519 AAAA...
```

```bash
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
```

Upload the **same** public key as an SSH signing key on GitHub/GitLab
(Settings → SSH and GPG keys → Signing). Authentication keys and signing
keys can be the same Ed25519 key.

If they have no Ed25519 key yet:

```bash
ssh-keygen -t ed25519 -C "them@example.com" -f ~/.ssh/id_ed25519
```

Do not generate a new key when `~/.ssh/id_ed25519.pub` already exists.

## Everyday behavior

```bash
git config --global pull.rebase true
git config --global rebase.autoStash true
git config --global fetch.prune true
git config --global push.autoSetupRemote true
git config --global rerere.enabled true
git config --global merge.conflictstyle zdiff3
git config --global diff.algorithm histogram
git config --global init.defaultBranch main
```

- `pull.rebase true` — no merge bubbles from `git pull`. `pull.ff only` is
  the stricter alternative; pick one, not `pull.rebase false` (merge pulls).
- `push.autoSetupRemote` — first push on a new branch sets upstream (Git 2.37+).
- `zdiff3` / `histogram` — better conflicts and diffs than the 2010s defaults.

Optional UX:

```bash
git config --global column.ui auto
git config --global branch.sort -committerdate
git config --global tag.sort version:refname
git config --global help.autocorrect prompt
```

Do not enable `help.autocorrect` as a positive integer (auto-runs the guess).

Line endings: **do not** set `core.autocrlf=true`. Repos carry `.gitattributes`.
On Windows, `core.autocrlf=input` is acceptable if some repos lack attributes;
the committed `.gitattributes` still wins.

## Maintenance

```bash
git maintenance start
```

Registers a per-user schedule (launchd/systemd/cron) for incremental
repack. Run once per machine, not per repo. Skip if the user does not want
background Git jobs.

Geometric strategy (Git 2.47+), if they asked for large-repo tuning:

```bash
git config --global maintenance.strategy incremental
```

Honor whatever `git config --get maintenance.strategy` already is.

## Per-forge identity (`includeIf`)

When work and personal emails differ, do not swap `user.email` by hand:

```gitconfig
# ~/.config/git/config  (or ~/.gitconfig)

[includeIf "gitdir:~/work/"]
    path = ~/.config/git/work

[includeIf "gitdir:~/src/personal/"]
    path = ~/.config/git/personal
```

Each included file sets `user.email` (and signing key if they differ).
Paths must match how the clones are laid out, including the trailing slash
on `gitdir:`.

## What never goes global from this skill

- `core.hooksPath` — Lefthook owns hooks per repo
- `commit.template` — Conventional Commits skill writes the message
- `init.defaultObjectFormat`
- `safe.directory *` — too blunt; add a specific directory only if Git
  complains about ownership
- Aliases that hide `switch` / `restore` / `restore --staged`

## `~/.config/git/config` sketch

When writing a file (user asked for machine setup), keep it this small:

```gitconfig
[user]
    name = Their Name
    email = them@example.com
    signingkey = ~/.ssh/id_ed25519.pub

[init]
    defaultBranch = main
    defaultRefFormat = reftable

[gpg]
    format = ssh

[gpg "ssh"]
    allowedSignersFile = ~/.ssh/allowed_signers

[commit]
    gpgsign = true

[tag]
    gpgsign = true

[pull]
    rebase = true

[rebase]
    autoStash = true

[fetch]
    prune = true

[push]
    autoSetupRemote = true

[rerere]
    enabled = true

[merge]
    conflictstyle = zdiff3

[diff]
    algorithm = histogram
```

XDG path `~/.config/git/config` is the 2026 location. If `~/.gitconfig`
already exists and is the file they edit, update that instead. Do not
create both.
