# Git Workflow

Two git hooks, wired via `git config core.hooksPath .husky` — no Node, no
npm package actually installed; just plain shell scripts and a one-time git
config change pointing at a folder of them.

- **`prepare-commit-msg`**: fires on every `git commit`. Prompts for a
  conventional-commit `type` (feat, fix, docs, style, refactor, perf, test,
  build, ci, chore, revert), an optional scope, and a short description, then
  writes the resulting `type(scope): description` into the commit message
  file before Git proceeds. This is triggered by plain `git commit` (or a
  `git commit` alias) — there is no wrapper script developers need to
  remember to run.
- **`pre-push`**: stashes any uncommitted work (staged, unstaged, and
  untracked), runs the test suite against exactly what's committed, then
  restores the stash regardless of whether the tests passed — so the push is
  blocked on a failure without ever losing in-progress, uncommitted work.

A third, smaller hook backs up the first:

- **`commit-msg`**: validates that the final commit message matches the
  conventional-commit format, whether it came from the prompt above or was
  supplied directly (`git commit -m "..."`, an IDE commit panel, `--amend`).

Ready-to-copy templates live in `templates/`:

```
templates/
  husky/
    pre-push
    prepare-commit-msg
    commit-msg
  scripts/
    commit.sh
    pre-push-tests.sh
```

## Why a git hook instead of a wrapper script

An earlier iteration of this setup exposed the interactive commit prompt as
a `some-tool commit` script. That works, but only if the developer remembers
to type it instead of `git commit`/`git cm`/their editor's commit button —
and IDEs, GUI git clients, and muscle memory all reach for plain `git
commit`. Wiring the prompt into `prepare-commit-msg` means it fires however
the commit is triggered from a real terminal, with zero extra steps to
remember. `git commit -m "..."` and IDE-driven commits still work exactly as
before — see "When the prompt does *not* appear" below.

## Why stash before testing

If the test suite (or a build step it depends on) reads from the working
tree rather than strictly from `git show HEAD`, uncommitted changes can
silently affect what gets tested — a fix might pass locally only because of
an uncommitted tweak that never makes it into the pushed commits. Stashing
before running tests guarantees the working tree matches `HEAD` exactly
while tests run, so a green pre-push check means "what's about to be pushed
passes," not "my working tree currently passes." The stash is always
restored afterward — on success, on failure, and if the script is
interrupted — via a shell `trap`.

## Setup

```bash
mkdir -p .husky scripts
cp templates/scripts/commit.sh scripts/commit.sh
cp templates/scripts/pre-push-tests.sh scripts/pre-push-tests.sh
chmod +x scripts/commit.sh scripts/pre-push-tests.sh

cp templates/husky/pre-push .husky/pre-push
cp templates/husky/prepare-commit-msg .husky/prepare-commit-msg
cp templates/husky/commit-msg .husky/commit-msg
chmod +x .husky/pre-push .husky/prepare-commit-msg .husky/commit-msg

git config core.hooksPath .husky
```

`pre-push-tests.sh` defaults `TEST_CMD` to `flutter test` — update that
variable at the top of the script for a package that isn't Flutter (e.g.
`dart test` for `core`/`backend`), or point it at a small script that runs
the right command in each of `core/`, `backend/`, and `frontend/` in turn.

Recommended: alias `git commit` so it doesn't stop to open an editor after
the hook has already written the message (Git only skips the editor when
told to):

```bash
git config alias.cm "commit --no-edit"
```

With this in place, `git commit` or `git cm` in a real terminal shows the
type/scope/description prompt and finishes the commit immediately — no
editor, no extra step.

## When the prompt does *not* appear

The hook intentionally stays out of the way in a few cases — it inspects the
commit source Git passes as its second argument, and the TTY on its stdin:

- `git commit -m "..."` / `-F file` (source = `message`) — a message was
  already given explicitly; the hook leaves it untouched.
- Merges, squashes, `--amend`/`-C` reusing an existing message (source =
  `merge` / `squash` / `commit`) — there's already a message to reuse or
  merge-specific content to preserve.
- No real terminal on stdin (source editors, IDE commit panels, CI) — the
  hook silently exits and Git falls back to its normal behavior (opening the
  configured editor, or using whatever message was supplied).

In every skipped case, the `commit-msg` hook still validates whatever
message ends up being used — bypassing the prompt does not bypass the
format check.

## Commit types

| type       | when                                                          |
|------------|----------------------------------------------------------------|
| `feat`     | a new feature                                                   |
| `fix`      | a bug fix                                                       |
| `docs`     | documentation only                                              |
| `style`    | formatting, whitespace — no code meaning change                 |
| `refactor` | code change that neither fixes a bug nor adds a feature         |
| `perf`     | performance improvement                                         |
| `test`     | adding or correcting tests                                      |
| `build`    | build system or external dependency changes                     |
| `ci`       | CI configuration changes                                        |
| `chore`    | anything else that doesn't touch `lib`/`bin` or tests           |
| `revert`   | reverts a previous commit                                       |

`templates/husky/commit-msg` enforces this same list with a POSIX regex
(`^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([^)]+\))?: .+`)
against the first line of the commit message — no Node-based linter
(commitlint or otherwise) needed for a check this small.

## What the pre-push hook does, step by step

1. Check for uncommitted changes (staged, unstaged, or untracked).
2. If any exist, `git stash push --include-untracked` them.
3. Run the project's test command against the now-clean working tree
   (matching `HEAD`, i.e. exactly what's about to be pushed).
4. Restore the stash unconditionally (`trap ... EXIT`), whether tests passed,
   failed, or the script was interrupted.
5. Exit non-zero on test failure, which aborts the push; exit zero on
   success, which lets the push proceed.

See `templates/scripts/pre-push-tests.sh` for the implementation.
